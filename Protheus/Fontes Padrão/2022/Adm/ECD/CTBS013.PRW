#INCLUDE "PROTHEUS.CH"
#INCLUDE "ECD.CH"

//Compatibilização de fontes 30/05/2018

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ECDImpLivro³ Autor ³						  ³ Data ³ 		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Importa arquivos texto dos Diarios Auxiliares				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ECDImpLivro(cEmp, aFils, cArqTxt , cLayout , cNumOrdem , cNatureza, dDataIni,dDataFim,cCodRev,oTree,bIncTree,nSitPer,nNire,nFinEsc,cHashSub,cNireSub,nGrandePorte, nTipoECD,nPlanoCtaRef,cCodPla,dDtApur,cArqSubst,nMotSubst,nMudplc,nAmrPlR)

Local aArea    	:= GetArea()
Local cBuffer  	:= "" 							//armazena a linha inteiro do TXT
Local nRec	   	:= 0
Local cQuery   	:= ""
Local nConta   	:= 1
Local nQtdReg  	:= 0
Local nContLin 	:= 1  //contador de linha
Local aVetFil  	:= {} //vetor com todas as filiais
Local oProcess 	:= Nil
Local CodRev	:= ""
Local aParamEcd := Array(ECD_NUMCOLS)
Local lRet		:= .T.
Local cMotSubst := ""

Default cEmp			:= cEmpAnt
Default aFils     		:= {{.T.,cEmpAnt,cFilAnt,"","","E"}}
Default cArqTxt   		:= {}
Default cLayout   		:= ""
Default cNumOrdem 		:= ""
Default cNatureza 		:= ""
Default dDataIni  		:= Ctod("")
Default dDataFim		:= Ctod("")
Default cCodRev			:= ""
Default bIncTree   		:= {||.T.}

Default nSitPer 		:= AllTrim("")
Default nNire			:= 2
Default nFinEsc			:= 1
Default cHashSub		:= Space(40)
Default cNireSub		:= Space(11)
Default nGrandePorte 	:= 1
Default nTipoECD 		:= 1
Default nPlanoCtaRef 	:= 1
Default cCodPla 		:= ''
Default dDtApur			:= Ctod("")
Default cArqSubst		:= ""
Default nMotSubst		:= 0
Default nMudplc			:= 2
Default nAmrPlR			:= 2

aParamEcd[ ECD_CODEMP		] := cEmp 
aParamEcd[ ECD_AFILS		] := aFils
aParamEcd[ ECD_TIPOESC		] := 1
aParamEcd[ ECD_IND_ESC		] := 5
aParamEcd[ ECD_NUM_ORDEM	] := cNumOrdem
aParamEcd[ ECD_NATUREZA		] := cNatureza
aParamEcd[ ECD_DATA_INI		] := dDataIni
aParamEcd[ ECD_DATA_FIM		] := dDataFim
aParamEcd[ ECD_OUT_INSC		] := 1
aParamEcd[ ECD_SIT_ESP		] := 1
aParamEcd[ ECD_CONTA_INI	] := ""
aParamEcd[ ECD_CONTA_FIM	] := Replicate('Z',TamSx3("CT1_CONTA")[1] )
aParamEcd[ ECD_PROC_CUSTO	] := .F.
aParamEcd[ ECD_COD_BALPAT	] := ""
aParamEcd[ ECD_COD_DRE 		] := ""
aParamEcd[ ECD_FIN_ESC 		] := 1
aParamEcd[ ECD_EXISTNIRE	] := 2
aParamEcd[ECD_HASH_ESC_SUBST] := ""
aParamEcd[ECD_NIRE_ESC_SUBST] := ""
aParamEcd[ ECD_SEL_DLPA_DMPL] := 2
aParamEcd[ ECD_COD_DLPA		] := ""
aParamEcd[ ECD_COD_DMPL     ] := ""
aParamEcd[ ECD_COD_DFC      ] := ""
aParamEcd[ ECD_COD_DVA      ] := ""
aParamEcd[ ECD_CAD_FATO_CTB ] := 2
aParamEcd[ ECD_DET_FATO_CTB ] := 2

If lLeiaute2
	aParamEcd[ECD_INDSITPER] 		:= Alltrim(Str(nSitPer - 1))   	//0-Inicio no primeiro dia do ano;1-Abertura;2-Result Cisao/Fusao;3-Obrig.Entrega FCONT
	aParamEcd[ECD_EXISTNIRE ]		:= nNire
	aParamEcd[ECD_FIN_ESC ]			:= nFinEsc
	aParamEcd[ECD_HASH_ESC_SUBST]	:= cHashSub                                                                    
	aParamEcd[ECD_NIRE_ESC_SUBST]  	:= cNireSub
EndIf

If lLeiaute3
	aParamEcd[ ECD_GDE_PORTE] 	:= nGrandePorte
	aParamEcd[ ECD_SCP_IND] 	:= nTipoECD
	aParamEcd[ ECD_PLANOREF] 	:= nPlanoCtaRef
	aParamEcd[ ECD_DATA_LP] 	:= dDtApur
EndIf
	
aParamEcd[ ECD_COD_PLA	]	:= Space(LEN(CVD->CVD_CODPLA))	

aParamEcd[ECD_OUT_TVFS]		:= cArqSubst

If lLeiaute7
	aParamEcd[ECD_MOT_SUBST] := nMotSubst
	Do Case
		Case aParamEcd[ECD_MOT_SUBST] == 2
			cMotSubst := "001"
		Case aParamEcd[ECD_MOT_SUBST] == 3
			cMotSubst := "002"
		Case aParamEcd[ECD_MOT_SUBST] == 4
			cMotSubst := "003"
		Case aParamEcd[ECD_MOT_SUBST] == 5
			cMotSubst := "004"
		Case aParamEcd[ECD_MOT_SUBST] == 6
			cMotSubst := "005"
		Case aParamEcd[ECD_MOT_SUBST] == 7
			cMotSubst := "099"
	End Case
EndIf

If lLeiaute8
	aParamEcd[ECD_MUD_PLC] := nMudplc
	aParamEcd[ECD_AMR_PLR] := nAmrPlR
EndIf

//tabela de diarios auxiliares especifica

lRet := lRet .And. GeraRevisao(oProcess, aParamEcd,,,,bIncTree)
lRet := lRet .And. ECDExpCad(oProcess, aParamEcd,,,nFinEsc )
lRet := lRet .And. ExportaOutDem(oProcess,aParamEcd[ECD_DATA_INI], aParamEcd[ECD_DATA_FIM],/*ECD_DATA_DEMINI*/,;
											/*ECD_DATA_DEMFIM*/,/*ECD_OUT_DEM*/,/*ECD_OUT_RAP*/,/*ECD_OUT_DFC*/,;
											/*ECD_OUT_DVA*/,/*ECD_OUT_NTE*/,/*ECD_OUT_RADM*/,/*ECD_OUT_PRAU*/,;
											/*ECD_OUT_OTR*/,aParamEcd[ECD_OUT_TVFS],"ECD",cMotSubst )
cCodRev := GetCodRev()

If !Empty(cArqTxt)
	lRet := lRet .And. ECDImpTXT(cArqTxt,cLayout,cCodRev)
EndIf

RestArea(aArea)
Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ECDImpTXTºAutor  ³Alvaro Camillo Neto º Data ³  26/03/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Importacao de arquivo texto                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ECDImpTXT(cArqTxt,cLayout,CodRev)
Local cBuffer := ""
Local nQtdReg := 0
Local lRet := .T.
Local nLinOk := 0
Local nConta := 0
Local cFilCSX := xFilial("CSX")

If File(cArqTxt)
	FT_FUSE(cArqTxt)
	nQtdReg := FT_FLASTREC()
	ProcRegua(nQtdReg)
	
	FT_FGOTOP() 
	While !FT_FEOF()  //FACA ENQUANTO NAO FOR FIM DE ARQUIVO
		nConta++
		IncProc( "Importando Registros "  + cValToChar(nConta) + " de " + cValToChar(nQtdReg) ) //"Importando Registros " ##" de "
		cBuffer := FT_FREADLN() //LENDO LINHA
		
		If Empty(AllTrim(cBuffer))
			FT_FSKIP()
			Loop
		EndIf
		
		If Len(AllTrim(cBuffer)) > 250
			Help("ECDFile",1,"HELP","Imp de Arquivo","Linha " + cValToChar(nConta) + " maior que 250 caracteres " ,1,0)
			lRet := .F.
			Exit
		EndIf
		
		nLinOk++
		RecLock("CSX",.T.)
		CSX->CSX_FILIAL 	:= cFilCSX
		CSX->CSX_CODREV 	:= CodRev
		CSX->CSX_CODLAY 	:= cLayout
		CSX->CSX_ORDEM  	:= StrZero(nConta,10)
		CSX->CSX_DESCRI 	:= AllTrim(cBuffer)
		MsUnlock()
		FT_FSKIP()
	EndDo	
	FT_FUSE() //fecha o arquivo txt
	dbCloseArea()
Else
	Help("ECDFile",1,"HELP","Imp de Arquivo","Arquivo não encontrado",1,0)
	lRet := .F.
EndIf

If lRet .And. nLinOk == 0
	Help("ECDFile",1,"HELP","Imp de Arquivo","Arquivo vazio",1,0)
	lRet := .F.
EndIf

Return lRet

