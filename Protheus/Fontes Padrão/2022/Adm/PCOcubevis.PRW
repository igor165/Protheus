#INCLUDE "pcocubevis.ch"
#INCLUDE "PROTHEUS.CH"

#define JOB_A_EXECUTAR 		"0"
#define JOB_INICIANDO 		"1"
#define JOB_AGUARDA_CARGA	"2"
#define JOB_EXECUTANDO 		"3"
#define JOB_FINALIZADO_OK 	"4"
#define JOB_NOCONECTION 	"5"
#define NUM_JOBEXEC 		Val(GetNewPar("MV_PCOXJOB","3"))
#define NUM_ESPERA 			10 //10000
#define LINHA 				Replicate("-",65)
#define MODOVISAO 			Val(GetNewPar("MV_PCOVGER","1"))
#define VISAONORMAL 		1
#define VISAOCONSOL			2

Static cFilAKT
Static cTipoDB
Static lQuery
Static lOracle
Static lPostgres
Static lDB2
Static cModoAcesso
Static lJob
Static aParamJob
Static aChaveJob
Static aResultJob
Static aNiveisJob
Static _oCubeVis1
Static _oCubeVis2
Static _oCubeVis3

/*/
_F_U_N_C_ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFUNCAO    ณPCOCUBEVISณ AUTOR ณ Edson Maricate        ณ DATA ณ 07-01-2004 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDESCRICAO ณ Funcoes de processamento dos cubos com visoes                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ USO      ณ SIGAPCO                                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ_DOCUMEN_ ณ PCOCUBEVIS                                                   ณฑฑ
ฑฑณ_DESCRI_  ณ                                                              ณฑฑ
ฑฑณ_FUNC_    ณ                                                              ณฑฑ
ฑฑณ          ณ                                                              ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoCubeVis(cVisao,nQtdVal,cProcessa,cConfig,nViewCfg,nDetCubos,lMudaChave,aVarPriv,lProcNlv)
Local aAuxTot 	:= {}
Local nu,Nx
Local aProcessa	:= {}
Local aIniCfg	:=	{}
Local aFimCfg	:=	{}
Local aFilCfg	:=	{}
Local aTamNiv   := {}
Local nRecAKO, nRecAKN, nRecAKL
Local cArqAKT
Local aStructAKT := {}
Local lRet := .T.

DEFAULT lMudaChave	:=	.F.
DEFAULT aVarPriv	:=	{}
DEFAULT lProcNlv	:= .T.

Private nCount := 0
Private cCodCube := ""

//carrega as variaveis staticas
cFilAKT := xFilial("AKT")
cTipoDB	 := Upper(TCGetDB())
lQuery := ( TcGetDb() # "AS/400" )
lOracle	 	:= ( "ORACLE"   $ cTipoDB )
lPostgres 	:= ( "POSTGRES" $ cTipoDB )
lDB2		:= ( "DB2"      $ cTipoDB )
cModoAcesso := GetNewPar("MV_PCOMCHV","1")
lJob      	:= .F. //( GetNewPar("MV_PCOVJOB","2") == "1" )

aAdd(aStructAKT,{"AKT_CHAVE","C", Len(AKT->AKT_CHAVE), 00})

aParamJob := {}
aResultJob := {}
aNiveisJob := {}
aChaveJob := {}

For nu := 1 to nQtdVal
	aAdd(aAuxTot,0)  // Acumuladores do processamento
Next
dbSelectArea("AKO")
dbSetOrder(2)
dbSeek(xFilial()+cVisao)
While !Eof() .And. xFilial()+cVisao==AKO->AKO_FILIAL+AKO->AKO_CODIGO
	nCount++
	dbSkip()
End

dbSelectArea("AKO")
dbSetOrder(3)
If dbSeek(xFilial()+cVisao+"001")
	nRecAKO := AKO->(Recno())
	dbSelectArea("AKN")
	dbSetOrder(1)
	If MsSeek(xFilial()+cVisao)
		nRecAKN := AKN->(Recno())
		dbSelectArea("AKL")
		dbSetOrder(1)
		If MsSeek(xFilial()+AKN->AKN_CONFIG)
			If !Empty(AKL->AKL_CUBE)        
				nRecAKL := AKL->(Recno())
				cCodCube := AKL->AKL_CUBE
				If cConfig == Nil .Or. Empty(cConfig).Or.CarregaConfig(nViewCfg,cConfig,aIniCfg,aFimCfg,aFilCfg,aTamNiv,aStructAKT)
					Processa({||ProcVisCube(cVisao,AKO->AKO_CO,nQtdVal,cProcessa,cConfig,nViewCfg,aAuxTot,,@aProcessa,nDetCubos,.T.,aIniCfg,aFimCfg,aFilCfg,lMudaChave,aTamNiv,aStructAKT,@cArqAKT,lProcNlv)})			
				Endif
				If lJob  //processa de novo com os resultados
					lErro := .F.
					aAuxTot := {}
					For nu := 1 to nQtdVal
						aAdd(aAuxTot,0)  // Acumuladores do processamento
					Next
					Processa( {|| ProcJobRunCube(aVarPriv, @lErro) } )  
					If lErro
						Alert(STR0010)//"Erro na consulta, tente novamente."
						lRet := .F.
					EndIf	

					If lRet	
						dbSelectArea("AKO")
						dbSetOrder(3)
						dbGoto(nRecAKO)
						dbSelectArea("AKN")
						dbSetOrder(1)
						dbGoto(nRecAKN)
						dbSelectArea("AKL")
						dbSetOrder(1)
						dbGoto(nRecAKL)
						//Processa( {|| ProcJobVisCube(cVisao,AKO->AKO_CO,nQtdVal,cProcessa,cConfig,nViewCfg,aAuxTot,,@aProcessa,nDetCubos,.T.,aIniCfg,aFimCfg,aFilCfg,lMudaChave,aTamNiv) } )
					EndIf			
				Endif
			Else
				Aviso(STR0001,STR0005,{"Ok"},2) //"Visao nao compativel" //"A Visao selecionada nao possui nenhum cubo relacionado. Apenas as Visoes com cubos relacionados poderao ser utilizadas nesta consulta. Verifique a Visao selecionada."
			EndIf
		Endif
	Else                       
		Aviso(STR0002,STR0003,{"Ok"},2) //"Visao nao encontrada"###"A Visao selecionada nao foi encontrada nas configura็๕es de Visoes. Verifique a Visao selecionada."
	EndIf
EndIf

aSort(aProcessa, ,,{|x,y| x[17]+x[1] < y[17]+y[1]})

If cModoAcesso == '4' .And. cArqAKT  != NIL
	MsErase(cArqAKT)
EndIf
Return aProcessa

Function ProcVisCube(cVisao,cCO,nQtdVal,cProcessa,cConfig,nViewCFG,aAuxTot,nPai,aProcessa,nDetCubos,lFirst,aIniCfg,aFimCfg,aFilCfg,lMudaChave,aTamNiv,aStructAKT,cArqAKT,lProcNlv)
Local aArea	:= GetArea()
Local aAreaAKO := AKO->(GetArea())
Local aFilIni := {} 
Local nx
Local aFilFim := {} 
Local aFiltros:= {} 
Local aNiveis := {}
Local cOperac	:= ""
Local nPosProc, nZ
Local cModoVisao := MODOVISAO
Local cChavAux
//Nao mostrar perguntas
nViewCfg	:=	2

Default nPai := 0
Default lFirst := .F.
Default lProcNlv	:= .T.

If lFirst
	ProcRegua(nCount)
Endif                
If cModoAcesso == '4' .And. cArqAKT  == NIL
	PcoCar_Query(cCodCube, aTamNiv, @cArqAKT, aStructAKT)
EndIf

If ! lJob
	If lProcNlv
	aAdd(aProcessa, {cCO, ;
			aClone(aAuxTot), ;
			STR0004, ; //"CONTA GERENCIAL"
			"AKO", ;
			STR0004, ; //"CONTA GERENCIAL"
			AKO->AKO_DESCRI,;
			AKO->(RecNo()),;
			0/*Val(AKO->AKO_NIVEL)*/, ;
			cCO,;
			.F.,;
			nPai,;
			.T.,;
			NIL,;
			NIL,;
			NIL,;
			AKO->AKO_IDTIMP,;
			AKO->AKO_ORDEM,;
			"1"/*cOperac*/ })

	nPai := Len(aProcessa)
	
	//Ponto de entrada para adicionar elementos no array aProcessa 
	If ExistBlock("CUBEVIS")
		aRetPe 		:= ExecBlock("CUBEVIS",.F.,.F.,aClone(aProcessa))
		aProcessa	:= aClone(aRetPe)
	EndIf
    
    EndIf
EndIf

IncProc()
If AKO->AKO_CLASSE == "1"	 // Analitca
	dbSelectArea("AKP")
	dbSetOrder(1)
	dbSeek(xFilial()+cVisao+cCO)
	cItem := AKP->AKP_ITEM
	cOperac := AKP->AKP_OPERAC
	While !Eof() .And. xFilial()+cVisao+cCO== AKP_FILIAL+AKP_CODIGO+AKP_CO
		aAdd(aFilIni,AKP->AKP_VALINI)
		aAdd(aFilFim,AKP->AKP_VALFIM)
		aAdd(aFiltros,Nil)
		If Len(aIniCfg) >= Len(aFilIni) .And. aIniCfg[Len(aFilIni)] <> Nil .And. aIniCfg[Len(aFilIni)] > aFilIni[Len(aFilIni)]
			aFilIni[Len(aFilIni)]	:=	aIniCfg[Len(aFilIni)]
		Endif
		If Len(aFimCfg) >= Len(aFilFim) .And. aFimCfg[Len(aFilFim)] <> Nil .And. aFimCfg[Len(aFilFim)] < aFilFim[Len(aFilFim)]
			If aFimCfg[Len(aFilFim)] < aFilIni[Len(aFilIni)]
			   Conout(STR0035) //"A Configuracao da Visao ou do Cubo, pois o valor inicial esta maior que o valor final"
			EndIf
			If ! Empty(aFimCfg[Len(aFilFim)])
				aFilFim[Len(aFilFim)]	:=	aFimCfg[Len(aFilFim)]
			EndIf	
		Endif                                              
		If Len(aFilCFg) >= Len(aFiltros) .And. aFilCfg[Len(aFiltros)] <> Nil
			aFiltros[Len(aFiltros)]	:=	aFilCfg[Len(aFiltros)]
		Endif                                              
		dbSkip()
		If Eof() .Or. cVisao+cCO+cItem<>AKP_CODIGO+AKP_CO+AKP_ITEM
			If lJob
				aAdd( aParamJob, { AKL->AKL_CUBE, nQtdVal, cProcessa, cConfig, nViewCFG, .F., /*aNiveis*/, aFilIni, aFilFim, NIL/*lReserv*/, NIL/*aCfgCube*/, .F./*lProcessa*/, .F./*lVerAcesso*/, .T./*lForceNoSint*/, NIL/*aItCfgBlq*/, aClone(aFiltros), cArqAKT, .F., .T. } )
				aAdd( aChaveJob, cVisao+cCO+cItem )
			Else
				aNiveis := {}
				aProcCube := PcoRunCube( AKL->AKL_CUBE, nQtdVal, cProcessa,cConfig,nViewCFG, .F.    ,aNiveis,aFilIni,aFilFim,/*lReserv*/,/*aCfgCube*/,.F./*lProcessa*/,.F./*lVerAcesso*/,.T./*lForceNoSint*/,/*aItCfgBlq*/,aFiltros, cArqAKT, .F. /*lLimpArqAKT*/, .T. /*lVisao*/) // Processa o cubo
				For nx := 1 to Len(aProcCube)
					If aProcCube[nx,8] == Len(aNiveis) // Rever esta logica
						If nDetCubos == 1
							If cModoVisao == VISAONORMAL
							    //solucao normal inclui cada linha da conta gerencial
							    //em um novo elemento de aProcessa
							aAdd(aProcessa,aClone(aProcCube[nx]))
							If lMudaChave
								aProcessa[Len(aProcessa),1]	:=	cCO+aProcessa[Len(aProcessa),1]
							Endif
							aProcessa[Len(aProcessa),11] := nPai
							aAdd(aProcessa[Len(aProcessa)],"0") // Adiciona elemento - IDTIMP
							aAdd(aProcessa[Len(aProcessa)],AKO->AKO_ORDEM) // Adiciona elemento - ORDEM
							aAdd(aProcessa[Len(aProcessa)],cOperac) // Adiciona elemento - sinal
								//
                            ElseIf cModoVisao == VISAOCONSOL
                            	
                            	cChavAux := If(lMudaChave, cCO+aProcCube[nX,1], aProcCube[nX,1])

								If ( nPosProc := Ascan(aProcessa, {|aVal| aVal[1] == cChavAux .And. aVal[11] == nPai}) ) == 0 //se nao achou a chave nesta conta gerencial
									aAdd(aProcessa,aClone(aProcCube[nx]))
									// Inverte o sinal caso o operador seja negativo
									For nZ := 1 TO Len(aProcCube[nx,2])
										aProcessa[Len(aProcessa),2,nZ] := If(cOperac == "1", aProcCube[nx,2,nZ], aProcCube[nx,2,nZ]*-1)
									Next
									aProcessa[Len(aProcessa),1]	:=	cChavAux
									aProcessa[Len(aProcessa),11] := nPai
									aAdd(aProcessa[Len(aProcessa)],"0") // Adiciona elemento - IDTIMP
									aAdd(aProcessa[Len(aProcessa)],AKO->AKO_ORDEM) // Adiciona elemento - ORDEM
									aAdd(aProcessa[Len(aProcessa)],cOperac) // Adiciona elemento - sinal
								Else 	//se achou a chave nesta conta gerencial
									For nZ := 1 TO Len(aProcCube[nx,2])
										aProcessa[nPosProc,2,nZ] += If(cOperac == "1", aProcCube[nx,2,nZ], aProcCube[nx,2,nZ]*-1)
									Next
								EndIf
							EndIf	
						EndIf
						Cubo_Totaliza(aProcessa, nPai, aProcCube[nx,2],cOperac)
					Else
						If nDetCubos == 1
							If cModoVisao == VISAONORMAL
							aAdd(aProcessa,aClone(aProcCube[nx]))
							If lMudaChave
								aProcessa[Len(aProcessa),1]	:=	cCO+aProcessa[Len(aProcessa),1]
							Endif
							aProcessa[Len(aProcessa),11] := nPai
							aAdd(aProcessa[Len(aProcessa)],"0") // Adiciona elemento - IDTIMP
							aAdd(aProcessa[Len(aProcessa)],AKO->AKO_ORDEM) // Adiciona elemento - ORDEM
							aAdd(aProcessa[Len(aProcessa)],cOperac) // Adiciona elemento - sinal
								//
							ElseIf cModoVisao == VISAOCONSOL
                            	cChavAux := If(lMudaChave, cCO+aProcCube[nX,1], aProcCube[nX,1])

								If ( nPosProc := Ascan(aProcessa, {|aVal| aVal[1] == cChavAux .And. aVal[11] == nPai}) ) == 0 //se nao achou a chave nesta conta gerencial
									aAdd(aProcessa,aClone(aProcCube[nx]))
									// Inverte o sinal caso o operador seja negativo
									For nZ := 1 TO Len(aProcCube[nx,2])
										aProcessa[Len(aProcessa),2,nZ] := If(cOperac == "1", aProcCube[nx,2,nZ], aProcCube[nx,2,nZ]*-1)
									Next
									aProcessa[Len(aProcessa),1]	:=	cChavAux
									aProcessa[Len(aProcessa),11] := nPai
									aAdd(aProcessa[Len(aProcessa)],"0") // Adiciona elemento - IDTIMP
									aAdd(aProcessa[Len(aProcessa)],AKO->AKO_ORDEM) // Adiciona elemento - ORDEM
									aAdd(aProcessa[Len(aProcessa)],cOperac) // Adiciona elemento - sinal
								Else 	//se achou a chave nesta conta gerencial
									For nZ := 1 TO Len(aProcCube[nx,2])
										aProcessa[nPosProc,2,nZ] += If(cOperac == "1", aProcCube[nx,2,nZ], aProcCube[nx,2,nZ]*-1)
									Next
								EndIf
							EndIf								
						EndIf
					EndIf
				Next					
			EndIf
			aFilIni := {}
			aFilFim := {}
			aFiltros:= {}
			cItem := AKP->AKP_ITEM
			cOperac := AKP->AKP_OPERAC
		EndIf
	End
Else
	dbSelectArea("AKO")
	dbSetOrder(2)
	dbSeek(xFilial()+cVisao+cCO)
	While !Eof() .And. xFilial()+cVisao+cCO==AKO->AKO_FILIAL+AKO->AKO_CODIGO+AKO->AKO_COPAI
		ProcVisCube(cVisao,AKO->AKO_CO,nQtdVal,cProcessa,cConfig,nViewCFG,aAuxTot,nPai,aProcessa,nDetCubos,,aIniCfg,aFimCfg,aFilCfg,lMudaChave,aTamNiv,aStructAKT,cArqAKT)
		dbSkip()
	End
EndIf

RestArea(aAreaAKO)
RestArea(aArea)
Return 


Static Function Cubo_Totaliza(aProcessa,  nX, aRet,cOperac)
Local nZerado
Local nu
nZerado := 0
aEval(aRet,{|x| nZerado += Abs(x)}) 

If nZerado != 0 
	For nu := 1 to Len(aProcessa[nX][2])
		If cOperac == "2"
			aProcessa[nX][2][nu] -= aRet[nu]
		Else
			aProcessa[nX][2][nu] += aRet[nu]
		EndIf
	Next

	If aProcessa[nX][11] > 0.And. !aProcessa[nX][10] 
		Cubo_Totaliza(aProcessa, aProcessa[nX][11], aRet,cOperac)
	EndIf

EndIf

Return

Static Function CarregaConfig(nViewCfg,cConfig,aIni,aFim,aFiltros,aTamNiv,aStructAKT)
Local lRet	:=	.T.
Local nX	:=	1
Local aAlias	:=	{}
Local aF3		:= {}
Local aDescri	:= {}
Local aFaixa	:= {}
Local aValid	:= {}
Local aConfig	:=	{}
Local aParametros	:=	{}
Local cValid	:=	""
Local aSavPar	:=	{}
Local nTamAcum  := 0
Local aChave	:={}
Private aRelac:={}
//utilizada na consulta padrใo das entidades adicionais

aIni		:=	{}
aFim		:=	{}
aFiltros	:=	{}

AKW->(DbSetOrder(1))
AKW->(MsSeek(xFilial()+AKL->AKL_CUBE))
nx := 0
While !AKW->(Eof()) .And. xFilial('AKW')+AKL->AKL_CUBE == AKW->AKW_FILIAL+AKW->AKW_COD
	nTamAcum += AKW->AKW_TAMANH
	aAdd(aAlias,AKW->AKW_ALIAS)
	aAdd(aF3,AKW->AKW_F3)
	aAdd(aIni,SPACE(AKW->AKW_TAMANH))
	aAdd(aFim,Replicate("z",AKW->AKW_TAMANH))
	aAdd(aDescri,AKW->AKW_DESCRI)
	aAdd(aFiltros,"")
	aAdd(aFaixa, .T. )
	aAdd(aValid, "" )
	aAdd(aTamNiv, nTamAcum)
	aAdd(aStructAKT,{"CAMPO"+StrZero(Len(aTamNiv),3),"C", AKW->AKW_TAMANH, 00})
	Aadd(aChave,AKW->AKW_CHAVER)
	AKW->(DbSkip())
Enddo	

AL4->(DbSetOrder(1))
If AL4->(dbSeek(xFilial()+cConfig+AKL->AKL_CUBE))
	While !AL4->(EOF()) .And. xFilial()+cConfig+AKL->AKL_CUBE == AL4->AL4_FILIAL+AL4->AL4_CODIGO+AL4->AL4_CONFIG

		AKW->(DbSetOrder(1))
		AKW->(MsSeek(xFilial()+AKL->AKL_CUBE+AL4->AL4_NIVEL))
		aIni[Val(AL4->AL4_NIVEL)] 		:= Left(AL4->AL4_EXPRIN,AKW->AKW_TAMANH)
		aFim[Val(AL4->AL4_NIVEL)] 		:= Left(AL4->AL4_EXPRFI,AKW->AKW_TAMANH)
		aFiltros[Val(AL4->AL4_NIVEL)] := Alltrim(AL4->AL4_FILTER)
		aFaixa[Val(AL4->AL4_NIVEL)] := (AL4->AL4_TPFAIX == "2")
		If !Empty(AL4->AL4_VALID)
			aValid[Val(AL4->AL4_NIVEL)] := Alltrim(AL4->AL4_VALID)
		EndIf
		AL4->(DbSkip())			
	Enddo
Endif				
If nViewCfg == 1
	For nx := 1 to Len(aAlias)
		If aFaixa[nX]
			aAdd(aParametros,{1,AllTrim(aDescri[nx])+STR0006,aIni[nx], "" ,"",aF3[nx],"", Len(aIni[nx])*7 ,.F.}) //" de "
			Aadd(aRelac,{'',aChave[nX]})
			aAdd(aParametros,{1,AllTrim(aDescri[nx])+STR0007,aFim[nx], "" ,"",aF3[nx],"", Len(aFim[nx])*7 ,.F.}) //" Ate "
			Aadd(aRelac,{'',aChave[nX]})
		Else
			cValid := If(Empty(aValid[nX]), "", aValid[nX])
			cValid := "(mv_par"+StrZero(Len(aAlias)+((nX*3)-3)+2,2)+":=mv_par"+StrZero(Len(aAlias)+((nX*3)-3)+1,2)+", "+If(Empty(cValid),".T.",cValid)+")"
			aAdd(aParametros,{1,AllTrim(aDescri[nx])+STR0006,aIni[nx], "" ,cValid,aF3[nx],"", Len(aIni[nx])*7 ,.F.}) //" de "
			Aadd(aRelac,{'',aChave[nX]})
			aAdd(aParametros,{1,AllTrim(aDescri[nx])+STR0007,aFim[nx], "" ,"",aF3[nx],".F.", Len(aFim[nx])*7 ,.F.}) //" Ate "
			Aadd(aRelac,{'',aChave[nX]})
		EndIf
		aAdd(aParametros,{7,STR0009+AllTrim(aDescri[nx]),aAlias[nx],aFiltros[nx]}) //"Filtro "
		Aadd(aRelac,{'',aChave[nX]})
	Next
	For nX := 1 To Len(aParametros)
		AAdd(aSavPar, &('MV_PAR'+StrZero(nX,2)))
		aRelac[nX][1]:='MV_PAR'+StrZero(nX,2)//criando relacionamento de mv_par/entidade para usar na xb
	Next
	lRet	:=	ParamBox(  aParametros ,STR0008,aConfig,,     ,.F.      ,,,,                           ,.F.)
	For nX := 1 To Len(aSavPar)
		 &('MV_PAR'+StrZero(nX,2)) := aSavPar[nX]
	Next

	nu := 1
	For nx := 1 To Len(aConfig)-2 Step 3
		aIni[nu] := aConfig[nx]
		nu++
	Next
	nu := 1
	For nx := 2 To Len(aConfig)-1 Step 3
		aFim[nu] := aConfig[nx]
		nu++
	Next
	nu := 1
	For nx := 3 To Len(aConfig)   Step 3
		aFiltros[nu] := aConfig[nx]
		nu++
	Next
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoCar_Query บAutor ณPaulo Carnelossi  บ Data ณ  26/09/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออสออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณQuery para extrair todas as chaves existentes na tabela de  บฑฑ
ฑฑบ          ณsaldos de movimentos diarios (AKT) que sera repassada a     บฑฑ
ฑฑบ          ณfuncao PcoRunCube() quando parametro MV_PCOMCHV = '4'       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoCar_Query(cCodCube, aTamNiv, cArquivo, aStructAKT)
Local cQuery := ""
Local cIndTmpAKT := ""
Local nX, nRecno := 0
//este bloco eh necessario quando esta funcao eh chamada da pcoruncube
If cFilAKT == NIL
	cFilAKT := xFilial("AKT")
EndIf	

//acaba definicao da estrutura do temporario
aAdd(aStructAKT,{"AKT_ID","C", 10, 00})
aAdd(aStructAKT,{"AKT_DELET","C", 1, 00})

//laco para montar indice a ser utilizada no indregua
For nX := 2 TO Len(aStructAKT)-2
	cIndTmpAKT += aStructAKT[nX, 1]
	If nX<Len(aStructAKT)-2
		cIndTmpAKT+="+"
	EndIf
Next

//definicao da query	
cQuery := "SELECT DISTINCT AKT.AKT_CHAVE "
cQuery += " FROM " + RetSqlName("AKT") + " AKT " 
//condicao normal da tabela de saldos diarios
cQuery += " WHERE "
cQuery += " AKT.AKT_FILIAL = '" + cFilAKT + "'"
cQuery += " AND AKT_CONFIG = '" + cCodCube + "' "
cQuery += " AND AKT.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY 1"

cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPAUX", .T., .T. )

// Cria a tabela temporia direto no banco de dados	                					
cArquivo := CriaTrab( , .F.)
MsErase(cArquivo)
MsCreate(cArquivo,aStructAKT, "TOPCONN")
Sleep(1000)
dbUseArea(.T., "TOPCONN",cArquivo,"TMPAKT",.T.,.F.)

// Cria o indice temporario
IndRegua("TMPAKT",cArquivo,cIndTmpAKT,,)

dbSelectArea("TMPAUX")
dbGoTop()
While ! Eof()

	dbSelectArea("TMPAKT")
	RecLock("TMPAKT", .T.)
	nRecno++
	TMPAKT->AKT_CHAVE := TMPAUX->AKT_CHAVE
	nInicio := 1
	For nX := 2 TO Len(aStructAKT)-2
		FieldPut( nX, Subs(TMPAUX->AKT_CHAVE, nInicio, aStructAKT[nX, 3]) )
		nInicio += aStructAKT[nX, 3]
	Next
	TMPAKT->AKT_ID := StrZero(nRecno,10)
	MsUnLock()
	
	dbSelectArea("TMPAUX")
	dbSkip() 

EndDo

dbSelectArea("TMPAUX")
dbCloseArea()
dbSelectArea("TMPAKT")
dbCloseArea()
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหออออออัออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณProcJobVisCube บAutor ณPaulo Carnelossi  บ Data ณ 26/09/07  บฑฑ
ฑฑฬออออออออออุอออออออออออออออสออออออฯออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณFuncao similar ProcVisCube() sendo que esta eh chamada apos บฑฑ
ฑฑบ          ณo processamento da PcoRunCube() por jobs                    บฑฑ
ฑฑบ          ณserve para popular o array aProcessa baseado no aResultJob  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ProcJobVisCube(cVisao,cCO,nQtdVal,cProcessa,cConfig,nViewCFG,aAuxTot,nPai,aProcessa,nDetCubos,lFirst,aIniCfg,aFimCfg,aFilCfg,lMudaChave,aTamNiv)
Local aArea	:= GetArea()
Local aAreaAKO := AKO->(GetArea())
Local nx, nPosRes
Local cOperac	:= ""
Local aProcCube 
Local aNiveis
Local nPosProc, nZ
Local cModoVisao := MODOVISAO
Local cChavAux
//Nao mostrar perguntas
nViewCfg	:=	2

Default nPai := 0
Default lFirst := .F.

If lFirst
	ProcRegua(nCount)
Endif                

	aAdd(aProcessa, {cCO, ;
			aClone(aAuxTot), ;
			STR0004, ; //"CONTA GERENCIAL"
			"AKO", ;
			STR0004, ; //"CONTA GERENCIAL"
			AKO->AKO_DESCRI,;
			AKO->(RecNo()),;
			0/*Val(AKO->AKO_NIVEL)*/, ;
			cCO,;
			.F.,;
			nPai,;
			.T.,;
			NIL,;
			NIL,;
			NIL,;
			AKO->AKO_IDTIMP ,;
			AKO->AKO_ORDEM, ;
			"1"/*cOperac*/ })
	
nPai := Len(aProcessa)

IncProc()

If AKO->AKO_CLASSE == "1"	 // Analitca
	dbSelectArea("AKP")
	dbSetOrder(1)
	dbSeek(xFilial()+cVisao+cCO)
	cItem := AKP->AKP_ITEM
	cOperac := AKP->AKP_OPERAC
	While !Eof() .And. xFilial()+cVisao+cCO== AKP_FILIAL+AKP_CODIGO+AKP_CO
		dbSkip()
		If Eof() .Or. cVisao+cCO+cItem<>AKP_CODIGO+AKP_CO+AKP_ITEM
			
			nPosRes := aScan( aChaveJob, cVisao+cCO+cItem )  //sempre vai encontrar
			
			If nPosRes == 0
				Alert(STR0011)//"Erro no processamento da visao."
				Return
			EndIf	
			
			aProcCube 	:= aClone(aResultJob[nPosRes])
			aNiveis 	:= aClone(aNiveisJob[nPosRes])
			
			For nx := 1 to Len(aProcCube)
				If aProcCube[nx,8] == Len(aNiveis) // Rever esta logica
					If nDetCubos == 1
						If cModoVisao == VISAONORMAL
						    //solucao normal inclui cada linha da conta gerencial
						    //em um novo elemento de aProcessa
						aAdd(aProcessa,aClone(aProcCube[nx]))
						If lMudaChave
							aProcessa[Len(aProcessa),1]	:=	cCO+aProcessa[Len(aProcessa),1]
						Endif
						aProcessa[Len(aProcessa),11] := nPai
						aAdd(aProcessa[Len(aProcessa)],"0") // Adiciona elemento - IDTIMP
						aAdd(aProcessa[Len(aProcessa)],AKO->AKO_ORDEM) // Adiciona elemento - ORDEM
						aAdd(aProcessa[Len(aProcessa)],cOperac) // Adiciona elemento - sinal
							//
        				ElseIf cModoVisao == VISAOCONSOL
                            	
                           	cChavAux := If(lMudaChave, cCO+aProcCube[nX,1], aProcCube[nX,1])

							If ( nPosProc := Ascan(aProcessa, {|aVal| aVal[1] == cChavAux .And. aVal[11] == nPai}) ) == 0 //se nao achou a chave nesta conta gerencial
								aAdd(aProcessa,aClone(aProcCube[nx]))
								// Inverte o sinal caso o operador seja negativo
								For nZ := 1 TO Len(aProcCube[nx,2])
									aProcessa[Len(aProcessa),2,nZ] := If(cOperac == "1", aProcCube[nx,2,nZ], aProcCube[nx,2,nZ]*-1)
								Next
								aProcessa[Len(aProcessa),1]	:=	cChavAux
								aProcessa[Len(aProcessa),11] := nPai
								aAdd(aProcessa[Len(aProcessa)],"0") // Adiciona elemento - IDTIMP
								aAdd(aProcessa[Len(aProcessa)],AKO->AKO_ORDEM) // Adiciona elemento - ORDEM
								aAdd(aProcessa[Len(aProcessa)],cOperac) // Adiciona elemento - sinal
							Else 	//se achou a chave nesta conta gerencial
								For nZ := 1 TO Len(aProcCube[nx,2])
									aProcessa[nPosProc,2,nZ] += If(cOperac == "1", aProcCube[nx,2,nZ], aProcCube[nx,2,nZ]*-1)
								Next
							EndIf
						EndIf	
					EndIf
					Cubo_Totaliza(aProcessa, nPai, aProcCube[nx,2],cOperac)
				Else
					If nDetCubos == 1
						If cModoVisao == VISAONORMAL
						    //solucao normal inclui cada linha da conta gerencial
						    //em um novo elemento de aProcessa
						aAdd(aProcessa,aClone(aProcCube[nx]))
						If lMudaChave
							aProcessa[Len(aProcessa),1]	:=	cCO+aProcessa[Len(aProcessa),1]
						Endif
						aProcessa[Len(aProcessa),11] := nPai
						aAdd(aProcessa[Len(aProcessa)],"0") // Adiciona elemento - IDTIMP
						aAdd(aProcessa[Len(aProcessa)],AKO->AKO_ORDEM) // Adiciona elemento - ORDEM
						aAdd(aProcessa[Len(aProcessa)],cOperac) // Adiciona elemento - sinal
							//
						ElseIf cModoVisao == VISAOCONSOL
                            	
                           	cChavAux := If(lMudaChave, cCO+aProcCube[nX,1], aProcCube[nX,1])

							If ( nPosProc := Ascan(aProcessa, {|aVal| aVal[1] == cChavAux .And. aVal[11] == nPai}) ) == 0 //se nao achou a chave nesta conta gerencial
								aAdd(aProcessa,aClone(aProcCube[nx]))
								// Inverte o sinal caso o operador seja negativo
								For nZ := 1 TO Len(aProcCube[nx,2])
									aProcessa[Len(aProcessa),2,nZ] := If(cOperac == "1", aProcCube[nx,2,nZ], aProcCube[nx,2,nZ]*-1)
								Next
								aProcessa[Len(aProcessa),1]	:=	cChavAux
								aProcessa[Len(aProcessa),11] := nPai
								aAdd(aProcessa[Len(aProcessa)],"0") // Adiciona elemento - IDTIMP
								aAdd(aProcessa[Len(aProcessa)],AKO->AKO_ORDEM) // Adiciona elemento - ORDEM
								aAdd(aProcessa[Len(aProcessa)],cOperac) // Adiciona elemento - sinal
							Else 	//se achou a chave nesta conta gerencial
								For nZ := 1 TO Len(aProcCube[nx,2])
									aProcessa[nPosProc,2,nZ] += If(cOperac == "1", aProcCube[nx,2,nZ], aProcCube[nx,2,nZ]*-1)
								Next
							EndIf
						EndIf	
					EndIf
				EndIf
			Next
		EndIf
		cItem := AKP->AKP_ITEM
		cOperac := AKP->AKP_OPERAC
	EndDo
Else
	dbSelectArea("AKO")
	dbSetOrder(2)
	dbSeek(xFilial()+cVisao+cCO)
	While !Eof() .And. xFilial()+cVisao+cCO==AKO->AKO_FILIAL+AKO->AKO_CODIGO+AKO->AKO_COPAI
		ProcJobVisCube(cVisao,AKO->AKO_CO,nQtdVal,cProcessa,cConfig,nViewCFG,aAuxTot,nPai,aProcessa,nDetCubos,,aIniCfg,aFimCfg,aFilCfg,lMudaChave,aTamNiv)
		dbSkip()
	End
EndIf

RestArea(aAreaAKO)
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัอออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณProcJobRunCubeบAutor ณ Paulo Carnelossi  บ Data ณ 26/09/07  บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯอออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que cria as tabelas temporarias e os jobs que irao   บฑฑ
ฑฑบ          ณexecutar a PcoRunCube() e controla a finalizacao dos jobs   บฑฑ
ฑฑบ          ณexibindo tela de monitoracao                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ProcJobRunCube(aVarPriv, lErro)
Local nX, nLenJob, nCtdEspera, nJobExec := 0
Local cArqTmp, cArqProc, cArqNiv := ""	
Local lProcManual := .F.
Local aProcCube, aNiveis  //armazena resultado final - joga dos arquivos para array
Local b_Db_Refresh := {|nTempo|	Sleep(nTempo ), ; //segurar processamento para deixar job(s) terminar
								dbSelectArea("TMPJOB"), ;
								dbGoTop() }

nLenJob := Len(aParamJob)  //qtde total de tarefas a ser executada por n jobs

If nLenJob <= 3 //entao nao executa job, pois custo nao compensa

	lProcManual := .T.

Else

    //funcao que cria as tabelas temporarias
	JobCriaTmp(@cArqTmp, @cArqProc, @cArqNiv)	
	
	//grava arquivo de controle da execucao dos jobs
	dbSelectArea("TMPJOB")
	nJobExec := 1

	For nX := 1 TO nLenJob
	
		RecLock("TMPJOB", .T.)
		TMPJOB->JOB_ID 	:= StrZero(nX, 6)
		TMPJOB->JOB_CHAVE 	:= aChaveJob[nX]  //chave
		TMPJOB->JOB_STATUS 	:= "0"        //status
		TMPJOB->JOB_EXEC 	:= nJobExec  //job que ira realizar a tarefa
		TMPJOB->JOB_INICIO 	:= Time()
		MsUnLock()
		nJobExec++
		If nJobExec > NUM_JOBEXEC
			nJobExec := 1
		EndIf
	
	Next
	
    //parametros que serao repassados ao job
	aParamAux := {cEmpAnt,cFilAnt,cArqTmp,cArqProc,cArqNiv,aParamJob,aVarPriv}
	aJobOk := {}

	MsAguarde( {|| IniciaJob(cArqTmp, "PcoJobAux", aParamAux, aJobOk)} )

	If Empty(aJobOK)
		Conout(STR0012)//"Erro - Nao iniciado os jobs, sera processado em modo normal."
		lProcManual := .T.
	Else
		Eval(b_Db_Refresh, Min(1000*Len(aJobOk), 3000) )
	EndIf

	//aguarda ate que todos os registros sejam processados com sucesso
	nCtdEspera := 0
	lContinua  := .T.
	
	While lContinua
	
		nCtdEspera++
		If nCtdEspera == NUM_ESPERA
			lErro := .T.
			Conout(STR0013)  // "Erro no Processamento. Tente mais tarde ! "
			Exit
		EndIf
        
		//exibe tela do monitor das tarefas em execucao pelos jobs
		LogProc(cArqTmp, Date(), Time(), nLenJob)
		
        //verifica se existem tarefas em execucao
        //qdo nao existirem mais sai fora do loop
		lContinua := C360AguardaJob(cArqTmp)
		
		If lContinua  //se existe - da 5 milisegundos 
			Sleep(5000)
		EndIf

	EndDo
	
	If !lProcManual .And. !lErro
	
		//aguarda todos os jobs finalizarem
		lContinua := .T.
		While lContinua
			aChkJob := {}
			For nX := 1 TO Len(aJobOK)
				aAdd(aChkJob, .F.)
				If JobVerStatus( aJobOK[nX] ) == JOB_FINALIZADO_OK
					aChkJob[Len(aChkJob)] := .T.
				EndIf
		    Next
   			For nX := 1 TO Len(aJobOK)
   				If ! aChkJob[nX]
   					Sleep(1000)
   					Exit
   				Else
   					If nX == Len(aJobOk)
   						//quando todos os jobs ja terminaram encerra
   						lContinua := .F.
   					EndIf		
   				EndIf
   			Next	
		EndDo
		
		//agora carrega os resultados processados no job para os arrays
		//usa dbGoTop() para dar refresh na base de dados
		
		JobCloseAllArq() //fecha os arquivos temporarios
		//arquivo que contem o array aProcessa gravado em tabela p/job
		dbUseArea(.T., "TOPCONN",cArqProc,"TMPPROC",.T.,.F.)
		//IndRegua("TMPPROC",cArqProc,"PROC_ID+PROC_ELEM",,)
		//arquivo que contem o array aNiveis gravado em tabela p/ job
		dbUseArea(.T., "TOPCONN",cArqNiv,"TMPNIV",.T.,.F.)
		//IndRegua("TMPNIV",cArqNiv,"NIV_ID+NIV_ELEM",,)
		
		dbSelectArea("TMPPROC")
		dbGoTop()   
	
		dbSelectArea("TMPNIV")
		dbGoTop()
        //laco for para popular array aResultJob (aProcessa) gravado na tabela p/ jobs
		For nX := 1 TO nLenJob
	        aProcCube := aClone({})
	        aNiveis   := aClone({})
	        nId := nX
			PcoRecupCubo(nId,aProcCube, cArqProc)   //recupera o = aProcessa
			PcoRecupNiv(nId,aNiveis, cArqNiv)   //recupera o  = aNiveis
			aAdd(aResultJob, aClone(aProcCube))
			aAdd(aNiveisJob, aClone(aNiveis))
		Next
		
	EndIf

	//fecha e apaga os arquivos utilizados nos jobs
	JobCloseAllArq()
	JobClearAllArq()

	//libera o semaforo ativado pela funcao de iniciacao de jobs
	For nX := 1 TO Len(aJobOk)
		JobUnLockNome( aJobOk[nX] )
	Next
	
EndIf	

//se tarefas for menor ou igual a 3 faz o processamento PcoRunCube() normal 
//sem utilizacao de jobs
If lProcManual

	For nX := 1 TO nLenJob
		//processa o cubo
		aNiveis := {}
		aProcCube := PcoRunCube( 	aParamJob[nX, 1] /*AKL->AKL_CUBE*/		, ;
									aParamJob[nX, 2] /*nQtdVal*/			, ;
									aParamJob[nX, 3] /*cProcessa*/			, ;
									aParamJob[nX, 4] /*cConfig*/			, ;
									aParamJob[nX, 5] /*nViewCFG*/			, ;
									aParamJob[nX, 6] /*.F.    */			, ;
									aNiveis									, ;
									aParamJob[nX, 8] /*aFilIni*/			, ;
									aParamJob[nX, 9] /*aFilFim*/			, ;
									aParamJob[nX,10] /*lReserv*/			, ;
									aParamJob[nX,11] /*aCfgCube*/			, ;
									aParamJob[nX,12] /*.F. lProcessa*/		, ;
									aParamJob[nX,13] /*.F. lVerAcesso*/		, ;
									aParamJob[nX,14] /*.T. lForceNoSint*/	, ;
									aParamJob[nX,15] /*aItCfgBlq*/			, ;
									aParamJob[nX,16] /*aFiltros*/			, ;
									aParamJob[nX,17] /*cArqAKT*/ 			, ;
									aParamJob[nX,18] /*lLimpArqAKT*/ 		, ;
									aParamJob[nX,19] /*lVisao*/ 		) // Processa o cubo
		aAdd(aResultJob, aClone(aProcCube))
		aAdd(aNiveisJob, aClone(aNiveis))
	Next
	
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณJobCriaTmp บAutor  ณPaulo Carnelossi   บ Data ณ  26/09/07   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria os arquivos temporarios diretamente no banco           บฑฑ
ฑฑบ          ณTMPJOB -> lista das chaves a ser processada pelo job        บฑฑ
ฑฑบ          ณTMPPROC -> tabela que contera o retorno da execucao da      บฑฑ
ฑฑบ          ณ           PcoRunCube() - aProcessa                         บฑฑ
ฑฑบ          ณTMPNIV -> tabela que contera o array aNiveis passada na     บฑฑ
ฑฑบ          ณ            execucao da PcoRunCube()                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function JobCriaTmp(cArqTmp, cArqProc, cArqNiv)
Local aStruct := {}   //estrutura para controle das tarefas dos jobs
Local aStruProc := {} //armazena resultado da pcoruncube - aProcessa
Local aStruNiv := {} //armazena resultado da pcoruncube - aNiveis

//definir a estrutura dos arquivo temporarios / q vai ser passado para todos os jobs
aAdd(aStruct, {"JOB_ID"		, "C", 6, 0})
aAdd(aStruct, {"JOB_CHAVE"	, "C", 50, 0})  //chave a ser processada
aAdd(aStruct, {"JOB_STATUS"	, "C", 1, 0})
aAdd(aStruct, {"JOB_EXEC"	, "N", 10, 0})
aAdd(aStruct, {"JOB_INICIO"	,"C", 08, 00})
aAdd(aStruct, {"JOB_FIM" 	,"C", 08, 00})
aAdd(aStruct, {"JOB_DURAC"	,"C", 08, 00})

// Cria a tabela temporia direto no banco de dados	                					
If _oCubeVis1 <> Nil
	_oCubeVis1:Delete()
	_oCubeVis1:=Nil
EndIf
_oCubeVis1 := FWTemporaryTable():New( "TMPJOB" )  
_oCubeVis1:SetFields(aStruct) 
_oCubeVis1:AddIndex("1", {"JOB_ID","JOB_CHAVE"})
_oCubeVis1:Create()
Sleep(1000)

cArqTmp := _oCubeVis1:GetRealName()

aAdd(aStruProc, {"PROC_ID"		, "C", 30, 0})
aAdd(aStruProc, {"PROC_ELEM" 	, "N", 5, 0})
aAdd(aStruProc, {"PROC_TIPO"	, "C", 1, 0})
aAdd(aStruProc, {"PROC_CONTE"	, "C", 100, 0})

// Cria a tabela temporia direto no banco de dados	                					
If _oCubeVis2 <> Nil
	_oCubeVis2:Delete()
	_oCubeVis2:=Nil
EndIf
_oCubeVis2 := FWTemporaryTable():New( "TMPPROC" )  
_oCubeVis2:SetFields(aStruProc) 
_oCubeVis2:AddIndex("1", {"PROC_ID","PROC_ELEM"})
_oCubeVis2:Create()
Sleep(1000)

cArqProc := _oCubeVis2:GetRealName()

/*
//bloco comentado se for necessario criar arquivo local no diretorio SYSTEM
cArqProc := CriaTrab(aStruProc,.t.)
dbUseArea(.T.,,cArqProc,"TMPPROC",.F.,.F.)
dbSelectArea("TMPPROC")
IndRegua("TMPPROC",cArqProc,"TMPPROC->PROC_ID",,,"Selecionando Registros...")
dbClearIndex()
dbCloseArea()
dbUseArea(.T.,,cArqProc,"TMPPROC",.T.,.F.)
dbSetIndex(cArqProc+OrdBagExt())
dbSetOrder(1)
*/
aAdd(aStruNiv, {"NIV_ID"	, "C", 30, 0})
aAdd(aStruNiv, {"NIV_ELEM" 	, "N", 10, 0})
aAdd(aStruNiv, {"NIV_TIPO"	, "C", 1, 0})
aAdd(aStruNiv, {"NIV_CONTE"	, "C", 100, 0})

// Cria a tabela temporia direto no banco de dados	                					
If _oCubeVis3 <> Nil
	_oCubeVis3:Delete()
	_oCubeVis3:=Nil
EndIf
_oCubeVis3 := FWTemporaryTable():New( "TMPNIV" )  
_oCubeVis3:SetFields(aStruNiv) 
_oCubeVis3:AddIndex("1", {"NIV_ID","NIV_ELEM"})
_oCubeVis3:Create()
Sleep(1000)

cArqNiv := _oCubeVis3:GetRealName()

/*
//bloco comentado se for necessario criar arquivo local no diretorio SYSTEM
cArqNiv := CriaTrab(aStruNiv,.t.)
dbUseArea(.T.,,cArqNiv,"TMPNIV",.F.,.F.)
dbSelectArea("TMPNIV")
IndRegua("TMPNIV",cArqNiv,"TMPNIV->NIV_ID",,,"Selecionando Registros...")
dbClearIndex()
dbCloseArea()
dbUseArea(.T.,,cArqNiv,"TMPNIV",.T.,.F.)
dbSetIndex(cArqNiv+OrdBagExt())
dbSetOrder(1)
*/

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหออออออัออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณJobCloseAllArq บAutor ณ Paulo Carnelossi บ Data ณ 26/09/07  บฑฑ
ฑฑฬออออออออออุอออออออออออออออสออออออฯออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณverifica se as tabelas temporarias estao abertas e fecha    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function JobCloseAllArq()

If Select("TMPPROC") > 0
	dbSelectArea("TMPPROC")
	dbCloseArea()
EndIf	

If Select("TMPNIV") > 0
	dbSelectArea("TMPNIV")
	dbCloseArea()
EndIf	
	
If Select("TMPJOB") > 0
	dbSelectArea("TMPJOB")
	dbCloseArea()   
EndIf	

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหออออออัออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณJobClearAllArq บAutor ณ Paulo Carnelossi บ Data ณ 26/09/07  บฑฑ
ฑฑฬออออออออออุอออออออออออออออสออออออฯออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณapaga asas tabelas temporarias utilizada por jobs           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function JobClearAllArq()
//excluir os arquivos temporarios gerados
If _oCubeVis1 <> Nil
	_oCubeVis1:Delete()
	_oCubeVis1:=Nil
EndIf
If _oCubeVis2 <> Nil
	_oCubeVis2:Delete()
	_oCubeVis2:=Nil
EndIf
If _oCubeVis3 <> Nil
	_oCubeVis3:Delete()
	_oCubeVis3:=Nil
EndIf
/*
//apaga estes arquivos quando e gerado local no diretorio SYSTEM
Ferase(AllTrim(cArqProc)+GetDBExtension())
Ferase(AllTrim(cArqProc)+OrdBagExt())
Ferase(AllTrim(cArqNiv)+GetDBExtension())
Ferase(AllTrim(cArqNiv)+OrdBagExt())
*/
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณPcoJobAux  บ Autor ณ Paulo Carnelossi   บ Data ณ  26/09/07  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao chamada por StartJob para processar a PcoRunCube()   บฑฑ
ฑฑบ          ณem jobs                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PcoJobAux(aParamAux)
Local cEmprAux	:= aParamAux[1,1]
Local cFilAux	:= aParamAux[1,2]
Local cArqTmp	:= aParamAux[1,3]
Local cArqProc	:= aParamAux[1,4]
Local cArqNiv	:= aParamAux[1,5]
Local aParJob   := aParamAux[1,6]
Local aVarPriv  := aParamAux[1,7]
Local cNomeJob  := aParamAux[2]
Local nId
Local aParam
Local aProcCube := {}, aNiveis := {}, nX
Local cVar, cConteudo
Local nJobExec, nJobProc
Local cHoraIni, cHoraFim, cDuracao
Local nQtdJobs := Len(aParJob)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ STATUS 1 - Iniciando execucao do Job						 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
JobAtualizaStatus(cNomeJob, JOB_INICIANDO)
RpcSetType( 3 )
RpcSetEnv( cEmprAux, cFilAux,,,'PCO' )

//fica aguardando ateh q todos os jobs subam
JobAtualizaStatus(cNomeJob, JOB_AGUARDA_CARGA)
While !KillApp() .And. JobVerStatus( cNomeJob ) == JOB_AGUARDA_CARGA
	Sleep(3000)
EndDo

//declara variaveis private necessaria para execucao da rotina
For nX := 1 TO Len(aVarPriv)
	cVar := aVarPriv[nX, 1]	
	cConteudo := If( Valtype(aVarPriv[nX,2])=="A", aClone(aVarPriv[nX,2]), aVarPriv[nX,2] )
	STORE cConteudo TO &cVar 
Next

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ STATUS 2 - Conexao efetuada com sucesso 					 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
JobAtualizaStatus(cNomeJob, JOB_EXECUTANDO)
cHoraIni := Time()
ConOut( LINHA )
ConOut( cNomeJob+" - "+STR0014+": "+DToC(Date())+" - "+cHoraIni )  //"Inicio"
ConOut( LINHA )

//abre os arquivos temporarios
dbUseArea(.T.,"TOPCONN",cArqTmp,"TMPJOB",.T.,.F.)

If Select("TMPJOB") > 0

	dbUseArea(.T.,"TOPCONN",cArqProc,"TMPPROC",.T.,.F.)

	If Select("TMPPROC") > 0

		dbUseArea(.T.,"TOPCONN",cArqNiv,"TMPNIV",.T.,.F.)
		
		If Select("TMPNIV") > 0

			nJobExec := Int(VAL(Right(cNomeJob,6)))
			dbSelectArea("TMPJOB")
			//filtra as tarefas que estao com status  a executar
			SET FILTER TO TMPJOB->JOB_STATUS == '0'	
			nJobProc := 0
			dbGoTop()
			
			While TMPJOB->( ! Eof() .And. ! Bof() )
			
				Sleep(5)  //para outros jobs poderem processar tambem
				nId := Val( TMPJOB->JOB_ID )
				nJobProc++

		    	If Int(TMPJOB->JOB_EXEC) == Int(nJobExec) .And. TMPJOB->JOB_STATUS == "0"
		    		If RLock()  //se lockar mudar status para 1 - em processamento
						TMPJOB->JOB_STATUS := "1"
						dbCommit()
						//processa o cubo
						aParam  := aParJob[ nId ]
						aNiveis := {}
						aProcCube := PcoRunCube( 	;
												aParam[ 1] /*AKL->AKL_CUBE*/	, ;
												aParam[ 2] /*nQtdVal*/			, ;
												aParam[ 3] /*cProcessa*/		, ;
												aParam[ 4] /*cConfig*/			, ;
												aParam[ 5] /*nViewCFG*/			, ;
												aParam[ 6] /*.F.    */			, ;
												aNiveis							, ;
												aParam[ 8] /*aFilIni*/			, ;
												aParam[ 9] /*aFilFim*/			, ;
												aParam[10] /*lReserv*/			, ;
												aParam[11] /*aCfgCube*/			, ;
												aParam[12] /*.F. lProcessa*/	, ;
												aParam[13] /*.F. lVerAcesso*/	, ;
												aParam[14] /*.T. lForceNoSint*/	, ;
												aParam[15] /*aItCfgBlq*/		, ;
												aParam[16] /*aFiltros*/			, ;
												aParam[17] /*cArqAKT*/			, ;
												aParam[18] /*lLimpArqAKT*/ 		, ;
												aParam[19] /*lVisao*/ 		) // Processa o cubo

						//armazena o resultado nos arquivos temporarios
						PcoArmazCubo(nId,aClone(aProcCube))
						PcoArmazNiv(nId,aClone(aNiveis))
		
						dbSelectArea("TMPJOB")
						//atualiza status e campos duracao
						TMPJOB->JOB_STATUS := "2"
						TMPJOB->JOB_FIM	:= Time()						
						TMPJOB->JOB_DURAC := ElapTime(TMPJOB->JOB_INICIO, TMPJOB->JOB_FIM)
						dbCommit()
					EndIf
					MsUnLock()	
				EndIf

				TMPJOB->(dbSkip())

			EndDo

			//apos processar as tarefas referente ao job fecha os arquivos		
			JobCloseAllArq()
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ  STATUS 3 - Processamento finalizado com sucesso			 ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			JobAtualizaStatus(cNomeJob, JOB_FINALIZADO_OK)

        EndIf
        
	EndIf

EndIf

RpcClearEnv()

If JobVerStatus( cNomeJob ) == JOB_FINALIZADO_OK
	cHoraFim := Time()
	cDuracao := ElapTime( cHoraIni, cHoraFim )
	ConOut( LINHA )
	ConOut( cNomeJob+" - "+STR0015+": "+DToC(Date())+" - "+cHoraFim+" - "+STR0016+": "+cDuracao )  //"Fim"##"Tempo"
	ConOut( LINHA )
Else
	ConOut( LINHA )
	ConOut( cNomeJob+" - "+STR0017 )  //"Erro de Conexao."
	ConOut( LINHA )
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ  STATUS 4 - Falha na conexao                       			 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	JobAtualizaStatus(cNomeJob, JOB_NOCONECTION)
EndIf

KillApp(.T.)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoArmazCubo บAutor ณ Paulo Carnelossi บ Data ณ  26/09/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออสออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณArmazena o array aProcCube que e o retorno da PcoRunCube()  บฑฑ
ฑฑบ          ณem tabela temporaria no banco de dados para posterior       บฑฑ
ฑฑบ          ณrecuperacao                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PcoArmazCubo(nId,aProcCube)
Local cChave
cChave := StrZero(nId,6)
PcoAuxCubo(cChave, aClone(aProcCube))

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoAuxCubo   บAutor ณ Paulo Carnelossi บ Data ณ  26/09/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออสออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAuxilia a execucao da funcao que rmazena o array aProcCube  บฑฑ
ฑฑบ          ณem tabela temporaria no banco de dados para posterior       บฑฑ
ฑฑบ          ณrecuperacao - Recursiva                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PcoAuxCubo(cChave, aProcCube)

Local nZ, xConteudo

For nZ := 1 TO Len(aProcCube)
	dbSelectArea("TMPPROC")
	RecLock("TMPPROC", .T.)
	TMPPROC->PROC_ID 	:= cChave
	TMPPROC->PROC_ELEM  	:= nZ
	TMPPROC->PROC_TIPO 	:= ValType(aProcCube[nZ])
	
	If 		TMPPROC->PROC_TIPO  == "C"
		xConteudo := aProcCube[nZ]
	ElseIf	TMPPROC->PROC_TIPO  == "N"
		xConteudo := Str(aProcCube[nZ], 15, 2)
	ElseIf	TMPPROC->PROC_TIPO  == "L"
		xConteudo := If(aProcCube[nZ], "1", "0")
	ElseIf	TMPPROC->PROC_TIPO  == "A"
		If Empty(aProcCube[nZ])
			xConteudo := Repl("*",20)
		Else
			xConteudo := ""	
		EndIf	
	Else
		xConteudo := aProcCube[nZ]
	EndIf		
	TMPPROC->PROC_CONTE  	:= xConteudo
	MsUnLock()

	If Empty(xConteudo) .And. TMPPROC->PROC_TIPO  == "A"
	    //recursividade para gravar o array
		PcoAuxCubo(cChave+StrZero(nZ,5), aClone(aProcCube[nZ]))
    EndIf

Next

Return(NIL)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoArmazNiv  บAutor ณ Paulo Carnelossi บ Data ณ  26/09/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออสออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณArmazena o array aNiveis que e processado na PcoRunCube()   บฑฑ
ฑฑบ          ณem tabela temporaria no banco de dados para posterior       บฑฑ
ฑฑบ          ณrecuperacao                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PcoArmazNiv(nId,aNiveis)
Local cChave
cChave := StrZero(nId,6)
PcoAuxNiv(cChave, aClone({aNiveis}))

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoAuxNiv  บAutor ณ Paulo Carnelossi   บ Data ณ  26/09/07   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao auxiliar que armazena o array aNiveis que e processa-บฑฑ
ฑฑบ          ณdo na PcoRunCube()em tabela temporaria no banco de dados    บฑฑ
ฑฑบ          ณpara posterior recuperacao                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PcoAuxNiv(cChave, aNiveis)

Local nZ, xConteudo
Local aArea := GetArea()

For nZ := 1 TO Len(aNiveis)
	dbSelectArea("TMPNIV")
	RecLock("TMPNIV", .T.)
	TMPNIV->NIV_ID 	:= cChave
	TMPNIV->NIV_ELEM  	:= nZ
	TMPNIV->NIV_TIPO 	:= ValType(aNiveis[nZ])
	
	If 		TMPNIV->NIV_TIPO  == "C"
		xConteudo := aNiveis[nZ]
	ElseIf	TMPNIV->NIV_TIPO  == "N"
		xConteudo := Str(aNiveis[nZ], 15, 2)
	ElseIf	TMPNIV->NIV_TIPO  == "L"
		xConteudo := If(aNiveis[nZ], "1", "0")
	ElseIf	TMPNIV->NIV_TIPO  == "A"
		If Empty(aNiveis[nZ])
			xConteudo := Repl("*",20)
		Else
			xConteudo := ""	
			PcoAuxNiv(cChave+StrZero(nZ,5), aClone(aNiveis[nZ]))
		EndIf	
	Else
		xConteudo := aNiveis[nZ]
	EndIf		
	RecLock("TMPNIV", .F.)
	TMPNIV->NIV_CONTE  	:= xConteudo
	MsUnLock()

Next

RestArea(aArea)

Return(NIL)

Static Function PcoRecupCubo(nId,aProcCube, cArqProc)
Local cChave
cChave := StrZero(nId,6)
PcoCarCubo(cChave, aProcCube, cArqProc)

Return(NIL)

Static Function PcoCarCubo(cChave, aProcCube, cArqProc)
Local nElem, cTipo, xConteudo
Local aArea := GetArea()
Local aAreaProc := TMPPROC->(GetArea())

dbSelectArea("TMPPROC")
If dbSeek(PadR(cChave,Len(TMPPROC->PROC_ID)))
	
	While TMPPROC->(! Eof() .AND. PROC_ID == PadR(cChave,Len(TMPPROC->PROC_ID)))
	
		nElem  	:= TMPPROC->PROC_ELEM
		cTipo 	:= TMPPROC->PROC_TIPO
		
		If 		cTipo  == "C"
			xConteudo := AllTrim(TMPPROC->PROC_CONTE)
		ElseIf	cTipo  == "N"
			xConteudo := Val(AllTrim(TMPPROC->PROC_CONTE))
		ElseIf	cTipo  == "L"
			xConteudo := If(AllTrim(TMPPROC->PROC_CONTE)=="1", .T., .F.)
		ElseIf	cTipo  == "A"
			If AllTrim(TMPPROC->PROC_CONTE) == Repl("*",20)
				xConteudo := aClone({})
			Else
				xConteudo := aClone({})
				PcoCarCubo(cChave+StrZero(nElem,5), xConteudo)
			EndIf	
		EndIf
	    aAdd(aProcCube, xConteudo)
	    
	    TMPPROC->(dbSkip())
	    
	EndDo
	
EndIf

RestArea(aAreaProc)
RestArea(aArea)

Return(NIL)


Static Function PcoRecupNiv(nId, aNiveis, cArqNiv)
Local cChave, aRetorno := {}
cChave := StrZero(nId,6)
PcoCarNiv(cChave, aRetorno, cArqNiv)

If ! Empty(aRetorno)
	aNiveis := aClone(aRetorno[1])
EndIf
	
Return

Static Function PcoCarNiv(cChave, aNiveis, cArqNiv)

Local nElem, cTipo, xConteudo
Local aArea := GetArea()
Local aAreaNiv := TMPNIV->(GetArea())


dbSelectArea("TMPNIV")
If dbSeek(PadR(cChave,Len(TMPNIV->NIV_ID)))

	While TMPNIV->(! Eof() .AND. NIV_ID == PadR(cChave,Len(TMPNIV->NIV_ID)))

		nElem  	:= TMPNIV->NIV_ELEM
		cTipo 	:= TMPNIV->NIV_TIPO
		
		If 		cTipo  == "C"
			xConteudo := AllTrim(TMPNIV->NIV_CONTE)
		ElseIf	cTipo  == "N"
			xConteudo := Val(AllTrim(TMPNIV->NIV_CONTE))
		ElseIf	cTipo  == "L"
			xConteudo := If(AllTrim(TMPNIV->NIV_CONTE)=="1", .T., .F.)
		ElseIf	cTipo  == "A"
			If AllTrim(TMPNIV->NIV_CONTE) == Repl("*",20)
				xConteudo := aClone({})
			Else
				xConteudo := aClone({})
				PcoCarNiv(cChave+StrZero(nElem,5), xConteudo)
			EndIf	
		EndIf
	    aAdd(aNiveis, xConteudo)

	    TMPNIV->(dbSkip())
	    
	EndDo

EndIf

RestArea(aAreaNiv)
RestArea(aArea)

Return(NIL)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIniciaJob บAutor  ณPaulo Carnelossi    บ Data ณ  26/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInicia os jobs que irao processar PcoRunCube()              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function IniciaJob(cArquivo, cRotina, aParamAux, aJobOk)	

Local nX, lRet := .F.
Local lCont, nVezesAbre, nVezesCon
Local aListaJob := {}
Local cStatusJob, nRunJobs := 0

For nX := 1 To NUM_JOBEXEC
    
	cNomeJob:=""
	JobLockNome(cArquivo, StrZero(nX, 6)/*cId*/, @cNomeJob)

	If ! Empty(cNomeJob)
	
		// Inicializa variavel global de controle do Job
		// 0 = nao subiu ainda
		JobAtualizaStatus(cNomeJob, JOB_A_EXECUTAR)
		
		aAdd(aListaJob, cNomeJob)
		
		StartJob( cRotina, GetEnvServer(), .F., { aParamAux, cNomeJob } )
		nRunJobs++
		Sleep(1000)
		                                       		
	EndIf	
	
Next

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se o JOB esta no "ar" 								 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
IncProc(STR0022)  //"Verificando status dos Jobs..."
Sleep(1000*Len(aListaJob))

For nX :=1 To Len(aListaJob)

	lCont 		:= .T.
	nVezesAbre  := 1     
	nVezesCon	:= 1
	
	While lCont
	
		cStatusJob	:= JobVerStatus( aListaJob[nX] )

		Do Case

			// Verifica se o Job subiu
			Case cStatusJob == JOB_A_EXECUTAR

				If nVezesAbre >= 50

					ConOut( LINHA )
					ConOut( STR0018 + aListaJob[nX] )  //"Nao foi possivel subir Job:"
					ConOut( LINHA )
					lCont := .F.

			    Else

					nVezesAbre ++

				EndIf
		
			// Verifica se conseguiu se conectar
			Case cStatusJob == JOB_INICIANDO
			
				Sleep(5000) 

				If nVezesCon >= 10

					ConOut( LINHA )
					ConOut( STR0017 +" ---> " + aListaJob[nX] )  //"Erro de conexao "
					ConOut( STR0019 )  //"Numero de tentativas excedido"
					ConOut( LINHA )
					lCont := .F.

				Else

					If nVezesCon >= 5

			    		If Empty(aJobOk)

							ConOut( LINHA )
							ConOut( STR0017+" --> " + aListaJob[nx] )  //"Erro de conexao"
							ConOut( STR0020 + StrZero(nVezesCon,2) )  //"Tentativa numero: "
							Conout( STR0021 )  //"Nova tentativa sera realizada." 
							Conout( LINHA )      

				    		// Inicializa variavel global de controle de Job
							JobAtualizaStatus(aListaJob[nX], JOB_A_EXECUTAR)

							// Reinicia o JOB para tentar conectar novamente
							StartJob( cRotina, GetEnvServer(), .F., { aParamAux, aListaJob[nX]} )
							Sleep(1000)
						EndIf	
						
                    EndIf
                    
				EndIf
				
				nVezesCon++

			// Verifica se o Job falhou entao eh pq os outros ja terminaram processamento
			// e este nao consegue mais abrir o arquivo compartilhado dos jobs pois realmente
			// eh desnecessario uma vez que todos ja foram processados
			Case cStatusJob == JOB_NOCONECTION
				lCont := .F.
				
			// Verifica se o Job esta ativo e aguardando start
			Case cStatusJob == JOB_AGUARDA_CARGA
				aAdd(aJOBOK ,aListaJob[nX])
				lCont := .F.
		
		EndCase

	EndDo

Next

lRet := ( Len(aJOBOK) == nRunJobs )

If lRet
	For nX := 1 TO Len(aJobOK)
		JobAtualizaStatus(aJobOK[nX], JOB_EXECUTANDO)
	Next
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออหอออออัอออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณJobAtualizaStatus บAutorณPaulo Carnelossi บ Data ณ 26/09/07 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออสอออออฯอออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณ Cria variavel global para controle de status do job        บฑฑ
ฑฑบ          ณ( serve tambem para atualizar )                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function JobAtualizaStatus(cNomeJob, cStatus)
PutGlbValue(cNomeJob, cStatus )
GlbUnLock()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหออออออัอออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณJobVerStatus บAutor ณ Paulo Carnelossi    บ Data ณ 26/09/07 บฑฑ
ฑฑฬออออออออออุอออออออออออออสออออออฯอออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna  status do job checkando a variavel global         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function JobVerStatus(cNomeJob)
Local cStatus
cStatus := GetGlbValue(cNomeJob)
Return(cStatus)

Static Function JobLockNome(cArquivo, cId, cNomeJob)
Local cString := Upper(GetPathSemaforo()+FunName()+"_"+cArquivo+"_"+cId)
Local lContinua := .T.
Local nTentativa := 0

While lContinua
    nTentativa++
	If nTentativa > 10
		Exit
	EndIf	
	If LockByName(cString,.T.,.T.,.T.)
		cNomeJob := cString
		lContinua := .F.
	Else
		Sleep(800)
	EndIf	
End

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณJobUnLockNomeบAutor ณPaulo Carnelossi  บ Data ณ  26/09/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออสออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTira o Lock do Nome do Job                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function JobUnLockNome(cNomeJob)
UnLockByName(cNomeJob,.T.,.T.,.T.)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณLogProc   บAutor  ณStanko              บ Data ณ  01/06/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monitoramento das tarefas em execucao p/ job				  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8 - Controladoria - CTB                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LogProc(cArquivo, dDtIni,cHrIni,nQtdCta)
Local aArea := GetArea()
Local oTimer
Local nTimeOut := 2000

Local oBrowse1
Local aDados1 := {}
Local aCpoTit1  := { STR0023, STR0024,STR0025,STR0026,STR0027,STR0028,STR0029,STR0030}                        
//"Data Inicio"##"Hora Inicio"##"Total"##"Processadas"##"% Realizado"##"Tempo"##"Restante"##"Estimativa"
Local aCampos1  := {}
Local aCpoCols1 := { 040, 040,040,040,040,040,040,040}

Local oBrowse2
Local aDados2 := {}

Local aCpoTit2  := { STR0031, STR0032,STR0024}//"Job"##"Chave"##"Hora Inicio"
Local aCampos2  := {}
Local aCpoCols2 := { 040, 120,040,040}

DEFINE MSDIALOG oDlg TITLE STR0033 From 1,1 To 20,95 OF oMainWnd   //"Monitor do Processamento"

aDados1 := aClone(CarregDad1(cArquivo, dDtIni,cHrIni,nQtdCta))
aDados2 := aClone(CarregDad2(cArquivo))

oBrowse1 := TWBrowse():New( 010, 005, 362, 030 , {|| { aCampos1 } }, aCpoTit1, aCpoCols1, oDlg, , , ,,,,,,,,,,"CT1", .T. )
oBrowse1:SetArray(aDados1)
oBrowse1:bLine := { || {aDados1[oBrowse1:nAt,1],aDados1[oBrowse1:nAt,2],aDados1[oBrowse1:nAt,3],aDados1[oBrowse1:nAt,4],aDados1[oBrowse1:nAt,5],aDados1[oBrowse1:nAt,6],aDados1[oBrowse1:nAt,7],aDados1[oBrowse1:nAt,8]}}
oBrowse1:LHSCROLL := .F. 

oBrowse2 := TWBrowse():New( 050, 005, 362, 065 , {|| { aCampos2 } }, aCpoTit2, aCpoCols2, oDlg, , , ,,,,,,,,,,"CT1", .T. )
oBrowse2:SetArray(aDados2)
oBrowse2:bLine := { || {aDados2[oBrowse2:nAt,1],aDados2[oBrowse2:nAt,2],aDados2[oBrowse2:nAt,3]}}
oBrowse2:LHSCROLL := .F. 

oTimer:= TTimer():New(nTimeOut,{|| oDlg:End()  },oDlg)
oTimer:Activate()

@ 125, 340 BUTTON STR0034      SIZE 30,13 PIXEL OF oDlg ACTION (oDlg:End())  //"Fechar"

ACTIVATE MSDIALOG oDlg CENTERED

RestArea(aArea)

Return Nil          

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณCarregDad1บAutor  ณStanko              บ Data ณ  01/06/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ														      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8 - Controladoria - CTB                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CarregDad1(cArquivo,dDtIni,cHrIni,nQtdCta)
Local aArea     := GetArea()
Local aRet 		:= {}
Local nQtdProc  := 0
Local cQuery 
Local nPercUtil, cTempoUtil, cTempoRest
Local nQtdRest, nAux
Local nHora, nMinu, nSeg

// Quantidade processada
cQuery := "SELECT COUNT(*) QTD FROM "+cArquivo+" WHERE JOB_STATUS IN ('1','2') "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQRY",.T.,.F.)
nQtdProc := TMPQRY->QTD       
dbCloseArea()
  
nPercUtil  := (nQtdProc * 100 ) / nQtdCta                
cTempoUtil := ElapTime( cHrIni, Time() )                

nQtdRest   := nQtdCta-nQtdProc
nAux := (nQtdRest * Secs(cTempoUtil) / nQtdProc)

nHora := int(nAux/3600)
nMinu := int(mod(nAux,3600)/60)
nSeg  := Int(nAux - ((nHora*3600)+(nMinu*60)))

cTempoRest := StrZero(nHora,2)+":"+StrZero(nMinu,2)+":"+StrZero(nSeg,2)

aAdd(aRet,{DToC(dDtIni),cHrIni,AllTrim(Str(nQtdCta)),AllTrim(Str(nQtdProc)),AllTrim(Transform(nPercUtil,"@E 999.99 %")),cTempoUtil,AllTrim(Str(nQtdRest)),cTempoRest})

RestArea(aArea)

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณCarregDad2บAutor  ณStanko              บ Data ณ  01/06/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ														      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8 - Controladoria - CTB                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CarregDad2(cArquivo)
Local aRet  := {{" "," "," ", " "}}
Local cQuery

cQuery := "SELECT JOB_ID, JOB_CHAVE, JOB_INICIO, JOB_FIM "
cQuery += "FROM "+cArquivo+" "
cQuery += "WHERE JOB_STATUS IN ('0','1') AND  JOB_INICIO <> ' ' AND JOB_FIM = ' ' "
cQuery += "ORDER BY 1, 2, 3, 4 "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQRY",.T.,.F.)

dbSelectArea("TMPQRY")
While !EOF()
	Aadd(aRet,{TMPQRY->JOB_ID, TMPQRY->JOB_CHAVE,TMPQRY->JOB_INICIO})
	dbSkip()
EndDo 
dbCloseArea()

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหออออออัออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณC360AguardaJob บAutor ณ Paulo Carnelossi บ Data ณ 26/09/07  บฑฑ
ฑฑฬออออออออออุอออออออออออออออสออออออฯออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Executa query checka se as tarefas foram executadas p/ job บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function C360AguardaJob(cArquivo)
Local cQuery, lRet

cQuery := " SELECT COUNT(1) QTDREC "
cQuery += " FROM "+cArquivo+" "
cQuery += " WHERE JOB_STATUS IN ('0','1')
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQRY",.T.,.F.)

dbSelectArea("TMPQRY")
If TMPQRY->QTDREC > 0
	lRet := .T.
Else
	lRet := .F.
EndIf	

dbCloseArea()

Return lRet
