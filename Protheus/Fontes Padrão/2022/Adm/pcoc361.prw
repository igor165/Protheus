#INCLUDE "pcoc361.ch"
#include "protheus.ch"
#include "msgraphi.ch"

Static __aChvOri
Static __cArqTemp		:= Nil
Static __cArqSald		:= Nil
Static __aFilesErased 	:= {}
Static __lBlind	 		:= IsBlind() 

Static __nDetalhe
Static __cCOGer             := ""

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFUNCAO    ณ PCOC361  ณ AUTOR ณ Edson Maricate        ณ DATA ณ 22/11/05   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDESCRICAO ณ Programa de Consulta a visao por cubos em periodos           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ USO      ณ SIGAPCO                                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ_DOCUMEN_ ณ PCOC361                                                      ณฑฑ
ฑฑณ_DESCRI_  ณ Programa de Consulta ao arquivo de saldos mensair dos Cubos  ณฑฑ
ฑฑณ_FUNC_    ณ Esta funcao podera ser utilizada com a sua chamada normal    ณฑฑ
ฑฑณ          ณ partir do Menu ou a partir de uma funcao pulando assim o     ณฑฑ
ฑฑณ          ณ browse principal e executando a chamada direta da rotina     ณฑฑ
ฑฑณ          ณ selecionada.                                                 ณฑฑ
ฑฑณ          ณ Exemplo: PCOC361(2) - Executa a chamada da funcao de visua-  ณฑฑ
ฑฑณ          ณ                       zacao da rotina.                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ_PARAMETR_ณ ExpN1 : Chamada direta sem passar pela mBrowse               ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOC361(nCallOpcx)

Local bBlock
Local nPos
SaveInter()

Private cCadastro	:= STR0001 //"Consulta Saldos por Periodos - Visoes"
Private aRotina 	:= {	{ STR0002,	"AxPesqui" 		, 0 , 1},; //"Pesquisar"
							{ Iif(STR0003 == STR0002, STR0003+"." ,STR0003), 	"Pco_360View" 	, 0 , 2} }  //"Consultar"
						
If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Adiciona botoes do usuario no Browse                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ExistBlock( "PCOC3611" )
		//P_Eฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//P_Eณ Ponto de entrada utilizado para inclusao de funcoes de usuarios no     ณ
		//P_Eณ browse da tela de Centros Orcamentarios                                            ณ
		//P_Eณ Parametros : Nenhum                                                    ณ
		//P_Eณ Retorno    : Array contendo as rotinas a serem adicionados na enchoice ณ
		//P_Eณ               Ex. :  User Function PCOC3611                            ณ
		//P_Eณ                      Return {{"Titulo", {|| U_Teste() } }}             ณ
		//P_Eภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If ValType( aUsRotina := ExecBlock( "PCOC3611", .F., .F. ) ) == "A"
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
		mBrowse(6,1,22,75,"AKN")
	EndIf
EndIf

RestInter()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPco_360ViewบAutor  ณPaulo Carnelossi    บ Data ณ  24/05/05   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณrotina que monta a grade e o grafico baseado nos parametros  บฑฑ
ฑฑบ          ณinformados                                                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Pco_360View(cAlias,nRecno,nOpcx)
Local nX, nZ, nY, lRet := .F.
Local aTotProc
Local aProcessa
Local nTpGraph
Local nCfgCubo  := 1
Local aCuboCfg := {}

Local dIni := dDataBase
Local  dFim := dDataBase+20
Local nTpPer	:= 3
Local nDetalhe
Local cPicture := PadR("@E 999,999,999,999.99",25)
Local aListArq := {}
Local aVarPriv := {}
Local nDirAcesso 	:= 0
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

Local aPcoCfg := {}
Local cCodCube, nQtdVal, cConfig, nViewCFG, lZerado, lForceNoSint

Private aConfig 	:= {}
Private aCfgCub 	:= {}

Private aPeriodo
Private aColAux
Private COD_CUBO
Private aDataSld 	:= {}
Private aDataIni 	:= {}
Private nQtdSerie 	:= 1
Private nSerie 		:= 1
Private nMoeda 	
Private aNiveis	 	:= {}
Private lMovimento 	:= .F.
Private nMaxNivel := 0

If SuperGetMV("MV_PCO_AKN",.F.,"2")!="1"  //1-Verifica acesso por entidade
	lRet := .T.                        // 2-Nao verifica o acesso por entidade
Else
	nDirAcesso := PcoDirEnt_User("AKN", AKN->AKN_CODIGO, __cUserID, .F.)
    If nDirAcesso == 0 //0=bloqueado
		Aviso(STR0047,STR0074,{STR0075},2) //"Aten็ใo"###"Usuario sem acesso a esta configura็ใo de visao gerencial. "###"Fechar"
		lRet := .F.
	
	Else
	    lRet := .T.
	EndIf
EndIf
If lRet
	dbSelectArea("AKL")
	dbSetOrder(1)
	lRet := dbSeek(xFilial("AKL")+AKN->AKN_CONFIG)
	If lRet
		COD_CUBO := AKL->AKL_CUBE
	EndIf
		
	dbSelectArea("AKN")
	If lRet
		lRet := ParamBox({ 		{ 1 ,STR0019,dIni,"" 	 ,""  ,""    ,"" ,50 ,.F. },; //"Periodo de"
						{ 1 ,STR0020,dFim,"" 	 ,""  ,""    ,"" ,50 ,.F. },; //"Periodo Ate"
						{ 2 ,STR0021,nTpPer,{STR0022,STR0023,STR0024,STR0025,STR0026,STR0027,STR0070},80,"",.F.},; //"Tipo Periodo"###"1=Semanal"###"2=Quinzenal"###"3=Mensal"###"4=Bimestral"###"5=Semestral"###"6=Anual"###"7=Diario"
						{ 2 ,STR0028,1,{STR0029,STR0030,STR0031,STR0032,STR0033},80,"",.F.},; //"Moeda"###"1=Moeda 1"###"2=Moeda 2"###"3=Moeda 3"###"4=Moeda 4"###"5=Moeda 5"
						{ 2 ,STR0034,4,aTpGrafico,80,"",.F.},; //"Tipo do Grafico"
						{ 1 ,STR0035,nCfgCubo,"" 	 ,""  ,""    ,"" ,50 ,.F. } ,;
						{2,STR0059,2,{"1="+STR0039,"2="+STR0040},80,"",.F.},;//"Detalhar Cubos"##"Sim"##"Nao" 
						{3,STR0060,2,{STR0061,STR0062,STR0063},40,,.F.,.T.},; //"Mostrar valores"##"Unidade","Milhar","Milhao"
						{ 1,"Picture",cPicture,"@!" 	 ,""  ,"" ,"" ,75 ,.F. };
				},STR0036,aConfig,{||PCOC361TOk()},,,,,, "PCOC361_01",,.T.) //"Qtd. Series"###"Parametros"
		
			//***********************
			// Confirmou a Parambox *
			//***********************
			If lRet
			nDetalhe  := If(ValType(aConfig[7])=="N", aConfig[7], Val(aConfig[7]))
			__nDetalhe := nDetalhe
			
			//nao retirar (serve para gravar corretamente os MV_PAR?? da Parambox - referente campos combo modificados)
			aConfig[3] := If(ValType(aConfig[3])=="N", aConfig[3], Val(aConfig[3])) 
			aConfig[4] := If(ValType(aConfig[4])=="N", aConfig[4], Val(aConfig[4])) 
			aConfig[5] := If(ValType(aConfig[5])=="N", aConfig[5], Val(aConfig[5])) 
			aConfig[7] := nDetalhe
			aEval(aConfig, {|x, y| &("MV_PAR"+StrZero(y,2)) := x})
			ParamSave(__cUserID+"_PCOC361_01",aConfig,"1")
			
			
			nCasas	 := aConfig[8]
			cPicture := Alltrim(aConfig[9])
			nMoeda := If(ValType(aConfig[4])=="N", aConfig[4], Val(aConfig[4]))
			nQtdSerie := aConfig[6]
			nTpPer := If(ValType(aConfig[3])=="N", aConfig[3], Val(aConfig[3]))
			aPeriodo := PcoRetPer(aConfig[1]/*dIniPer*/, aConfig[2]/*dFimPer*/, Str(nTpPer,1)/*cTipoPer*/, .F./*lAcumul*/)
			
			If Len(aPeriodo) > 180 //limitar em 180 no maximo
						Aviso("Atencao", "Consulta limitada a 180 periodos no maximo. Verifique a periodicidade.", {"Ok"})  
				lRet := .F.
			EndIf
			
			If lRet
				For nX := 1 TO Len(aPeriodo)
					aAdd(aDataIni, CtoD(Subs(aPeriodo[nX], 1, 10))) 
					aAdd(aDataSld, CtoD(Subs(aPeriodo[nX], 14))) 
				Next
			
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

	EndIf

	If lRet .And. ParamBox(aCuboCfg, STR0046, aCfgCub,/*bOk*/,/*aButtons*/,/*lCentered*/,/*nPosx*/,/*nPosy*/, /*oDlgWizard*/, "PCOC361_02"/*cArqParam*/,,.T.) //"Configuracao de Cubos"

		CursorWait()

		//processa primeira configuracao do cubo sempre
		nSerie 		:= 1
		lMovimento  := ( aCfgCub[4]==2 )
		dbSelectArea("AKL")
		dbSetOrder(1)
		If MsSeek(xFilial()+AKN->AKN_CONFIG)
			cCodCube := AKL->AKL_CUBE
		Else
			HELP("   ",1,"PCOC361INV",,STR0077,1,0)   //"Nao informado o cubo gerencial na visao. Verifique!"
			Return	    
		EndIf
		nQtdVal := Len(aPeriodo)*aConfig[6]
		cCfgCub := aCfgCub[1]
		nParCfg := aCfgCub[2]
		lZerado := .F.
		lForceNoSint := .T.                            
		
		aAdd( aPcoCfg, {cCodCube, nQtdVal, cCfgCub, nParCfg, lZerado, lForceNoSint,{} } )
		aProcessa 	:= PcoCub_Vis(AKN->AKN_CODIGO,Len(aPeriodo)*aConfig[6],"Pco_360Sld",aCfgCub[1],aCfgCub[2],nDetalhe,.T., aNiveis, aPcoCfg[1,7])

			If Len(aProcessa) > 0

				//processa a partir da segunda configuracao
				For nX := 2 TO aConfig[6]
						
				nSerie 		:= nX
				lMovimento  := ( aCfgCub[nX*4]==2 )
				
				nQtdVal := Len(aPeriodo)
				cCfgCub := aCfgCub[nX*4-3]
				nParCfg := aCfgCub[nX*4-2]
				lZerado := .F.
				lForceNoSint := .T.

				aAdd( aPcoCfg, {cCodCube, nQtdVal, cCfgCub, nParCfg, lZerado, lForceNoSint,{} } )
				aProcAux 	:= PcoCub_Vis(AKN->AKN_CODIGO,Len(aPeriodo),"Pco_360Sld",aCfgCub[nX*4-3],aCfgCub[nX*4-2],nDetalhe,.T., aNiveis, aPcoCfg[nX,7])

				If Len(aProcAux) > 0
					For nZ:=1 TO Len(aProcAux)
						If aProcAux[nZ,4]== "AKO"
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
		
		CursorArrow()
		
		If !Empty(aProcessa)
			nTpGraph  := If(ValType(aConfig[5])=="N", aConfig[5], Val(aConfig[5]))
			//montagem da planilha e grafico
			PCOC_360PFI(aProcessa, 0/*nNivel*/, ""/*cChave*/, nTpGraph, "COG"/*cDescri*/,""/*cDescrChv*/, nCasas, cPicture, .T./*lShowGraph*/, aListArq, aPcoCfg)		
		Else
			Aviso(STR0047,STR0048,{STR0049},2) //"Aten็ใo"###"Nใo existem valores a serem visualizados na configura็ใo selecionada. Verifique as configura็๕es da consulta."###"Fechar"
		EndIf

		If ! Empty(__aFilesErased)
			//apaga os arquivos temporarios criado no banco de dados
			For nZ := 1 TO Len(__aFilesErased)
				If Select(Alltrim(__aFilesErased[nZ])) > 0
					dbSelectArea(Alltrim(__aFilesErased[nZ]))
					dbCloseArea()
				EndIf
				MsErase(Alltrim(__aFilesErased[nZ]))
			Next

			__cArqTemp := Nil
			__cArqSald := Nil
		EndIf

	EndIf
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOC_360PFI บAutor  ณPaulo Carnelossi  บ Data ณ  24/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณrotina que exibe a grade e o grafico                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PCOC_360PFI(aProcessa, nNivel, cChave, nTpGrafico, cDescri, cDescrChv, nCasas, cPicture, lShowGraph, aListArq, aPcoCfg)

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
Local aCpyaProcessa, aCpyTabMail, aCpyValGraph

DEFAULT cChave 		:= ""
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

If nNivel <= Len(aNiveis)
					//NAO TIRAR COMENTARIO PARA IMPLEMENTACAO FUTURA
	aButtons := {	{"PMSZOOMIN"	, {|| Eval(oView:blDblClick) },STR0052 ,STR0053},; //"Drilldown do Cubo"###"Drilldown"
						{"BMPPOST"  , {|| PmsGrafMail(oGrafico,Padr(cDescri,150),{cCadastro },aTabMail, NIL, 2, .T.) },STR0054,STR0055 },; //"Enviar Email"###"Email"
						{"GRAF2D"   , {|| HideShowGraph(oPanel2, oPanel1, @lShowGraph) },STR0068,STR0069 },; //"Exibir/Esconder Grafico"###"Grafico"
						{"SALVAR"	, {|| PcoSaveGraf(oGrafico, lPergNome, .T., .F., aListArq, NIL, 2, .T. ) },STR0072,STR0073 },; //"Imprimir/Gerar Grafico em formato BMP"##"Salva/BMP"
						{"PESQUISA" , {|| PcoConsPsq(aView,.F.,@aParam,oView) },STR0002,STR0002 },; //Pesquisar
						{"E5"       , {|| PcoConsPsq(aView,.T.,@aParam,oView) },STR0071 ,STR0071 }; //"Proximo"
					}
Else
					//NAO TIRAR COMENTARIO PARA IMPLEMENTACAO FUTURA
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

If nNivel < 1
	aView := C_360View(aProcessa, nNivel, cChave, aChave, @cDescri,@aTabMail, aChaveOri, @cFiltro,nCasas,cPicture, aValGraph)
	aColAux[1] := cDescri
Else
	If __nDetalhe != 1
		HELP("   ",1,"PCOC361DET",,STR0078,1,0)   //"Operacao somente permitida quando opcao detalhar cubos igual a sim."
		Return
	EndIf	
	If nNivel > nMaxNivel
		HELP("   ",1,"PCOC361MAX",,STR0079,1,0) //"Operacao somente permitida para niveis dos cubos gerenciais."
		Return
	EndIf	
	//aqui fazer tratamento para drilldown a partir do 2o. nivel
	aCpyaProcessa := aClone(aProcessa)
	aCpyTabMail := aClone(aTabMail)
	aCpyValGraph := aClone(aValGraph)
	
	If nNivel > 1  //primeiro nivel a chave eh a conta gerencial
		__aChvOri[nNivel-1] := cChave
	Else
		If AKN->AKN_CODIGO  == cChave .OR. PcoC361Sint(cChave)
			HELP("   ",1,"PCOC361SINT",,STR0080,1,0)   //"Esta operacao somente e permitida para contas gerenciais analiticas."
			Return
		EndIf
	EndIf
	
	aProcessa := {}
	aTabMail  := {}
	aAdd(aTabMail, aClone(aColAux) )

	CursorArrow()

	C360Niv2Down(aProcessa, nNivel, cChave, aPcoCfg)

	CursorArrow()

	aView := C_360View(aProcessa, nNivel, cChave, aChave, @cDescri, @aTabMail, aChaveOri, @cFiltro,nCasas,cPicture, aValGraph)
	
	aColAux[1] := cDescri
	
EndIf	

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
	oView:bChange 	:= { || oGrafico:=C_360Grafico(aPosObj, oPanel2, oFont, nTpGrafico, aProcessa, cChave, nNivel, aValGraph[oView:nAT],aConfig,aPeriodo) }
	oView:bLine 	:= { || aView[oView:nAT]}

	oView:blDblClick := { || PCOC_360PFI(aProcessa, nNivel+1, aView[oView:nAT,1], nTpGrafico, cDescri, IF(!Empty(cDescrChv),cDescrChv+CHR(13)+CHR(10),"")+Str(nNivel,2,0)+". "+Alltrim(cDescri)+" : "+AllTrim(aView[oView:nAT,1])+" - "+AllTrim(aView[oView:nAT,2]),nCasas, cPicture, lShowGraph, aListArq, aPcoCfg) }

	oGrafico := C_360Grafico(aPosObj, oPanel2, oFont, nTpGrafico, aProcessa, cChave, nNivel, aValGraph[oView:nAT],aConfig,aPeriodo)
	
	aButtons := aClone(AddToExcel(aButtons,{ {"ARRAY",STR0066+DTOC(aConfig[1])+STR0067+DTOC(aConfig[2])+ IIf(nCasas==0,"" ,IIf(nCasas==-3,STR0064,STR0065)),aColAux,aView} } ))
	
	dbSelectArea("AKN")
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| Eval(bEncerra)},{|| Eval(bEncerra)},,aButtons )
EndIf
RestArea(aArea)

If nNivel > 1
	aProcessa := aClone(aCpyaProcessa)
	aTabMail := aClone(aCpyTabMail)
	aValGraph := aClone(aCpyValGraph)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC_360GraficoบAutor  ณPaulo Carnelossi  บ Data ณ  24/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณrotina que monta o objeto grafico para exibicao no folder   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function C_360Grafico(aPosObj, oPanel, oFont, nTpGrafico, aProcessa, cChave, nNivel, aValGraph, aConfig)
Local nZ  
Local ny
Local oGraphic
Local nPeriodo	:= 1
Local aSeries	:= {}
Local aColors := {CLR_BLUE,CLR_GREEN,CLR_RED,CLR_CYAN,CLR_MAGENTA,CLR_BROWN,CLR_HGRAY,CLR_YELLOW,CLR_HBLUE}

	@ 2,2 MSGRAPHIC oGraphic SIZE aPosObj[1,4]-10,aPosObj[1,3]-aPosObj[1,1]-30 OF oPanel
	oGraphic:Align := CONTROL_ALIGN_ALLCLIENT
	oGraphic:oFont := oFont
	
	oGraphic:SetMargins( 0, 10, 10,10 )
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
ฑฑบPrograma  ณC_360View บAutor  ณPaulo Carnelossi    บ Data ณ  24/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณrotina que retorna o array aview que e exibido na grade e   บฑฑ
ฑฑบ          ณserve de base para montagem do grafico                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function C_360View(aProcessa, nNivel, cChave, aChave, cDescri,aTabMail, aChaveOri, cFiltro, nCasas, cPicture, aValGraph)
Local nx, nz
Local aView := {} 
Local aAuxView 
Local aAuxGraph
Local nDivisor	:=	10**(Abs(nCasas))

For nx := 1 to Len(aProcessa)
	If nNivel == aProcessa[nX][8] .And. Padr(aProcessa[nx][1],Len(cChave))==cChave
		cDescri := AllTrim(aProcessa[nx][5])
		aAuxView := {}
		aAuxGraph := {}
		aAdd(aAuxView	, Substr(aProcessa[nx][1],Len(cChave)+1))
		aAdd(aAuxGraph	, Substr(aProcessa[nx][1],Len(cChave)+1))
		aAdd(aAuxView	, aProcessa[nx][6])
		aAdd(aAuxGraph	, aProcessa[nx][6])
		For nZ := 1 TO Len(aProcessa[nx][2])
			aAdd(aAuxView, TransForm(aProcessa[nx][2][nZ]/nDivisor * If(aProcessa[nx, 18] == "1",1,-1),cPicture))
			aAdd(aAuxGraph	, aProcessa[nx][2][nZ]/nDivisor * If(aProcessa[nx, 18] == "1",1,-1) )
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
ฑฑบPrograma  ณPco_360SldบAutor  ณMicrosiga           บ Data ณ  29/08/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o array aProcessa quando chamada pela funcao        บฑฑ
ฑฑบ          ณPcoCub_Vis()                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function Pco_360Sld( cCodCube, nQtdVal, cConfig, nViewCFG, lZerado, aNiveis, aFilIni, aFilFim, aFiltros, lForceNoSint, nNivel)
Local aProcCub := {}
Local oStructCube
Local nX
Local cWhereTpSld
Local cArqTmp
Local cArqSld
Local nZ, lAuxSint
Local aQueryDim
Local nY
Local cArqAS400 := ""
Local cSrvType := Alltrim(Upper(TCSrvType()))
Local cArquivo
Local cProcScript := ""
Local nPTratRec := 0
Local cNomProc := ""
Local aResult := {}
Local aCposQry := {}
Local cFetch := ""
Local cCampos := ""
Local cValues := ""
Local lProc :=  lMovimento .And. (Alltrim(TcGetDB())$"ORACLE|MSSQL|MSSQL7|POSTGRES") .And. ( SuperGetMV("MV_PCOCPRC",.T.,"0") == "1" )   //.T. COM PROCEDURE .F. SEM PROCEDURE (PADRAO)

DEFAULT nNivel := 1

If __cArqTemp <> Nil
	cArquivo := __cArqTemp
Endif

If __cArqSald <> Nil
	cArqSld := __cArqSald
Endif

oStructCube := PcoStructCube( cCodCube, cConfig )
nMaxNivel := oStructCube:nMaxNiveis

If __aChvOri == Nil
	__aChvOri := Array(nMaxNivel)
EndIf
			
If Empty(oStructCube:aAlias)  //se estiver vazio eh pq a estrutura nao esta correta
	Return aProcCub
EndIf

For nX := 1 To Len(aFilIni)
	oStructCube:aIni[nX] := PadR(aFilIni[nX], Len(oStructCube:aIni[nX]))
Next

For nX := 1 To Len(aFilFim)
	oStructCube:aFim[nX] := PadR(aFilFim[nX], Len(oStructCube:aFim[nX]))
Next

For nX := 1 To Len(aFilFim)
	oStructCube:aFiltros[nX] := aFiltros[nX]
Next

cWhereTpSld := ""
If oStructCube:nNivTpSld > 0 .And. ;
	oStructCube:aIni[oStructCube:nNivTpSld] == oStructCube:aFim[oStructCube:nNivTpSld] .And. ;
	Empty(oStructCube:aFiltros[oStructCube:nNivTpSld])
		cWhereTpSld := " AKT.AKT_TPSALD = '" + oStructCube:aIni[oStructCube:nNivTpSld] + "' AND "
EndIf								

aAdd(aNiveis, nNivel)

If cSrvType == "ISERIES" //outros bancos de dados que nao DB2 com ambiente AS/400
	//cria arquivo para popular
	PcoCriaTemp(oStructCube, @cArqAS400, nQtdVal)
	aAdd(__aFilesErased, cArqAS400)
EndIf

If cArquivo == Nil .Or. Select( cArquivo ) <= 0
	//cria arquivo para popular
	PcoCriaTemp(oStructCube, @cArquivo, nQtdVal, lProc)
	aAdd(__aFilesErased, cArquivo)

	__cArqTemp := cArquivo
Endif

PcoLimpTemp(cArquivo)
If lProc
	//--------------------
	dbSelectArea(cArquivo)
	cNomProc := Subs(cArquivo,1,8)+"PR_"+cEmpAnt
	cProcScript := " CREATE PROCEDURE "+cNomProc
	cProcScript += "("+CRLF
	cProcScript += "   @OUT_RESULT   Char( 01 ) OutPut"+CRLF
	cProcScript += ")"+CRLF
	cProcScript += "as"+CRLF
	
	For nX := 1 TO FCOUNT()
		cCpoAux := &(FieldName(nX))
		cProcScript += "  DECLARE @"+FieldName(nX)+" "+If( Valtype(cCpoAux)=="C", ;
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
	//--------------------
	EndIf

aQryDim 	:= {}                          

For nZ := 1 TO oStructCube:nMaxNiveis

	aQueryDim := PcoCriaQueryDim(oStructCube, nZ, .F./*lSintetica*/, .T. /*lForceNoSint*/,lProc)
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
			aAdd(__aFilesErased, cArqTmp)
	
			If ! aQueryDim[4]
				aAdd( aQryDim, { aQueryDim[1], ""} )
			Else	
				aAdd( aQryDim, { aQueryDim[1], aQueryDim[5]} )
			EndIf
		EndIf
	EndIf	
Next

aQuery := PcoCriaQry( cCodCube, nNivel, nMoeda, cArqAS400, If(nSerie==1, nQtdVal/nQtdSerie, nQtdVal), aDataSld, aQryDim, ""/*cWhere*/, cWhereTpSld, oStructCube:nNivTpSld, lMovimento, aDataIni, .T./*lAllNiveis*/, /*aCposNiv*/, /*lDebito*/, /*lCredito*/, lProc, aCposQry )

For nY := 1 TO Len(aCposQry)
	cFetch 	+= " @"+Alltrim( aCposQry[nY] )+If(nY<Len(aCposQry),", ","")
	cCampos += Alltrim( aCposQry[nY] )+", "
	cValues += "@"+Alltrim( aCposQry[nY] )+", "
Next

If lProc
	//--------------------
	
	For nX := 1 TO Len(aQuery)
	
		cProcScript += aQuery[nX]
		cProcScript += " FOR READ ONLY "+CRLF
		cProcScript += " "+CRLF
		cProcScript += "OPEN POPTEMP"+StrZero(nX,2)+" "+CRLF
		cProcScript += "Fetch POPTEMP"+StrZero(nX,2)+" into " //@AKT_NIV01, @AKT_SLD001, @AKT_SLD002, @AKT_SLD003, @AKT_SLD004, @AKT_SLD005, @AKT_SLD006, @AKT_SLD007, @AKT_SLD008, @AKT_SLD009, @AKT_SLD010, @AKT_SLD011, @AKT_SLD012  "+CRLF
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
		cProcScript += "     select @iRecno = IsNull(Max( R_E_C_N_O_ ), 0 ) from "+cArquivo+CRLF
		cProcScript += "     select @iRecno = @iRecno + 1 "+CRLF
		cProcScript += "   "+CRLF
		cProcScript += "   		##TRATARECNO @iRecno\" + CRLF
		cProcScript += "     Insert into "+cArquivo+" ( " //AKT_NIV01, AKT_SLD001, AKT_SLD002, AKT_SLD003, AKT_SLD004, AKT_SLD005, AKT_SLD006, AKT_SLD007, AKT_SLD008, AKT_SLD009, AKT_SLD010, AKT_SLD011, AKT_SLD012, 
		cProcScript += 	cCampos+"R_E_C_N_O_ ) "+CRLF
		cProcScript += "                      values( " //@AKT_NIV01, @AKT_SLD001, @AKT_SLD002, @AKT_SLD003, @AKT_SLD004, @AKT_SLD005, @AKT_SLD006, @AKT_SLD007, @AKT_SLD008, @AKT_SLD009, @AKT_SLD010, @AKT_SLD011, @AKT_SLD012 , 
		cProcScript += cValues+"@iRecno ) "+CRLF
		cProcScript += " "+CRLF
		cProcScript += " "+CRLF
		cProcScript += " ##FIMTRATARECNO "+ CRLF
		cProcScript += "   "+CRLF
		cProcScript += "   Fetch POPTEMP"+StrZero(nX,2)+" into " //@AKT_NIV01, @AKT_SLD001, @AKT_SLD002, @AKT_SLD003, @AKT_SLD004, @AKT_SLD005, @AKT_SLD006, @AKT_SLD007, @AKT_SLD008, @AKT_SLD009, @AKT_SLD010, @AKT_SLD011, @AKT_SLD012 "+CRLF
		cProcScript += cFetch+" "+CRLF
		cProcScript += "   If @iNroRegs >= 4000 begin"+CRLF
		cProcScript += "      commit tran"+CRLF
		cProcScript += "      select @iNroRegs = 0"+CRLF
		cProcScript += "   End"+CRLF
		cProcScript += " "+CRLF
		cProcScript += " End"+CRLF
		cProcScript += " "+CRLF
		cProcScript += " Close POPTEMP"+StrZero(nX,2)+" "+CRLF
		cProcScript += " Deallocate POPTEMP"+StrZero(nX,2)+" "+CRLF
		cProcScript += " "+CRLF
		cProcScript += " If @iNroRegs > 0 begin"+CRLF
		cProcScript += "    commit tran"+CRLF
		cProcScript += "    select @iTranCount = 0"+CRLF
		cProcScript += " End"+CRLF
	
		If nX < Len(aQuery)
			cProcScript  += "   Declare POPTEMP"+StrZero(nx+1,2)+" insensitive cursor for"+CRLF
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
			If !__lBlind
				MsgAlert('Erro na criacao da procedure ' + cNomProc)
				lRet:= .F.
			EndIf
		Else

			MsgRun( STR0001 , cNomProc , {|| aResult := TCSPEXEC( xProcedures(Left(cNomProc,10))) } )
			
			If Empty(aResult) .or. aResult[1] = "0"
				lUsaProc := .F.
				MsgAlert( "Erro na inclusใo de dados via procedure " + cNomProc )
			Endif
	
			nRet := TcSqlExec(" DROP PROCEDURE " + cNomProc)
			If nRet != 0 
				If !__lBlind
					MsgAlert("Erro na exclusao da procedure " + cNomProc)
					lRet:= .F.
				EndIf	
			EndIf	
		EndIf
	EndIf
	//--------------------
Else	
	PcoPopulaTemp(oStructCube, cArquivo, aQuery, nQtdVal, lZerado, cArqAS400)
EndIf

If cArqSld == Nil
	//cria arquivo que contera o resultado da query agrupada 
	PcoCriaTemp(oStructCube, @cArqSld, nQtdVal)
	aAdd(__aFilesErased, cArqSld)

	__cArqSald := cArqSld
Endif

PcoLimpTemp(cArqSld)

//execucao da query para agrupar os diversos periodos e popular arq temporario que sera usado na consulta
PcoQryFinal( oStructCube, nNivel, cArqSld/*cAliasSld*/, nQtdVal, cArquivo)

dbSelectArea(cArqSld)
(cArqSld)->(dbGoTop())

While (cArqSld)->( ! Eof() )

	cChave := (cArqSld)->(FieldGet(FieldPos("AKT_NIV"+StrZero(nNivel,2))))
	nTamNiv := oStructCube:aTam[nNivel]
	nPai := 0
	cChavOri := ""
	//descricao tem q macro executar a expressao contida em oStrucCube:aDescRel
	dbSelectArea(oStructCube:aAlias[nNivel])
	If dbSeek(xFilial()+cChave)
		cDescrAux := &(oStructCube:aDescRel[nNivel])
		If ! Empty(oStructCube:aCondSint[nNivel])
			lAuxSint := &(oStructCube:aCondSint[nNivel])
		Else	
			lAuxSint := .F.	
		EndIf
	Else
		cDescrAux := STR0076 // "Outros"
		lAuxSint := .F.		
	EndIf	

	If nSerie == 1	

	  	aAdd(aProcCub, {	PadR(cChave, nTamNiv), ;
	  						ARRAY(nQtdVal), ;
		  					oStructCube:aConcat[nNivel], ;
		  					"AKO"/*oStructCube:aAlias[nNivel]*/, ;
	  						oStructCube:aDescri[nNivel], ;
	  						cDescrAux,;
		  					0,;
		  					nNivel,;
	  						cChavOri,;
	  						lAuxSint/*oStructCube:aCondSint[nNivel]*/,;
	  						nPai,;
		  					.T.,;
		  					oStructCube:aDescCfg[nNivel],;
							PadR(cChave, nTamNiv),;
							( nNivel  == oStructCube:nMaxNiveis ) })
	
							//armazena no 2o.elemento os valores apurados na query
							//primeiro preenche com zeros
							For nY := 1 TO nQtdVal
								aProcCub[Len(aProcCub),2,nY] := 0
							Next
							//em seguida atribui o valor
							For nY := 1 TO Len(aPeriodo)
								aProcCub[ Len(aProcCub), 2 , ((nY-1)*nQtdSerie) + 1 ] := (cArqSld)->(FieldGet(FieldPos("AKT_SLD"+StrZero(nY, 3))))						
							Next

	Else

	  	aAdd(aProcCub, {	PadR(cChave, nTamNiv), ;
	  						ARRAY(nQtdVal), ;
		  					oStructCube:aConcat[nNivel], ;
		  					"AKO"/*oStructCube:aAlias[nNivel]*/, ;
	  						oStructCube:aDescri[nNivel], ;
	  						cDescrAux,;
		  					0,;
		  					nNivel,;
	  						cChavOri,;
	  						lAuxSint/*oStructCube:aCondSint[nNivel]*/,;
	  						nPai,;
		  					.T.,;
		  					oStructCube:aDescCfg[nNivel],;
							PadR(cChave, nTamNiv),;
							( nNivel  == oStructCube:nMaxNiveis ) })
	
							//armazena no 2o.elemento os valores apurados na query
							//primeiro preenche com zeros
							For nY := 1 TO nQtdVal
								aProcCub[Len(aProcCub),2,nY] := 0
							Next
							//em seguida atribui o valor
							For nY := 1 TO nQtdVal
								aProcCub[ Len(aProcCub), 2 , nY ] := (cArqSld)->(FieldGet(FieldPos("AKT_SLD"+StrZero(nY, 3))))						
							Next

    EndIf

	dbSelectArea(cArqSld)
	(cArqSld)->(dbSkip())

EndDo	

dbSelectArea(cArquivo)
PcoLimpTemp(cArquivo)
TcRefresh(cArquivo)

dbSelectArea(cArqSld)
PcoLimpTemp(cArqSld)
TcRefresh(cArqSld)

Return aProcCub

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC360Niv2Down บAutor  ณMicrosiga        บ Data ณ  29/08/14   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o array aProcessa quando pressionado opcao drilldownบฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function C360Niv2Down(aProcessa, nNivel, cChave, aPcoCfg)	
Local nX, nZ, nY
Local aChavAnt := {}
Local cCodCube
Local aIni, aFim, aFlt
Local nPosCfg
Local nConf 

dbSelectArea("AL3")
dbSetOrder(1)   //FILIAL+CODIGO DA CONFIGURACAO
dbSeek(xFilial("AL3")+aCfgCub[1])
cCodCube := AL3->AL3_CONFIG
oStructCube := PcoStructCube( cCodCube, aCfgCub[1] )
			
If Empty(oStructCube:aAlias)  //se estiver vazio eh pq a estrutura nao esta correta
	Return
EndIf

If nNivel > 1
	For nX := nNivel TO 2 STEP -1
		aAdd(aChavAnt, "AKT.AKT_NIV"+StrZero(nX-1, 2) + " = '" + PadR(__aChvOri[nX-1], oStructCube:aTamNiv[nX-1]) +"' AND " )
	Next	
EndIf

If nNivel == 1 
	__cCOGer := cChave
EndIf

nSerie 		:= 1
lMovimento  := ( aCfgCub[4]==2 )

//1a. configuracao valor eh fixo
nConf := 1
nPosCfg := aScan(aPcoCfg[nConf, 7], {|aVal| aVal[1] == __cCOGer })

If nPosCfg > 0 

	For nX := 1 TO Len(aPcoCfg[nConf, 7, nPosCfg, 2])
	
		aIni := aClone( aPcoCfg[nConf,7,nPosCfg,2,nX,1] )
		aFim := aClone( aPcoCfg[nConf,7,nPosCfg,2,nX,2] )
		aFlt := aClone( aPcoCfg[nConf,7,nPosCfg,2,nX,3] )
		aProcAux	:=  C360aProcessa(cCodCube, nNivel, cChave, oStructCube, Len(aPeriodo)*nQtdSerie, nSerie, aChavAnt, lMovimento, aIni, aFim, aFlt)
		If nX == 1
			aProcessa := aClone(aProcAux)
		Else
			For nZ:=1 TO Len(aProcAux)
	
				nPos := ASCAN(aProcessa, {|aVal| aVal[1] == aProcAux[nZ,1]})
			
				If nPos > 0 //caso ja exista no cubo (aprocessa) incrementa no periodo de referencia
					For nY := 1 TO Len(aProcAux[nZ][2])
						aProcessa[nPos][2][nY] += aProcAux[nZ][2][nY]
					Next
				Else // caso nao exista no cubo (aprocessa) adiciona ao cubo
					aAdd(aProcessa, aClone(aProcAux[nZ]))
				EndIf
		   
		   Next
		EndIf

	Next
Else
	HELP("   ",1,"PCOC361DRIL",,STR0081,1,0)   //"Nao Encontrado Conta Gerencial para Drilldown."
EndIf

If Len(aProcessa) > 0

   	//processa a partir da segunda configuracao
   	For nConf := 2 TO aConfig[6]
        
		nSerie 		:= nConf
		lMovimento  := ( aCfgCub[nConf*4]==2 )

		nPosCfg := aScan(aPcoCfg[nConf, 7], {|aVal| aVal[1] == __cCOGer })

		If nPosCfg > 0 

	        dbSelectArea("AL3")
			dbSeek(xFilial("AL3")+aCfgCub[nConf*4-3])
			cCodCube := AL3->AL3_CONFIG
			oStructCube := PcoStructCube( AL3->AL3_CONFIG, aCfgCub[(nConf*4)-3] )
				
			If Empty(oStructCube:aAlias)  //se estiver vazio eh pq a estrutura nao esta correta
				Loop
			EndIf

			For nX := 1 TO Len(aPcoCfg[nConf, 7, nPosCfg, 2])
	
				aIni := aClone( aPcoCfg[nConf,7,nPosCfg,2,nX,1] )
				aFim := aClone( aPcoCfg[nConf,7,nPosCfg,2,nX,2] )
				aFlt := aClone( aPcoCfg[nConf,7,nPosCfg,2,nX,3] )
			
				aProcAux 	:=  C360aProcessa(cCodCube, nNivel, cChave, oStructCube, Len(aPeriodo), nSerie, aChavAnt, lMovimento, aIni, aFim, aFlt)
		
				If Len(aProcAux) > 0
			
					For nZ:=1 TO Len(aProcAux)
						If aProcAux[nZ,4]== "AKO"
							nPos := ASCAN(aProcessa, {|aVal| aVal[1] == aProcAux[nZ][1]})
							If nPos > 0 //caso ja exista no cubo (aprocessa) incrementa no periodo de referencia
								For nY := 1 TO Len(aProcAux[nZ][2])
									aProcessa[nPos][2][nConf+((nY-1)*aConfig[6])] += aProcAux[nZ][2][nY]
								Next	
							Else // caso nao exista no cubo (aprocessa) adiciona ao cubo
								aAdd(aProcessa, aClone(aProcAux[nZ]))
								
								aProcessa[Len(aProcessa)][2] := {}   //coloca um array vazio e popula zerado
								For nY := 1 TO aConfig[6]*Len(aPeriodo)
									aAdd(aProcessa[Len(aProcessa)][2], 0)
								Next
								//incrementa no cubo os valores do cubo auxiliar
								For nY := 1 TO Len(aProcAux[nZ][2])
									aProcessa[Len(aProcessa)][2][nConf+((nY-1)*aConfig[6])] += aProcAux[nZ][2][nY]
								Next
							EndIf
						Endif
					
					Next
					
				EndIf

			Next

	    EndIf
	Next
	
EndIf

Return		

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC360aProcessaบAutor  ณMicrosiga        บ Data ณ  29/08/14   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o array aProcessa quando pressionado opcao drilldownบฑฑ
ฑฑบ          ณchamada pela funcao C360Niv2Down                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function C360aProcessa(cCodCube, nNivel, cChvOri, oStructCube, nQtdVal, nSerie, aWhere, lMovimento, aIni, aFim, aFlt)
Local cArquivo

Local aQryDim
Local nZ
Local cArqTmp
Local lZerado := .F.
Local cArqSld
Local nTamNiv, nPai, cChavOri
Local lAuxSint
Local cDescrAux
Local aProcCub := {}
Local cWhere
Local cWhereTpSld
Local nY
Local cArqAS400 := ""
Local cSrvType := Alltrim(Upper(TCSrvType()))

If __cArqTemp <> Nil
	cArquivo := __cArqTemp
Endif

If __cArqSald <> Nil
	cArqSld := __cArqSald
Endif

oStructCube:aIni 		:= If( aIni!= NIL, aClone(aIni), oStructCube:aIni )
oStructCube:aFim 		:= If( aFim!= NIL, aClone(aFim), oStructCube:aFim )
oStructCube:aFiltros 	:= If( aFlt!= NIL, aClone(aFlt), oStructCube:aFiltros ) 

cWhereTpSld := ""
If oStructCube:nNivTpSld > 0 .And. ;
	oStructCube:aIni[oStructCube:nNivTpSld] == oStructCube:aFim[oStructCube:nNivTpSld] .And. ;
	Empty(oStructCube:aFiltros[oStructCube:nNivTpSld])
		cWhereTpSld := " AKT.AKT_TPSALD = '" + oStructCube:aIni[oStructCube:nNivTpSld] + "' AND "
EndIf								

cWhere := ""
For nZ := 1 TO Len(aWhere)
	cWhere += aWhere[nZ]
Next	

aAdd(aNiveis, nNivel)

If cSrvType == "ISERIES" //outros bancos de dados que nao DB2 com ambiente AS/400
	//cria arquivo para popular
	PcoCriaTemp(oStructCube, @cArqAS400, nQtdVal)
	aAdd(__aFilesErased, cArqAS400)
EndIf

If cArquivo == Nil// .Or. Select( cArquivo ) <= 0
	//cria arquivo para popular
	PcoCriaTemp(oStructCube, @cArquivo, nQtdVal)
	aAdd(__aFilesErased, cArquivo)

	__cArqTemp := cArquivo
Endif

PcoLimpTemp(cArquivo)
	
aQryDim 	:= {}                          

For nZ := 1 TO oStructCube:nMaxNiveis
	aQueryDim := PcoCriaQueryDim(oStructCube, nZ, .F./*lSintetica*//*, .T. /*lForceNoSint*/)
	
	//aqui fazer tratamento quando expressao de filtro e expressao sintetica nao for resolvida

	If (aQueryDim[2] .And. aQueryDim[3])  //neste caso foi resolvida
		
		If ! aQueryDim[4]
			aAdd( aQryDim, { aQueryDim[1], ""} )
		Else	
			aAdd( aQryDim, { aQueryDim[1], aQueryDim[5]} )
		EndIf
		
	Else  //se filtro ou condicao de sintetica nao foi resolvida pela query
	
		aQueryDim := PcoQueryDim(oStructCube, nZ, @cArqTmp, aQueryDim[1] )
		aAdd(__aFilesErased, cArqTmp)
		If ! aQueryDim[4]
			aAdd( aQryDim, { aQueryDim[1], ""} )
		Else	
			aAdd( aQryDim, { aQueryDim[1], aQueryDim[5]} )
		EndIf
		
	EndIf	
Next

aQuery := PcoCriaQry( cCodCube, nNivel, nMoeda, cArqAS400, If(nSerie==1, nQtdVal/nQtdSerie, nQtdVal), aDataSld, aQryDim, cWhere, cWhereTpSld, oStructCube:nNivTpSld, lMovimento, aDataIni )

PcoPopulaTemp(oStructCube, cArquivo, aQuery, nQtdVal, lZerado, cArqAS400)

If cArqSld == Nil// .Or. Select( cArqSld ) <= 0
	//cria arquivo que contera o resultado da query agrupada 
	PcoCriaTemp(oStructCube, @cArqSld, nQtdVal)
	aAdd(__aFilesErased, cArqSld)

	__cArqSald := cArqSld
Endif

PcoLimpTemp(cArqSld)
	
//execucao da query para agrupar os diversos periodos e popular arq temporario que sera usado na consulta
PcoQryFinal( oStructCube, nNivel, cArqSld/*cAliasSld*/, nQtdVal, cArquivo)

dbSelectArea(cArqSld)
(cArqSld)->(dbGoTop())

While (cArqSld)->( ! Eof() )

	cChave := (cArqSld)->(FieldGet(FieldPos("AKT_NIV"+StrZero(nNivel,2))))
	nTamNiv := oStructCube:aTam[nNivel]
	nPai := 0
	cChavOri := ""

	//descricao tem q macro executar a expressao contida em oStrucCube:aDescRel
	dbSelectArea(oStructCube:aAlias[nNivel])
	If dbSeek(xFilial()+cChave)
		cDescrAux := &(oStructCube:aDescRel[nNivel])
		If ! Empty(oStructCube:aCondSint[nNivel])
			lAuxSint := &(oStructCube:aCondSint[nNivel])
		Else	
			lAuxSint := .F.	
		EndIf
	Else
		cDescrAux := STR0076  //"Outros"
		lAuxSint := .F.		
	EndIf	

	If nSerie == 1	

	  	aAdd(aProcCub, {	cChvOri+PadR(cChave, nTamNiv), ;
	  						ARRAY(nQtdVal), ;
		  					oStructCube:aConcat[nNivel], ;
		  					"AKO"/*oStructCube:aAlias[nNivel]*/, ;
	  						oStructCube:aDescri[nNivel], ;
	  						cDescrAux,;
		  					0,;
		  					nNivel,;
	  						cChavOri,;
	  						lAuxSint/*oStructCube:aCondSint[nNivel]*/,;
	  						nPai,;
		  					.T.,;
		  					oStructCube:aDescCfg[nNivel],;
							PadR(cChave, nTamNiv),;
							( nNivel  == oStructCube:nMaxNiveis ), ;
							"0", ;
							"", ;
							"1" })
							//armazena no 2o.elemento os valores apurados na query
							//primeiro preenche com zeros
							For nY := 1 TO nQtdVal
								aProcCub[Len(aProcCub),2,nY] := 0
							Next
							//em seguida atribui o valor
							For nY := 1 TO Len(aPeriodo)
								aProcCub[ Len(aProcCub), 2 , ((nY-1)*nQtdSerie) + 1 ] := (cArqSld)->(FieldGet(FieldPos("AKT_SLD"+StrZero(nY, 3))))						
							Next

	Else

	  	aAdd(aProcCub, {	cChvOri+PadR(cChave, nTamNiv), ;
	  						ARRAY(nQtdVal), ;
		  					oStructCube:aConcat[nNivel], ;
		  					"AKO"/*oStructCube:aAlias[nNivel]*/, ;
	  						oStructCube:aDescri[nNivel], ;
	  						cDescrAux,;
		  					0,;
		  					nNivel,;
	  						cChavOri,;
	  						lAuxSint/*oStructCube:aCondSint[nNivel]*/,;
	  						nPai,;
		  					.T.,;
		  					oStructCube:aDescCfg[nNivel],;
							PadR(cChave, nTamNiv),;
							( nNivel  == oStructCube:nMaxNiveis ), ;
							"0", ;
							"", ;
							"1" })
							
							//armazena no 2o.elemento os valores apurados na query
							//primeiro preenche com zeros
							For nY := 1 TO nQtdVal
								aProcCub[Len(aProcCub),2,nY] := 0
							Next
							//em seguida atribui o valor
							For nY := 1 TO nQtdVal
								aProcCub[ Len(aProcCub), 2 , nY ] := (cArqSld)->(FieldGet(FieldPos("AKT_SLD"+StrZero(nY, 3))))						
							Next

    EndIf

	dbSelectArea(cArqSld)
	(cArqSld)->(dbSkip())

EndDo	

Return(aProcCub)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ PCOC361TOk บAutor  ณ Gustavo Henrique   บ Data ณ  18/04/08 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Validacoes gerais na confirmacao dos parametros informados บฑฑ
ฑฑบ          ณ na Parambox inicial.                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Consulta de Saldos por Periodo                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PCOC361TOk()
Local lRet := .T.

lRet := PCOCVldPer( mv_par01, mv_par02 )

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoC361Sint  บAutor  ณMicrosiga        บ Data ณ  29/08/14   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se a conta gerencial (cChave) eh sintetica         บฑฑ
ฑฑบ          ณchamada pela funcao PCOC_360PFI                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PcoC361Sint(cChave)
Local aArea := GetArea()
Local aAreaAKO := AKO->( GetArea() )
Local lSintetica := .T.

//AKO 1 AKO_FILIAL+AKO_CODIGO+AKO_CO
dbSelectArea("AKO")
dbSetOrder(1)

If MsSeek( xFilial("AKO")+AKN->AKN_CODIGO+cChave )
	lSintetica := ( AKO->AKO_CLASSE != "1" )
EndIf	

RestArea(aAreaAKO)
RestArea(aArea)

Return(lSintetica)
