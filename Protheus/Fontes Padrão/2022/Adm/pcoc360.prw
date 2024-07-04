#INCLUDE "pcoc360.ch"
#include "protheus.ch"
#include "msgraphi.ch"
//amarracao subida pcoc361

/*/
_F_U_N_C_ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFUNCAO    ณ PCOC360  ณ AUTOR ณ Edson Maricate        ณ DATA ณ 22/11/05   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDESCRICAO ณ Programa de Consulta a visao por cubos em periodos           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ USO      ณ SIGAPCO                                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ_DOCUMEN_ ณ PCOC360                                                      ณฑฑ
ฑฑณ_DESCRI_  ณ Programa de Consulta ao arquivo de saldos mensair dos Cubos  ณฑฑ
ฑฑณ_FUNC_    ณ Esta funcao podera ser utilizada com a sua chamada normal    ณฑฑ
ฑฑณ          ณ partir do Menu ou a partir de uma funcao pulando assim o     ณฑฑ
ฑฑณ          ณ browse principal e executando a chamada direta da rotina     ณฑฑ
ฑฑณ          ณ selecionada.                                                 ณฑฑ
ฑฑณ          ณ Exemplo: PCOC360(2) - Executa a chamada da funcao de visua-  ณฑฑ
ฑฑณ          ณ                       zacao da rotina.                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ_PARAMETR_ณ ExpN1 : Chamada direta sem passar pela mBrowse               ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOC360(nCallOpcx)

Local bBlock
Local nPos
SaveInter()
Private cCadastro	:= STR0001 //"Consulta Saldos por Periodos - Visoes"
Private aRotina := MenuDef()
						
If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Adiciona botoes do usuario no Browse                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ExistBlock( "PCOC3601" )
		//P_Eฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//P_Eณ Ponto de entrada utilizado para inclusao de funcoes de usuarios no     ณ
		//P_Eณ browse da tela de Centros Orcamentarios                                            ณ
		//P_Eณ Parametros : Nenhum                                                    ณ
		//P_Eณ Retorno    : Array contendo as rotinas a serem adicionados na enchoice ณ
		//P_Eณ               Ex. :  User Function PCOC3601                            ณ
		//P_Eณ                      Return {{"Titulo", {|| U_Teste() } }}             ณ
		//P_Eภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If ValType( aUsRotina := ExecBlock( "PCOC3601", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf

	If nCallOpcx <> Nil
		nPos := Ascan(aRotina,{|x| x[4]== nCallOpcx})
		If ( nPos # 0 )
			bBlock := &( "{ |x,y,z,k,w,a,b,c,d,e,f,g| " + aRotina[ nPos,2 ] + "(x,y,z,k,w,a,b,c,d,e,f,g) }" )
			Eval( bBlock,Alias(),AKN->(Recno()),nPos)
		EndIf
	Else 
		PCOC361(nCallOpcx) //removida a valida็ใo SuperGetMV("MV_PCOCNIV",.F., .F.) executando sempre pela rotina PCOC361 (ganho de performance)      
	EndIf
EndIf
RestInter()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPco360ViewบAutor  ณPaulo Carnelossi    บ Data ณ  24/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณrotina que monta a grade e o grafico baseado nos parametros บฑฑ
ฑฑบ          ณinformados                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Pco360View(cAlias,nRecno,nOpcx)
Local nX, nZ, nY, lRet := .F.
Local aTotProc  := {}
Local aProcessa := {}
Local nTpGraph  := 0
Local nCfgCubo  := 1
Local aNiveis	 := {}
Local aCuboCfg := {}

Local aCfgAuxCube := {}
Local aAuxCube := {}
Local aSeriesCfg := {}
Local dINi := dDataBase
Local  dFim := dDataBase+20
Local lProcNlv
Local nTpPer	:= 3
Local nDetalhe
Local cPicture := PadR("@E 999,999,999,999.99",25)
Local aListArq := {}
Local aVarPriv := {}
Local nDirAcesso := 0
Local bCond := {|| If(nDetalhe!=1, (aProcAux[nZ,4]== "AKO"), .T. ) }
Local aTpGrafico:= {STR0004,; //"1=Linha"
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

Private aConfig := {}
Private aCfgCub := {}

Private aPrcSldIni := {}
Private nProcCubo := 0

Private aPeriodo
Private aColAux
Private COD_CUBO
                
If SuperGetMV("MV_PCO_AKN",.F.,"2")!="1"  //1-Verifica acesso por entidade
	lRet := .T.                        // 2-Nao verifica o acesso por entidade
Else
	nDirAcesso := PcoDirEnt_User("AKN", AKN->AKN_CODIGO, __cUserID, .F.)
    If nDirAcesso == 0 //0=bloqueado
		Aviso(STR0047,STR0075,{STR0076},2) //"Aten็ใo"###" Usuario sem acesso a esta configura็ใo de visao gerencial. "###"Fechar"
		lRet := .F.
		Return Nil
	Else
	    lRet := .T.
	EndIf
EndIf

dbSelectArea("AKL")
dbSetOrder(1)
lRet := dbSeek(xFilial("AKL")+AKN->AKN_CONFIG)
If lRet
	COD_CUBO := AKL->AKL_CUBE
EndIf

dbSelectArea("AKN")

If lRet
	lRet	:= ParamBox({ 	{ 1 ,STR0019,dIni,"" 	 ,""  ,""    ,"" ,50 ,.F. },; //"Periodo de"
					{ 1 ,STR0020,dFim,"" 	 ,""  ,""    ,"" ,50 ,.F. },; //"Periodo Ate"
					{ 2 ,STR0021,nTpPer,{STR0022,STR0023,STR0024,STR0025,STR0026,STR0027,STR0070},80,"",.F.},; //"Tipo Periodo"###"1=Semanal"###"2=Quinzenal"###"3=Mensal"###"4=Bimestral"###"5=Semestral"###"6=Anual"###"7=Diario"
					{ 2 ,STR0028,1,{STR0029,STR0030,STR0031,STR0032,STR0033},80,"",.F.},; //"Moeda"###"1=Moeda 1"###"2=Moeda 2"###"3=Moeda 3"###"4=Moeda 4"###"5=Moeda 5"
					{ 2 ,STR0034,4,aTpGrafico,80,"",.F.},; //"Tipo do Grafico"
					{ 1 ,STR0035,nCfgCubo,"" 	 ,""  ,""    ,"" ,50 ,.F. } ,;
					{2,STR0059,2,{"1="+STR0039,"2="+STR0040},80,"",.F.},;//"Detalhar Cubos"##"Sim"##"Nao"
					{3,STR0060,2,{STR0061,STR0062,STR0063},40,,.F.},; //"Mostrar valores"##"Unidade","Milhar","Milhao"
					{1,IIf(cPaisLoc$"RUS",STR0077,"Picture"),cPicture,"@!" 	 ,""  ,"" ,"" ,75 ,.F. },;
					{5,STR0074,.F.,145,,.F.} ;//"Mostrar resultados sint้ticos a partir do segundo nivel "
						},STR0036,aConfig,{||PCOC360TOk()},,,,,, "PCOC360_01",,.T.) //"Qtd. Series"###"Parametros"

	If lRet
		nDetalhe  := If(ValType(aConfig[7])=="N", aConfig[7], Val(aConfig[7]))
		nCasas	 := aConfig[8]
		cPicture := Alltrim(aConfig[9])
		lProcNlv		:= !aConfig[Len(aConfig)]
		For nX := 1 TO aConfig[6]
			&("MV_PAR"+AllTrim(STRZERO(nX+(1*(nX-1)),2,0))) := Space(LEN(AL4->AL4_CODIGO))
			&("MV_PAR"+AllTrim(STRZERO(nX+(1*(nX-1)+1),2,0))) := 1
			aAdd(aCuboCfg, { 1  ,STR0037+Str(nX, 2,0),Space(LEN(AL3->AL3_CODIGO))		  ,"@!" 	 ,''  ,"AL3" ,"" ,25 ,.F. }) //"Config.Cubo Serie"
			aAdd(aCuboCfg, { 3 ,STR0038,1,{STR0039,STR0040},40,,.F.}) //"Exibe Configura็๕es"###"Sim"###"Nao"
			aAdd(aCuboCfg, { 1  ,STR0041,STR0042+Str(nx,2,0),"@!" 	 ,""  ,"" ,"" ,75 ,.F. })//"Descri็ใo S้rie"###"Serie "
			aAdd(aCuboCfg, { 3 ,STR0043,1,{STR0044,STR0045},95,,.F.}) //"Considerar "###"Saldo final do periodo"###"Movimento do periodo"
		Next
	EndIf
EndIf

If lRet .And. ParamBox(aCuboCfg, STR0046, aCfgCub,/*bOk*/,/*aButtons*/,/*lCentered*/,/*nPosx*/,/*nPosy*/, /*oDlgWizard*/, "PCOC360_02"/*cArqParam*/,,.T.) //"Configuracao de Cubos"
	nTpPer		:= If(ValType(aConfig[3])=="N", aConfig[3], Val(aConfig[3]))
	aConfig[4]	:= If(ValType(aConfig[4])=="N", aConfig[4], Val(aConfig[4]))
	aPeriodo	:= PcoRetPer(aConfig[1]/*dIniPer*/, aConfig[2]/*dFimPer*/, Str(nTpPer,1)/*cTipoPer*/, .F./*lAcumul*/)
    // Salta o primeiro nivel da visใo
   For nX := 1 TO aConfig[6]
		aAdd(aPrcSldIni, aCfgCub[nX*4])
		aAdd(aSeriesCfg, Str(nX,1,0)+"="+aCfgCub[nX*4-1])
   Next
	//processa primeira configuracao do cubo sempre
	nProcCubo := 1
	aAuxCube := {}

	aVarPriv := {}
	aAdd(aVarPriv, {"aPeriodo", aClone(aPeriodo)})                
	aAdd(aVarPriv, {"aPrcSldIni", aClone(aPrcSldIni)})                
	aAdd(aVarPriv, {"nProcCubo", nProcCubo})                
	aAdd(aVarPriv, {"aConfig", aClone(aConfig)})                

	aProcessa := PcoCubeVis(AKN->AKN_CODIGO,Len(aPeriodo)*aConfig[6],"Pcoc361Sld",aCfgCub[1],aCfgCub[2],nDetalhe,.T.,aClone(aVarPriv),lProcNlv)

	aAdd(aCfgAuxCube, aClone(aAuxCube))
   	
  	If Len(aProcessa) > 0
   	//processa a partir da segunda configuracao
   	For nX := 2 TO aConfig[6]
	
			nProcCubo++
			aAuxCube := {}
			aVarPriv := {}
			aAdd(aVarPriv, {"aPeriodo", aClone(aPeriodo)})                
			aAdd(aVarPriv, {"aPrcSldIni", aClone(aPrcSldIni)})                
			aAdd(aVarPriv, {"nProcCubo", nProcCubo})                
			aAdd(aVarPriv, {"aConfig", aClone(aConfig)})                

			aProcAux := PcoCubeVis(AKN->AKN_CODIGO,Len(aPeriodo),"Pcoc360Sld",aCfgCub[(4*(nx-1))+1],aCfgCub[(4*(nx-1))+2],nDetalhe,.T.,aClone(aVarPriv),lProcNlv)
			aAdd(aCfgAuxCube, aClone(aAuxCube))
			
			If Len(aProcAux) > 0
				For nZ:=1 TO Len(aProcAux)
					If Eval(bCond)
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
					Endif
				Next
			EndIf
		Next  	
    EndIf
	If !Empty(aProcessa)
		nTpGraph  := If(ValType(aConfig[5])=="N", aConfig[5], Val(aConfig[5]))
		//montagem da planilha e grafico
		PCOC360PFI(aProcessa,0,,nTpGraph,{},0,,aCfgCub,,aCfgAuxCube,1/*nSerie*/,aSeriesCfg,nCasas,,cPicture,aListArq)
	Else
		Aviso(STR0047,STR0048,{STR0049},2) //"Aten็ใo"###"Nใo existem valores a serem visualizados na configura็ใo selecionada. Verifique as configura็๕es da consulta."###"Fechar"
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOC360PFI  บAutor  ณPaulo Carnelossi  บ Data ณ  24/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณrotina que exibe a grade e o grafico                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PCOC360PFI(aProcessa,nNivel,cChave,nTpGrafico,aNiveis,nCall,cDescrChv,aCfgCub,cChaveOri,aCfgAuxCube,nSerie,aSeriesCfg,nCasas, lShowGraph, cPicture, aListArq)
Local oDlg
Local oFolder 
Local oView
Local aArea		:= GetArea()
Local cAlias
Local nRecView
Local nStep
Local dx
Local cTexto
Local aSize     := {}
Local aPosObj   := {}
Local aObjects  := {}
Local aInfo     := {}
Local aView		:= {}
Local aValGraph := {}
Local aChave 	:= {}
Local nx,ny, nZ
Local cDescri	:= ""
Local aButtons  := {}
Local oGrafico
Local oPanel
Local oPanel1
Local oPanel2
Local bEncerra := {|| If(nNivel>0,oDlg:End(),If(Aviso(STR0050,STR0051, {STR0039, STR0040},2)==1, ( PcoArqSave(aListArq), oDlg:End() ), NIL))} //"Atencao"###"Deseja abandonar a consulta ?"###"Sim"###"Nao"
Local aTabMail	:=	{}
Local aParam	:=	{"",.F.,.F.,.F.}
Local aChaveOri:= {}
Local nNivCub	:= 0
Local cFiltro
Local lPergNome  := ( SuperGetMV("MV_PCOGRAF",.F.,"2") == "1" )
Local lRetPe := .F.
Local lPCO360GRF := ExistBlock("PCO360GRF")

DEFAULT cChave 		:= ""
DEFAULT cChaveOri 	:= ""
DEFAULT nSerie 		:= 1
DEFAULT lShowGraph 	:= .T.
DEFAULT cPicture 	:= ""
DEFAULT aListArq := {}

If nNivel == 0
	nCasas	:=	Iif(nCasas==1,0,IIf(nCasas==2,-3,-6))
	cCadastro	+=	IIf(nCasas==0,"" ,IIf(nCasas==-3,STR0064,STR0065))//" - (Valores em milhares)"##" - (Valores em milhoes)"
Endif

nDivisor	:=	10**(Abs(nCasas))

If Empty(cPicture)
	cPicture	:=	If(nCasas==-6,"@E 999,999,999,999.99","@E 999,999,999,999")
EndIf

If nCall + 1 <= Len(aNiveis)
	aButtons := {	{"PMSZOOMIN"	, {|| Eval(oView:blDblClick) },STR0052 ,STR0053},; //"Drilldown do Cubo"###"Drilldown"
						{"BMPPOST"  , {|| PmsGrafMail(oGrafico,Padr(cDescri,150),{cCadastro },aTabMail, NIL, 2, .T.) },STR0054,STR0055 },; //"Enviar Email"###"Email"
						{"GRAF2D"   , {|| HideShowGraph(oPanel2, oPanel1, @lShowGraph) },STR0068,STR0069 },; //"Exibir/Esconder Grafico"###"Grafico"
						{"SALVAR"	, {|| PcoSaveGraf(oGrafico, lPergNome, .T., .F., aListArq) },STR0072,STR0073 },; //"Imprimir/Gerar Grafico em formato BMP"##"Salva/BMP"
						{"PESQUISA" , {|| PcoConsPsq(aView,.F.,@aParam,oView) },STR0002,STR0002 },; //Pesquisar
						{"E5"       , {|| PcoConsPsq(aView,.T.,@aParam,oView) },STR0071 ,STR0071 }; //"Proximo"
					}
Else
	aButtons := {	{"PMSZOOMIN"	, {|| Eval(oView:blDblClick) },STR0052 ,STR0053},; //"Drilldown do Cubo"###"Drilldown"
						{"BMPPOST"  , {|| PmsGrafMail(oGrafico,Padr(cDescri,150),{cCadastro },aTabMail, NIL, 2, .T.) },STR0054,STR0055 },; //"Enviar Emial"###"Email"
						{"GRAF2D"   , {|| HideShowGraph(oPanel2, oPanel1, @lShowGraph) },STR0068,STR0069 },; //"Exibir/Esconder Grafico"###"Grafico"
						{"SALVAR"	, {|| PcoSaveGraf(oGrafico, lPergNome, .T., .F., aListArq) },STR0072,STR0073 },; //"Imprimir/Gerar Grafico em formato BMP"##"Salva/BMP"
						{"PESQUISA" , {|| PcoConsPsq(aView,.F.,@aParam,@oView) },STR0002,STR0002 },; //Pesquisar
						{"E5"       , {|| PcoConsPsq(aView,.T.,@aParam,@oView) },STR0071 ,STR0071 }; //"Proximo"
					}
Endif
aColAux := {}
aAdd(aColAux, cDescri)
aAdd(aColAux, STR0058)//"Descricao"
For nX := 1 TO Len(aPeriodo)
	aAdd(aColAux, aPeriodo[nx]+"["+AllTrim(aCfgCub[3])+"]")
	For nZ := 2 TO aConfig[6]
		aAdd(aColAux, aPeriodo[nx]+"["+AllTrim(aCfgCub[(4*(nz-1))+3])+"]")
	Next
Next
aAdd(aTabMail, aClone(aColAux) )

aView := C360View(aProcessa, nNivel, cChave, aChave, @cDescri,@aTabMail, aChaveOri, @cFiltro,aCfgAuxCube, nSerie,nCasas,cPicture, aValGraph)

If !Empty(aView)                                                
	aSize := MsAdvSize(,.F.,400)
	aObjects := {}
	
	AAdd( aObjects, { 100, 100 , .T., .T. } )
	
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 2, 2 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )
	
	DEFINE FONT oBold NAME "Arial" SIZE 0, -11 BOLD
	DEFINE FONT oFont NAME "Arial" SIZE 0, -10 
	DEFINE MSDIALOG oDlg TITLE cCadastro + " - "+cDescri From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	oDlg:lMaximized := .T.
	
	oPanel := TPanel():New(0,0,'',oDlg, , .T., .T.,, ,10,20+((nNivel)*9),.T.,.T. )
	oPanel:Align := CONTROL_ALIGN_TOP

	oPanel1 := TPanel():New(0,0,'',oDlg, , .T., .T.,, ,40,40,.T.,.T. )
	oPanel1:Align := CONTROL_ALIGN_ALLCLIENT

	oPanel2 := TPanel():New(0,0,'',oDlg, , .T., .T.,, ,40,120,.T.,.T. )
	oPanel2:Align := CONTROL_ALIGN_BOTTOM

	If !lShowGraph
		oPanel2:Hide()
	EndIf

	@ 2,4 SAY AKN->AKN_DESCRI  of oPanel SIZE 120,9 PIXEL FONT oBold COLOR RGB(80,80,80)
	@ 3,3 BITMAP oBar RESNAME "MYBAR" Of oPanel SIZE BrwSize(@oDlg,0)/2,8 NOBORDER When .F. PIXEL ADJUST

	@ 12,2 SAY STR0066+DTOC(aConfig[1])+STR0067+DTOC(aConfig[2])+ IIf(nCasas==0,"" ,IIf(nCasas==-3,STR0064,STR0065)) Of oPanel PIXEL SIZE 640 ,79 FONT oBold //"Saldo de : "##" a "
	@ 19,4 SAY cDescrChv Of oPanel PIXEL SIZE 640 ,79 FONT oBold

	oView	:= TWBrowse():New( 2,2,aPosObj[1,4]-6,aPosObj[1,3]-aPosObj[1,1]-16,,aColAux,,oPanel1,,,,,,,oFont,,,,,.F.,,.T.,,.F.,,,)
	oView:Align := CONTROL_ALIGN_ALLCLIENT
	oView:SetArray(aView)
	
	If ExistBlock("PCO360GRF")
   		lRetPe :=	ExecBlock("PCO360GRF",.F.,.F.,{aProcessa,oView:nAT})
	EndIf			

	oView:bChange 	:= {|| If(lRetPe, oGrafico:= C360Grafico(aPosObj, oPanel2, oFont, nTpGrafico, aProcessa, cChave, nNivel, aValGraph[oView:nAT],aConfig,aPeriodo), Nil) }

	oView:bLine 	:= { || aView[oView:nAT]}

	oView:blDblClick := { || PCOC360PFI(aProcessa,nCall+1,aChave[oView:nAT,1],nTpGrafico,aNiveis,nCall+1,IF(!Empty(cDescrChv),cDescrChv+CHR(13)+CHR(10),"")+Str(nNivel,2,0)+". "+Alltrim(cDescri)+" : "+AllTrim(aView[oView:nAT,1])+" - "+AllTrim(aView[oView:nAT,2]),aCfgCub,aChaveOri[oView:nAT,1],aCfgAuxCube, nSerie,aSeriesCfg,nCasas,lShowGraph,cPicture,aListArq) }

	oGrafico:=C360Grafico(aPosObj, oPanel2, oFont, nTpGrafico, aProcessa, cChave, nNivel, aValGraph[oView:nAT],aConfig,aPeriodo)
	
	aButtons := aClone(AddToExcel(aButtons,{ {"ARRAY",STR0066+DTOC(aConfig[1])+STR0067+DTOC(aConfig[2])+ IIf(nCasas==0,"" ,IIf(nCasas==-3,STR0064,STR0065)),aColAux,aView} } ))
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| Eval(bEncerra)},{|| Eval(bEncerra)},,aButtons )
EndIf
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC360Grafico บAutor  ณPaulo Carnelossi  บ Data ณ  24/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณrotina que monta o objeto grafico para exibicao no folder   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function C360Grafico(aPosObj, oPanel, oFont, nTpGrafico, aProcessa, cChave, nNivel, aValGraph, aConfig)
Local nZ  
Local ny
Local oGraphic
Local nPeriodo	:= 1
Local aSeries	:= {}
Local aColors := {CLR_BLUE,CLR_GREEN,CLR_RED,CLR_CYAN,CLR_MAGENTA,CLR_BROWN,CLR_HGRAY,CLR_YELLOW,CLR_HBLUE}

	@ 2,2 MSGRAPHIC oGraphic SIZE aPosObj[1,4]-10,aPosObj[1,3]-aPosObj[1,1]-30 OF oPanel
	oGraphic:Align := CONTROL_ALIGN_ALLCLIENT
	oGraphic:oFont := oFont
	
	oGraphic:SetMargins( 15, 10, 10,10 )
	oGraphic:SetGradient( GDBOTTOMTOP, CLR_HGRAY, CLR_WHITE )
	oGraphic:SetTitle( "", "" , CLR_BLACK , A_LEFTJUST , GRP_TITLE )
	oGraphic:SetLegenProp( GRP_SCRRIGHT, CLR_WHITE, GRP_SERIES, .F. )
	For nZ := 1 TO aConfig[6]
		aAdd(aSeries,Nil	)
		aSeries[nz] := oGraphic:CreateSerie( nTpGrafico )	
	Next nz
	oGraphic:l3D := .F.
	
	For nZ := 3 To Len(aValGraph) Step aConfig[6]
		For ny := 1 TO aConfig[6]
			oGraphic:Add(aSeries[ny], aValGraph[nZ+ny-1], aPeriodo[nPeriodo], aColors[ny])	
		Next
		nPeriodo++
	Next	

Return(oGraphic)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC360View  บAutor  ณPaulo Carnelossi    บ Data ณ  24/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณrotina que retorna o array aview que e exibido na grade e   บฑฑ
ฑฑบ          ณserve de base para montagem do grafico                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function C360View(aProcessa, nNivel, cChave, aChave, cDescri,aTabMail, aChaveOri, cFiltro, aCfgAuxCube, nSerie,nCasas, cPicture, aValGraph)
Local nx, nz
Local aView := {} 
Local aAuxView 
Local aAuxGraph
Local nDivisor	:=	10**(Abs(nCasas))
Local nPosSinal := 0

For nx := 1 to Len(aProcessa)
	If (nNivel == 0 .And. aProcessa[nX][4] == "AKO" ) .Or. (nNivel == aProcessa[nX][8] .And. aProcessa[nX][4] <> "AKO" .And. Padr(aProcessa[nx][1],Len(cChave))==cChave)
		cDescri := AllTrim(aProcessa[nx][5])
		aAuxView := {}
		aAuxGraph := {}
		aAdd(aAuxView	, Substr(aProcessa[nx][1],Len(cChave)+1))
		aAdd(aAuxGraph	, Substr(aProcessa[nx][1],Len(cChave)+1))
		aAdd(aAuxView	, aProcessa[nx][6])
		aAdd(aAuxGraph	, aProcessa[nx][6])
		
		nPosSinal := 18
		If aProcessa[nX, 4]<>"AKO" .And. Len(aProcessa[nX])>18
			nPosSinal := 19
		EndIf
		
		For nZ := 1 TO Len(aProcessa[nx][2])
			aAdd(aAuxView, TransForm(aProcessa[nx][2][nZ]/nDivisor * If(aProcessa[nx, nPosSinal] == "1",1,-1),cPicture))
			aAdd(aAuxGraph	, aProcessa[nx][2][nZ]/nDivisor * If(aProcessa[nx, nPosSinal] == "1",1,-1) )
		Next
		aAdd(aView, aAuxView)     
		aAdd(aValGraph	, aAuxGraph)     // carregar array igual aview mas com os valores p/grafico
		aAdd(aTabMail,{})                             
		For nZ:=1 To Len(aAuxView)        
			If ValType(aAuxView[nZ]) == "N"
				AAdd(aTabMail[Len(aTabMail)],Alltrim(Transform(aAuxView[nZ], cPicture)))
			Else
				AAdd(aTabMail[Len(aTabMail)],aAuxView[nZ] )
			Endif
		Next
		aAdd(aChave,{aProcessa[nx][1]})
		aAdd(aChaveOri,{aProcessa[nx,9]})
	Endif
Next


Return(aView)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoC360SldบAutor  ณPaulo Carnelossi    บ Data ณ  24/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณrotina que executa o calculo do saldo utilizada pela funcao บฑฑ
ฑฑบ          ณPcoRunCube() (observacao-se mudar algo mudar tb pcoc361sld) บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoC360Sld(cConfig,cChave)
Local aRetorno := {}
Local aRetFim
Local nCrdFim
Local nDebFim
Local ny

For ny := 1 to Len(aPeriodo)
   
	nSldIni := 0
	
	If aPrcSldIni[nProcCubo] == 2
	   // PROCESSA CUBO SALDO INICIAL 
		dIni := CtoD(Subs(aPeriodo[ny], 1, 10))-1

		aRetIni := PcoRetSld(cConfig,cChave,dIni)
		nCrdIni := aRetIni[1, aConfig[4]]
		nDebIni := aRetIni[2, aConfig[4]]

		nSldIni := nCrdIni-nDebIni
   EndIf
   
   // PROCESSA CUBO SALDO FINAL
	dFim := CtoD(Subs(aPeriodo[ny],14))

	aRetFim := PcoRetSld(cConfig,cChave,dFim)
	nCrdFim := aRetFim[1, aConfig[4]]
	nDebFim := aRetFim[2, aConfig[4]]

	nSldFim := nCrdFim-nDebFim

	//retorna saldo final - saldo inicial
	aAdd(aRetorno,nSldFim-nSldIni)
	
Next

Return aRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoC361SldบAutor  ณPaulo Carnelossi    บ Data ณ  24/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณrotina que executa o calculo do saldo utilizada pela funcao บฑฑ
ฑฑบ          ณPcoRunCube()  -- utilizada no primeiro processamento        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoC361Sld(cConfig,cChave)
Local aRetorno := {}
Local aRetFim
Local nCrdFim
Local nDebFim
Local ny, nZ

For ny := 1 to Len(aPeriodo)

	nSldIni := 0
	
	If aPrcSldIni[nProcCubo] == 2
	   // PROCESSA CUBO SALDO INICIAL 
		dIni := CtoD(Subs(aPeriodo[ny], 1, 10))-1

		aRetIni := PcoRetSld(cConfig,cChave,dIni)
		nCrdIni := aRetIni[1, aConfig[4]]
		nDebIni := aRetIni[2, aConfig[4]]

		nSldIni := nCrdIni-nDebIni
   EndIf
   
   // PROCESSA CUBO SALDO FINAL

	dFim := CtoD(Subs(aPeriodo[ny],14))

	aRetFim := PcoRetSld(cConfig,cChave,dFim)
	nCrdFim := aRetFim[1, aConfig[4]]
	nDebFim := aRetFim[2, aConfig[4]]

	nSldFim := nCrdFim-nDebFim
	
	aAdd(aRetorno,nSldFim-nSldIni)
	
	For nZ := 2 TO aConfig[6]
		aAdd(aRetorno,0)   //aqui coloca os valores zerados para as proximas cfg cubos
	Next                  //para o periodo que esta sendo implementado
	
Next

Return aRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ PCOC360TOk บAutor  ณ Gustavo Henrique   บ Data ณ  18/04/08 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Validacoes gerais na confirmacao dos parametros informados บฑฑ
ฑฑบ          ณ na Parambox inicial.                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Consulta de Saldos por Periodo                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PCOC360TOk()
Local lRet := .T.
lRet := PCOCVldPer( mv_par01, mv_par02 )
Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MenuDef  บAutor  ณ Pedro Pereira Lima บ Data ณ  09/29/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
Local aRotina 	:= {	{ STR0002,		"AxPesqui" , 0 , 1},; //"Pesquisar"
							{ Iif(STR0003 == STR0002, STR0003+"." ,STR0003), 	"Pco360View" , 0 , 2} }  //"Consultar"

Return aRotina