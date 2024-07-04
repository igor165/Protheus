#INCLUDE "plsa264.ch"
#include "rwmake.CH"
#include "protheus.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "PLSMGER.CH"

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLSA264 Ё Autor Ё Eduardo Motta         Ё Data Ё 20.05.2004 Ё╠╠
╠╠цддддддддддедддддддддадддддддаддддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Emissao de arquivo de remessa para carteirinha.            Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё Advanced Protheus                                          Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ _nTipo := 1 - Apos o cadastro do usuario                   Ё╠╠
╠╠Ё          Ё _nTipo := 2 - Geracao por lote                             Ё╠╠
╠╠Ё          Ё _nTipo := 3 - Imprime Usuario Posicionario                 Ё╠╠
╠╠Ё          Ё _nTipo := 4 - Imprime Familia Posicionario                 Ё╠╠
╠╠Ё          Ё _nTipo := 5 - Re-Imprime lote                              Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function Plsa264(paramixb,Lweb,cProtoc,lAutoma,lCartaoVirtual)
Static cDirPls := ""

Local lEnd    	:= .F.
Local lImp    	:= .T.
Local lNewLot 	:= .F.
Local aRet    	:= {}
Local dDatVal 	:= NIL
Local cDirGrava	:= ''
Local aArea		:= getArea()
		
Private nTotal      := 100
Private nSeqCar     := 1
Private nOriDad     := 0
Private lPriCar     := .T.
Private cArquivo  	:= ""
Private cArqTemp	:= ""
Private lAbortprint := .f.
Private aParamet    := aClone(paramixb)
Private aCabCar     := {}
Private aRodCar     := {}
Private aDadCar     := {}
Private nViaCar     := 0
Private dDtVali     := CtoD("")
Private oTempTable	:= nil

Default LWeb    	:= .F.  // Variavel do Portal do beneficiario
Default cProtoc		:= ""    //Protocolo Emitido paa o Portal do beneficiario
Default lAutoma		:= .F.
Default lCartaoVirtual := .F.

_nTipo    := Iif(Len(aParamet)>=5 ,aParamet[5] ,NIL)
lReemite  := Iif(Len(aParamet)>=6 ,aParamet[6] ,NIL)
lImp      := Iif(Len(aParamet)>=7 ,aParamet[7] ,NIL)
dDatVal   := Iif(Len(aParamet)>=8 ,aParamet[8] ,NIL)
lNewLot   := Iif(Len(aParamet)>=9 ,aParamet[9] ,NIL)
cDirGrava := Iif(Len(aParamet)>=10,aParamet[10],NIL)
lGeraInt  := Iif(Len(aParamet)>=11,aParamet[11],.F.)
lImpressao:= Iif(Len(aParamet)>=12,aParamet[12],.F.)

//Variavel do Portal do Beneficiario
If !lWeb 
	Processa({|lEnd|aRet := PLSEXEC(_nTipo,lReemite,lImp,dDatVal,lNewLot,cDirGrava,LWeb,cProtoc,lImpressao,lAutoma)},STR0001,,.T.) // //"Gerando dados do cartЦo magnИtico."
Else
	aRet := PLSEXEC(_nTipo,lReemite,lImp,dDatVal,lNewLot,cDirGrava,LWeb,cProtoc,lImpressao,lAutoma,lCartaoVirtual)
Endif

RestArea(aArea)

Return (aRet)

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Funcao    ЁPLSEXEC   ╨Autor  ЁMicrosiga           ╨ Data Ё  02/17/04   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     ЁFuncao que efetua a geracao dos cartoes magneticos          ╨╠╠
╠╠╨          ЁEsta segunda funcao eh para a utilizacao da PROCESSA        ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP6                                                        ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function PLSEXEC(_nTipo,lReemissao,lImp,dDatVal,lNewLot,cDirGrava,LWeb,cProtoc,lImpressao,lAutoma,lCartaoVirtual)
Local cSQL       	:= ""
Local cOperadora 	:= ""
Local cTipoGrupo 	:= ""
Local cEmpDe    	:= ""
Local cEmpAte    	:= ""
Local cDeCont    	:= ""
Local cAteCont   	:= ""
Local cDeSubCont 	:= ""
Local cAteSubCont 	:= ""
Local cMatrDe     	:= ""
Local cMatrAte    	:= ""
Local cTrb        	:= ""
Local cDataNasc   	:= ""
Local cDataInsc   	:= ""
Local cDatXInsc 	:= ""
Local cDataValid  	:= ""
Local cMotivo     	:= ""
Local cCodInt     	:= ""
Local cMudaVal    	:= ""
Local cProduto    	:= ""
Local cCodGruDe   	:= ""
Local cCodGruAte  	:= "ZZZZ"
Local cSelect1    	:= ""
Local cSelect2    	:= ""
Local cDatBlo     	:= ""
Local cNLin       	:= ""
Local cValor      	:= ""
Local cMsg 		  	:= ""
Local cMsgCri	    := ""
Local nRet        	:= 0
Local nI       	  	:= 0
Local nUniLocal   	:= 0
Local nCarencia   	:= 0
Local nRodape     	:= 0
Local nH          	:= 0
LOCAL nW          	:= 0
Local nLinha      	:= 0
Local nValor      	:= 0
Local nRecno      	:= 0
Local nQtd        	:= 0
Local nPerRen     	:= 0
Local nRegBED     	:= 0
Local nRegBEDV    	:= 0
Local nOrdBED     	:= 0
Local nUltVia     	:= 0
Local nRegAnt     	:= 0
Local aStruc      	:= {}
Local aRetNome    	:= {}
Local aRetVlrCar  	:= {}
Local aRecno      	:= {}
Local aArea      	:= {}
Local lOK         	:= .T.
Local lNenhum     	:= .T.
Local lErro       	:= .F.
Local dData1      	:= CtoD("")
Local dData2      	:= CtoD("")
Local cPerg       	:= "PLSEXP"
Local cCodigo     	:= STR0002 //"AVULSA"
Local cCodAnt     	:= ""
Local cGrpEmpIE 	:= GetNewPar("MV_PLSGEIN","0050")
Local nPeRePF   	:= GetNewPar("MV_PLSPRPF",12)
Local nLayOut  		:= iif(lImpressao,4,Val(GetNewPar("MV_PLSLCAR","1")) )    
Local cTipUsu       := GetNewPar("MV_PLCDTIT","T")  
Local cTipReg       := PlGrauTit() 
Local lValid      	:= .F.
Local dDatCpt
Local dDatFim
LOCAL aRetPto
Local nDias
Local cNatJco       := ""
Local cLocCob
Local aRetCar
Local cNomTit
Local nRegBTS
Local nRegBA1
Local aRetInfo    	:= {}
LOCAL aCriticas   	:= {}
local aDados		:= {}
Local nUltViaV    	:= 0
LOCAL cMaior		:= GetMv("MV_PLSMAIO",.F.,"2")
LOCAL cUniver     	:= ""
LOCAL _nIdMAXm    	:= 0
Local _nAno       	:= 0
Local _sMesDia    	:= ""
LOCAL nHIn
LOCAL nTamFileIn
LOCAL cBufferIn
LOCAL nTamLin
LOCAL nTamTot
LOCAL cNumTit		:= GetNewPar('MV_PLTRTIT','00')
Local bProcTit 		:= {|x| x == PLSEXP1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+cNumTit)}
Local aTitular		:= {}
Local lNomCar		:= .F.
Local lPtoRee		:= .T. // Retorno do ponto de entrada PLS264REE
Local lTpCtrBI3		:= (GetNewPar("MV_PLTPBI3","0")=="1") .AND. BII->(FieldPos("BII_TIPPLA")) > 0 // Verifica se busca o tipo de plano SIP pelo BI3 ou continua pelo BT5
Local cTipPlan 		:= ''
Local cNumPlan 		:= ''
Local cDTContrat 	:= ''
Local cMaxCarenc 	:= ''
Local nCont
Local _cIndexTmp	:= ''
LOCAL lPLS264E2  := ExistBlock("PLS264E2")
LOCAL lPLS264CA  := ExistBlock("PLS264CA")
LOCAL lPLS264EM  := ExistBlock("PLS264EM")
LOCAL lPLS264DT  := ExistBlock("PLS264DT")
LOCAL lPLS264FAM := ExistBlock("PLS264FAM")
LOCAL lPLS264VL  := ExistBlock("PLS264VL")
LOCAL lPLS264L2  := ExistBlock("PLS264L2")
LOCAL lPL264INFO := ExistBlock("PL264INFO")
LOCAL lPLS264OB  := ExistBlock("PLS264OB")
LOCAL lPLS264REE := ExistBlock("PLS264REE")
LOCAL lPLS264L4  := ExistBlock("PLS264L4")
LOCAL lPLS264FW  := ExistBlock( "PLS264FW" )
LOCAL cMvPLSFILA := GetMv("MV_PLSFILA")
LOCAL cMvPLSFIAU := GetMv("MV_PLSFIAU")
LOCAL cMvPLSFILO := GetMv("MV_PLSFILO")
LOCAL cMvPLSFIOU := GetMv("MV_PLSFIOU") 
LOCAL aCabBDE	 := {}
Local nX		 := 0

DEFAULT cDirGrava 	:= ""
DEFAULT _nTipo    	:= 2
DEFAULT lReemissao	:= .F.
DEFAULT lImp      	:= .T.
DEFAULT lNewLot   	:= .F.
DEFAULT LWeb		:= .F.  // Variavel que identifica se a solicitaГЦo vem do Portal do beneficiario
DEFAULT cProtoc     := .F.  // Campo novo para retornar Protocolo de Saida ao Portal beneficiario
DEFAULT lImpressao	:= .F.	// Imprime a carteirinha (papel)
DEFAULT lAutoma		:= .F.
Default lCartaoVirtual := .F.

//зддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Valida data                                       Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддды
If dDatVal == NIL
	dDatVal := CtoD("")
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Pega o diretorio se nao informado                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Empty(cDirGrava)
	cDirGrava := GetNewPar("MV_PLSDIRC","C:\")
Endif
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Tipo: Apos o cadastro do usuario...                         Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If _nTipo == 1
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica se eh PJ...                                       Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If BA3->BA3_TIPOUS == "2"
		Return({.F.,{nQtd},aCriticas,aDados})
	EndIf
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Emissao da primeira via da carteirinha...                  Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cMotivo := GetNewPar("MV_PLSMP1V","4")
	cCodInt := BA3->BA3_CODINT
	
	If lImp .and. !lImpressao
	
		cCodigo := PLSA262NUM(cCodInt)
		
		BDE->(DbSetOrder(1))
		BDE->(RecLock("BDE",.T.))
			BDE->BDE_FILIAL := xFilial("BDE")
			BDE->BDE_CODINT := cCodInt
			BDE->BDE_CODIGO := cCodigo
			BDE->BDE_UNILOC := "1"
			BDE->BDE_TIPGRU := "3"
			BDE->BDE_STACAR := "1"
			BDE->BDE_TIPGER := "1"
			If  BDE->( FieldPos("BDE_PROTOC") ) > 0 .and. LWeb 
				BDE->BDE_PROTOC := cProtoc
			Endif
		BDE->(MsUnlock())
	EndIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Tipo: Geracao por lote...                                   Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
ElseIf _nTipo == 2

	cCodigo := aParamet[1]
	cMotivo := aParamet[2]
	cCodInt := aParamet[3]
	oDlg  	:= aParamet[4]
	
	cOperadora  	:= M->BDE_CODINT
	nUniLocal   	:= val(M->BDE_UNILOC)
	cTipoGrupo  	:= M->BDE_TIPGRU
	cEmpDe       	:= M->BDE_EMPDE
	cEmpAte      	:= M->BDE_EMPATE
	cDeCont      	:= M->BDE_CONDE
	cAteCont    	:= M->BDE_CONATE
	cDeSubCont  	:= M->BDE_SUBDE
	cAteSubCont 	:= M->BDE_SUBATE
	cMatrDe     	:= M->BDE_MATDE
	cMatrAte 		:= M->BDE_MATATE
	
	If !Empty(M->BDE_DIRGRV)
		cDirGrava   := Alltrim(M->BDE_DIRGRV)
	EndIf
	
	dData1      := M->BDE_DATA1
	dData2      := M->BDE_DATA2
	cMudaVal    := M->BDE_MUDVAL
	dDatVal     := M->BDE_DATVAL
	cProduto    := M->BDE_CODPRO

	If BDE->( FieldPos("BDE_GRPDE") ) > 0 .AND. BDE->( FieldPos("BDE_GRPATE") ) > 0
		cCodGruDe   := M->BDE_GRPDE
		cCodGruAte  := M->BDE_GRPATE
	EndIf
	
	lValid := Pl264Val(cOperadora,nUniLocal,cTipoGrupo,cEmpDe,cEmpAte,cDeCont,cAteCont,cDeSubCont,cAteSubCont,cMatrDe,;
						cMatrAte,cDirGrava,dData1,dData2,cMudaVal,dDatVal,cMotivo,cCodGruDe,cCodGruAte)

	If  lValid
		cMsg := chr(13) + STR0003 //"JА existem lotes anteriores em aberto para o intervalo informado."
		cMsg += chr(13)
		cMsg += chr(13) + STR0004 //"                           Deseja prosseguir ?"
		cMsg += chr(13)
		If !LWeb
			If  Aviso(STR0005,cMsg, { STR0006,STR0007 },2) <> 1 //###### //"ConfirmaГЦo"###"&Sim"###"&NЦo"
		   		Return({.F.,{nQtd},aCriticas,aDados})
			Endif
		Else 
			Aadd(aCriticas, {STR0036,cMsg}) 	
			Return({.F.,{nQtd},aCriticas,aDados})
		Endif
	Else
		cCodInt := BA3->BA3_CODINT
	Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Tipo: Imprime Usuario/Familia Posicionario...               
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
ElseIf _nTipo == 3 .Or. _nTipo == 4

	cCodigo  := aParamet[1]
	cMotivo  := aParamet[2]
	cCodInt  := aParamet[3]
	oDlg   	 := aParamet[4]
	
	If ! lReemissao .and. !Empty(dDatVal)
		cMudaVal := "1"
	Endif
	
	If lReemissao
		If !PLSA264GET()
		   	Return({.F.,{nQtd},aCriticas,aDados})
		EndIf   
	Else
		If !LWeb
			Pergunte("PLS262",.F.)
			cDirPls := MV_PAR05
		Endif
	Endif
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Tratamento para posicionar corretamente as perguntas      Ё
    //Ё quando a rotina for chamada pelo Callcenter               Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If FunName() == "TMKA271"  .or. lWeb .OR. Empty(MV_PAR01)
	  MV_PAR01 := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) //Matricula
	  MV_PAR02 := aParamet[2] //Motivo
	EndIf
	
	If !Empty(cDirPls)
		cDirGrava := AllTrim(cDirPls)
	Endif
	
	if !lImpressao
		BED->(DbSetOrder(1))
		BED->(msSeek(xFilial("BED")+MV_PAR01))
		
		while !BED->(EOF()) .and. MV_PAR01 == BED->(BED_CODINT+BED_CODEMP+BED_MATRIC+BED_TIPREG+BED_DIGITO) .and. !lValid
		
			If BED->BED_MOTIVO == MV_PAR02 .and. BED->BED_STACAR == '1' .and. (BED->BED_BLOIDE == "0" .or. empty(BED->BED_BLOIDE))
				lValid := .T.
			endif
			
		BED->(DbSkip())
		enddo
		
		if lValid  .and. !lReemissao
		
			If !LWeb
				Help("",1,"PLSA264001")
				Return({.F.,{nQtd},aCriticas,aDados})
			Else
				Aadd(aCriticas, {"PLSA264001",STR0008}) 	
				Return({.F.,{nQtd},aCriticas,aDados})
			Endif
			
		endif
	endif
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Tipo: Re-Imprime lote...                                    Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
ElseIf _nTipo == 5
	cCodigo := BDE->BDE_CODIGO
	cMotivo := BDE->BDE_MOTIVO
	cCodInt := BDE->BDE_CODINT
	If lImp
		cDirPls := MV_PAR04
		If !Empty(cDirPls)
			cDirGrava := alltrim(cDirPls)
		Endif
	Endif
Endif
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se nao informou a barra                                             Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If SubStr(cDirGrava,Len(cDirGrava),1) <> "\"
	cDirGrava += "\"
EndIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se e possivel criar o arquivo                      Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
if !lImpressao .AND. !lAutoma .And. !lCartaoVirtual // AUTOMAгцO - NAO GRAVA O ARQUIVO
	nW := FCreate(cDirGrava+STR0009) // //"Valida.txt"
	
	If FERROR() == 430
		If !lWeb
			Help("",1,"PLSA264ARQ",,cDirGrava+cArquivo,1,0)
			Return({.F.,{nQtd},aCriticas,aDados})
		Else
			Aadd(aCriticas, {"PLSA264ARQ",STR0010}) 	
			Return({.F.,{nQtd},aCriticas,aDados})		
		Endif
		
	Else
		FClose(nW)
		FErase(cDirGrava+STR0009) //"Valida.txt"
	Endif
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define nome do arquivo...                                   Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If _nTipo == 2 .Or. _nTipo == 5
		cArquivo := AllTrim(cCodigo) + ".TXT"
		cArqTemp := AllTrim(cCodigo) + ".TMP"
	Else
		cArquivo := "CM" + AllTrim(BA3->BA3_NUMCON) + ".TXT"
		cArqTemp := "CM" + AllTrim(BA3->BA3_NUMCON) + ".TMP"
	Endif
	cArquivo := Alltrim(cArquivo)
endIf	
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Motivos para Emissao de Carteira...                                 Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BPX->( DbSetOrder(1) )
BPX->( MsSeek(xFilial("BPX")+cCodInt+cMotivo) )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ponto de Entrada para utilizacao de Lay-Out diferente...                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ExistBlock("PLS264L1")
	aStruc := ExecBlock("PLS264L1",.F.,.F.)
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё LayOut PLS...                                                       Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	if( nLayOut == 2 )
		_cIndexTmp := "NOMEUSUARI"
	else
		_cIndexTmp := "MATRICULA"
	endIf
ElseIf nLayOut == 1
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Tarja magnetica...                                                  Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Aadd(aStruc,{"TARJAMAG1"   ,"C",34,0})
	Aadd(aStruc,{"TARJAMAG2"   ,"C",30,0})
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Frente do Cartao...                                                 Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Aadd(aStruc,{"MATRICULA"   ,"C",21,0})
	Aadd(aStruc,{"CONTRATACA"  ,"C",17,0})
	Aadd(aStruc,{"NOMEUSUARI"  ,"C",30,0})
	Aadd(aStruc,{"DTNACTO"     ,"C",10,0})
	Aadd(aStruc,{"DTVALID"     ,"C",10,0})
	Aadd(aStruc,{"DTINC"    ,"C",10,0})
	Aadd(aStruc,{"PLANO"    ,"C",04,0})
	Aadd(aStruc,{"TPCONTRATO"     ,"C",04,0})
	Aadd(aStruc,{"RZSOCIAL"    ,"C",40,0})
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verso do Cartao...                                                  Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Aadd(aStruc,{"INFORMACOE"  ,"C",11,0})
	Aadd(aStruc,{"MENSAGEM1"   ,"C",30,0})
	Aadd(aStruc,{"MENSAGEM2"   ,"C",30,0})
	Aadd(aStruc,{"MENSAGEM3"   ,"C",30,0})
	Aadd(aStruc,{"MENSAGEM4"   ,"C",30,0})
	Aadd(aStruc,{"MENSAGEM5"   ,"C",30,0})
	Aadd(aStruc,{"MENSAGEM6"   ,"C",30,0})
	Aadd(aStruc,{"MENSAGEM7"   ,"C",30,0})
	Aadd(aStruc,{"MENSAGEM8"   ,"C",30,0})
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё LayOut PTU...                                                       Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	
	_cIndexTmp := "MATRICULA"
ElseIf nLayOut == 2
	Aadd(aStruc,{"SEP01"       	,"C",10,0})
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Linha 1            						                        	Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды			   
	Aadd(aStruc,{"CONTRATACA"	,"C",22,0})	                 
	Aadd(aStruc,{"NOMPRO"		,"C",30,0})
	Aadd(aStruc,{"CODSISCOP"   	,"C",01,0})       
	Aadd(aStruc,{"BRANCO01"    	,"C",01,0})
	Aadd(aStruc,{"UNIBENEF"    	,"C",03,0})       
	Aadd(aStruc,{"BRANCO02"    	,"C",01,0})       
	Aadd(aStruc,{"EMPRESA"     	,"C",04,0})       
	Aadd(aStruc,{"INSCRICAO"   	,"C",06,0})       
	Aadd(aStruc,{"GRAUDEPEN"   	,"C",02,0})       
	Aadd(aStruc,{"BRANCO03"    	,"C",01,0})       
	Aadd(aStruc,{"DIGITO"      	,"C",01,0})
	Aadd(aStruc,{"CRLF01"      	,"C",01,0})

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Linha 2             					                        	Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
	Aadd(aStruc,{"DTNACTO"     	,"C",10,0}) 
	Aadd(aStruc,{"BRANCO04"    	,"C",04,0}) 
	Aadd(aStruc,{"BRANCO05"		,"C",04,0}) 
	Aadd(aStruc,{"TPACOMODA"	,"C",13,0}) 
	Aadd(aStruc,{"BRANCO06"		,"C",04,0}) 
	Aadd(aStruc,{"DTVIGPL"		,"C",10,0}) 
	Aadd(aStruc,{"DTVALID"		,"C",10,0}) 
	Aadd(aStruc,{"CRLF02"      	,"C",01,0})
		                        
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Linha 3         						                        	Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Aadd(aStruc,{"NOMEUSUARI"	,"C",25,0}) 
	Aadd(aStruc,{"BRANCO07"		,"C",10,0}) 
	Aadd(aStruc,{"REDATE"	    ,"C",13,0}) 
   	Aadd(aStruc,{"CRLF03"      	,"C",01,0})
   	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Linha 4            						                        	Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
	Aadd(aStruc,{"LOCALCOB"		,"C",04,0})  
	Aadd(aStruc,{"BRANCO08"		,"C",05,0})  
	Aadd(aStruc,{"DESPLA"		,"C",22,0}) 
	Aadd(aStruc,{"BRANCO09"		,"C",06,0}) 
	Aadd(aStruc,{"ABRANG"  		,"C",19,0}) 
	Aadd(aStruc,{"BRANCO10"  	,"C",02,0}) 	
	Aadd(aStruc,{"VIACAR"  		,"C",02,0}) 	
	Aadd(aStruc,{"CRLF04"      	,"C",01,0})
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Linha 5                              	                        	Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Aadd(aStruc,{"CPT"    		,"C",10,0})  
	Aadd(aStruc,{"BRANCO11"		,"C",21,0})  
	Aadd(aStruc,{"NREDUZ" 		,"C",30,0})
	Aadd(aStruc,{"CRLF05"      	,"C",01,0})                                  
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Linha 6                              	                        	Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
	Aadd(aStruc,{"SEGASSPL"      	,"C",56,0})
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Trilha 1                            	                        	Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
	Aadd(aStruc,{"SEP02"	    ,"C",05,0})
	Aadd(aStruc,{"SS01"	    	,"C",01,0})
	Aadd(aStruc,{"TARJAMAG1"	,"C",25,0})
	Aadd(aStruc,{"ES01"	    	,"C",01,0})                             
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Trilha 2                            	                        	Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Aadd(aStruc,{"SS02"	    	,"C",01,0})
	Aadd(aStruc,{"TARJAMAG2"	,"C",37,0})  	
	Aadd(aStruc,{"ES02"	    	,"C",01,0})
	Aadd(aStruc,{"SEP03"	    ,"C",11,0})	

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Carencias                            	                        	Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Aadd(aStruc,{"CLSCAR"	    ,"C",400,0})
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Abrangencia                            	                        	Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Aadd(aStruc,{"ABRCAR"	    ,"C",100,0})
	Aadd(aStruc,{"SUSEP"	    ,"C",12,0})              
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё CNES                           	                        	Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
	Aadd(aStruc,{"CNESUSU"	    ,"C",15,0})    
	Aadd(aStruc,{"SEASPL"      	,"C",60,0})
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Nome Social do Beneficiario                                      	Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Aadd(aStruc,{"NOMSOC"       ,"C",25,0})    
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё QRCODE                                                          	Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Aadd(aStruc,{"QRCODE"       ,"C",143,0})    

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё LayOut 3                                                            Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	
	_cIndexTmp := "NOMEUSUARI"
ElseIf nLayOut == 3
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Frente do Cartao...                                                 Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Aadd(aStruc,{"CODEMP"      ,"C",04,0})  // 01
	Aadd(aStruc,{"DESEMP"      ,"C",50,0})  // 02
	Aadd(aStruc,{"VALIDADE"    ,"C",10,0})  // 03
	Aadd(aStruc,{"TITULAR"     ,"C",50,0})  // 04
	Aadd(aStruc,{"DEPENDENTE"  ,"C",50,0})  // 05
	Aadd(aStruc,{"MATRICULA"   ,"C",22,0})  // 06
	Aadd(aStruc,{"PLANO"       ,"C",04,0})  // 07
	Aadd(aStruc,{"DESPLANO"    ,"C",50,0})  // 08
	Aadd(aStruc,{"REDE"        ,"C",10,0})  // 09
	Aadd(aStruc,{"CONSULTA"    ,"C",08,0})  // 10
	Aadd(aStruc,{"EXAME"       ,"C",08,0})  // 11
	Aadd(aStruc,{"INTERN"      ,"C",08,0})  // 12
	Aadd(aStruc,{"PARTO"       ,"C",08,0})  // 13
	Aadd(aStruc,{"PADRAO"      ,"C",15,0})  // 14
	Aadd(aStruc,{"NASCIMENTO"  ,"C",10,0})  // 15
	Aadd(aStruc,{"OBS"         ,"C",50,0})  // 15
	Aadd(aStruc,{"EXAMEESP"    ,"C",08,0})  // 16
	Aadd(aStruc,{"VIACAR"      ,"C",02,0})  // 16
	Aadd(aStruc,{"BADGET"      ,"C",10,0})  // 17

	_cIndexTmp := "MATRICULA"
//RN-360	
elseIf nLayOut == 4
	
	//Tarja magnetica...
	Aadd(aStruc,{"TARJAMAG1"   ,"C",34,0})
	Aadd(aStruc,{"TARJAMAG2"   ,"C",30,0})

	//Frente do Cartao...

	Aadd(aStruc,{"NOMEUSUARI"  	,"C",30,0}) //nome do beneficiario
	Aadd(aStruc,{"MATRICULA"   	,"C",21,0}) //numero da matricula
	Aadd(aStruc,{"DTNACTO"     	,"C",10,0}) //data de ascimento do beneficiario
	Aadd(aStruc,{"CNESUSU"	    ,"C",15,0}) //numero do cartao naciona de saude CNS
	Aadd(aStruc,{"SUSEP"	    ,"C",12,0}) //numero do registro do plano ou do cad. do plano na ans
	Aadd(aStruc,{"SEGASSPL"     ,"C",56,0}) //segmentacao assistencial do plano
	Aadd(aStruc,{"NUMREGOPE"    ,"C",6,0}) 	//codigo do registro da operadora na ans - BA0_SUSEP //BA0_FILIAL+BA0_CODIDE+BA0_CODINT
	Aadd(aStruc,{"CONTATOOPE"   ,"C",75,0}) //informacao de contato com a operadora - BIM_NOME-BIM_TELCON-BIM_EMAIL (Quando setor == 012 BIM_SETOR) //BIM_FILIAL+BIM_CODINT+BIM_CODIGO
	Aadd(aStruc,{"CONTATOANS"   ,"C",85,0}) //informacao de contato com a ans - BK5_NOME-BK5_TEL-BK5_EMAIL //BK5_FILIAL+BK5_NOME
	Aadd(aStruc,{"CPT"    		,"C",10,0})  //data de termino da cobertura parcial temporaria
	//Verso do Cartao...

	Aadd(aStruc,{"TPACOMODA"	,"C",13,0})  //padrao de acomodacao
	Aadd(aStruc,{"CONTRATACA"  	,"C",17,0})  //tipo de contratacao
	Aadd(aStruc,{"ABRANG"  		,"C",19,0})  //area de abrangencia geografica
	Aadd(aStruc,{"NOMPRO"		,"C",30,0})	 //nome do produto
	Aadd(aStruc,{"NFANTAZOPE"   ,"C",60,0})	 //nome fantasia da operadora - BA0_NOMINT
	Aadd(aStruc,{"NFAADMBENE"   ,"C",20,0})	 //nome fantasia da administradora de beneficios - BG9_NREDUZ 
	Aadd(aStruc,{"RZSOCIAL"     ,"C",40,0})  //nome da p. juridica contratante do plano coletivo ou emp.
	Aadd(aStruc,{"DTVIGPL"  	,"C",10,0})  //data de inicio da vigencia do plano
	Aadd(aStruc,{"NUMCON"  		,"C",20,0})  //Numero do contrato apСlice
	Aadd(aStruc,{"DATCON"  		,"C",10,0})  //Data de contrataГЦo do plano de saЗde
	Aadd(aStruc,{"DTMAXCON"  	,"C",10,0})  //Prazo mАximo previsto no contrato para carЙncia
	Aadd(aStruc,{"INFOPLAN"  	,"C",20,0})  //InformaГЦo sobre a regulamentaГЦo do plano
	Aadd(aStruc,{"INFORMACOE"   ,"C",11,0})  //informacoes

	_cIndexTmp := "MATRICULA"
Else
	If !Lweb
		MsgStop(STR0011) // //"Lay-Out Invalido!"
		Help("",1,"PLSA264002")
		Return({.F.,{nQtd},aCriticas,aDados})
	Else
		Aadd(aCriticas, {"PLSA264002",STR0011}) 	
		Return({.F.,{nQtd},aCriticas,aDados})
	Endif
	
EndIf

//--< CriaГЦo do objeto FWTemporaryTable >---
oTempTable := FWTemporaryTable():New( "Dados" )
oTempTable:SetFields( aStruc )
oTempTable:AddIndex( "INDStruc",{ _cIndexTmp } )

if( select( "Dados" ) > 0 )
	Dados->( dbCloseArea() )
endIf

oTempTable:Create()

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Tipo: Apos o cadastro do usuario...                         Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If _nTipo == 1 // ApСs o cadastro do beneficiАrio
	
	cSQL := "SELECT   BA1.R_E_C_N_O_ BA1REG, BA3.R_E_C_N_O_  BA3REG, BA1_DATNAS, BA1_DATINC, "
	cSQL +=     " BA1_DTVLCR, BA1_TIPREG, BA1_CODINT, BA1_CODEMP, "
	cSQL +=     " BA1_MATRIC, BA1_DIGITO, BA1_NOMUSR, BA1_TIPUSU, "
	cSQL +=     " BA1_DATCAR, BA1_VIACAR, BA1_OPERES, BA1_SEXO, "
	cSQL +=     " BA3_CODPLA, BA3_VERSAO, BA3_CODINT, BA3_TIPOUS, "
	cSQL +=     " BA3_CONEMP, BA3_VERCON, BA3_SUBCON, BA3_VERSUB, "
	cSQL +=     " BA3_CODEMP, BTS_NOMCAR, BTS_NOMUSR, BA3_TIPCON, BA1_TIPUSU "

	If BTS->(fieldpos("BTS_NOMSOC")) > 0
		cSQL += ", BTS_NOMSOC "
	EndIf
	
	cSQL += " FROM " + RetSQLName("BA1")+" BA1, " + RetSQLName("BA3")+" BA3, " + RetSQLName("BTS")+" BTS "
	
	cSQL += " WHERE BA1.BA1_FILIAL = '" + xFilial("BA1") + "' AND "
	cSQL +=    " BA3.BA3_FILIAL = '" + xFilial("BA3") + "' AND "
	cSQL +=    " BTS.BTS_FILIAL = '" + xFilial("BTS") + "' AND "
	
	cSQL +=    " BA1.BA1_CODINT = '" + BA3->BA3_CODINT + "' AND "
	cSQL +=    " BA1.BA1_CODEMP = '" + BA3->BA3_CODEMP + "' AND "
	cSQL +=    " BA1.BA1_MATRIC = '" + BA3->BA3_MATRIC + "' AND "
	
	If lGeraInt
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Gerar empresa de intercambio                                Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If  BDE->(fieldpos("BDE_GERINT")) > 0
			If M->BDE_GERINT == "0"  //Nao
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Exclui Empresa Intercambio...                               Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				cSQL +=    " BA1.BA1_CODEMP <> '" + cGrpEmpIE + "' AND "
			Endif
		Else
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Exclui Empresa Intercambio...                               Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			cSQL +=    " BA1.BA1_CODEMP <> '" + cGrpEmpIE + "' AND "
		Endif
	Endif
	
	cSQL +=    " BA3.BA3_CODINT = '" + BA3->BA3_CODINT + "' AND "
	cSQL +=    " BA3.BA3_CODEMP = '" + BA3->BA3_CODEMP + "' AND "
	cSQL +=    " BA3.BA3_MATRIC = '" + BA3->BA3_MATRIC + "' AND "
	
	cSQL +=    " BA1.BA1_MATVID = BTS.BTS_MATVID AND "
	
	cSQL += " BA1.D_E_L_E_T_ <> '*' AND BA3.D_E_L_E_T_ <> '*' AND BTS.D_E_L_E_T_ <> '*' "
	If lPLS264OB
		cSQL += ExecBlock("PLS264OB",.F.,.F.)
	Else
		cSQL += " ORDER BY BA1_CODINT,BA1_CODEMP,BA1_NOMUSR "
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Tipo: Geracao por lote...                                   Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
ElseIf _nTipo == 2
	
	cSelect1 := " SELECT COUNT(*) TOTAL "
	cSelect1 += "FROM " + RetSQLName("BA1") + " BA1, " + RetSQLName("BA3") + " BA3, " + RetSQLName("BTS") + " BTS "
	
	cSelect2 := " SELECT BA1.R_E_C_N_O_ BA1REG, BA3.R_E_C_N_O_ BA3REG, BA1_DATNAS, BA1_DATINC, BA1_DTVLCR, "
	cSelect2 += "        BA1_DTVLCR, BA1_CODINT,BA1_CONEMP,BA1_VERCON, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, BA1_DIGITO, BA1_TIPUSU,"
	cSelect2 += "        BA1_NOMUSR, BA1_DATCAR, BA1_VIACAR, BA1_OPERES, BA1_SEXO,   BA3_CODPLA, "
	cSelect2 += "        BA3_VERSAO, BA3_CODINT, BA3_CODEMP, BA3_SUBCON, BA3_VERSUB, BA3_VERCON, "
	cSelect2 += "        BA3_TIPCON, BA3_TIPOUS, BA3_CONEMP, BTS_NOMCAR, BA1_TIPUSU, BA1_MATVID, BTS_NOMUSR, BTS_NRCRNA "

	If BTS->(fieldpos("BTS_NOMSOC")) > 0
		cSelect2 += ", BTS_NOMSOC "
	EndIf
	
	cSelect2 += "FROM " + RetSQLName("BA1") + " BA1, " + RetSQLName("BA3") + " BA3, " + RetSQLName("BTS")+ " BTS "
	
	cSQL := " WHERE BA1.BA1_FILIAL = '" + xFilial("BA1")       	+"' AND "
	cSQL += 		" BA3.BA3_FILIAL = '" + xFilial("BA3")         	+"' AND "
	cSQL += 		" BTS.BTS_FILIAL = '" + xFilial("BTS")         	+"' AND "
	cSQL += 		" BA1.BA1_CODINT = '" + cOperadora             	+"' AND "
	cSQL += 		" BA1.BA1_CODEMP BETWEEN '"+cEmpDe             	+"' AND '"+cEmpAte            +"' AND "
	cSQL += 		" BA1.BA1_CONEMP BETWEEN '"+cDeCont            	+"' AND '"+cAteCont           +"' AND "
	cSQL += 		" BA1.BA1_SUBCON BETWEEN '"+cDeSubCont         	+"' AND '"+cAteSubCont        +"' AND "
	cSQL += 		" BA1.BA1_MATRIC BETWEEN '"+Subs(cMatrDe,1,6)  	+"' AND '"+Subs(cMatrAte,1,6) +"' AND "
	cSQL += 		" BA1.BA1_TIPREG BETWEEN '"+Subs(cMatrDe,7,2)  	+"' AND '"+Subs(cMatrAte,7,2) +"' AND "
	If !empty(DtoS(dData1)) .AND. !empty(DtoS(dData2))
		cSQL +=		" BA1.BA1_DTVLCR BETWEEN '"+DtoS(dData1)+"' AND '"+DtoS(dData2)+"' AND "
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Exclui usuarios da Operadora Local...                       Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If nUniLocal = 2
		cSQL += 		" BA1.BA1_CODINT <> '" + cCodInt + "' AND "
	EndIf
	
	If lGeraInt
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Gerar empresa de intercambio                                Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If  BDE->(fieldpos("BDE_GERINT")) > 0
			If M->BDE_GERINT == "0" //Nao
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Exclui Empresa Intercambio...                               Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				cSQL += 	" BA1.BA1_CODEMP <> '" + cGrpEmpIE + "' AND "
			Endif
		Else
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Exclui Empresa Intercambio...                               Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			cSQL += 		" BA1.BA1_CODEMP <> '" + cGrpEmpIE + "' AND "
		Endif
	EndIf
	
	//Verifica se eh primeira Via de Carteirinha...             
	if !lImpressao .Or. _nTipo == 2
		If cMotivo == GetNewPar("MV_PLSMP1V","4")
			cSQL += 		" BA1.BA1_VIACAR = 0 AND "
		Else
			cSQL += 		" BA1.BA1_VIACAR <> 0 AND "
		Endif
	endIf	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica o tipo de contratacao (PF/PJ)...                   Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If cTipoGrupo <> "3"
		cSQL += 		" BA3.BA3_TIPOUS = '" + cTipoGrupo + "' AND "
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica se eh apenas para alteracao cadastral                                    Ё
	//Ё BA1_EMICAR = 0=Nunca Emitir;1=Cad. Alterado;2=Cartao Preparado;3=Cartao Gerado    Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If  BPX->(fieldpos("BPX_TIPEMI")) > 0 .and. BA1->(fieldpos("BA1_EMICAR")) > 0 .and. posicione("BPX",1,xFilial("BPX")+cOperadora+cMotivo,"BPX_TIPEMI") == "2"
		cSQL += " (BA1.BA1_EMICAR = '1' OR BA1.BA1_EMICAR = '2') AND "
	Else
		cSQL += " BA1.BA1_EMICAR <> '0' AND "
	Endif

	If BA3->(FieldPos("BA3_CARVIR")) > 0 .And. BA1->(FieldPos("BA1_CARVIR")) > 0 .And. lCartaoVirtual
		cSQL += " BA3.BA3_CARVIR <> '0' AND "
		cSQL += " BA1.BA1_CARVIR <> '0' AND "
	EndIf
	
	cSQL += 		" BA3.BA3_CODINT = BA1.BA1_CODINT AND "
	cSQL += 		" BA3.BA3_CODEMP = BA1.BA1_CODEMP AND "
	cSQL += 		" BA3.BA3_MATRIC = BA1.BA1_MATRIC AND "
	cSQL += 		" BTS.BTS_MATVID = BA1.BA1_MATVID AND "
	cSQL += 		" BA1.D_E_L_E_T_ <> '*' AND BA3.D_E_L_E_T_ <> '*' AND BTS.D_E_L_E_T_ <> '*' "

	//Ponto de entrada que possibilita realizar os ajustes necessАrio na query das carteirinhas
	If ExistBlock("PL264QRY")
		aRetSQL := ExecBlock("PL264QRY",.F.,.F.,{cSelect1,cSelect2,cSQL})
		
		If Len(aRetSQL) > 0
			cSelect1 := aRetSQL[1]
			cSelect2 := aRetSQL[2]
			cSQL     := aRetSQL[3]
		Endif
		
	Endif	

	PLSQuery(cSelect1+cSQL,"PLSEXP1")
	nTotal := PLSEXP1->TOTAL
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Fecha temporario...                                         Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	PLSEXP1->(DbCloseArea())
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Acrescenta linha para ordenar os registros...
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If lPLS264OB
		cSQL += ExecBlock("PLS264OB",.F.,.F.)
	Else
		cSQL += " ORDER BY BA1_CODINT,BA1_CODEMP,BA1_NOMUSR "
	EndIf
	cSQL := cSelect2 + cSQL
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Tipo: Imprime Usuario/Familia Posicionario...               Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
ElseIf (_nTipo == 3 .Or. _nTipo == 4)
	
	cSQL := "SELECT BA1.R_E_C_N_O_ BA1REG, BA3.R_E_C_N_O_ BA3REG, BA1_DATNAS ,BA1_DATINC, BA1_DTVLCR, "
	cSQL += 		" BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, BA1_DIGITO, BA1_NOMUSR, BA1_TIPUSU, "
	cSQL += 		" BA1_DATCAR, BA1_VIACAR, BA1_OPERES, BA1_SEXO  , BA3_MATRIC, BA3_CODPLA, BA3_VERSAO, "
	cSQL += 		" BA3_TIPCON, BA3_TIPOUS, BA3_CONEMP, BA3_VERCON, BA3_SUBCON, BA3_VERSUB, "
	cSQL += 		" BA3_CODEMP, BA3_CODINT, BTS_NOMCAR, BTS_NOMUSR, BTS_NRCRNA, BA1_DATINC, BA1_NUMCON,BA1_CONEMP,BA1_VERCON  "

	If BTS->(fieldpos("BTS_NOMSOC")) > 0
		cSQL += ", BTS_NOMSOC "
	EndIf
	
	cSQL += " FROM " + RetSQLName("BA1") + " BA1, " + RetSQLName("BA3") + " BA3, " + RetSQLName("BTS") + " BTS  "
	
	cSQL += " WHERE BA1.BA1_FILIAL = '" + xFilial("BA1") + "' AND "
	cSQL += 		" BA3.BA3_FILIAL = '" + xFilial("BA3") + "' AND "
	cSQL += 		" BTS.BTS_FILIAL = '" + xFilial("BTS") + "' AND "
	
	If _nTipo == 4
		
		cSQL += 	" BA3.BA3_CODINT = '" + BA3->BA3_CODINT + "' AND "
		cSQL += 	" BA3.BA3_CODEMP = '" + BA3->BA3_CODEMP + "' AND "
		cSQL += 	" BA3.BA3_MATRIC = '" + BA3->BA3_MATRIC + "' AND "
		
	ElseiF _nTipo == 3
		
		cSQL += 	" BA3.R_E_C_N_O_ = " + Str(BA3->(Recno())) + " AND "
		cSQL += 	" BA1.R_E_C_N_O_ = " + Str(BA1->(Recno())) + " AND "
		
	Endif
	
	cSQL += 		" BA3.BA3_CODINT = BA1.BA1_CODINT AND "
	cSQL += 		" BA3.BA3_CODEMP = BA1.BA1_CODEMP AND "
	cSQL += 		" BA3.BA3_MATRIC = BA1.BA1_MATRIC AND "
	cSQL += 		" BA1.BA1_MATVID = BTS.BTS_MATVID AND "
	
	If lGeraInt
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Gerar empresa de intercambio                                Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If  BDE->(fieldpos("BDE_GERINT")) > 0
			If M->BDE_GERINT == "0" //Nao
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Exclui Empresa Intercambio...                               Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				cSQL += " BA1.BA1_CODEMP <> '" + cGrpEmpIE + "' AND "
			Endif
		Else
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Exclui Empresa Intercambio...                               Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			cSQL += 	" BA1.BA1_CODEMP <> '" + cGrpEmpIE + "' AND "
		Endif
	EndIf
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica se eh primeira Via de Carteirinha...               Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If _nTipo == 3 .and. !lReemissao .and. (!lImpressao .Or. _nTipo == 2)
	
		If cMotivo == GetNewPar("MV_PLSMP1V","4")
			cSQL += " BA1_VIACAR = 0 AND "
		Else
			cSQL += " BA1_VIACAR <> 0 AND "
		Endif
		
	Endif
	
	cSQL += "       BA1.D_E_L_E_T_ <> '*' AND BA3.D_E_L_E_T_ <> '*' AND BTS.D_E_L_E_T_ <> '*' "
	If lPLS264OB
		cSQL += ExecBlock("PLS264OB",.F.,.F.)
	Else
		cSQL += " ORDER BY BA1_CODINT,BA1_CODEMP,BA1_TIPREG,BA1_NOMUSR "
	EndIf
	
Endif
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Tipo: Re-Imprime lote...                                    Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If _nTipo <> 5
	PLSQuery(cSQL,"PLSEXP1")
	
	While !PlSEXP1->(Eof())
		aAdd(aTitular, PLSEXP1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG))
		PLSEXP1->(dbSkip())
	EndDo
	
	PLSEXP1->(dbGoTop())
	
EndIf

BQC->(DbSetOrder(1))
ProcRegua(nTotal)

While _nTipo <> 5 .and. !PLSEXP1->(Eof())

	If PLSEXP1->BA1_TIPREG == cTipReg .Or. PLSEXP1->BA1_TIPUSU == cTipUsu
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Alimenta Mensagem...										Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		
		If _nTipo <> 2
			IncProc(STR0035 + Str(nQtd,10)) 		 //"Selecionando inf. para cartЦo magnetico. "
		Else
			IncProc(STR0035 + AllTrim(Str(nQtd,10)) + "/" + AllTrim(Str(nTotal,10))) //"Selecionando inf. para cartЦo magnetico. "
		EndIf
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Para qualquer exportacao ou emissao atualizar como modelo abaixo... Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		BA1->(DbGoTo(PLSEXP1->BA1REG))
		BA3->(DbGoTo(PLSEXP1->BA3REG))

		If lCartaoVirtual
			If !ChckProdCardVirtual(BA3->BA3_CODPLA, BA3->BA3_VERSAO, BA3->BA3_CODINT, BA3->BA3_CODEMP, BA3->BA3_CONEMP,;
									BA3->BA3_VERCON, BA3->BA3_SUBCON, BA3->BA3_VERSUB)
				PLSEXP1->(DbSkip())
				Loop
			EndIf
		EndIf

		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifica RegulamentaГЦo do Plano                                    Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды		
			BI3->(dbSetOrder(1))
			BI3->(msSeek(xFilial("BF3")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)))

			Do Case
				Case BI3->BI3_APOSRG == '0'
					cTipPlan := 'Plano Nao Regulamentado'
				Case BI3->BI3_APOSRG == '1'
					cTipPlan := 'Plano Regulamentado'
				Case BI3->BI3_APOSRG == '2'
					cTipPlan := 'Plano Adaptado'
			EndCase
			
			cNumPlan := BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifica Prazo Maximo de carencia                                   Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
			aVetCarenc := {}
			aRetCarenc := PLSCLACAR(BA1->BA1_CODINT,BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),/*dDataBase*/)
		
			If Len(aRetCarenc) > 0 .And. aRetCarenc[1]
			cMaxCarenc := aRetCarenc[2][1][3]
				For nCont := 1 to len(aRetCarenc[2])
					If Len(aRetCarenc[2][nCont]) > 7 
						If aRetCarenc[2][nCont][3] > cMaxCarenc
							cMaxCarenc := aRetCarenc[2][nCont][3]
						Endif	
					Endif	
				Next    
			Endif

		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica CPT                                                        Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		BF3->(dbSetOrder(1))
		BF3->(msSeek(xFilial("BF3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)))
		
		dDatCpt := ctod("  /  /  ")
		
		While ! BF3->(eof()) .and. BF3->(BF3_FILIAL+BF3_CODINT+BF3_CODEMP+BF3_MATRIC+BF3_TIPREG) == xFilial("BF3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)
			
			If  ! empty(BF3->BF3_CODDOE)
				If BF3->BF3_UNAGR == "3" //"Meses"
					If  Empty(BF3->BF3_DATCPT)
						If  Empty(BA1->BA1_DATCPT)
							nDias	:=	Abs(( date() -MonthSum( date() , 0 )))
							dDatCPt:= date()+nDias
						Else
							nDias	:=	Abs((BA1->BA1_DATCPT -MonthSum(BA1->BA1_DATCPT , BF3->BF3_MESAGR )))
							dDatCPt:= BA1->BA1_DATCPT+nDias
						Endif
					Else
						nDias	:=	Abs((BF3->BF3_DATCPTT -MonthSum(BF3->BF3_DATCPTT , BF3->BF3_MESAGR )))
						dDatCPt:= BF3->BF3_DATCPT+nDias
					Endif	
				Else			
				nDias   := PLSCarDias(BF3->BF3_MESAGR,BF3->BF3_UNAGR)
					dDatFim := BF3->BF3_DATCPT + nDias
				If  dDatFim > dDatCpt
					dDatCpt := dDatFim
					Endif
				Endif
			Endif
			BF3->(dbSkip())
		Enddo
		
		If BA3->BA3_TIPOUS <> "1"
			
			If  BT5->(BT5_FILIAL+BT5_CODINT+BT5_CODIGO+BT5_NUMCON+BT5_VERSAO) <>  xFilial("BT5")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON)

				BT5->(DbSetOrder(1))
				BT5->(msSeek(xFilial("BT5")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON)))
				If ! BT5->(Found())
					If lPLS264E2
						Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0013}) //"Contrato nЦo Cadastrado."
						PLSEXP1->(DbSkip())
						Loop
					Else
						cMsgCri := AllTrim(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)) + " - "
						cMsgCri += STR0013 //"Contrato nЦo Cadastrado."
						If !lweb
							If Aviso(STR0036,cMsgCri,{STR0006,STR0007},3,STR0038) == 1 //"CrМtica!"###"&Sim"###"&NЦo"###"Deseja Continuar?"
								PLSEXP1->(DbSkip())
								Loop
							Else
								PLSEXP1->(dbCloseArea())
								PLApag(cTrb)
								Return({.F.,{nQtd},aCriticas,aDados})
							Endif
						Else
							PLSEXP1->(dbCloseArea())
							PLApag(cTrb)
							
							Aadd(aCriticas, {STR0036,cMsgCri}) 	
							Return({.F.,{nQtd},aCriticas,aDados})					
						EndIf
					EndIf
				Endif
			Endif
			
			If  BQC->(BQC_FILIAL+BQC_CODIGO+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB) <> xFilial("BQC")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)
				BQC->(DbSetOrder(1))
				BQC->(msSeek(xFilial("BQC")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))
				If ! BQC->(Found())
					If lPLS264E2
						Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0014})				 //"Sub-Contrato nЦo Cadastrado."
						PLSEXP1->(DbSkip())
						Loop
					Else
						cMsgCri := AllTrim(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)) + " - "
						cMsgCri += STR0014 //"Sub-Contrato nЦo Cadastrado."
						
						If !Lweb
							If Aviso(STR0036,cMsgCri,{STR0006,STR0007},3,STR0038) == 1 //"CrМtica!"###"&Sim"###"&NЦo"###"Deseja Continuar?"
								PLSEXP1->(DbSkip())
								Loop
							Else
								PLSEXP1->(DbCloseArea())
								PLApag(cTrb)
								Return({.F.,{nQtd},aCriticas,aDados})
							EndIf
							
						Else
							PLSEXP1->(DbCloseArea())
							PLApag(cTrb)							 
							Aadd(aCriticas, {STR0036,cMsgCri}) 	
							Return({.F.,{nQtd},aCriticas,aDados})														
						Endif
						
						
					EndIf
				Endif
			Endif
			
			If  BQC->BQC_EMICAR == "0" // indica que nao deve gerar cartao para este subcontrato
				PLSEXP1->(DbSkip())
				Loop
			Endif
			
		Endif
		
		
		If  BG9->(BG9_FILIAL+BG9_CODINT+BG9_CODIGO) <> xFilial("BG9")+PLSEXP1->(BA3_CODINT+BA3_CODEMP)
			BG9->(DbSetOrder(1))
			BG9->(msSeek(xFilial("BG9")+PLSEXP1->(BA3_CODINT+BA3_CODEMP)))
		Endif
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Posiciona Produto do usuario... 									Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If  ! empty(BA1->(BA1_CODPLA+BA1_VERSAO))
			If  BI3->(BI3_FILIAL+BI3_CODINT+BI3_CODIGO+BI3_VERSAO) <> xFilial("BI3")+BA1->(BA1_CODINT+BA1_CODPLA+BA1_VERSAO)
				BI3->(DbSetOrder(1))
				If  ! BI3->(msSeek(xFilial("BI3")+BA1->(BA1_CODINT+BA1_CODPLA+BA1_VERSAO)))
					If lPLS264E2
						Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0015})	        	 //"Plano do usuАrio nЦo cadastrado."
						PLSEXP1->(DbSkip())
						Loop
					Else
						cMsgCri := AllTrim(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)) + " - "
						cMsgCri += STR0015 //"Plano do usuАrio nЦo cadastrado."
						If !Lweb
							If Aviso(STR0036,cMsgCri,{STR0006,STR0007},3,STR0038) == 1 //"CrМtica!"###"&Sim"###"&NЦo"###"Deseja Continuar?"
								PLSEXP1->(DbSkip())
								Loop
							Else
								PLSEXP1->(DbCloseArea())
								PLApag(cTrb)
								Return({.F.,{nQtd},aCriticas,aDados})
							Endif
						Else
							PLSEXP1->(DbCloseArea())
							PLApag(cTrb)
							Aadd(aCriticas, {STR0036,cMsgCri}) 	
							Return({.F.,{nQtd},aCriticas,aDados})
							
						EndIf
					EndIf
				Endif
			Endif
		Else
			If  BI3->(BI3_FILIAL+BI3_CODINT+BI3_CODIGO+BI3_VERSAO) <> xFilial("BI3")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)
				BI3->(DbSetOrder(1))
				If ! BI3->(msSeek(xFilial("BI3")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)))
					If lPLS264E2
						Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0016})   //"Plano da famМlia nЦo cadastrado."
						PLSEXP1->(DbSkip())
						Loop
					Else
						cMsgCri := AllTrim(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)) + " - "
						cMsgCri += STR0016 //"Plano da famМlia nЦo cadastrado."
						If !Lweb
							If Aviso(STR0036,cMsgCri,{STR0006,STR0007},3,STR0038) == 1 //"CrМtica!"###"&Sim"###"&NЦo"###"Deseja Continuar?"
								PLSEXP1->(DbSkip())
								Loop
							Else
								PLSEXP1->(DbCloseArea())
								PLApag(cTrb)
								Return({.F.,{nQtd},aCriticas,aDados})
							EndIf
						Else
							PLSEXP1->(DbCloseArea())
							PLApag(cTrb)
							
							Aadd(aCriticas, {STR0036,cMsgCri}) 	
							Return({.F.,{nQtd},aCriticas,aDados})													
						Endif
						
					EndIf
				Endif
			Endif
		Endif
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se foi selecionado produto na tela de lote de carteirinha  Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If  ! empty(cProduto)
			If  BI3->BI3_CODIGO <> cProduto
				PLSEXP1->(DbSkip())
				Loop
			Endif
		Endif
		
		nRegBTS := BTS->(Recno())
		BA1->(DbSetOrder(2))
		BA1->(DbSeek(xFilial()+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+GetNewPar('MV_PLTRTIT','00'))))
		BTS->(DbSetOrder(1))
		BTS->(DbSeek(xFilial()+BA1->BA1_MATVID))
		
		If BDE->( FieldPos("BDE_NOMCAR") ) > 0 .And. TYPE("M->BDE_NOMCAR") <> "U" 
			If M->BDE_NOMCAR == "1"
				cNomTit := BTS->BTS_NOMCAR
			Else
				cNomTit := BTS->BTS_NOMUSR
			EndIf
		Else
			cNomTit := BTS->BTS_NOMCAR
		EndIf
		
		cUniver := BTS->BTS_UNIVER
		
		BTS->(DbGoto(nRegBTS))
		BA1->(DbGoTo(PLSEXP1->BA1REG))
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Posiciona BED...										 			Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If _nTipo == 4
			BED->(DbSetOrder(1))
			BED->(msSeek(xFilial("BED")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)))
			While BED->(BED_CODINT+BED_CODEMP+BED_MATRIC+BED_TIPREG) == BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)
				If BA1->BA1_VIACAR ==  BED->BED_VIACAR
					Exit
				Endif
				BED->(DbSkip())
			Enddo
			
			If BED->(BED_CODINT+BED_CODEMP+BED_MATRIC+BED_TIPREG) <> BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)
				If lPLS264E2
					Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),;
					STR0017+strzero(BA1->BA1_VIACAR,2)+STR0018})     //"Via de cartЦo "###" nЦo encontrada."
					PLSEXP1->(DbSkip())
					Loop
				Else
					cMsgCri := AllTrim(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG))+ " - "
					cMsgCri += STR0041 + strzero(BA1->BA1_VIACAR,2)+STR0018  //"Via de CartЦo"###" nЦo encontrada."
					If !Lweb
						If Aviso(STR0036,cMsgCri,{STR0006,STR0007},3,STR0038) == 1 //"CrМtica!"###"&Sim"###"&NЦo"###"Deseja Continuar?"
							PLSEXP1->(DbSkip())
							Loop
						Else
							PLSEXP1->(DbCloseArea())
							PLApag(cTrb)
							Return({.F.,{nQtd},aCriticas,aDados})
						EndIf
					Else
						PLSEXP1->(DbCloseArea())
						PLApag(cTrb)
							
						Aadd(aCriticas, {STR0036,cMsgCri}) 	
						Return({.F.,{nQtd},aCriticas,aDados})
					Endif
					
				EndIf
			Endif
		Endif
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Nao imprime Via com Titulo em aberto...						Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lReemissao
			If BED->BED_FATUR == "2"
				If lPLS264E2
					Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0019}) //"TМtulo da via de cartЦo em aberto."
					PLSEXP1->(DbSkip())
					Loop
				Else
					cMsgCri := AllTrim(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)) + " - "
					cMsgCri += STR0019 //"TМtulo da via de cartЦo em aberto."
					If !Lweb
						If Aviso(STR0036,cMsgCri,{STR0006,STR0007},3,STR0038) == 1 //"CrМtica!"###"&Sim"###"&NЦo"###"Deseja Continuar?"
							PLSEXP1->(DbSkip())
							Loop
						Else
							PLSEXP1->(DbCloseArea())
							PLApag(cTrb)
							Return({.F.,{nQtd},aCriticas,aDados})
						EndIf
						
					Else
						PLSEXP1->(DbCloseArea())
						PLApag(cTrb)
						Aadd(aCriticas, {STR0036,cMsgCri}) 	
						Return({.F.,{nQtd},aCriticas,aDados})
					Endif
					
				EndIf
			Endif
		Endif
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se usuario esta bloqueado...					 			Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If UsuBlq264(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),BA1->BA1_TIPREG,dDatabase, BA1->BA1_DATBLO, BA1->BA1_MOTBLO, BA1->BA1_CONSID)
			PLSEXP1->(DbSkip())
			Loop
		Endif
		
		aRetCar := {}
		
		If lPLS264CA
			aRetCar := ExecBlock("PLS264CA",.F.,.F.,{BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),BA1->BA1_TIPREG})
		EndIf
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se usuario possui Via de Cartao para emitir... 			Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		nRegBED := BED->(Recno())
		nOrdBED := BED->(IndexOrd())
		
		BED->(DbSetOrder(1))
		BED->(msSeek(xFilial("BED")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),.T.))
		
		nUltViaV := 0
		nRegBEDV := 0
		If BED->(FieldPos("BED_USRDEL")) > 0
			While BED->(BED_CODINT+BED_CODEMP+BED_MATRIC+BED_TIPREG) == BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)
				If BED->(FieldPos("BED_USRDEL")) > 0 
					If nUltViaV <= BED->BED_VIACAR  .and. Empty(BED->BED_USRDEL)
						nUltViaV := BED->BED_VIACAR
						nRegBEDV := BED->(Recno())
					Endif                          
				Else
					If nUltViaV <= BED->BED_VIACAR  
						nUltViaV := BED->BED_VIACAR
						nRegBEDV := BED->(Recno())
					Endif                          
				Endif
				BED->(DbSkip())
			Enddo
		EndIf
				
		If nRegBEDV > 0
			BED->(DbGoTo(nRegBEDV))
		EndIf
		
		If BED->(BED_FILIAL+BED_CODINT+BED_CODEMP+BED_MATRIC+BED_TIPREG) == BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG) .and. !lImpressao
			
			If  BED->BED_STACAR == "1"
			
				If lPLS264E2
			
					Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0020+AllTrim(BED->BED_VIACAR)+STR0056+BED->BED_CDIDEN+STR0022})     //"Via de nЗmero "###" gerada pelo lote "###" estА em aberto e precisa ser encerrada."
					
					BED->(DbSetOrder(nOrdBED))
					BED->(DbGoTo(nRegBED))
					PLSEXP1->(DbSkip())
					Loop
				Else
					cMsgCri := AllTrim(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)) +" - " + BA1->BA1_NOMUSR + CHR(13) + CHR(10)
					
					If AllTrim(BED->BED_CDIDEN) <> STR0002 //"AVULSA"
						cMsgCri += STR0020+AllTrim(BED->BED_VIACAR)+STR0056+BED->BED_CDIDEN + CHR(13) + CHR(10) //"Via de nЗmero "###" gerada pelo lote "
						cMsgCri += STR0045 //"EstА em aberto e precisa ser encerrada."
					Else
						cMsgCri += STR0064 //"O LanГamento avulso do beneficiАrio estА em aberto e precisa ser encerrado."
					Endif
					
					If !lWeb
						If Aviso(STR0036,cMsgCri,{STR0006,STR0007},3,STR0038) == 1 //"CrМtica!"###"&Sim"###"&NЦo"###"Deseja Continuar?"
							BED->(DbSetOrder(nOrdBED))
							BED->(DbGoTo(nRegBED))
							PLSEXP1->(DbSkip())
							Loop
						Else
							PLSEXP1->(DbCloseArea())
							PLApag(cTrb)
							Return({.F.,{nQtd},aCriticas,aDados})
						EndIf
					Else
						PLSEXP1->(DbCloseArea())
						PLApag(cTrb) 
						Aadd(aCriticas, {STR0036,cMsgCri}) 	
						Return({.F.,{nQtd},aCriticas,aDados})							
		
					Endif
					
				EndIf
			Endif
			nUltVia := BED->BED_VIACAR
		Else
			nUltVia := BA1->BA1_VIACAR
		Endif
		
		BED->(DbSetOrder(nOrdBED))
		If nRegBEDV > 0
			BED->(DbGoTo(nRegBEDV))
		Else
		BED->(DbGoTo(nRegBED))
		EndIf
		
		
		If ! lReemissao
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Nao permite emitir uma nova Via caso a ultima esteja em aberto...	Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If BA1->BA1_VIACAR <> nUltVia .And. BED->BED_STACAR == "1"
			 
				If lPLS264E2
					Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0023})     //"зltima via do usuАrio encontra-se em aberto."
					PLSEXP1->(DbSkip())
					Loop
				Else
					cMsgCri := AllTrim(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG))+ " - "
					cMsgCri += STR0023 	    	 //"зltima via do usuАrio encontra-se em aberto."
					
					If !Lweb
						If Aviso(STR0036,cMsgCri,{STR0006,STR0007},3,STR0038) == 1 //"CrМtica!"###"&Sim"###"&NЦo"###"Deseja Continuar?"
							PLSEXP1->(DbSkip())
							Loop
						Else
							PLSEXP1->(DbCloseArea())
							PLApag(cTrb)
							Return({.F.,{nQtd},aCriticas,aDados})
						EndIf
					Else
						PLSEXP1->(DbCloseArea())
						PLApag(cTrb)
						Aadd(aCriticas, {STR0036,cMsgCri}) 	
						Return({.F.,{nQtd},aCriticas,aDados})							
						
					Endif
					
				EndIf
			Endif
			
		Else
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifica se a via do cartao esta bloqueada...						Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If BED->( FieldPos("BED_CODBLO") ) = 0 .or. BED->( FieldPos("BED_BLOIDE") ) = 0
				If lPLS264E2
					Aadd(aCriticas, {'',STR0057})     //"DicionАrio de dados desatualizado!"
					PLSEXP1->(DbSkip())
					Loop
				Else
					If !Lweb
						If Aviso(STR0036,STR0057,{STR0006,STR0007},3,STR0038) == 1 //"CrМtica!"###"DicionАrio de dados desatualizado!"###"&Sim"###"&NЦo"###"Deseja Continuar?"
							PLSEXP1->(DbSkip())
							Loop
						Else
							PLSEXP1->(DbCloseArea())
							PLApag(cTrb)
							Return({.F.,{nQtd},aCriticas,aDados})
						EndIf
					Else
						PLSEXP1->(DbCloseArea())
						PLApag(cTrb)
						Aadd(aCriticas, {STR0036,cMsgCri}) 	
						Return({.F.,{nQtd},aCriticas,aDados})							
						
					Endif
					
				EndIf
			Else
				If BED->BED_BLOIDE == "1"
					If lPLS264E2
						Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0024})     //"Via de cartЦo bloqueada."
						PLSEXP1->(DbSkip())
						Loop
					Else
						cMsgCri := AllTrim(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)) + " - "
						cMsgCri += STR0024 //"Via de cartЦo bloqueada."
						
						If !Lweb
							If Aviso(STR0036,cMsgCri,{STR0006,STR0007},3,STR0038) == 1 //"CrМtica!"###"&Sim"###"&NЦo"###"Deseja Continuar?"
								PLSEXP1->(DbSkip())
								Loop
							Else
								PLSEXP1->(DbCloseArea())
								PLApag(cTrb)
								Return({.F.,{nQtd},aCriticas,aDados})
							EndIf
						Else
							PLSEXP1->(DbCloseArea())
							PLApag(cTrb)
							Aadd(aCriticas, {STR0036,cMsgCri}) 	
							Return({.F.,{nQtd},aCriticas,aDados})										
						Endif
						
					EndIf
				Endif
			Endif
			
		Endif
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Ponto de Entrada antes da Emissao... 								Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lPLS264EM
			If ! ExecBlock("PLS264EM",.F.,.F.,{_nTipo})
				PLSEXP1->(DbSkip())
				Loop
			Endif
		Endif
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Ponto de Entrada antes da Emissao... enviando dados para manipular as criticas Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lPLS264E2
			aRetPto := ExecBlock("PLS264E2",.F.,.F.,{_nTipo,aCriticas})
			If ! aRetPto[1]
				aCriticas := aClone(aRetPto[2])
				PLSEXP1->(DbSkip())
				Loop
			Endif
		Endif
		
		If lCartaoVirtual
			aRetVlrCar := {0, "0", "", "", "", "", 0, .T., 0, "", BA1->BA1_CODINT, BA1->BA1_CODEMP, BA1->BA1_MATRIC, BA1->BA1_TIPREG}
		Else
			aRetVlrCar := PLSEXPIVL(BA1->BA1_CODINT	,	BA1->BA1_CODEMP,	BA1->BA1_CONEMP,	BA1->BA1_VERCON,;
									BI3->BI3_CODIGO,	BI3->BI3_VERSAO,	BG9->BG9_TIPO,		BA1->BA1_VIACAR,;
									BA1->BA1_TIPUSU,	BA1->BA1_GRAUPA,	BA1->BA1_MATRIC,	BA1->BA1_TIPREG,;
									BA1->BA1_SUBCON,	BA1->BA1_VERSUB,	If(nUltVia = 0,GetNewPar("MV_PLSMP1V","4"),cMotivo))
		EndIf
		
		If lOK .and. ! aRetVlrCar[8]
			MostraErro()
			lOK := .F.
		Endif
		
		If !lReemissao
			If aRetVlrCar[8]
				
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Calcula Nova Data de Validade... 									Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If cMudaVal == "1"
					If Empty(dDatVal)
						If BA3->BA3_TIPOUS == "1"
							nPerRen := nPeRePF
						Else
							nPerRen := BQC->BQC_NPERRN
						Endif
						dDtVali := BA1->BA1_DTVLCR
						While nPerRen > 12
							dDtVali := stod(strzero((val(substr(dtos(dDtVali),1,4))+1),4)+substr(dtos(dDtVali),5,4))
							nPerRen := nPerRen-12
						EndDo
						dDtVali := stod(substr(dtos(stod(substr(dtos(dDtVali),1,6)+"15")+(nPerRen*30)),1,6)+substr(dtos(dDtVali),7,2))
					Else
						dDtVali := dDatVal
					Endif
					If  lPLS264DT
						dDtVali := ExecBlock("PLS264DT",.F.,.F.,{dDtVali})
					Endif
					
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    			    //Ё So atualiza data no sub-contrato se for geracao por lote            Ё
	    		    //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		     		If FunName() == "PLSA262" .And. TYPE("M->BDE_DTRNCR") == "D" 

					    If  BA3->BA3_TIPOUS <> "1" .and. BDE->(fieldpos("BDE_DTRNCR")) > 0 .And. ! Empty(M->BDE_DTRNCR) .And. BQC->BQC_VALID <> M->BDE_DTRNCR
					    	BQC->(RecLock("BQC",.F.))
					    		BQC->BQC_VALID := M->BDE_DTRNCR
					    	BQC->(MsUnLock())
				     	Endif

					EndIf
				Else
					dDtVali := BA1->BA1_DTVLCR
				Endif
				If BA1->BA1_TIPUSU <> cTipUsu
					If cMaior == "1" .And.;
						BDE->(FieldPos("BDE_MAIORI")) > 0 .And.;
						BDE->(FieldPos("BDE_GFILHO")) > 0 .And.;
						BDE->(FieldPos("BDE_GFILUN")) > 0 .And.;
						BDE->(FieldPos("BDE_GFILHA")) > 0 .And.;
						BDE->(FieldPos("BDE_GFILAU")) > 0 .And.;
						BDE->BDE_MAIORI == "1" .And.;
						BA1->BA1_GRAUPA $ (M->BDE_GFILHO,M->BDE_GFILUN,M->BDE_GFILHA,M->BDE_GFILAU)
						
						BT0->(DbSetOrder(1))
						BT1->(DbSetOrder(1))
						If BT0->(MsSeek(xFilial("BT0") + BA1->(BA1_CODINT + BA1_CODEMP + BA1_NUMCON + BA1_VERCON + BA1_SUBCON + BA1_VERSUB) + BI3->(BI3_CODIGO + BI3_VERSAO)))
							While BT0->(BT0_FILIAL + BT0_CODIGO + BT0_NUMCON + BT0_VERCON + BT0_SUBCON + BT0_VERSUB + BT0_CODPRO + BT0_VERSAO) ==;
								(xFilial("BT0") + BA1->(BA1_CODINT + BA1_CODEMP + BA1_NUMCON + BA1_VERCON + BA1_SUBCON + BA1_VERSUB)+BI3->(BI3_CODIGO + BI3_VERSAO))
								If BT0->BT0_GRAUPA == BA1->BA1_GRAUPA .And.;
									BT0->BT0_TIPUSR == BA1->BA1_TIPUSU .And.;
									BT0->BT0_ESTCIV == BA1->BA1_ESTCIV .And.;
									BT0->BT0_SEXO == BA1->BA1_SEXO
									
									_nIdMAXm := BT0->BT0_IDAMAX
								EndIf
								BT0->(DbSkip())
							EndDo
						ElseIf BT1->(MsSeek(xFilial("BT1")+ BI3->(BI3_CODINT + BI3_CODIGO + BI3_VERSAO)))
							While BT1->(BT1_FILIAL + BT1_CODIGO + BT1_VERSAO + BT1_TIPUSR) ==;
								(xFilial("BT1") + BI3->(BI3_CODINT + BI3_CODIGO + BI3_VERSAO) + BA1->(BA1_TIPUSU))
								If BT1->BT1_GRAUPA == BA1->BA1_GRAUPA .And.;
									BT1->BT1_TIPUSR == BA1->BA1_TIPUSU .And.;
									BT1->BT1_ESTCIV == BA1->BA1_ESTCIV .And.;
									BT1->BT1_SEXO == BA1->BA1_SEXO
									
									_nIdMAXm := BT1->BT1_IDAMAX
								EndIf
								BT1->(DbSkip())
							EndDo
						EndIf
						If Empty(_nIdMAXm)
							Do Case
								Case BA1->BA1_SEXO == "1" .And. cUniver == "1"
									//BA1->BA1_SEXO == 1 - Masculino // BTS->BTS_UNIVER == 1 - Sim
									_nIdMAXm := IIF(BDE->BDE_IMFOUN > 0, BDE->BDE_IMFOUN, cMvPLSFIOU)  
								Case BA1->BA1_SEXO == "1" .And. cUniver == "0"
									//BA1->BA1_SEXO == 1 - Masculino // BTS->BTS_UNIVER == 0 - Nao
									_nIdMAXm := IIF(BDE->BDE_IMFILO > 0, BDE->BDE_IMFILO, cMvPLSFILO)  
								Case BA1->BA1_SEXO == "2" .And. cUniver == "1"
									//BA1->BA1_SEXO == 2 - Feminino // BTS->BTS_UNIVER == 1 - Sim
									_nIdMAXm := IIF(BDE->BDE_IMFAUN > 0, BDE->BDE_IMFAUN, cMvPLSFIAU)  
								Case BA1->BA1_SEXO == "2" .And. cUniver == "0"
									//BA1->BA1_SEXO == 2 - Feminino // BTS->BTS_UNIVER == 0 - Nao
									_nIdMAXm := IIF(BDE->BDE_IMFIHA > 0, BDE->BDE_IMFIHA, cMvPLSFILA)  
							EndCase
						EndIf
						_nAno := Year(BA1->BA1_DATNAS) + _nIdMaxm
						_sMesDia := SUBSTR(DTOS(BA1->BA1_DATNAS),5,4)
						If _sMesDia  == '0229' .or. _sMesDia  == '0228'
							_sMesDia := '0301'
						Endif
						If _sMesDia  == '1231'
							_nAno  := _nAno +1
						Endif
						If (STOD(Str(_nAno,4) + _sMesDia ) + 1) < dDtVali
							dDtVali := STOD(Str(_nAno,4) + _sMesDia ) + 1
						EndIf
					EndIf
				EndIf
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Se nao teve cobranca ou nao foi cobrado direto do usuario... Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				if !lImpressao .Or. _nTipo == 2
				
					If aRetVlrCar[1] == 0 .or. aRetVlrCar[2] <> "2"
						
						BA1->(RecLock("BA1",.F.))
							BA1->BA1_VIACAR 	:= BA1->BA1_VIACAR + 1
							cCodAnt				:= BA1->BA1_CDIDEN
							BA1->BA1_CDIDEN  	:= cCodigo
							If  ! empty(dDtVali)
								BA1->BA1_DTVLCR := dDtVali
							Endif
						BA1->(MsUnLock())
						
						If lPLS264FAM
							If ! ExecBlock("PLS264FAM",.F.,.F.) .Or. ExecBlock("PLS264FAM",.F.,.F.,{BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)})
								GrvVldCarUsr(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),dDtVali)
							Endif
						Else
							GrvVldCarUsr(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),dDtVali)
						EndIf
						
					Endif
					
					If  lPLS264VL  // PONTO DE ENTRADA PARA GRAVAR DATA DE VALIDADE EM OUTRAS TABELAS RELACIONADAS
						ExecBlock("PLS264VL",.F.,.F.,{dDtVali})
					Endif
				
					BED->(RecLock("BED",.T.))
						BED->BED_FILIAL := xFilial("BED")
						BED->BED_CODINT := BA1->BA1_CODINT
						BED->BED_CODEMP := BA1->BA1_CODEMP
						BED->BED_MATRIC := BA1->BA1_MATRIC
						BED->BED_TIPREG := BA1->BA1_TIPREG
						BED->BED_DIGITO := BA1->BA1_DIGITO
						BED->BED_MATANT := BA1->BA1_MATANT
						BED->BED_TIPANT := BA1->BA1_TIPANT
						BED->BED_NOMUSR := BA1->BA1_NOMUSR
						BED->BED_VALOR  := aRetVlrCar[1]
						BED->BED_DTSOLI := dDataBase
						BED->BED_CDIDEN := cCodigo
						BED->BED_DATVAL := dDtVali		
						BED->BED_CODANT := cCodAnt
						BED->BED_ORIGEM := AllTrim(FunName())
		
						
						If BED->( FieldPos("BED_PROTOC") ) <> 0 .and. LWeb
							BED->BED_PROTOC := cProtoc
						Endif
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Tratamento para verificar se o sistema ira imprimir o cartao Ё
						//Ё com o nome do cartao ou do usuario quando a rotina for       Ё
						//Ё chamada pelo Call-Center.                                    Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						If BED->( FieldPos("BED_NOMCAR") ) <> 0
							If FunName() == "TMKA271" 
							    If GetNewPar("MV_PLCATMK","0") == "1"
							        BED->BED_NOMCAR := "1"
							    Else
							        BED->BED_NOMCAR := "0"
							    EndIf
							Else
							    BED->BED_NOMCAR := M->BDE_NOMCAR
							EndIf   
						EndIf
		
						If BED->( FieldPos("BED_BLOIDE") ) <> 0
							BED->BED_BLOIDE := "0"
						Endif
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Se nao teve cobranca ou nao foi cobrado direto do usuario... Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						If aRetVlrCar[1] == 0 .or. aRetVlrCar[2] <> "2"
							BED->BED_VIACAR := BA1->BA1_VIACAR
						Else
							BED->BED_VIACAR := BA1->BA1_VIACAR + 1
						Endif
						
						If BED->BED_VIACAR == 1
							BED->BED_MOTIVO := GetNewPar("MV_PLSMP1V","4")
						Else
							BED->BED_MOTIVO := cMotivo
						EndIf
						
						If aRetVlrCar[2] == "2" //Aguardando liquidacao do titulo...
							BED->BED_FATUR := "2"
						Elseif aRetVlrCar[2] == "1" //Faturado para proxima cobranca...
							BED->BED_FATUR  := If(BED->BED_VALOR==0,"0","1")
						Elseif aRetVlrCar[2] == "0" //Nao Faturado...
							BED->BED_FATUR := "0"
						Endif
						
						If BED->BED_FATUR $ "1,2"
							BED->BED_ANMSFT := subs(dtos(dDataBase),1,6)
						Else
							BED->BED_ANMSFT := ""
						Endif
						
						BED->BED_NUMCOB := IIf(lCartaoVirtual, "VIRTUAL", STR0002) //"AVULSA"
						BED->BED_COBRAR := aRetVlrCar[2]
						BED->BED_PREFIX := aRetVlrCar[3]
						BED->BED_NUMTIT := aRetVlrCar[4]
						BED->BED_PARCEL := aRetVlrCar[5]
						BED->BED_TIPTIT := aRetVlrCar[6]
						
						BED->BED_STACAR := "1"
					
					BED->(MsUnLock())
				endIf
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Acumula quantidade de registros criados...					Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				nQtd ++
			Endif
		EndIf
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Valida via do Cartao...										Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If BA1->BA1_VIACAR == 0 .And. aRetVlrCar[2] <> "2" .and. !lImpressao

			If lPLS264E2
				Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0025}) //"Via do cartЦo do usuАrio invАlida."
				PLSEXP1->(DbSkip())
				Loop
			Else
				cMsgCri := AllTrim(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)) + " - "
				cMsgCri += STR0025 //"Via do cartЦo do usuАrio invАlida."
				
				If !Lweb

					If Aviso(STR0036,cMsgCri,{STR0006,STR0007},3,STR0038) == 1 //"CrМtica!"###"&Sim"###"&NЦo"###"Deseja Continuar?"
						PLSEXP1->(DbSkip())
						Loop
					Else
						PLSEXP1->(DbCloseArea())
						PLApag(cTrb)
						Return({.F.,{nQtd},aCriticas,aDados})
					EndIf
				Else
					PLSEXP1->(DbCloseArea())
					PLApag(cTrb)
					Aadd(aCriticas, {STR0036,cMsgCri}) 	
					Return({.F.,{nQtd},aCriticas,aDados})													
				Endif
				
			EndIf
		Endif
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Alimenta Data de Validade e Via do Cartao...						Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lReemissao
			nViaCar := BED->BED_VIACAR
			dDtVali := BED->BED_DATVAL
		Else
			nViaCar := BA1->BA1_VIACAR
			dDtVali := BA1->BA1_DTVLCR
		Endif
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Mensagens para cabecalho...									Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		aCabCar := PLSM02TEXT( BA1->BA1_CODINT, 3, BA3->BA3_TIPOUS, BI3->BI3_MODPAG, BA1->BA1_CODEMP, BA1->BA1_CONEMP, BA1->BA1_SUBCON,	BA1->BA1_MATRIC, BI3->BI3_CODIGO, substr(dtos(dDataBase),1,6))
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Mensagens para rodape...									Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		aRodCar := PLSM02TEXT( BA1->BA1_CODINT, 4, BA3->BA3_TIPOUS, BI3->BI3_MODPAG, BA1->BA1_CODEMP, BA1->BA1_CONEMP, BA1->BA1_SUBCON,	BA1->BA1_MATRIC, BI3->BI3_CODIGO, substr(dtos(dDataBase),1,6))
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё LayOut PLS... 						                                Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If nLayOut == 1
			cDataNasc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATNAS),2), cMes := StrZero(Month(BA1->BA1_DATNAS),2), cAno := StrZero(Year(BA1->BA1_DATNAS),4), cDia+"/"+cMes+"/"+cAno })
			cDataInsc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATINC),2), cMes := StrZero(Month(BA1->BA1_DATINC),2), cAno := StrZero(Year(BA1->BA1_DATINC),4), cDia+"/"+cMes+"/"+cAno })
			cDataValid:= Eval({ || cDia := StrZero(Day(dDtVali),2), cMes := StrZero(Month(dDtVali),2), cAno := StrZero(Year(dDtVali),4), cDia+"/"+cMes+"/"+cAno })
			cDatXInsc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATINC),2), cMes := StrZero(Month(BA1->BA1_DATINC),2), cAno := StrZero(Year(BA1->BA1_DATINC),4), cDia+"/"+cMes+"/"+cAno })					
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё LayOut PTU... 						                                Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		ElseIf nLayOut == 2
			cDataNasc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATNAS),2), cMes := StrZero(Month(BA1->BA1_DATNAS),2), cAno := StrZero(Year(BA1->BA1_DATNAS),4), cDia+"/"+cMes+"/"+cAno })
			cDataInsc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATINC),2), cMes := StrZero(Month(BA1->BA1_DATINC),2), cAno := StrZero(Year(BA1->BA1_DATINC),4), cDia+cMes+SubStr(cAno,3) })
			cDatXInsc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATINC),2), cMes := StrZero(Month(BA1->BA1_DATINC),2), cAno := StrZero(Year(BA1->BA1_DATINC),4), cDia+"/"+cMes+"/"+cAno })			
			cDataValid:= Eval({ || cDia := StrZero(Day(dDtVali),2), cMes := StrZero(Month(dDtVali),2), cAno := StrZero(Year(dDtVali),4), cDia+"/"+cMes+"/"+cAno })
		ElseIf nLayOut == 3
			cDataNasc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATNAS),2), cMes := StrZero(Month(BA1->BA1_DATNAS),2), cAno := StrZero(Year(BA1->BA1_DATNAS),4), cDia+"/"+cMes+"/"+cAno })
			cDataInsc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATINC),2), cMes := StrZero(Month(BA1->BA1_DATINC),2), cAno := StrZero(Year(BA1->BA1_DATINC),4), cDia+cMes+SubStr(cAno,3) })
			cDataValid:= Eval({ || cDia := StrZero(Day(dDtVali),2), cMes := StrZero(Month(dDtVali),2), cAno := StrZero(Year(dDtVali),4), cDia+"/"+cMes+"/"+cAno })
			cDatXInsc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATINC),2), cMes := StrZero(Month(BA1->BA1_DATINC),2), cAno := StrZero(Year(BA1->BA1_DATINC),4), cDia+"/"+cMes+"/"+cAno })			
		elseIf nLayOut == 4
			cDataNasc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATNAS),2), cMes := StrZero(Month(BA1->BA1_DATNAS),2), cAno := StrZero(Year(BA1->BA1_DATNAS),4), cDia+"/"+cMes+"/"+cAno })
			cDataInsc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATINC),2), cMes := StrZero(Month(BA1->BA1_DATINC),2), cAno := StrZero(Year(BA1->BA1_DATINC),4), cDia+"/"+cMes+"/"+cAno })
			cDataValid:= Eval({ || cDia := StrZero(Day(dDtVali),2), cMes := StrZero(Month(dDtVali),2), cAno := StrZero(Year(dDtVali),4), cDia+"/"+cMes+"/"+cAno })
			cDatXInsc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATINC),2), cMes := StrZero(Month(BA1->BA1_DATINC),2), cAno := StrZero(Year(BA1->BA1_DATINC),4), cDia+"/"+cMes+"/"+cAno })					
		
		Endif
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Retorna a carencia dos produtos...							Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		aDadCar := PLSLISMSGC(	PLSEXP1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO), BI3->(BI3_CODINT+BI3_CODIGO),;
								PLSEXP1->BA3_VERSAO,PLSEXP1->BA1_DATCAR,PLSEXP1->BA1_SEXO)
		
		aRetNome:= PLSAVERNIV(	PLSEXP1->BA1_CODINT, PLSEXP1->BA1_CODEMP, PLSEXP1->BA1_MATRIC,	IF(PLSEXP1->BA3_TIPOUS=="1","F","J"),;
								PLSEXP1->BA3_CONEMP, PLSEXP1->BA3_VERCON, PLSEXP1->BA3_SUBCON, PLSEXP1->BA3_VERSUB, 1,;
								PLSEXP1->BA1_TIPREG)
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Alimenta arquivo com os dados para arquivo texto...			Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		Dados->(RecLock("Dados",.T.))
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Ponto de Entrada para impressao com LayOut diferente...             Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lPLS264L2 
			nOriDad := 0
			cAlias := "PLSEXP1"
			ExecBlock("PLS264L2",.F.,.F.,{cAlias})
			nSeqCar++
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё LayOut PLS... 						                                Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		ElseIf nLayOut == 1
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Tarja magnetica... 						                            Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			Dados->TARJAMAG1 :=	PLSEXP1->BA1_CODINT+;
								PLSEXP1->BA1_CODEMP+;
								PLSEXP1->BA1_MATRIC+;
								PLSEXP1->BA1_TIPREG+;
								PLSEXP1->BA1_DIGITO+;
								"="+; //Campo separador
								Strzero(nViaCar,2)+;
								SubStr(cDataValid,9,2)+SubStr(cDataValid,4,2)+;
								"="+; //Campo separador
								PLSEXP1->BA1_OPERES+;
								BI3->BI3_IDECAR+; //Codigo do produto no Intercambio
								SubStr(BI3->BI3_ABRANG,Len(BI3->BI3_ABRANG),1)+;
								PLSEXP1->BA3_TIPCON
			If BDE->( FieldPos("BDE_NOMCAR") ) > 0 .And. TYPE("M->BDE_NOMCAR") <> "U" 
				If M->BDE_NOMCAR == "1"
					Dados->TARJAMAG2 := PLSEXP1->BTS_NOMCAR
				Else
					Dados->TARJAMAG2 := PLSEXP1->BTS_NOMUSR
				EndIf
			Else
				Dados->TARJAMAG2 := PLSEXP1->BTS_NOMCAR
			EndIf
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Frente do Cartao... 						                        Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			Dados->MATRICULA := PLSEXP1->BA1_CODINT + " " +;
								PLSEXP1->BA1_CODEMP + " " +;
								PLSEXP1->BA1_MATRIC + " " +;
								PLSEXP1->BA1_TIPREG + " " +;
								PLSEXP1->BA1_DIGITO
			
			If  BA3->BA3_TIPOUS == "1"
				Do Case
					Case BI3->BI3_NATJCO = "2"
						Dados->CONTRATACA := BI3->BI3_NATJCO + STR0048 //"-FISICA"
					Case BI3->BI3_NATJCO = "3"
						Dados->CONTRATACA := BI3->BI3_NATJCO + STR0049 //"-EMPRESARIAL"
					Case BI3->BI3_NATJCO = "4"
						Dados->CONTRATACA := BI3->BI3_NATJCO + STR0050 //"-ADESAO"
					Case BI3->BI3_NATJCO = "5"
						Dados->CONTRATACA := BI3->BI3_NATJCO + STR0051 //"-BENEFICENTE"
				EndCase
			Else
				If  BQC->BQC_ENTFIL == "1"
					Dados->CONTRATACA := STR0052   // Beneficente //"5-BENEFICENTE"
				Else
					If  !(BT5->BT5_TIPCON $ "3,4")
						Dados->CONTRATACA := STR0054   // Empresarial //"3-EMPRESARIAL"
					Endif
				Endif
			Endif
			
			If BDE->( FieldPos("BDE_NOMCAR") ) > 0 .And. TYPE("M->BDE_NOMCAR") <> "U" 
				If M->BDE_NOMCAR == "1"
					Dados->NOMEUSUARI := PLSEXP1->BTS_NOMCAR
				Else
					Dados->NOMEUSUARI := PLSEXP1->BTS_NOMUSR
				EndIf
			Else
				Dados->NOMEUSUARI := PLSEXP1->BTS_NOMCAR
			EndIf
			Dados->DTNACTO    := cDataNasc
			Dados->DTVALID    := cDataValid
			Dados->DTINC      := cDataInsc
			Dados->PLANO      := BI3->BI3_CODIGO
			Dados->TPCONTRATO := BI3->BI3_NATJCO
			
			//Para customizar campos como por exemplo "BQC_YNOMCA" e BQC_YINFCA
			If lPL264INFO
				aRetInfo:= ExecBlock("PL264INFO",.F.,.F.,{Dados->NOMEUSUARI,Dados->DTNACTO,Dados->DTVALID,Dados->DTINC,Dados->PLANO,Dados->TPCONTRATO,BA3->BA3_TIPOUS,aRetNome[1][3]})
				Dados->RZSOCIAL   := aRetInfo[1]
				Dados->INFORMACOE := aRetInfo[2]
			Else
				If  BA3->BA3_TIPOUS <> "1" .and. !Empty(BQC->BQC_NOMCAR)
					Dados->RZSOCIAL   := BQC->BQC_NOMCAR
				Else
					Dados->RZSOCIAL   := aRetNome[1][3]
				Endif
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Verso do Cartao... 						                        	Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				Dados->INFORMACOE := STR0055 //"InformaГУes"
			EndIf
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁCarrega informacoes das mensagens dinamicamente...					Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			For nI := 1 To Len(aCabCar)
				If nI > 8
					Exit
				EndIf
				Dados->&("MENSAGEM"+strzero(nI,1)) := Alltrim(aCabCar[nI])
			Next nI
			
			For nCarencia := 1 To Len(aDadCar)
				If nI > 8
					Exit
				EndIf
				Dados->&("MENSAGEM"+strzero(nI,1)) := Alltrim(Alltrim(aDadCar[nCarencia][2])+"-"+dtoc(aDadCar[nCarencia][3]))
				nI++
			Next nCarencia
			
			For nRodape := 1 To Len(aRodCar)
				If nI>8
					Exit
				EndIf
				Dados->&("MENSAGEM"+strzero(nI,1)) := Alltrim(aRodCar[nRodape])
				nI++
			Next nRodape
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё LayOut PTU... 						                                Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		ElseIf nLayOut == 2
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Linha 1       						                                Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды									
			Dados->SEP01     := "#DCC##EMB#"
			Dados->CODSISCOP := "0"
			Dados->UNIBENEF  := SubStr(PLSEXP1->BA1_CODINT,2)
			Dados->EMPRESA   := PLSEXP1->BA1_CODEMP
			Dados->INSCRICAO := PLSEXP1->BA1_MATRIC
			Dados->GRAUDEPEN := PLSEXP1->BA1_TIPREG
			Dados->DIGITO    := PLSEXP1->BA1_DIGITO
			Dados->CRLF01    := '"'
			
			Dados->CNESUSU	 :=  AllTrim(PLSEXP1->BTS_NRCRNA)
			Dados->SEGASSPL  :=  padr(substr(POSICIONE("BI6",1,XFILIAL("BI6")+ BI3->BI3_CODSEG,"BI6_DESCRI"),1,56),56)
			                        
			If BQC->(FieldPos('BQC_SEASPL')) > 0 .and. BA3->BA3_TIPOUS <> '1'
				Dados->SEASPL  :=  BQC->BQC_SEASPL
			Endif
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Linha 2       						                                Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды				
			Dados->DTNACTO   := cDataNasc			
			If  BA3->BA3_TIPOUS == "1"
				Do Case
					Case BI3->BI3_NATJCO = "2"
						Dados->CONTRATACA := 'INDIVIDUAL OU FAMILIAR'
					Case BI3->BI3_NATJCO = "3"
						Dados->CONTRATACA := 'COLETIVO EMPRESARIAL'
					Case BI3->BI3_NATJCO = "4"
						Dados->CONTRATACA := 'COLETIVO POR ADESAO'
					Case BI3->BI3_NATJCO = "5"
						Dados->CONTRATACA := 'BENEFICIENTE'
					Otherwise
						Dados->CONTRATACA := "SEM CONTRATACAO"
				EndCase
			Else
				If  AllTrim(BQC->BQC_ENTFIL) == "1"
					Dados->CONTRATACA := 'BENEFICIENTE'
				Else
					BII->(DbSetOrder(1))
					If lTpCtrBI3 .AND. BII->( msSeek(xFilial("BII")+BI3->BI3_TIPCON) ) .AND. !EMPTY(BII->BII_TIPPLA)
						If  AllTrim(BII->BII_TIPPLA) $ "1,3"
							Dados->CONTRATACA := 'COLETIVO POR ADESAO'
						Else
							Dados->CONTRATACA := 'COLETIVO EMPRESARIAL'
						Endif
					Else
						If BII->( msSeek(xFilial("BII")+BT5->BT5_TIPCON) ) .AND. !EMPTY(BII->BII_TIPPLA)
							If  AllTrim(BII->BII_TIPPLA) $ "1,3"
								Dados->CONTRATACA := 'COLETIVO POR ADESAO'
							Else
								Dados->CONTRATACA := 'COLETIVO EMPRESARIAL'
							Endif
						Endif
					EndIf
				Endif
			Endif
				
			BI4->(dbSetOrder(1))      			
			If Empty(BI3->BI3_CODACO)
				Dados->TPACOMODA := PadR(STR0061, 13)	// "NAO SE APLICA"								
			Else
				If BI4->(MsSeek(xFilial("BI4")+AllTrim(BI3->(BI3_CODACO)))) .And.;
					BI4->(FieldPos("BI4_CODEDI")) > 0
											
					If Empty(BI4->BI4_CODEDI)
						Dados->TPACOMODA := PadR(STR0061, 13)	// "NAO SE APLICA"
					Else
						If AllTrim(BI4->BI4_CODEDI) == "1"
							Dados->TPACOMODA := PadR(STR0062,13)	// INDIVIDUAL
						ElseIf AllTrim(BI4->BI4_CODEDI) == "2"
							Dados->TPACOMODA := PadR(STR0063,13)	// COLETIVA
						Else
							Dados->TPACOMODA := PadR(STR0061, 13) 	// "NAO SE APLICA"     
						EndIf
					EndIf   
				Else 
					Dados->TPACOMODA := PadR(STR0061, 13)	// "NAO SE APLICA"     
				EndIf
			EndIf		  
			Dados->DTVIGPL    := cDatXInsc
			Dados->DTVALID    := cDataValid
			Dados->CRLF02	:= '"'
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Linha 3       						                                Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды				
			If BDE->( FieldPos("BDE_NOMCAR") ) > 0 .And. TYPE("M->BDE_NOMCAR") <> "U" 
				If M->BDE_NOMCAR == "1"
					Dados->NOMEUSUARI := PadR(PLSEXP1->BTS_NOMCAR,25)
				Else
					Dados->NOMEUSUARI := PadR(PLSEXP1->BTS_NOMUSR,25)
				EndIf
			Else
				Dados->NOMEUSUARI := PadR(PLSEXP1->BTS_NOMCAR,25)
			EndIF        			
			                 
			If BI3->(FieldPos("BI3_REDEDI")) > 0 
				Dados->REDATE := BI3->BI3_REDEDI			
			EndIf
			
			Dados->CRLF03     := '"'            
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Linha 4       						                                Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды						
			If  ! empty(BA1->BA1_LOCCOB)
				If  BA1->BA1_LOCCOB == "1" // origem
					cLocCob := BA1->BA1_OPEORI
				Else
					cLocCob := BA1->BA1_OPEDES
				Endif
			Else
				cLocCob     := PlsIntPad()
			Endif
			
			Dados->LOCALCOB := cLocCob
			Dados->DESPLA   := BI3->BI3_DESCAR			
			
			Do Case
				Case BI3->BI3_ABRANG == "01"
					Dados->ABRANG := "NACIONAL"
				Case BI3->BI3_ABRANG == "02"
					Dados->ABRANG := "GRUPO DE ESTADOS"
				Case BI3->BI3_ABRANG == "03"
					Dados->ABRANG := "ESTADUAL"
				Case BI3->BI3_ABRANG == "04"
					Dados->ABRANG := "GRUPO DE MUNICмPIOS"
				Case BI3->BI3_ABRANG == "05"
					Dados->ABRANG := "LOCAL"
				Otherwise
					Dados->ABRANG := BI3->BI3_ABRANG
			EndCase
			Dados->VIACAR    := strzero(nViaCar,2)                                                         			
			Dados->CRLF04    := '"'				
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Linha 5       						                                Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды                    			
			Dados->CPT       := IIF(empty(dDatCpt),PadR("NцO Hа",12),substr(dtos(dDatCpt),7,2)+"/"+substr(dtos(dDatCpt),5,2)+"/"+substr(dtos(dDatCpt),1,4))			
			Dados->NREDUZ    := IIF(BA3->BA3_TIPOUS=="1",BI3->BI3_NREDUZ,BQC->BQC_NREDUZ)                                                                    
		    Dados->NOMPRO    := BI3->BI3_NREDUZ
		    Dados->CRLF05    := '"'	
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Trilha 1       						                                Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды								
			Dados->SEP02     := '#ENC#'
			Dados->SS01		 := '%'
			
			If BDE->( FieldPos("BDE_NOMCAR") ) > 0 .And. TYPE("M->BDE_NOMCAR") <> "U" 
				If M->BDE_NOMCAR == "1"
					Dados->TARJAMAG1 :=	SubStr(PLSEXP1->BTS_NOMCAR,1,25)
				Else
					Dados->TARJAMAG1 :=	SubStr(PLSEXP1->BTS_NOMUSR,1,25)
				EndIf
			Else
				Dados->TARJAMAG1 :=	SubStr(PLSEXP1->BTS_NOMCAR,1,25)
			EndIf    
			                                               
			Dados->ES01		:= '?'
						
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Trilha 2       						                                Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды			
			If  AllTrim(BA3->BA3_TIPOUS) == "1"
				cNatJco := BI3->BI3_NATJCO
			Else
				If  AllTrim(BQC->BQC_ENTFIL) == "1"
				    cNatJco := "5"   // Beneficente
				Else
					BII->(DbSetOrder(1))
					If lTpCtrBI3 .AND. BII->( msSeek(xFilial("BII")+BI3->BI3_TIPCON) ) .AND. !EMPTY(BII->BII_TIPPLA)
						If  AllTrim(BII->BII_TIPPLA) $ "1,3"
							cNatJco := "4"   // Adesao
						Else
							cNatJco := "3"   // Empresarial
						Endif
					Else
						If BII->( msSeek(xFilial("BII")+BT5->BT5_TIPCON) ) .AND. !EMPTY(BII->BII_TIPPLA)
								If  AllTrim(BII->BII_TIPPLA) $ "1,3"
									cNatJco := "4"   // Adesao
								Else
									cNatJco := "3"   // Empresarial
								Endif
						Endif
					EndIf
				Endif
			Endif
			
			Dados->SS02		 := ';'											
			Dados->TARJAMAG2 := PLSEXP1->BA1_CODINT+;
								PLSEXP1->BA1_CODEMP+;
								PLSEXP1->BA1_MATRIC+;
								PLSEXP1->BA1_TIPREG+;
								PLSEXP1->BA1_DIGITO+;
								"="+; //Campo separador
								Strzero(nViaCar,2)+;
								SubStr(cDataValid,9,2)+SubStr(cDataValid,4,2)+;
								"="+; //Campo separador
								cLocCob+; //Local de Atendimento (Operadora)
								BI3->BI3_IDECAR+;//Produto
								SubStr(BI3->BI3_ABRANG,Len(BI3->BI3_ABRANG),1)+;//Abrangencia
								cNatJco+;//Natureza JurМdica da ContrataГЦo
								"1"+;// "1" - Fixo
								CodRedeRef()//CСdigo da Rede Referenciada
								  
			Dados->ES02	 := "?"
			Dados->SEP03 := "#END#@@@@@@"
			
			If GetNewPar("MV_PLSIMCL","0") == "1" // Imprime classe de carencia no cartao ?
				Dados->CLSCAR := ClsCar(PLSEXP1->BA1_CODINT,PLSEXP1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),PLSEXP1->BA1_DATCAR)
			EndIf
			If BI3->(FieldPos('BI3_ABRCAR')) > 0
				Dados->ABRCAR := BI3->BI3_ABRCAR
			Endif
			Dados->SUSEP := Iif(BI3->BI3_APOSRG == "1",BI3->BI3_SUSEP,BI3->BI3_SCPA)

			If BTS->(fieldpos("BTS_NOMSOC")) > 0
				Dados->NOMSOC := PadR(PLSEXP1->BTS_NOMSOC,25) // Nome social do beneficiario
			EndIf
			// QRCODE
			Dados->QRCODE := "1"+; 					// Indicador de cartЦo - Fixo ⌠1■ - cartЦo fМsico	 
							 "="+; 					// Field Separator
							 "01"+; 				// Versionamento das informaГУes do QR Code do Manual do CartЦo √ fixo: ⌠01■
							 "="+; 					// Field Separator
							 PLSEXP1->BA1_CODINT+; 	
						     PLSEXP1->BA1_CODEMP+;
							 PLSEXP1->BA1_MATRIC+;	// CСdigo do beneficiАrio com 17 posiГУes
							 PLSEXP1->BA1_TIPREG+;
							 PLSEXP1->BA1_DIGITO+;
							 "="+; 					// Field Separator
							 Dados->NOMEUSUARI+; 	// Nome reduzido do beneficiАrio
							 "="+; 					// Field Separator
							 cDataNasc+; 			// Data de nascimento
							 "="+; 					// Field Separator
							 IIF(PLSEXP1->BA1_SEXO == "1","M","F")+; // Sexo
							 "="+; 					// Field Separator
							 Padr(PLSEXP1->BTS_NRCRNA,15)+; // CartЦo Nacional de SaЗde
							 "="+; 					// Field Separator
							 cDataValid+; 			// Data de validade
							 "="+; 					// Field Separator
							 strzero(nViaCar,2)+; 	// Via do cartЦo
							 "="+; 					// Field Separator
							 Substr(BI3->BI3_REDEDI,1,4)+; // Rede de Atendimento
							 "="+; 					// Field Separator
							 PadR(Dados->SUSEP,20)+;// registro ANS do produto
							 "="+; 					// Field Separator
							 Dados->NOMSOC          // Nome social do beneficiАrio
			
		ElseIf nLayOut == 3  // GRAVACAO layout samed
			Dados->CODEMP     := PLSEXP1->BA1_CODEMP
			Dados->DESEMP     := IIF(BA3->BA3_TIPOUS=="1",BI3->BI3_DESCRI,BQC->BQC_DESCRI)
			Dados->VALIDADE   := cDataValid
			Dados->TITULAR    := cNomTit  // buscar nome do titular
			
			If BDE->( FieldPos("BDE_NOMCAR") ) > 0 .And. TYPE("M->BDE_NOMCAR") <> "U" 
				If M->BDE_NOMCAR == "1"
					Dados->DEPENDENTE := PLSEXP1->BTS_NOMCAR
				Else
					Dados->DEPENDENTE := PLSEXP1->BTS_NOMUSR
				EndIf
			Else
				Dados->DEPENDENTE := PLSEXP1->BTS_NOMCAR
			EndIf
			
			Dados->MATRICULA  := 	PLSEXP1->BA1_CODINT+"."+;
									PLSEXP1->BA1_CODEMP+"."+;
									PLSEXP1->BA1_MATRIC+"-"+;
									PLSEXP1->BA1_TIPREG+"."+;
									PLSEXP1->BA1_DIGITO
									Dados->PLANO      := BI3->BI3_CODIGO
									Dados->DESPLANO   := BI3->BI3_DESCRI
									Dados->REDE       := If(Len(aRetCar)>=1,aRetCar[1],"") // STANDARD
									Dados->CONSULTA   := If(Len(aRetCar)>=2,aRetCar[2],"")
									Dados->EXAME      := If(Len(aRetCar)>=3,aRetCar[3],"")
									Dados->INTERN     := If(Len(aRetCar)>=4,aRetCar[4],"")
									Dados->PARTO      := If(Len(aRetCar)>=5,aRetCar[5],"")
									Dados->PADRAO     := If(Len(aRetCar)>=6,aRetCar[6],"") // ENFERMARIA
									Dados->NASCIMENTO := cDataNasc
									Dados->EXAMEESP   := If(Len(aRetCar)>=7,aRetCar[7],"")
									Dados->VIACAR     := strzero(nViaCar,2)
									Dados->BADGET     := If(Len(aRetCar)>=8,aRetCar[8],"") //"Uliana"
									Dados->OBS        := If(Len(aRetCar)>=9,aRetCar[9],"")
		elseIf nLayOut = 4
		
			Dados->TARJAMAG1 :=	PLSEXP1->BA1_CODINT+;
								PLSEXP1->BA1_CODEMP+;
								PLSEXP1->BA1_MATRIC+;
								PLSEXP1->BA1_TIPREG+;
								PLSEXP1->BA1_DIGITO+;
								"="+; //Campo separador
								Strzero(nViaCar,2)+;
								SubStr(cDataValid,9,2)+SubStr(cDataValid,4,2)+;
								"="+; //Campo separador
								PLSEXP1->BA1_OPERES+;
								BI3->BI3_IDECAR+; //Codigo do produto no Intercambio
								SubStr(BI3->BI3_ABRANG,Len(BI3->BI3_ABRANG),1)+;
								PLSEXP1->BA3_TIPCON
								
			if BDE->( FieldPos("BDE_NOMCAR") ) > 0 .And. TYPE("M->BDE_NOMCAR") <> "U" 
				if M->BDE_NOMCAR == "1"
					Dados->TARJAMAG2 := PLSEXP1->BTS_NOMCAR
				else
					Dados->TARJAMAG2 := PLSEXP1->BTS_NOMUSR
				endIf
			else
				Dados->TARJAMAG2 := PLSEXP1->BTS_NOMCAR
			endIf

			Dados->MATRICULA := PLSEXP1->BA1_CODINT + " " +;
								PLSEXP1->BA1_CODEMP + " " +;
								PLSEXP1->BA1_MATRIC + " " +;
								PLSEXP1->BA1_TIPREG + " " +;
								PLSEXP1->BA1_DIGITO

			Dados->NUMCON		:= cNumPlan
			cDTContrat := Eval({ || cDia := StrZero(Day(PLSEXP1->BA1_DATINC),2), cMes := StrZero(Month(PLSEXP1->BA1_DATINC),2), cAno := StrZero(Year(PLSEXP1->BA1_DATINC),4), cDia+"/"+cMes+"/"+cAno })
			Dados->DATCON		:= cDTContrat
			IIF(ValType(cMaxCarenc) == "C",cMaxCarenc := CTOD(cMaxCarenc),) // Se a variavel for um caracter, converte em date
			Dados->DTMAXCON	:= Eval({ || cDia := StrZero(Day(cMaxCarenc),2), cMes := StrZero(Month(cMaxCarenc),2), cAno := StrZero(Year(cMaxCarenc),4), cDia+"/"+cMes+"/"+cAno })
			Dados->INFOPLAN 	:= cTipPlan
			If lPL264INFO
				aRetInfo := ExecBlock("PL264INFO",.F.,.F.,{Dados->NOMEUSUARI,Dados->DTNACTO,Dados->DTVALID,Dados->DTINC,Dados->PLANO,Dados->TPCONTRATO,BA3->BA3_TIPOUS,aRetNome[1][3]})
				
				Dados->RZSOCIAL   := aRetInfo[1]
				Dados->INFORMACOE := aRetInfo[2]
			Else
				If  BA3->BA3_TIPOUS <> "1" .and. !Empty(BQC->BQC_NOMCAR)
					Dados->RZSOCIAL   := BQC->BQC_NOMCAR
				Else
					Dados->RZSOCIAL   := aRetNome[1][3]
				Endif
				Dados->INFORMACOE := STR0055 //"InformaГУes"
			EndIf
								
			Dados->CNESUSU	 :=  AllTrim(PLSEXP1->BTS_NRCRNA)
			Dados->SEGASSPL  :=  padr(substr(POSICIONE("BI6",1,XFILIAL("BI6")+ BI3->BI3_CODSEG,"BI6_DESCRI"),1,56),56)
			
			BA0->(DbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
			BA0->( msSeek(xFilial("BA0")+PLSEXP1->BA1_CODINT) )
			
			Dados->NUMREGOPE  := BA0->BA0_SUSEP
			Dados->NFANTAZOPE := BA0->BA0_NOMINT

			BIM->(DbSetOrder(1))//BIM_FILIAL+BIM_CODINT+BIM_CODIGO
			BIM->( msSeek(xFilial("BIM")+PLSEXP1->BA1_CODINT) )
			
			while !BIM->(eof())
			
				if BIM->BIM_SETOR == GetNewPar("MV_PLBIMSE","012")
					Dados->CONTATOOPE  := padR(BIM->BIM_NOME,30) + padR(BIM->BIM_TELCON,15) + padR(BIM->BIM_EMAIL,30)
					exit 
				endIf
			
			BIM->(dbSkip())
			endDo
			
			BK5->(DbSetOrder(1))//BK5_FILIAL+BK5_NOME
			BK5->( msSeek(xFilial("BK5")) )

			Dados->CONTATOANS := padR(BK5->BK5_NOME,40) + padR(BK5->BK5_TEL,15) + padR(BK5->BK5_EMAIL,30) 
			Dados->CPT        := IIF(empty(dDatCpt),PadR("NцO Hа",12),substr(dtos(dDatCpt),7,2)+"/"+substr(dtos(dDatCpt),5,2)+"/"+substr(dtos(dDatCpt),1,4))			

			BG9->(DbSetOrder(1))//BG9_FILIAL+BG9_CODINT+BG9_CODIGO+BG9_TIPO
			BG9->( msSeek( xFilial("BG9")+PLSEXP1->(BA1_CODINT+BA1_CODEMP) ) )

			Dados->NFAADMBENE := BG9->BG9_NREDUZ
			Dados->DTNACTO    := cDataNasc			

			If  BA3->BA3_TIPOUS == "1"
				Do Case
					Case BI3->BI3_NATJCO = "2"
						Dados->CONTRATACA := 'INDIVIDUAL OU FAMILIAR'
					Case BI3->BI3_NATJCO = "3"
						Dados->CONTRATACA := 'COLETIVO EMPRESARIAL'
					Case BI3->BI3_NATJCO = "4"
						Dados->CONTRATACA := 'COLETIVO POR ADESAO'
					Case BI3->BI3_NATJCO = "5"
						Dados->CONTRATACA := 'BENEFICIENTE'
					Otherwise
						Dados->CONTRATACA := "SEM CONTRATACAO"
				EndCase
			Else
				If  AllTrim(BQC->BQC_ENTFIL) == "1"
					Dados->CONTRATACA := 'BENEFICIENTE'
				Else
					BII->(DbSetOrder(1))
					If lTpCtrBI3 .AND. BII->( msSeek(xFilial("BII")+BI3->BI3_TIPCON) ) .AND. !EMPTY(BII->BII_TIPPLA)
						If  AllTrim(BII->BII_TIPPLA) $ "1,3"
							Dados->CONTRATACA := 'COLETIVO POR ADESAO'
						Else
							Dados->CONTRATACA := 'COLETIVO EMPRESARIAL'
						Endif
					Else
						If BII->( msSeek(xFilial("BII")+BT5->BT5_TIPCON) ) .AND. !EMPTY(BII->BII_TIPPLA)
							If  AllTrim(BII->BII_TIPPLA) $ "1,3"
								Dados->CONTRATACA := 'COLETIVO POR ADESAO'
							Else
								Dados->CONTRATACA := 'COLETIVO EMPRESARIAL'
							Endif
						Endif
					EndIf
				Endif
			Endif
				
			BI4->(dbSetOrder(1))      			
			If Empty(BI3->BI3_CODACO)
				Dados->TPACOMODA := PadR(STR0061, 13)	// "NAO SE APLICA"								
			Else
				If BI4->(MsSeek(xFilial("BI4")+AllTrim(BI3->(BI3_CODACO)))) .And.;
					BI4->(FieldPos("BI4_CODEDI")) > 0
											
					If Empty(BI4->BI4_CODEDI)
						Dados->TPACOMODA := PadR(STR0061, 13)	// "NAO SE APLICA"
					Else
						If AllTrim(BI4->BI4_CODEDI) == "1"
							Dados->TPACOMODA := PadR(STR0062,13)	// INDIVIDUAL
						ElseIf AllTrim(BI4->BI4_CODEDI) == "2"
							Dados->TPACOMODA := PadR(STR0063,13)	// COLETIVA
						Else
							Dados->TPACOMODA := PadR(STR0061, 13) 	// "NAO SE APLICA"     
						EndIf
					EndIf   
				Else 
					Dados->TPACOMODA := PadR(STR0061, 13)	// "NAO SE APLICA"     
				EndIf
			EndIf		  

			If BDE->( FieldPos("BDE_NOMCAR") ) > 0 .And. TYPE("M->BDE_NOMCAR") <> "U" 
				If M->BDE_NOMCAR == "1"
					Dados->NOMEUSUARI := PadR(PLSEXP1->BTS_NOMCAR,25)
				Else
					Dados->NOMEUSUARI := PadR(PLSEXP1->BTS_NOMUSR,25)
				EndIf
			Else
				Dados->NOMEUSUARI := PadR(PLSEXP1->BTS_NOMCAR,25)
			EndIF        			
			
			Do Case
				Case BI3->BI3_ABRANG == "01"
					Dados->ABRANG := "NACIONAL"
				Case BI3->BI3_ABRANG == "02"
					Dados->ABRANG := "GRUPO DE ESTADOS"
				Case BI3->BI3_ABRANG == "03"
					Dados->ABRANG := "ESTADUAL"
				Case BI3->BI3_ABRANG == "04"
					Dados->ABRANG := "GRUPO DE MUNICмPIOS"
				Case BI3->BI3_ABRANG == "05"
					Dados->ABRANG := "LOCAL"
				Otherwise
					Dados->ABRANG := BI3->BI3_ABRANG
			EndCase

			Dados->DTVIGPL 	:= cDatXInsc
		    Dados->NOMPRO   := BI3->BI3_NREDUZ
			Dados->SUSEP 	:= Iif(BI3->BI3_APOSRG == "1",BI3->BI3_SUSEP,BI3->BI3_SCPA)
			
		EndIf
		
		Dados->(MsUnlock())
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё caso o usuario esteja marcado como alterado, marca o    	Ё
		//Ё como cartao gerado         					             	Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		if !lImpressao .Or. _nTipo == 2
			If  BA1->(FieldPos("BA1_EMICAR")) > 0 .and. BA1->BA1_EMICAR == "1"
				If  BA1->(RecLock("BA1",.F.))
						BA1->BA1_EMICAR := "2" // preparado
					BA1->(msUnLock())
				Endif
			Endif
		endIf	
		
		If _nTipo == 1
			
			cSQL := "SELECT   BA1.R_E_C_N_O_ BA1REG, BA3.R_E_C_N_O_ BA3REG, BA1_DATNAS, BA1_DATINC, "
			cSQL += 		" BA1_DTVLCR, BA1_TIPREG, BA1_CODINT, BA1_CODEMP, "
			cSQL += 		" BA1_MATRIC, BA1_DIGITO, BA1_NOMUSR, BA1_TIPUSU,"
			cSQL += 		" BA1_DATCAR, BA1_VIACAR, BA1_OPERES, BA1_SEXO, "
			cSQL += 		" BA3_CODPLA, BA3_VERSAO, BA3_CODINT, BA3_TIPOUS, "
			cSQL += 		" BA3_CONEMP, BA3_VERCON, BA3_SUBCON, BA3_VERSUB, "
			cSQL += 		" BA3_CODEMP, BTS_NOMCAR, BTS_NOMUSR, BA3_TIPCON "

			If BTS->(fieldpos("BTS_NOMSOC")) > 0
				cSQL += ", BTS_NOMSOC "
			EndIf
			
			cSQL += " FROM " + RetSQLName("BA1")+" BA1, " + RetSQLName("BA3")+" BA3, " + RetSQLName("BTS")+" BTS "
			
			cSQL += " WHERE BA1.BA1_FILIAL = '" + xFilial("BA1") + "' AND "
			cSQL += 	  " BA3.BA3_FILIAL = '" + xFilial("BA3") + "' AND "
			cSQL += 	  " BTS.BTS_FILIAL = '" + xFilial("BTS") + "' AND "
			
			cSQL += " BA1.BA1_CODINT = '" + PLSEXP1->BA1_CODINT + "' AND "
			cSQL += " BA1.BA1_CODEMP = '" + PLSEXP1->BA1_CODEMP + "' AND "
			cSQL += " BA1.BA1_MATRIC = '" + PLSEXP1->BA1_MATRIC + "' AND "
			cSQL += 	  " BA1.BA1_TIPREG <> '" + cTipReg + "' AND "
			
			If lGeraInt
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Gerar empresa de intercambio								Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If  BDE->(fieldpos("BDE_GERINT")) > 0
					If M->BDE_GERINT == "0"  //Nao
						//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Exclui Empresa Intercambio...								Ё
						//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						cSQL += 	  " BA1.BA1_CODEMP <> '" + cGrpEmpIE + "' AND "
					Endif
				Else
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Exclui Empresa Intercambio...								Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					cSQL += 	  " BA1.BA1_CODEMP <> '" + cGrpEmpIE + "' AND "
				Endif
			Endif
			
			cSQL += 	  " BA3.BA3_CODINT = '" + PLSEXP1->BA3_CODINT + "' AND "
			cSQL += 	  " BA3.BA3_CODEMP = '" + PLSEXP1->BA3_CODEMP + "' AND "
			cSQL += 	  " BA3.BA3_MATRIC = '" + PLSEXP1->BA3_MATRIC + "' AND "
			
			cSQL += 	  "	BA1.BA1_MATVID = BTS.BTS_MATVID AND "
			
			cSQL += " BA1.D_E_L_E_T_ <> '*' AND BA3.D_E_L_E_T_ <> '*' AND BTS.D_E_L_E_T_ <> '*' "
			If lPLS264OB
				cSQL += ExecBlock("PLS264OB",.F.,.F.)
			Else
				cSQL += " ORDER BY BA1_CODINT,BA1_CODEMP,BA1_NOMUSR "
			EndIf
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Tipo: Geracao por lote...									Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		ElseIf _nTipo == 2
			
			cSQL := " SELECT BA1.R_E_C_N_O_ BA1REG, BA3.R_E_C_N_O_ BA3REG, BA1_DATNAS, BA1_DATINC, BA1_DTVLCR, "
			cSQL += " BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, BA1_DIGITO, BA1_NOMUSR, BA1_MATVID, BA1_TIPUSU,"
			cSQL += " BA1_DATCAR, BA1_VIACAR, BA1_OPERES, BA1_SEXO,   BA3_CODPLA, BA3_VERSAO, BA3_CODINT, "
			cSQL += " BA3_CODEMP, BA3_SUBCON, BA3_VERSUB, BA3_VERCON, BA3_TIPCON, BA3_TIPOUS, "
			cSQL += " BA3_CONEMP, BTS_NOMCAR, BTS_NOMUSR, BTS_NRCRNA  "
			
			If BTS->(fieldpos("BTS_NOMSOC")) > 0
				cSQL += ", BTS_NOMSOC "
			EndIf
			
			cSQL += " FROM " + RetSQLName("BA1") + " BA1, " + RetSQLName("BA3") + " BA3, " + RetSQLName("BTS") + " BTS "
			
			cSQL += " WHERE BA1.BA1_FILIAL = '" + xFilial("BA1") + "' AND "
			cSQL += " BA3.BA3_FILIAL = '" + xFilial("BA3") + "' AND "
			cSQL += " BTS.BTS_FILIAL = '" + xFilial("BTS") + "' AND "
			cSQL += " BA1.BA1_CODINT = '" + PLSEXP1->BA1_CODINT + "' AND "
			cSQL += " BA1.BA1_CODEMP = '" + PLSEXP1->BA1_CODEMP + "' AND "
			cSQL += " BA1.BA1_MATRIC = '" + PLSEXP1->BA1_MATRIC + "' AND "
			cSql += " BA1.BA1_TIPREG <> '" + cTipReg + "' AND"
			if !empty(DtoS(dData1)) .AND. !empty(DtoS(dData2))
				cSQL +=  " BA1.BA1_DTVLCR >= '" + DtoS(dData1) + "' AND BA1.BA1_DTVLCR <= '" + DtoS(dData2) + "' AND "
			endif
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Exclui usuarios da Operadora Local...						Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If nUniLocal = 2
				cSQL += " BA1.BA1_CODINT <> '" + cCodInt + "' AND "
			EndIf
			
			If lGeraInt
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Gerar empresa de intercambio								Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If  BDE->(fieldpos("BDE_GERINT")) > 0
					If M->BDE_GERINT == "0" //Nao
						//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Exclui Empresa Intercambio...								Ё
						//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						cSQL += " BA1.BA1_CODEMP <> '" + cGrpEmpIE + "' AND "
					Endif
				Else
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Exclui Empresa Intercambio...								Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					cSQL += " BA1.BA1_CODEMP <> '" + cGrpEmpIE + "' AND "
				Endif
			Endif
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifica se eh primeira Via de Carteirinha...				Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if !lImpressao .Or. _nTipo == 2
				If cMotivo == GetNewPar("MV_PLSMP1V","4")
					cSQL += " BA1.BA1_VIACAR = 0 AND "
				Else
					cSQL += " BA1.BA1_VIACAR <> 0 AND "
				Endif
			endIf	
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifica o tipo de contratacao (PF/PJ)...					Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if cTipoGrupo <> "3"
				cSQL += " BA3.BA3_TIPOUS = '" + cTipoGrupo + "' AND "
			endif
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifica se eh apenas para alteracao cadastral             						  Ё
			//Ё BA1_EMICAR = 0=Nunca Emitir;1=Cad. Alterado;2=Cartao Preparado;3=Cartao Gerado 	  Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If  BPX->(fieldpos("BPX_TIPEMI")) > 0 .and. BA1->(fieldpos("BA1_EMICAR")) > 0 .and. posicione("BPX",1,xFilial("BPX")+cOperadora+cMotivo,"BPX_TIPEMI") == "2"
				cSQL += " (BA1.BA1_EMICAR = '1' OR BA1.BA1_EMICAR = '2') AND "
			Else
				cSQL += " BA1.BA1_EMICAR <> '0' AND "
			Endif

			If BA3->(FieldPos("BA3_CARVIR")) > 0 .And. BA1->(FieldPos("BA1_CARVIR")) > 0 .And. lCartaoVirtual
				cSQL += " BA3.BA3_CARVIR <> '0' AND "
				cSQL += " BA1.BA1_CARVIR <> '0' AND "
			EndIf

			cSQL += " BA1.BA1_TIPREG <> '" + cTipReg + "' AND "
			cSQL += " BA1.BA1_TIPUSU <> '" + cTipUsu + "' AND "
			cSQL += " BA3.BA3_CODINT = '" + PLSEXP1->BA1_CODINT + "' AND "
			cSQL += " BA3.BA3_CODEMP = '" + PLSEXP1->BA1_CODEMP + "' AND "
			cSQL += " BA3.BA3_MATRIC = '" + PLSEXP1->BA1_MATRIC + "' AND "
			cSQL += " BTS.BTS_MATVID = BA1.BA1_MATVID AND "
			cSQL += " BA1.D_E_L_E_T_ <> '*' AND BA3.D_E_L_E_T_ <> '*' AND BTS.D_E_L_E_T_ <> '*' "
			If lPLS264OB
				cSQL += ExecBlock("PLS264OB",.F.,.F.)
			Else	
				cSQL += " ORDER BY BA1_CODINT,BA1_CODEMP,BA1_NOMUSR "
			EndIf
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Tipo: Imprime Usuario/Familia Posicionario...				Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		ElseIf (_nTipo == 3 .Or. _nTipo == 4)
			
			cSQL := "SELECT BA1.R_E_C_N_O_ BA1REG, BA3.R_E_C_N_O_ BA3REG, BA1_DATNAS ,BA1_DATINC, BA1_DTVLCR, "
			cSQL += 	  " BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, BA1_DIGITO, BA1_NOMUSR, BA1_MATVID, BA1_TIPUSU,"
			cSQL += 	  " BA1_DATCAR, BA1_VIACAR, BA1_OPERES, BA1_SEXO,   BA3_CODPLA, BA3_VERSAO, BA3_TIPCON, "
			cSQL += 	  " BA3_TIPOUS, BA3_CONEMP, BA3_VERCON, BA3_SUBCON, BA3_VERSUB, BA3_CODEMP, "
			cSQL += 	  " BA3_CODINT, BTS_NOMCAR, BTS_NOMUSR, BTS_NRCRNA "

			If BTS->(fieldpos("BTS_NOMSOC")) > 0
				cSQL += ", BTS_NOMSOC "
			EndIf
			
			cSQL += " FROM " + RetSQLName("BA1") + " BA1, " + RetSQLName("BA3") + " BA3, " + RetSQLName("BTS") + " BTS  "
			
			cSQL += " WHERE BA1.BA1_FILIAL = '" + xFilial("BA1") + "' AND "
			cSQL += 	  " BA3.BA3_FILIAL = '" + xFilial("BA3") + "' AND "
			cSQL += 	  " BTS.BTS_FILIAL = '" + xFilial("BTS") + "' AND "
			
			If _nTipo == 4
				
				cSQL += " BA3.BA3_CODINT = '" + PLSEXP1->BA3_CODINT + "' AND "
				cSQL += " BA3.BA3_CODEMP = '" + PLSEXP1->BA3_CODEMP + "' AND "
				cSQL += " BA3.BA3_MATRIC = '" + PLSEXP1->BA3_MATRIC + "' AND "
				
			ElseiF _nTipo == 3
				
				cSQL += " BA3.R_E_C_N_O_ = " + Str(BA3->(Recno())) + " AND "
				cSQL += " BA1.R_E_C_N_O_ = " + Str(BA1->(Recno())) + " AND "
				
			Endif
			
			cSQL += " BA3.BA3_CODINT = BA1.BA1_CODINT AND "
			cSQL += " BA3.BA3_CODEMP = BA1.BA1_CODEMP AND "
			cSQL += " BA3.BA3_MATRIC = BA1.BA1_MATRIC AND "
			cSql += " BA1.BA1_TIPREG <> '" + cTipReg + "' AND"
			cSQL += " BA1.BA1_MATVID = BTS.BTS_MATVID AND "
			
			If lGeraInt
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Gerar empresa de intercambio								Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддд дддддддддды
				If  BDE->(fieldpos("BDE_GERINT")) > 0
					If M->BDE_GERINT == "0" //Nao
						//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Exclui Empresa Intercambio...								Ё
						//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						cSQL += " BA1.BA1_CODEMP <> '" + cGrpEmpIE + "' AND "
					Endif
				Else
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Exclui Empresa Intercambio...								Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					cSQL += " BA1.BA1_CODEMP <> '" + cGrpEmpIE + "' AND "
				Endif
			Endif
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifica se eh primeira Via de Carteirinha...				Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If _nTipo == 3 .and. ! lReemissao .and. (!lImpressao .Or. _nTipo == 2)
				If cMotivo == GetNewPar("MV_PLSMP1V","4")
					cSQL += " BA1_VIACAR = 0 AND "
				Else
					cSQL += " BA1_VIACAR <> 0 AND "
				Endif
			Endif
			
			cSQL += " BA1.D_E_L_E_T_ <> '*' AND BA3.D_E_L_E_T_ <> '*' AND BTS.D_E_L_E_T_ <> '*' "
			
			If lPLS264OB
				cSQL += ExecBlock("PLS264OB",.F.,.F.)
			Else
				cSQL += " ORDER BY BA1_CODINT,BA1_CODEMP,BA1_NOMUSR "
			EndIf
			
		Endif
		
		PLSQuery(cSQL,"PLSEXP2")
		
		While !PLSEXP2->(Eof())
			
			If _nTipo <> 2
				IncProc(STR0035 + Str(nQtd,10)) // "Selecionando inf. para cartЦo magnetico. "
			Else
				If ! (AllTrim(PLSEXP2->(BA1_MATRIC+BA1_TIPREG)) >= AllTrim(cMatrDe) .And.;
					AllTrim(PLSEXP2->(BA1_MATRIC+BA1_TIPREG)) <= AllTrim(cMatrAte))
					PLSEXP2->(dbSkip())
					Loop
				EndIf
				IncProc(STR0035 + AllTrim(Str(nQtd,10)) + "/" + AllTrim(Str(nTotal,10))) // "Selecionando inf. para cartЦo magnetico. "
			EndIf
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Para qualquer exportacao ou emissao atualizar como modelo abaixo... Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			BA1->(DbGoTo(PLSEXP2->BA1REG))
			BA3->(DbGoTo(PLSEXP2->BA3REG))

			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifica CPT                                                        Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			BF3->(dbSetOrder(1))
			BF3->(msSeek(xFilial("BF3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)))
			dDatCpt := ctod("  /  /  ")
			While ! BF3->(eof()) .and. BF3->(BF3_FILIAL+BF3_CODINT+BF3_CODEMP+BF3_MATRIC+BF3_TIPREG) == xFilial("BF3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)
				If  ! empty(BF3->BF3_CODDOE)
					If BF3->BF3_UNAGR == "3" //"Meses"
						If  Empty(BF3->BF3_DATCPT)
							If  Empty(BA1->BA1_DATCPT)
								nDias	:=	Abs(( date() -MonthSum( date() , 0 )))
								dDatCPt:= date()+nDias
							Else
								nDias	:=	Abs((BA1->BA1_DATCPT -MonthSum(BA1->BA1_DATCPT , BF3->BF3_MESAGR )))
								dDatCPt:= BA1->BA1_DATCPT+nDias
							Endif
						Else
							nDias	:=	Abs((BF3->BF3_DATCPTT -MonthSum(BF3->BF3_DATCPTT , BF3->BF3_MESAGR )))
							dDatCPt:= BF3->BF3_DATCPT+nDias
						Endif	
					Else			
					nDias   := PLSCarDias(BF3->BF3_MESAGR,BF3->BF3_UNAGR)
						dDatFim := BF3->BF3_DATCPT + nDias
					If  dDatFim > dDatCpt
						dDatCpt := dDatFim
						Endif
					Endif
				Endif
				BF3->(dbSkip())
			Enddo
			
			If BA3->BA3_TIPOUS <> "1"
				
				If  BT5->(BT5_FILIAL+BT5_CODINT+BT5_CODIGO+BT5_NUMCON+BT5_VERSAO) <> xFilial("BT5")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON)
					BT5->(DbSetOrder(1))
					BT5->(msSeek(xFilial("BT5")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON)))
					If ! BT5->(Found())
						If lPLS264E2
							Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG), STR0013}) //"Contrato nЦo Cadastrado."
							PLSEXP2->(DbSkip())
							Loop
						Else
							cMsgCri := AllTrim(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)) + " - "
							cMsgCri += STR0013 //"Contrato nЦo Cadastrado."
							
							If !lweb
								If Aviso(STR0036,cMsgCri,{STR0006,STR0007},3,STR0038) == 1 //"CrМtica!"###"&Sim"###"&NЦo"###"Deseja Continuar?"
									PLSEXP2->(DbSkip())
									Loop
								Else
									PLSEXP1->(DbCloseArea())
									PLSEXP2->(DbCloseArea())
									PLApag(cTrb)
									Return({.F.,{nQtd},aCriticas,aDados})
								EndIf
								
							Else
								PLSEXP1->(dbCloseArea())
								PLSEXP2->(DbCloseArea())
								PLApag(cTrb)
								Aadd(aCriticas, {STR0036,cMsgCri}) 	
								Return({.F.,{nQtd},aCriticas,aDados})															
							Endif
							
						EndIf
					Endif
				Endif
				
				If  BQC->(BQC_FILIAL+BQC_CODIGO+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB) <> xFilial("BQC")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)
					BQC->(DbSetOrder(1))
					BQC->(msSeek(xFilial("BQC")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))
					If ! BQC->(Found())
						If lPLS264E2
							Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0014}) //"Sub-Contrato nЦo Cadastrado."
							PLSEXP2->(DbSkip())
							Loop
						Else
							cMsgCri := AllTrim(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)) + " - "
							cMsgCri += STR0014 //"Sub-Contrato nЦo Cadastrado."
							If !lweb
								If Aviso(STR0036,cMsgCri,{STR0006,STR0007},3,STR0038) == 1 //"CrМtica!"###"&Sim"###"&NЦo"###"Deseja Continuar?"
									PLSEXP2->(DbSkip())
									Loop
								Else
									PLSEXP1->(DbCloseArea())
									PLSEXP2->(DbCloseArea())
									PLApag(cTrb)
									Return({.F.,{nQtd},aCriticas,aDados})
								EndIf
							Else
								PLSEXP1->(dbCloseArea())
								PLSEXP2->(DbCloseArea())
								PLApag(cTrb)
								Aadd(aCriticas, {STR0036,cMsgCri}) 	
								Return({.F.,{nQtd},aCriticas,aDados})														
							Endif
						EndIf
					Endif
				Endif
				
				If  BQC->BQC_EMICAR == "0" // indica que nao deve gerar cartao para este subcontrato
					PLSEXP2->(DbSkip())
					Loop
				Endif
			Endif
			
			If  BG9->(BG9_FILIAL+BG9_CODINT+BG9_CODIGO) <> xFilial("BG9")+PLSEXP2->(BA3_CODINT+BA3_CODEMP)
				BG9->(DbSetOrder(1))
				BG9->(msSeek(xFilial("BG9")+PLSEXP2->(BA3_CODINT+BA3_CODEMP)))
			Endif
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Posiciona Produto do usuario... 									Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If  ! empty(BA1->(BA1_CODPLA+BA1_VERSAO))
				If  BI3->(BI3_FILIAL+BI3_CODINT+BI3_CODIGO+BI3_VERSAO) <> xFilial("BI3")+BA1->(BA1_CODINT+BA1_CODPLA+BA1_VERSAO)
					BI3->(DbSetOrder(1))
					If  ! BI3->(msSeek(xFilial("BI3")+BA1->(BA1_CODINT+BA1_CODPLA+BA1_VERSAO)))
						If lPLS264E2
							Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0015}) //"Plano do usuАrio nЦo cadastrado."
							PLSEXP2->(DbSkip())
							Loop
						Else
							cMsgCri := AllTrim(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)) + " - "
							cMsgCri += STR0015 //"Plano do usuАrio nЦo cadastrado."
							If !lweb
								If Aviso(STR0036,cMsgCri,{STR0006,STR0007},3,STR0038) == 1 //"CrМtica!"###"&Sim"###"&NЦo"###"Deseja Continuar?"
									PLSEXP2->(DbSkip())
									Loop
								Else
									PLSEXP1->(DbCloseArea())
									PLSEXP2->(DbCloseArea())
									PLApag(cTrb)
									Return({.F.,{nQtd},aCriticas,aDados})
								EndIf

							Else
								PLSEXP1->(dbCloseArea())
								PLSEXP2->(DbCloseArea())
								PLApag(cTrb)
								Aadd(aCriticas, {STR0036,cMsgCri}) 	
								Return({.F.,{nQtd},aCriticas,aDados})							
							Endif
							
						EndIf
					Endif
				Endif
			Else
				If  BI3->(BI3_FILIAL+BI3_CODINT+BI3_CODIGO+BI3_VERSAO) <> xFilial("BI3")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)
					BI3->(DbSetOrder(1))
					If ! BI3->(msSeek(xFilial("BI3")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)))
						If lPLS264E2
							Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0016}) //"Plano da familia nЦo cadastrado."
							PLSEXP2->(DbSkip())
							Loop
						Else
							cMsgCri := AllTrim(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)) + " - "
							cMsgCri += STR0016 //"Plano da familia nЦo cadastrado."
							
							If !lweb
								If Aviso(STR0036,cMsgCri,{STR0006,STR0007},3,STR0038) == 1 //"CrМtica!"###"&Sim"###"&NЦo"###"Deseja Continuar?"
									PLSEXP2->(DbSkip())
									Loop
								Else
									PLSEXP1->(DbCloseArea())
									PLSEXP2->(DbCloseArea())
									PLApag(cTrb)
									Return({.F.,{nQtd},aCriticas,aDados})
								EndIf
							Else
								PLSEXP1->(dbCloseArea())
								PLSEXP2->(DbCloseArea())
								PLApag(cTrb)
								Aadd(aCriticas, {STR0036,cMsgCri}) 	
								Return({.F.,{nQtd},aCriticas,aDados})							
							Endif
							
						EndIf
					Endif
				Endif
			Endif
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifica se foi selecionado produto na tela de lote de carteirinha  Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If  ! empty(cProduto)
				If  BI3->BI3_CODIGO <> cProduto
					PLSEXP2->(DbSkip())
					Loop
				Endif
			Endif
			nRegBTS := BTS->(Recno())
			BA1->(DbSetOrder(2))
			BA1->(DbSeek(xFilial()+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+GetNewPar('MV_PLTRTIT','00'))))
			BTS->(DbSetOrder(1))
			BTS->(DbSeek(xFilial()+BTS->BTS_MATVID))
			
			cUniver := BTS->BTS_UNIVER
			BTS->(DbGoto(nRegBTS))
			BA1->(DbGoTo(PLSEXP2->BA1REG))
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Posiciona BED...										 			Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If _nTipo == 4
				BED->(DbSetOrder(1))
				BED->(msSeek(xFilial("BED")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)))
				While BED->(BED_CODINT+BED_CODEMP+BED_MATRIC+BED_TIPREG) == BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)
					If BA1->BA1_VIACAR ==  BED->BED_VIACAR
						Exit
					Endif
					BED->(DbSkip())
				Enddo
				
				If BED->(BED_CODINT+BED_CODEMP+BED_MATRIC+BED_TIPREG) <> BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)
					If lPLS264E2
						Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),;
						STR0017 + strzero(BA1->BA1_VIACAR,2) + STR0018}) //"Via de cartЦo "###" nЦo encontrada."
						PLSEXP2->(DbSkip())
						Loop
					Else
						cMsgCri := AllTrim(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)) + " - "
						cMsgCri += STR0017 + strzero(BA1->BA1_VIACAR,2) + STR0018 //"Via de cartЦo "###" nЦo encontrada."
						If !lweb
							If Aviso(STR0036,cMsgCri,{STR0006,STR0007},3,STR0038) == 1 //"CrМtica!"###"&Sim"###"&NЦo"###"Deseja Continuar?"
								PLSEXP2->(DbSkip())
								Loop
							Else
								PLSEXP1->(DbCloseArea())
								PLSEXP2->(DbCloseArea())
								PLApag(cTrb)
								Return({.F.,{nQtd},aCriticas,aDados})
							EndIf
						Else
							PLSEXP1->(dbCloseArea())
							PLSEXP2->(DbCloseArea())
							PLApag(cTrb)
							Aadd(aCriticas, {STR0036,cMsgCri}) 	
							Return({.F.,{nQtd},aCriticas,aDados})							

						Endif
						
					EndIf
				Endif
			Endif
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Nao imprime Via com Titulo em aberto...						Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If lReemissao
				If BED->BED_FATUR == "2"
					If lPLS264E2
						Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0019})//"TМtulo da via de cartЦo em aberto."
						PLSEXP2->(DbSkip())
						Loop
					Else
						cMsgCri := AllTrim(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)) + " - "
						cMsgCri += STR0019	//"TМtulo da via de cartЦo em aberto."
						If !lweb
							If Aviso(STR0036,cMsgCri,{STR0006,STR0007},3,STR0038) == 1 //"CrМtica!"###"&Sim"###"&NЦo"###"Deseja Continuar?"
								PLSEXP2->(DbSkip())
								Loop
							Else
								PLSEXP1->(DbCloseArea())
								PLSEXP2->(DbCloseArea())
								PLApag(cTrb)
								Return({.F.,{nQtd},aCriticas,aDados})
							EndIf
						Else
							PLSEXP1->(DbCloseArea())
							PLSEXP2->(dbCloseArea())
							PLApag(cTrb)
							Aadd(aCriticas, {STR0036,cMsgCri}) 	
							Return({.F.,{nQtd},aCriticas,aDados})							

						Endif
						
					EndIf
				Endif
			Endif
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifica se usuario esta bloqueado...					 			Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If UsuBlq264(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),BA1->BA1_TIPREG,dDatabase, BA1->BA1_DATBLO, BA1->BA1_MOTBLO, BA1->BA1_CONSID)
				PLSEXP2->(DbSkip())
				Loop
			Endif
			aRetCar := {}
			If lPLS264CA
				aRetCar := ExecBlock("PLS264CA",.F.,.F.,{BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),BA1->BA1_TIPREG})
			EndIf
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifica se usuario possui Via de Cartao para emitir... 			Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			nRegBED := BED->(Recno())
			nOrdBED := BED->(IndexOrd())
			
			BED->(DbSetOrder(1))
			BED->(msSeek(xFilial("BED")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),.T.))
			
			nUltViaV := 0
			nRegBEDV := 0
			If BED->(FieldPos("BED_USRDEL")) > 0
				While BED->(BED_CODINT+BED_CODEMP+BED_MATRIC+BED_TIPREG) == BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)				
					If BED->(FieldPos("BED_USRDEL")) > 0 
						If nUltViaV <= BED->BED_VIACAR  .and. Empty(BED->BED_USRDEL)
							nUltViaV := BED->BED_VIACAR
							nRegBEDV := BED->(Recno())
						Endif                          
					Else
						If nUltViaV <= BED->BED_VIACAR  
							nUltViaV := BED->BED_VIACAR
							nRegBEDV := BED->(Recno())
						Endif                          
					Endif
					BED->(DbSkip())
				Enddo
			EndIf				
			If nRegBEDV > 0
				BED->(DbGoTo(nRegBEDV))
			EndIf
			
			If BED->(BED_FILIAL+BED_CODINT+BED_CODEMP+BED_MATRIC+BED_TIPREG) == BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG) .and. (!lImpressao .Or. _nTipo == 2)
				If  BED->BED_STACAR == "1"
					If lPLS264E2
						Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),;
						STR0020+AllTrim(BED->BED_VIACAR)+STR0021+BED->BED_CDIDEN+STR0022})//"Via de nЗmero "###" gerado pelo lote "####" estА em aberto e precisa ser encerrada."
						BED->(DbSetOrder(nOrdBED))
						BED->(DbGoTo(nRegBED))
						PLSEXP2->(DbSkip())
						Loop
					Else

						cMsgCri := AllTrim(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)) +" - " + BA1->BA1_NOMUSR + CHR(13) + CHR(10)
						If AllTrim(BED->BED_CDIDEN) <> STR0002 //"AVULSA"
							cMsgCri += STR0020+AllTrim(BED->BED_VIACAR)+STR0021+BED->BED_CDIDEN + CHR(13) + CHR(10) //"Via de nЗmero "###" gerada pelo lote "
							cMsgCri += STR0045 //"EstА em aberto e precisa ser encerrada."
						Else
							cMsgCri += STR0064 //"O LanГamento avulso do beneficiАrio estА em aberto e precisa ser encerrado."
						Endif

						If !lweb
							If Aviso(STR0036,cMsgCri,{STR0006,STR0007},3,STR0038) == 1 //"CrМtica!"###"&Sim"###"&NЦo"###"Deseja Continuar?"
								BED->(DbSetOrder(nOrdBED))
								BED->(DbGoTo(nRegBED))
								PLSEXP2->(DbSkip())
								Loop
							Else
								PLSEXP1->(DbCloseArea())
								PLSEXP2->(DbCloseArea())
								PLApag(cTrb)
								Return({.F.,{nQtd},aCriticas,aDados})
							EndIf
						Else
							PLSEXP1->(dbCloseArea())
							PLSEXP2->(DbCloseArea())
							PLApag(cTrb)
							Aadd(aCriticas, {STR0036,cMsgCri}) 	
							Return({.F.,{nQtd},aCriticas,aDados})							

						Endif
						
					EndIf
				Endif
				nUltVia := BED->BED_VIACAR
			Else
				nUltVia := BA1->BA1_VIACAR
			Endif
			
			BED->(DbSetOrder(nOrdBED))
			BED->(DbGoTo(nRegBED))
			
			If ! lReemissao
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Nao permite emitir uma nova Via caso a ultima esteja em aberto...	Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If BA1->BA1_VIACAR <> nUltVia .And. BED->BED_STACAR <> "2"
					If lPLS264E2
						Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0023})//"зltima via do usuАrio encontra-se em aberto."
						PLSEXP2->(DbSkip())
						Loop
					Else
						cMsgCri := AllTrim(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)) + " - "
						cMsgCri += STR0023 //"зltima via do usuАrio encontra-se em aberto."
						If !lweb
							If Aviso(STR0036,cMsgCri,{STR0006,STR0007},3,STR0038) == 1 //"CrМtica!"###"&Sim"###"&NЦo"###"Deseja Continuar?"
								PLSEXP2->(DbSkip())
								Loop
							Else
								PLSEXP1->(DbCloseArea())
								PLSEXP2->(DbCloseArea())
								PLApag(cTrb)
								Return({.F.,{nQtd},aCriticas,aDados})
							EndIf
						Else
							PLSEXP1->(dbCloseArea())
							PLSEXP2->(DbCloseArea())
							PLApag(cTrb)
							Aadd(aCriticas, {STR0036,cMsgCri}) 	
							Return({.F.,{nQtd},aCriticas,aDados})							

						Endif
						
					EndIf
				Endif
				
			Else
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Verifica se a via do cartao esta bloqueada...						Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If BED->( FieldPos("BED_CODBLO") ) = 0 .or. BED->( FieldPos("BED_BLOIDE") ) = 0
					If lPLS264E2
						Aadd(aCriticas, {'',STR0057})//"DicionАrio de dados desatualizado!"
						PLSEXP2->(DbSkip())
						Loop
					Else
						If !lweb
							If Aviso(STR0036,STR0057,{STR0006,STR0007},3,STR0038) == 1 //"CrМtica!"###"DicionАrio de dados desatualizado!"###"&Sim"###"&NЦo"###"Deseja Continuar?"
								PLSEXP2->(DbSkip())
								Loop
							Else
								PLSEXP1->(DbCloseArea())
								PLSEXP2->(DbCloseArea())
								PLApag(cTrb)
								Return({.F.,{nQtd},aCriticas,aDados})
							EndIf
						Else
							PLSEXP1->(dbCloseArea())
							PLSEXP2->(DbCloseArea())
							PLApag(cTrb)
							Aadd(aCriticas, {STR0036,cMsgCri}) 	
							Return({.F.,{nQtd},aCriticas,aDados})							

						Endif
						
					EndIf
				Else
					If BED->BED_BLOIDE == "1"
						If lPLS264E2
							Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0024}) //"Via de cartЦo bloqueada."
							PLSEXP2->(DbSkip())
							Loop
						Else
							cMsgCri := AllTrim(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)) + " - "
							cMsgCri += STR0024 //"Via de cartЦo bloqueada."
							If !lweb
								If Aviso(STR0036,cMsgCri,{STR0006,STR0007},3,STR0038) == 1 //"CrМtica!"###"&Sim"###"&NЦo"###"Deseja Continuar?"
									PLSEXP2->(DbSkip())
									Loop
								Else
									PLSEXP1->(DbCloseArea())
									PLSEXP2->(DbCloseArea())
									PLApag(cTrb)
									Return({.F.,{nQtd},aCriticas,aDados})
								EndIf
							Else
								PLSEXP1->(dbCloseArea())
								PLSEXP2->(DbCloseArea())
								PLApag(cTrb)
								Aadd(aCriticas, {STR0036,cMsgCri}) 	
								Return({.F.,{nQtd},aCriticas,aDados})							
							Endif
							
						EndIf
					Endif
				Endif
				
			Endif
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Ponto de Entrada antes da Emissao... 								Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If lPLS264EM
				If ! ExecBlock("PLS264EM",.F.,.F.,{_nTipo})
					PLSEXP2->(DbSkip())
					Loop
				Endif
			Endif
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Ponto de Entrada antes da Emissao... enviando dados para manipular as criticas Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If lPLS264E2
				aRetPto := ExecBlock("PLS264E2",.F.,.F.,{_nTipo,aCriticas})
				If ! aRetPto[1]
					aCriticas := aClone(aRetPto[2])
					PLSEXP2->(DbSkip())
					Loop
				Endif
			Endif

			If lCartaoVirtual
				aRetVlrCar := {0, "0", "", "", "", "", 0, .T., 0, "", BA1->BA1_CODINT, BA1->BA1_CODEMP, BA1->BA1_MATRIC, BA1->BA1_TIPREG}
			Else
				aRetVlrCar := PLSEXPIVL(BA1->BA1_CODINT	,	BA1->BA1_CODEMP,	BA1->BA1_CONEMP,	BA1->BA1_VERCON,;
										BI3->BI3_CODIGO,	BI3->BI3_VERSAO,	BG9->BG9_TIPO,		BA1->BA1_VIACAR,;
										BA1->BA1_TIPUSU,	BA1->BA1_GRAUPA,	BA1->BA1_MATRIC,	BA1->BA1_TIPREG,;
										BA1->BA1_SUBCON,	BA1->BA1_VERSUB,	If(nUltVia = 0,GetNewPar("MV_PLSMP1V","4"),cMotivo))
			EndIf

			If lOK .and. ! aRetVlrCar[8]
				MostraErro()
				lOK := .F.
			Endif
			
			If !lReemissao
				If aRetVlrCar[8]
					
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Calcula Nova Data de Validade... 									Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If cMudaVal == "1"
						If Empty(dDatVal)
							If BA3->BA3_TIPOUS == "1"
								nPerRen := nPeRePF
							Else
								nPerRen := BQC->BQC_NPERRN
							Endif
							dDtVali := BA1->BA1_DTVLCR
							While nPerRen > 12
								dDtVali := stod(strzero((val(substr(dtos(dDtVali),1,4))+1),4)+substr(dtos(dDtVali),5,4))
								nPerRen := nPerRen-12
							EndDo
							dDtVali := stod(substr(dtos(stod(substr(dtos(dDtVali),1,6)+"15")+(nPerRen*30)),1,6)+substr(dtos(dDtVali),7,2))
						Else
							dDtVali := dDatVal
						Endif
						If  lPLS264DT
							dDtVali := ExecBlock("PLS264DT",.F.,.F.,{dDtVali})
						Endif
						
						//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    			    	//Ё So atualiza data no sub-contrato se for geracao por lote            Ё
	    		     	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		     			If FunName() == "PLSA262" .And. TYPE("M->BDE_DTRNCR") == "D"
		     			 
						    If  BA3->BA3_TIPOUS <> "1" .and. BDE->(fieldpos("BDE_DTRNCR")) > 0 .And. ! Empty(M->BDE_DTRNCR) .And. BQC->BQC_VALID <> M->BDE_DTRNCR
							    BQC->(RecLock("BQC",.F.))
							    	BQC->BQC_VALID := M->BDE_DTRNCR
							    BQC->(MsUnLock())
						    Endif
						    
						EndIf    
						
					Else
						dDtVali := BA1->BA1_DTVLCR
					Endif
					
					If BA1->BA1_TIPUSU <> cTipUsu
					
						If cMaior == "1" .And.;
							BDE->(FieldPos("BDE_MAIORI")) > 0 .And.;
							BDE->(FieldPos("BDE_GFILHO")) > 0 .And.;
							BDE->(FieldPos("BDE_GFILUN")) > 0 .And.;
							BDE->(FieldPos("BDE_GFILHA")) > 0 .And.;
							BDE->(FieldPos("BDE_GFILAU")) > 0 .And.;
							BDE->BDE_MAIORI == "1" .And.;
							BA1->BA1_GRAUPA $ (M->BDE_GFILHO,M->BDE_GFILUN,M->BDE_GFILHA,M->BDE_GFILAU)
							
							BT0->(DbSetOrder(1))
							BT1->(DbSetOrder(1))
							If BT0->(MsSeek(xFilial("BT0") + BA1->(BA1_CODINT + BA1_CODEMP + BA1_NUMCON + BA1_VERCON + BA1_SUBCON + BA1_VERSUB) + BI3->(BI3_CODIGO + BI3_VERSAO)))
								While BT0->(BT0_FILIAL + BT0_CODIGO + BT0_NUMCON + BT0_VERCON + BT0_SUBCON + BT0_VERSUB + BT0_CODPRO + BT0_VERSAO) ==;
									(xFilial("BT0") + BA1->(BA1_CODINT + BA1_CODEMP + BA1_NUMCON + BA1_VERCON + BA1_SUBCON + BA1_VERSUB)+BI3->(BI3_CODIGO + BI3_VERSAO))
									If BT0->BT0_GRAUPA == BA1->BA1_GRAUPA .And.;
										BT0->BT0_TIPUSR == BA1->BA1_TIPUSU .And.;
										BT0->BT0_ESTCIV == BA1->BA1_ESTCIV .And.;
										BT0->BT0_SEXO == BA1->BA1_SEXO
										
										_nIdMAXm := BT0->BT0_IDAMAX
									EndIf
									BT0->(DbSkip())
								EndDo
							ElseIf BT1->(MsSeek(xFilial("BT1")+ BI3->(BI3_CODINT + BI3_CODIGO + BI3_VERSAO)))
								While BT1->(BT1_FILIAL + BT1_CODIGO + BT1_VERSAO + BT1_TIPUSR) ==;
									(xFilial("BT1") + BI3->(BI3_CODINT + BI3_CODIGO + BI3_VERSAO) + BA1->(BA1_TIPUSU))
									If BT1->BT1_GRAUPA == BA1->BA1_GRAUPA .And.;
										BT1->BT1_TIPUSR == BA1->BA1_TIPUSU .And.;
										BT1->BT1_ESTCIV == BA1->BA1_ESTCIV .And.;
										BT1->BT1_SEXO == BA1->BA1_SEXO
										
										_nIdMAXm := BT1->BT1_IDAMAX
									EndIf
									BT1->(DbSkip())
								EndDo
							EndIf
							If Empty(_nIdMAXm)
								Do Case
									Case BA1->BA1_SEXO == "1" .And. cUniver == "1"
										//BA1->BA1_SEXO == 1 - Masculino // BTS->BTS_UNIVER == 1 - Sim
										_nIdMAXm := IIF(BDE->BDE_IMFOUN > 0, BDE->BDE_IMFOUN, cMvPLSFIOU) 
									Case BA1->BA1_SEXO == "1" .And. cUniver == "0"
										//BA1->BA1_SEXO == 1 - Masculino // BTS->BTS_UNIVER == 0 - Nao
										_nIdMAXm := IIF(BDE->BDE_IMFILO > 0, BDE->BDE_IMFILO, cMvPLSFILO)
									Case BA1->BA1_SEXO == "2" .And. cUniver == "1"
										//BA1->BA1_SEXO == 2 - Feminino // BTS->BTS_UNIVER == 1 - Sim
										_nIdMAXm := IIF(BDE->BDE_IMFAUN > 0, BDE->BDE_IMFAUN, cMvPLSFIAU)
									Case BA1->BA1_SEXO == "2" .And. cUniver == "0"
										//BA1->BA1_SEXO == 2 - Feminino // BTS->BTS_UNIVER == 0 - Nao
										_nIdMAXm := IIF(BDE->BDE_IMFIHA > 0, BDE->BDE_IMFIHA, cMvPLSFILA)
								EndCase
							EndIf
							_nAno 		:= Year(BA1->BA1_DATNAS) + _nIdMaxm
							_sMesDia 	:= SUBSTR(DTOS(BA1->BA1_DATNAS),5,4)
							If _sMesDia  == '0229' .or. _sMesDia  == '0228'
								_sMesDia := '0301'
							Endif
							If _sMesDia  == '1231'
								_nAno  := _nAno +1
							Endif
							If (STOD(Str(_nAno,4) + _sMesDia ) + 1) < dDtVali
								dDtVali := STOD(Str(_nAno,4) + _sMesDia ) + 1
							EndIf
						EndIf
					EndIf
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Se nao teve cobranca ou nao foi cobrado direto do usuario... Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					if !lImpressao .Or. _nTipo == 2
					
						If aRetVlrCar[1] == 0 .or. aRetVlrCar[2] <> "2" 
							
							BA1->(RecLock("BA1",.F.))
								BA1->BA1_VIACAR 	:= BA1->BA1_VIACAR + 1
								cCodAnt				:= BA1->BA1_CDIDEN
								BA1->BA1_CDIDEN 	:= cCodigo
								If  ! empty(dDtVali)
									BA1->BA1_DTVLCR := dDtVali
								Endif
							BA1->(MsUnLock())
							
							If lPLS264FAM
								If ! ExecBlock("PLS264FAM",.F.,.F.) .Or. ExecBlock("PLS264FAM",.F.,.F.,{BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)})
									GrvVldCarUsr(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),dDtVali)
								Endif
							Else
								GrvVldCarUsr(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),dDtVali)
							EndIf
							
						endIf
						
						If  lPLS264VL  // PONTO DE ENTRADA PARA GRAVAR DATA DE VALIDADE EM OUTRAS TABELAS RELACIONADAS
							ExecBlock("PLS264VL",.F.,.F.,{dDtVali})
						Endif
						
						BED->(RecLock("BED",.T.))
							BED->BED_FILIAL := xFilial("BED")
							BED->BED_CODINT := BA1->BA1_CODINT
							BED->BED_CODEMP := BA1->BA1_CODEMP
							BED->BED_MATRIC := BA1->BA1_MATRIC
							BED->BED_TIPREG := BA1->BA1_TIPREG
							BED->BED_DIGITO := BA1->BA1_DIGITO
							BED->BED_MATANT := BA1->BA1_MATANT
							BED->BED_TIPANT := BA1->BA1_TIPANT
							BED->BED_NOMUSR := BA1->BA1_NOMUSR
							BED->BED_VALOR  := aRetVlrCar[1]
							BED->BED_DTSOLI := dDataBase
							BED->BED_CDIDEN := cCodigo
							BED->BED_DATVAL := dDtVali		
							BED->BED_CODANT := cCodAnt
							BED->BED_ORIGEM := AllTrim(FunName())

							If BED->( FieldPos("BED_NOMCAR") ) <> 0
								BED->BED_NOMCAR := M->BDE_NOMCAR
							EndIf
							If BED->( FieldPos("BED_BLOIDE") ) <> 0
								BED->BED_BLOIDE := "0"
							Endif
							If BED->( FieldPos("BED_PROTOC") ) <> 0 .and. LWeb 
						   		BED->BED_PROTOC := cProtoc
							Endif
							
							//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//Ё Se nao teve cobranca ou nao foi cobrado direto do usuario... Ё
							//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							If aRetVlrCar[1] == 0 .or. aRetVlrCar[2] <> "2"
								BED->BED_VIACAR := BA1->BA1_VIACAR
							Else
								BED->BED_VIACAR := BA1->BA1_VIACAR + 1
							Endif
							
							If BED->BED_VIACAR==1
								BED->BED_MOTIVO := GetNewPar("MV_PLSMP1V","4")
							Else
								BED->BED_MOTIVO := cMotivo
							EndIf
							
							If aRetVlrCar[2] == "2" //Aguardando liquidacao do titulo...
								BED->BED_FATUR := "2"
							Elseif aRetVlrCar[2] == "1" //Faturado para proxima cobranca...
								BED->BED_FATUR  := If(BED->BED_VALOR==0,"0","1")
							Elseif aRetVlrCar[2] == "0" //Nao Faturado...
								BED->BED_FATUR := "0"
							Endif
							
							If BED->BED_FATUR $ "1,2"
								BED->BED_ANMSFT := subs(dtos(dDataBase),1,6)
							Else
								BED->BED_ANMSFT := ""
							Endif
							
							BED->BED_NUMCOB := IIf(lCartaoVirtual, "VIRTUAL", STR0002) //"AVULSA"
							BED->BED_COBRAR := aRetVlrCar[2]
							BED->BED_PREFIX := aRetVlrCar[3]
							BED->BED_NUMTIT := aRetVlrCar[4]
							BED->BED_PARCEL := aRetVlrCar[5]
							BED->BED_TIPTIT := aRetVlrCar[6]
							
							BED->BED_STACAR := "1"
						
						BED->(MsUnLock())
					endIf
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Acumula quantidade de registros criados...					Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					nQtd ++
				Endif
			EndIf
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Valida via do Cartao...										Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If BA1->BA1_VIACAR == 0 .And. aRetVlrCar[2] <> "2"  .and. !lImpressao

				If lPLS264E2
					Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0025}) //"Via do cartЦo do usuАrio invАlida."
					PLSEXP2->(DbSkip())
					Loop
				Else

					cMsgCri := AllTrim(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)) + " - "
					cMsgCri += STR0025 //"Via do cartЦo do usuАrio invАlida."

					If !lweb

						If Aviso(STR0036,cMsgCri,{STR0006,STR0007},3,STR0038) == 1 //"CrМtica!"###"&Sim"###"&NЦo"###"Deseja Continuar?"
							PLSEXP2->(DbSkip())
							Loop
						Else
							PLSEXP1->(DbCloseArea())
							PLSEXP2->(DbCloseArea())
							PLApag(cTrb)
							Return({.F.,{nQtd},aCriticas,aDados})
						EndIf
					Else
						PLSEXP2->(DbCloseArea())
						PLSEXP1->(dbCloseArea())
						PLApag(cTrb)
						Aadd(aCriticas, {STR0036,cMsgCri}) 	
						Return({.F.,{nQtd},aCriticas,aDados})							
					Endif
					
				EndIf
			Endif
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Alimenta Data de Validade e Via do Cartao...						Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If lReemissao
				nViaCar := BED->BED_VIACAR
				dDtVali := BED->BED_DATVAL
			Else
				nViaCar := BA1->BA1_VIACAR
				dDtVali := BA1->BA1_DTVLCR
			Endif
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Mensagens para cabecalho...									Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aCabCar := PLSM02TEXT( BA1->BA1_CODINT, 3, BA3->BA3_TIPOUS, BI3->BI3_MODPAG, BA1->BA1_CODEMP, BA1->BA1_CONEMP, BA1->BA1_SUBCON,	BA1->BA1_MATRIC, BI3->BI3_CODIGO, substr(dtos(dDataBase),1,6))
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Mensagens para rodape...									Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aRodCar := PLSM02TEXT( BA1->BA1_CODINT, 4, BA3->BA3_TIPOUS, BI3->BI3_MODPAG, BA1->BA1_CODEMP, BA1->BA1_CONEMP, BA1->BA1_SUBCON,	BA1->BA1_MATRIC, BI3->BI3_CODIGO, substr(dtos(dDataBase),1,6))
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё LayOut PLS... 						                                Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If nLayOut == 1
				cDataNasc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATNAS),2), cMes := StrZero(Month(BA1->BA1_DATNAS),2), cAno := StrZero(Year(BA1->BA1_DATNAS),4), cDia+"/"+cMes+"/"+cAno })
				cDataInsc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATINC),2), cMes := StrZero(Month(BA1->BA1_DATINC),2), cAno := StrZero(Year(BA1->BA1_DATINC),4), cDia+"/"+cMes+"/"+cAno })
				cDataValid:= Eval({ || cDia := StrZero(Day(dDtVali),2), cMes := StrZero(Month(dDtVali),2), cAno := StrZero(Year(dDtVali),4), cDia+"/"+cMes+"/"+cAno })
				cDatXInsc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATINC),2), cMes := StrZero(Month(BA1->BA1_DATINC),2), cAno := StrZero(Year(BA1->BA1_DATINC),4), cDia+"/"+cMes+"/"+cAno })			
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё LayOut PTU... 						                                Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			ElseIf nLayOut == 2
				cDataNasc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATNAS),2), cMes := StrZero(Month(BA1->BA1_DATNAS),2), cAno := StrZero(Year(BA1->BA1_DATNAS),4), cDia+"/"+cMes+"/"+cAno })
				cDataInsc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATINC),2), cMes := StrZero(Month(BA1->BA1_DATINC),2), cAno := StrZero(Year(BA1->BA1_DATINC),4), cDia+cMes+SubStr(cAno,3) })
				cDatXInsc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATINC),2), cMes := StrZero(Month(BA1->BA1_DATINC),2), cAno := StrZero(Year(BA1->BA1_DATINC),4), cDia+"/"+cMes+"/"+cAno })			
				cDataValid:= Eval({ || cDia := StrZero(Day(dDtVali),2), cMes := StrZero(Month(dDtVali),2), cAno := StrZero(Year(dDtVali),4), cDia+"/"+cMes+"/"+cAno })
			ElseIf nLayOut == 3
				cDataNasc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATNAS),2), cMes := StrZero(Month(BA1->BA1_DATNAS),2), cAno := StrZero(Year(BA1->BA1_DATNAS),4), cDia+"/"+cMes+"/"+cAno })
				cDataInsc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATINC),2), cMes := StrZero(Month(BA1->BA1_DATINC),2), cAno := StrZero(Year(BA1->BA1_DATINC),4), cDia+cMes+SubStr(cAno,3) })
				cDataValid:= Eval({ || cDia := StrZero(Day(dDtVali),2), cMes := StrZero(Month(dDtVali),2), cAno := StrZero(Year(dDtVali),4), cDia+"/"+cMes+"/"+cAno })
				cDatXInsc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATINC),2), cMes := StrZero(Month(BA1->BA1_DATINC),2), cAno := StrZero(Year(BA1->BA1_DATINC),4), cDia+"/"+cMes+"/"+cAno })			
			elseIf nLayOut == 4
				cDataNasc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATNAS),2), cMes := StrZero(Month(BA1->BA1_DATNAS),2), cAno := StrZero(Year(BA1->BA1_DATNAS),4), cDia+"/"+cMes+"/"+cAno })
				cDataInsc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATINC),2), cMes := StrZero(Month(BA1->BA1_DATINC),2), cAno := StrZero(Year(BA1->BA1_DATINC),4), cDia+"/"+cMes+"/"+cAno })
				cDataValid:= Eval({ || cDia := StrZero(Day(dDtVali),2), cMes := StrZero(Month(dDtVali),2), cAno := StrZero(Year(dDtVali),4), cDia+"/"+cMes+"/"+cAno })
				cDatXInsc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATINC),2), cMes := StrZero(Month(BA1->BA1_DATINC),2), cAno := StrZero(Year(BA1->BA1_DATINC),4), cDia+"/"+cMes+"/"+cAno })			
			Endif
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Retorna a carencia dos produtos...							Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aDadCar := PLSLISMSGC(	PLSEXP2->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO), BI3->(BI3_CODINT+BI3_CODIGO),;
									PLSEXP2->BA3_VERSAO,PLSEXP2->BA1_DATCAR,PLSEXP2->BA1_SEXO)
			
			aRetNome:= PLSAVERNIV(	PLSEXP2->BA1_CODINT, PLSEXP2->BA1_CODEMP, PLSEXP2->BA1_MATRIC,	IF(PLSEXP2->BA3_TIPOUS=="1","F","J"),;
									PLSEXP2->BA3_CONEMP, PLSEXP2->BA3_VERCON, PLSEXP2->BA3_SUBCON, PLSEXP2->BA3_VERSUB, 1,;
									PLSEXP2->BA1_TIPREG)
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Alimenta arquivo com os dados para arquivo texto...			Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			Dados->(RecLock("Dados",.T.))
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Ponto de Entrada para impressao com LayOut diferente...             Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If lPLS264L2
				nOriDad := 0
				cAlias := "PLSEXP2"
				ExecBlock("PLS264L2",.F.,.F.,{cAlias})
				nSeqCar++
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё LayOut PLS... 						                                Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			ElseIf nLayOut == 1
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Tarja magnetica... 						                            Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				Dados->TARJAMAG1 :=	PLSEXP2->BA1_CODINT+;
									PLSEXP2->BA1_CODEMP+;
									PLSEXP2->BA1_MATRIC+;
									PLSEXP2->BA1_TIPREG+;
									PLSEXP2->BA1_DIGITO+;
									"="+; //Campo separador
									Strzero(nViaCar,2)+;
									SubStr(cDataValid,9,2)+SubStr(cDataValid,4,2)+;
									"="+; //Campo separador
									PLSEXP2->BA1_OPERES+;
									BI3->BI3_IDECAR+; //Codigo do produto no Intercambio
									SubStr(BI3->BI3_ABRANG,Len(BI3->BI3_ABRANG),1)+;
									PLSEXP2->BA3_TIPCON
				If BDE->( FieldPos("BDE_NOMCAR") ) > 0 .And. TYPE("M->BDE_NOMCAR") <> "U" 
					If M->BDE_NOMCAR == "1"
						Dados->TARJAMAG2 := PLSEXP2->BTS_NOMCAR
					Else
						Dados->TARJAMAG2 := PLSEXP2->BTS_NOMUSR
					EndIf
				Else
					Dados->TARJAMAG2 := PLSEXP2->BTS_NOMCAR
				EndIf
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Frente do Cartao... 						                        Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				Dados->MATRICULA := PLSEXP2->BA1_CODINT + " " +;
									PLSEXP2->BA1_CODEMP + " " +;
									PLSEXP2->BA1_MATRIC + " " +;
									PLSEXP2->BA1_TIPREG + " " +;
									PLSEXP2->BA1_DIGITO
				
				If  BA3->BA3_TIPOUS == "1"
					Do Case
						Case BI3->BI3_NATJCO = "2"
							Dados->CONTRATACA := BI3->BI3_NATJCO + STR0048 //"-FISICA"
						Case BI3->BI3_NATJCO = "3"
							Dados->CONTRATACA := BI3->BI3_NATJCO + STR0049 //"-EMPRESARIAL"
						Case BI3->BI3_NATJCO = "4"
							Dados->CONTRATACA := BI3->BI3_NATJCO + STR0050 //"-ADESAO"
						Case BI3->BI3_NATJCO = "5"
							Dados->CONTRATACA := BI3->BI3_NATJCO + STR0051 //"-BENEFICENTE"
					EndCase
				Else
					If  BQC->BQC_ENTFIL == "1"
						Dados->CONTRATACA := STR0052 //"5-BENEFICENTE"
					Else
						If  BT5->BT5_TIPCON $ "3,4"
							Dados->CONTRATACA := STR0053 //"4-ADESAO"
						Else
							Dados->CONTRATACA := STR0054 //"3-EMPRESARIAL"
						Endif
					Endif
				Endif
				
				If BDE->( FieldPos("BDE_NOMCAR") ) > 0 .And. Type("M->BDE_NOMCAR") <> "U" 
					If M->BDE_NOMCAR == "1"
						Dados->NOMEUSUARI := PLSEXP2->BTS_NOMCAR
					Else
						Dados->NOMEUSUARI := PLSEXP2->BTS_NOMUSR
					EndIf
				Else
					Dados->NOMEUSUARI := PLSEXP2->BTS_NOMCAR
				EndIf
				Dados->DTNACTO    := cDataNasc
				Dados->DTVALID    := cDataValid
				Dados->DTINC      := cDataInsc
				Dados->PLANO      := BI3->BI3_CODIGO
				Dados->TPCONTRATO := BI3->BI3_NATJCO
				
				//Para customizar campos como por exemplo "BQC_YNOMCA" e BQC_YINFCA
				If lPL264INFO
					aRetInfo:= ExecBlock("PL264INFO",.F.,.F.,{Dados->NOMEUSUARI,Dados->DTNACTO,Dados->DTVALID,Dados->DTINC,Dados->PLANO,Dados->TPCONTRATO,BA3->BA3_TIPOUS,aRetNome[1][3]})
					Dados->RZSOCIAL   := aRetInfo[1]
					Dados->INFORMACOE := aRetInfo[2]
				Else
					Dados->RZSOCIAL   := aRetNome[1][3]
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Verso do Cartao... 						                        	Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					Dados->INFORMACOE := STR0055 //"InformaГУes"
				EndIf
				
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//ЁCarrega informacoes das mensagens dinamicamente...					Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				For nI := 1 To Len(aCabCar)
					If nI > 8
						Exit
					EndIf
					Dados->&("MENSAGEM"+strzero(nI,1)) := Alltrim(aCabCar[nI])
				Next nI
				
				For nCarencia := 1 To Len(aDadCar)
					If nI > 8
						Exit
					EndIf
					Dados->&("MENSAGEM"+strzero(nI,1)) := Alltrim(Alltrim(aDadCar[nCarencia][2])+"-"+dtoc(aDadCar[nCarencia][3]))
					nI++
				Next nCarencia
				
				For nRodape := 1 To Len(aRodCar)
					If nI>8
						Exit
					EndIf
					Dados->&("MENSAGEM"+strzero(nI,1)) := Alltrim(aRodCar[nRodape])
					nI++
				Next nRodape
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё LayOut PTU... 						                                Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			ElseIf nLayOut == 2
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Linha 1       						                                Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды				
				Dados->SEP01     	:= "#DCC##EMB#"
				Dados->CODSISCOP 	:= "0"
				Dados->UNIBENEF  	:= SubStr(PLSEXP2->BA1_CODINT,2)
				Dados->EMPRESA   	:= PLSEXP2->BA1_CODEMP
				Dados->INSCRICAO 	:= PLSEXP2->BA1_MATRIC
				Dados->GRAUDEPEN 	:= PLSEXP2->BA1_TIPREG
				Dados->DIGITO    	:= PLSEXP2->BA1_DIGITO
				Dados->CRLF01		:= '"'
				                                                             
				Dados->CNESUSU		:=  AllTrim(PLSEXP2->BTS_NRCRNA)
				

				Dados->SEGASSPL  :=  padr(substr(POSICIONE("BI6",1,XFILIAL("BI6")+ BI3->BI3_CODSEG,"BI6_DESCRI"),1,56),56)
				If BQC->(FieldPos('BQC_SEASPL')) > 0 .and. BA3->BA3_TIPOUS <> '1'
					Dados->SEASPL  :=  BQC->BQC_SEASPL
				Endif
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Linha 2       						                                Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды								
				Dados->DTNACTO   	:= cDataNasc				
				If  BA3->BA3_TIPOUS == "1"
					Do Case
						Case BI3->BI3_NATJCO = "2"
							Dados->CONTRATACA := 'INDIVIDUAL OU FAMILIAR'
						Case BI3->BI3_NATJCO = "3"
							Dados->CONTRATACA := 'COLETIVO EMPRESARIAL'
						Case BI3->BI3_NATJCO = "4"
							Dados->CONTRATACA := 'COLETIVO POR ADESAO'
						Case BI3->BI3_NATJCO = "5"
							Dados->CONTRATACA := 'BENEFICIENTE'
						Otherwise
							Dados->CONTRATACA := "SEM CONTRATACAO"
					EndCase
				Else
					If  AllTrim(BQC->BQC_ENTFIL) == "1"
						Dados->CONTRATACA := 'BENEFICIENTE'
					Else
						BII->(DbSetOrder(1))
						If lTpCtrBI3 .AND. BII->( msSeek(xFilial("BII")+BI3->BI3_TIPCON) ) .AND. !EMPTY(BII->BII_TIPPLA)
							If  AllTrim(BII->BII_TIPPLA) $ "1,3"
								Dados->CONTRATACA := 'COLETIVO POR ADESAO'
							Else
								Dados->CONTRATACA := 'COLETIVO EMPRESARIAL'
							Endif
						Else
							If BII->( msSeek(xFilial("BII")+BT5->BT5_TIPCON) ) .AND. !EMPTY(BII->BII_TIPPLA)
								If  AllTrim(BII->BII_TIPPLA) $ "1,3"
									Dados->CONTRATACA := 'COLETIVO POR ADESAO'
								Else
									Dados->CONTRATACA := 'COLETIVO EMPRESARIAL'
								Endif
							Endif
						EndIf
					Endif
				Endif
				
				BI4->(dbSetOrder(1))      			
				If Empty(BI3->BI3_CODACO)
					Dados->TPACOMODA := PadR(STR0061, 13)	// "NAO SE APLICA"								
				Else
					If BI4->(MsSeek(xFilial("BI4")+AllTrim(BI3->(BI3_CODACO)))) .And.;
						BI4->(FieldPos("BI4_CODEDI")) > 0
						If Empty(BI4->BI4_CODEDI)
							Dados->TPACOMODA := PadR(STR0061, 13)	// "NAO SE APLICA"
						Else
							If AllTrim(BI4->BI4_CODEDI) == "1"
								Dados->TPACOMODA := PadR(STR0062,13)	// "Individual"
							ElseIf AllTrim(BI4->BI4_CODEDI) == "2"
								Dados->TPACOMODA := PadR(STR0063,13)	// "Coletiva"
							Else
								Dados->TPACOMODA := PadR(STR0061, 13) 	// "NAO SE APLICA"     
							EndIf
						EndIf   
					Else 
						Dados->TPACOMODA := PadR(STR0061, 13)	// "NAO SE APLICA"     
					EndIf
				EndIf			
				Dados->DTVIGPL    := cDatXInsc
				Dados->DTVALID    := cDataValid
				Dados->CRLF02	:= '"'
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Linha 3       						                                Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды				
				If BDE->( FieldPos("BDE_NOMCAR") ) > 0 .And. TYPE("M->BDE_NOMCAR") <> "U" 
					If M->BDE_NOMCAR == "1"
						Dados->NOMEUSUARI := PadR(PLSEXP2->BTS_NOMCAR,25)
					Else
						Dados->NOMEUSUARI := PadR(PLSEXP2->BTS_NOMUSR,25)
					EndIf
				Else
					Dados->NOMEUSUARI := PadR(PLSEXP2->BTS_NOMCAR,25)
				EndIf
				Dados->VIACAR     := strzero(nViaCar,2)

				If BI3->(FieldPos("BI3_REDEDI")) > 0 
					Dados->REDATE := BI3->BI3_REDEDI			
				EndIf				
			
				Dados->CRLF03     := '"'               
				
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Linha 4       						                                Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды				
				Dados->DESPLA     := BI3->BI3_DESCAR
				
				If  ! empty(BA1->BA1_LOCCOB)
					If  BA1->BA1_LOCCOB == "1" // origem
						cLocCob := BA1->BA1_OPEORI
					Else
						cLocCob := BA1->BA1_OPEDES
					Endif
				Else
					cLocCob     := PlsIntPad()
				Endif
				
				Dados->LOCALCOB := cLocCob
				
				Do Case
					Case BI3->BI3_ABRANG == "01"
						Dados->ABRANG := "NACIONAL"
					Case BI3->BI3_ABRANG == "02"
						Dados->ABRANG := "GRUPO DE ESTADOS"
					Case BI3->BI3_ABRANG == "03"
						Dados->ABRANG := "ESTADUAL"
					Case BI3->BI3_ABRANG == "04"
						Dados->ABRANG := "GRUPO DE MUNICмPIOS"
					Case BI3->BI3_ABRANG == "05"
						Dados->ABRANG := "LOCAL"
					Otherwise
						Dados->ABRANG := BI3->BI3_ABRANG
				EndCase
				
				Dados->CRLF04    := '"'				
				
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Linha 5       						                                Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды				
				Dados->CPT       := IIF(empty(dDatCpt),PadR("NцO Hа",12),substr(dtos(dDatCpt),7,2)+"/"+substr(dtos(dDatCpt),5,2)+"/"+substr(dtos(dDatCpt),1,4))				
				Dados->NREDUZ    := IIF(BA3->BA3_TIPOUS=="1",BI3->BI3_NREDUZ,BQC->BQC_NREDUZ)
				Dados->NOMPRO    := BI3->BI3_NREDUZ
				Dados->CRLF05    := '"'	
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Trilha 1       						                                Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды								
				Dados->SEP02     := '#ENC#'				
				Dados->SS01 := "%"				
				If BDE->( FieldPos("BDE_NOMCAR") ) > 0 .And. TYPE("M->BDE_NOMCAR") <> "U" 
					If M->BDE_NOMCAR == "1"
						Dados->TARJAMAG1 :=	SubStr(PLSEXP2->BTS_NOMCAR,1,25)
					Else
						Dados->TARJAMAG1 :=	SubStr(PLSEXP2->BTS_NOMUSR,1,25)
					EndIf
				Else
					Dados->TARJAMAG1 :=	SubStr(PLSEXP2->BTS_NOMCAR,1,25)
				EndIf             
				Dados->ES01 := "?"				
				
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Trilha 2       						                                Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды				
				If  AllTrim(BA3->BA3_TIPOUS) == "1"
					cNatJco := BI3->BI3_NATJCO
				Else
   					If  AllTrim(BQC->BQC_ENTFIL) == "1"
						cNatJco := "5"   // Beneficente
					Else
						BII->(DbSetOrder(1))
						If lTpCtrBI3 .AND. BII->( msSeek(xFilial("BII")+BI3->BI3_TIPCON) ) .AND. !EMPTY(BII->BII_TIPPLA)
							If  AllTrim(BII->BII_TIPPLA) $ "1,3"
								cNatJco := "4"   // Adesao
							Else
								cNatJco := "3"   // Empresarial
							Endif
						Else
							If BII->( msSeek(xFilial("BII")+BT5->BT5_TIPCON) ) .AND. !EMPTY(BII->BII_TIPPLA)
									If  AllTrim(BII->BII_TIPPLA) $ "1,3"
										cNatJco := "4"   // Adesao
									Else
										cNatJco := "3"   // Empresarial
									Endif
							Endif
						Endif
					Endif
				Endif
				Dados->SS02 := ";"
				Dados->TARJAMAG2 := PLSEXP2->BA1_CODINT+;
									PLSEXP2->BA1_CODEMP+;
									PLSEXP2->BA1_MATRIC+;
									PLSEXP2->BA1_TIPREG+;
									PLSEXP2->BA1_DIGITO+;
									"="+; //Campo separador
									Strzero(nViaCar,2)+;
									SubStr(cDataValid,9,2)+SubStr(cDataValid,4,2)+;
									"="+; //Campo separador
								    cLocCob+; //Local de Atendimento (Operadora)
							     	BI3->BI3_IDECAR+;//Produto
							     	SubStr(BI3->BI3_ABRANG,Len(BI3->BI3_ABRANG),1)+;//Abrangencia
							     	cNatJco+;//Natureza JurМdica da ContrataГЦo
							    	"1"+;// "1" - Fixo
							    	CodRedeRef()//CСdigo da Rede Referenciada
				Dados->ES02  :=	"?"
				Dados->SEP03 := "#END#@@@@@@"
				
				If GetNewPar("MV_PLSIMCL","0") == "1" // Imprime classe de carencia no cartao ?
					Dados->CLSCAR := ClsCar(PLSEXP2->BA1_CODINT,PLSEXP2->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),PLSEXP2->BA1_DATCAR)
				EndIf                           
				If BI3->(FieldPos('BI3_ABRCAR')) > 0
					Dados->ABRCAR := BI3->BI3_ABRCAR
				Endif
				Dados->SUSEP := Iif(BI3->BI3_APOSRG == "1",BI3->BI3_SUSEP,BI3->BI3_SCPA)

				If BTS->(fieldpos("BTS_NOMSOC")) > 0 
					Dados->NOMSOC := PadR(PLSEXP2->BTS_NOMSOC,25) // Nome social do beneficiario
				EndIf
				// QRCODE
				Dados->QRCODE := "1"+; 					// Indicador de cartЦo - Fixo ⌠1■ - cartЦo fМsico	 
								 "="+; 					// Field Separator
								 "01"+; 				// Versionamento das informaГУes do QR Code do Manual do CartЦo √ fixo: ⌠01■
								 "="+; 					// Field Separator
								 PLSEXP2->BA1_CODINT+; 	
								 PLSEXP2->BA1_CODEMP+;
								 PLSEXP2->BA1_MATRIC+;	// CСdigo do beneficiАrio com 17 posiГУes
								 PLSEXP2->BA1_TIPREG+;
								 PLSEXP2->BA1_DIGITO+;
								 "="+; 					// Field Separator
								 Dados->NOMEUSUARI+; 	// Nome reduzido do beneficiАrio
								 "="+; 					// Field Separator
								 cDataNasc+; 			// Data de nascimento
								 "="+; 					// Field Separator
								 IIF(PLSEXP2->BA1_SEXO == "1","M","F")+; // Sexo
								 "="+; 					// Field Separator
								 Padr(PLSEXP2->BTS_NRCRNA,15)+; // CartЦo Nacional de SaЗde
								 "="+; 					// Field Separator
								 cDataValid+; 			// Data de validade
								 "="+; 					// Field Separator
								 strzero(nViaCar,2)+; 	// Via do cartЦo
								 "="+; 					// Field Separator
								 Substr(BI3->BI3_REDEDI,1,4)+; // Rede de Atendimento
								 "="+; 					// Field Separator
								 PadR(Dados->SUSEP,20)+;// registro ANS do produto
								 "="+; 					// Field Separator
								 Dados->NOMSOC			// Nome social do beneficiАrio
				
			ElseIf nLayOut == 3  // GRAVACAO layout samed
				Dados->CODEMP     := PLSEXP2->BA1_CODEMP
				Dados->DESEMP     := IIF(BA3->BA3_TIPOUS=="1",BI3->BI3_DESCRI,BQC->BQC_DESCRI)
				Dados->VALIDADE   := cDataValid
				Dados->TITULAR    := cNomTit  // buscar nome do titular
				
				If BDE->( FieldPos("BDE_NOMCAR") ) > 0 .And. TYPE("M->BDE_NOMCAR") <> "U" 
					If M->BDE_NOMCAR == "1"
						Dados->DEPENDENTE := PLSEXP2->BTS_NOMCAR
					Else
						Dados->DEPENDENTE := PLSEXP2->BTS_NOMUSR
					EndIf
				Else
					Dados->DEPENDENTE := PLSEXP2->BTS_NOMCAR
				EndIf
				
				Dados->MATRICULA  := 	PLSEXP2->BA1_CODINT+"."+;
										PLSEXP2->BA1_CODEMP+"."+;
										PLSEXP2->BA1_MATRIC+"-"+;
										PLSEXP2->BA1_TIPREG+"."+;
										PLSEXP2->BA1_DIGITO
										Dados->PLANO      := BI3->BI3_CODIGO
										Dados->DESPLANO   := BI3->BI3_DESCRI
										Dados->REDE       := If(Len(aRetCar)>=1,aRetCar[1],"") // STANDARD
										Dados->CONSULTA   := If(Len(aRetCar)>=2,aRetCar[2],"")
										Dados->EXAME      := If(Len(aRetCar)>=3,aRetCar[3],"")
										Dados->INTERN     := If(Len(aRetCar)>=4,aRetCar[4],"")
										Dados->PARTO      := If(Len(aRetCar)>=5,aRetCar[5],"")
										Dados->PADRAO     := If(Len(aRetCar)>=6,aRetCar[6],"") // ENFERMARIA
										Dados->NASCIMENTO := cDataNasc
										Dados->EXAMEESP   := If(Len(aRetCar)>=7,aRetCar[7],"")
										Dados->VIACAR     := strzero(nViaCar,2)
										Dados->BADGET     := If(Len(aRetCar)>=8,aRetCar[8],"") //"Uliana"
										Dados->OBS        := If(Len(aRetCar)>=9,aRetCar[9],"")
				
			elseIf nLayOut = 4
			
				Dados->TARJAMAG1 :=	PLSEXP2->BA1_CODINT+;
									PLSEXP2->BA1_CODEMP+;
									PLSEXP2->BA1_MATRIC+;
									PLSEXP2->BA1_TIPREG+;
									PLSEXP2->BA1_DIGITO+;
									"="+; //Campo separador
									Strzero(nViaCar,2)+;
									SubStr(cDataValid,9,2)+SubStr(cDataValid,4,2)+;
									"="+; //Campo separador
									PLSEXP2->BA1_OPERES+;
									BI3->BI3_IDECAR+; //Codigo do produto no Intercambio
									SubStr(BI3->BI3_ABRANG,Len(BI3->BI3_ABRANG),1)+;
									PLSEXP2->BA3_TIPCON
									
				if BDE->( FieldPos("BDE_NOMCAR") ) > 0 .And. TYPE("M->BDE_NOMCAR") <> "U" 
					if M->BDE_NOMCAR == "1"
						Dados->TARJAMAG2 := PLSEXP2->BTS_NOMCAR
					else
						Dados->TARJAMAG2 := PLSEXP2->BTS_NOMUSR
					endIf
				else
					Dados->TARJAMAG2 := PLSEXP2->BTS_NOMCAR
				endIf
	
				Dados->MATRICULA := PLSEXP2->BA1_CODINT + " " +;
									PLSEXP2->BA1_CODEMP + " " +;
									PLSEXP2->BA1_MATRIC + " " +;
									PLSEXP2->BA1_TIPREG + " " +;
									PLSEXP2->BA1_DIGITO
	
				If lPL264INFO
					aRetInfo := ExecBlock("PL264INFO",.F.,.F.,{Dados->NOMEUSUARI,Dados->DTNACTO,Dados->DTVALID,Dados->DTINC,Dados->PLANO,Dados->TPCONTRATO,BA3->BA3_TIPOUS,aRetNome[1][3]})
					Dados->RZSOCIAL   := aRetInfo[1]
					Dados->INFORMACOE := aRetInfo[2]
				Else
					If  BA3->BA3_TIPOUS <> "1" .and. !Empty(BQC->BQC_NOMCAR)
						Dados->RZSOCIAL   := BQC->BQC_NOMCAR
					Else
						Dados->RZSOCIAL   := aRetNome[1][3]
					Endif
					Dados->INFORMACOE := STR0055 //"InformaГУes"
				EndIf
									
				Dados->CNESUSU	 :=  AllTrim(PLSEXP2->BTS_NRCRNA)
				Dados->SEGASSPL  :=  padr(substr(POSICIONE("BI6",1,XFILIAL("BI6")+ BI3->BI3_CODSEG,"BI6_DESCRI"),1,56),56)
				
				BA0->(DbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
				BA0->( msSeek(xFilial("BA0")+PLSEXP2->BA1_CODINT) )
				
				Dados->NUMREGOPE  := BA0->BA0_SUSEP
				Dados->NFANTAZOPE := BA0->BA0_NOMINT
	
				BIM->(DbSetOrder(1))//BIM_FILIAL+BIM_CODINT+BIM_CODIGO
				BIM->( msSeek(xFilial("BIM")+PLSEXP2->BA1_CODINT) )
				
				while !BIM->(eof())
				
					if BIM->BIM_SETOR == GetNewPar("MV_PLBIMSE","012")	
						Dados->CONTATOOPE  := padR(BIM->BIM_NOME,30) + padR(BIM->BIM_TELCON,15) + padR(BIM->BIM_EMAIL,30)						
						exit 
					endIf
				
				BIM->(dbSkip())
				endDo
				
				BK5->(DbSetOrder(1))//BK5_FILIAL+BK5_NOME
				BK5->( msSeek(xFilial("BK5")) )
	
				Dados->CONTATOANS := padR(BK5->BK5_NOME,40) + padR(BK5->BK5_TEL,15) + padR(BK5->BK5_EMAIL,30) 
				Dados->CPT        := IIF(empty(dDatCpt),PadR("NцO Hа",12),substr(dtos(dDatCpt),7,2)+"/"+substr(dtos(dDatCpt),5,2)+"/"+substr(dtos(dDatCpt),1,4))			
	
				BG9->(DbSetOrder(1))//BG9_FILIAL+BG9_CODINT+BG9_CODIGO+BG9_TIPO
				BG9->( msSeek( xFilial("BG9")+PLSEXP2->(BA1_CODINT+BA1_CODEMP) ) )
	
				Dados->NFAADMBENE := BG9->BG9_NREDUZ
				Dados->DTNACTO    := cDataNasc			
	
				If  BA3->BA3_TIPOUS == "1"
					Do Case
						Case BI3->BI3_NATJCO = "2"
							Dados->CONTRATACA := 'INDIVIDUAL OU FAMILIAR'
						Case BI3->BI3_NATJCO = "3"
							Dados->CONTRATACA := 'COLETIVO EMPRESARIAL'
						Case BI3->BI3_NATJCO = "4"
							Dados->CONTRATACA := 'COLETIVO POR ADESAO'
						Case BI3->BI3_NATJCO = "5"
							Dados->CONTRATACA := 'BENEFICIENTE'
						Otherwise
							Dados->CONTRATACA := "SEM CONTRATACAO"
					EndCase
				Else
					If  AllTrim(BQC->BQC_ENTFIL) == "1"
						Dados->CONTRATACA := 'BENEFICIENTE'
					Else
						BII->(DbSetOrder(1))
						If lTpCtrBI3 .AND. BII->( msSeek(xFilial("BII")+BI3->BI3_TIPCON) ) .AND. !EMPTY(BII->BII_TIPPLA)
							If  AllTrim(BII->BII_TIPPLA) $ "1,3"
								Dados->CONTRATACA := 'COLETIVO POR ADESAO'
							Else
								Dados->CONTRATACA := 'COLETIVO EMPRESARIAL'
							Endif
						Else
							If BII->( msSeek(xFilial("BII")+BT5->BT5_TIPCON) ) .AND. !EMPTY(BII->BII_TIPPLA)
								If  AllTrim(BII->BII_TIPPLA) $ "1,3"
									Dados->CONTRATACA := 'COLETIVO POR ADESAO'
								Else
									Dados->CONTRATACA := 'COLETIVO EMPRESARIAL'
								Endif
							Endif
						EndIf
					Endif
				Endif
					
				BI4->(dbSetOrder(1))      			
				If Empty(BI3->BI3_CODACO)
					Dados->TPACOMODA := PadR(STR0061, 13)	// "NAO SE APLICA"								
				Else
					If BI4->(MsSeek(xFilial("BI4")+AllTrim(BI3->(BI3_CODACO)))) .And.;
						BI4->(FieldPos("BI4_CODEDI")) > 0
												
						If Empty(BI4->BI4_CODEDI)
							Dados->TPACOMODA := PadR(STR0061, 13)	// "NAO SE APLICA"
						Else
							If AllTrim(BI4->BI4_CODEDI) == "1"
								Dados->TPACOMODA := PadR(STR0062,13)	// INDIVIDUAL
							ElseIf AllTrim(BI4->BI4_CODEDI) == "2"
								Dados->TPACOMODA := PadR(STR0063,13)	// COLETIVA
							Else
								Dados->TPACOMODA := PadR(STR0061, 13) 	// "NAO SE APLICA"     
							EndIf
						EndIf   
					Else 
						Dados->TPACOMODA := PadR(STR0061, 13)	// "NAO SE APLICA"     
					EndIf
				EndIf		  
	
				If BDE->( FieldPos("BDE_NOMCAR") ) > 0 .And. TYPE("M->BDE_NOMCAR") <> "U" 
					If M->BDE_NOMCAR == "1"
						Dados->NOMEUSUARI := PadR(PLSEXP2->BTS_NOMCAR,25)
					Else
						Dados->NOMEUSUARI := PadR(PLSEXP2->BTS_NOMUSR,25)
					EndIf
				Else
					Dados->NOMEUSUARI := PadR(PLSEXP2->BTS_NOMCAR,25)
				EndIF        			
				
				Do Case
					Case BI3->BI3_ABRANG == "01"
						Dados->ABRANG := "NACIONAL"
					Case BI3->BI3_ABRANG == "02"
						Dados->ABRANG := "GRUPO DE ESTADOS"
					Case BI3->BI3_ABRANG == "03"
						Dados->ABRANG := "ESTADUAL"
					Case BI3->BI3_ABRANG == "04"
						Dados->ABRANG := "GRUPO DE MUNICмPIOS"
					Case BI3->BI3_ABRANG == "05"
						Dados->ABRANG := "LOCAL"
					Otherwise
						Dados->ABRANG := BI3->BI3_ABRANG
				EndCase
	
				Dados->DTVIGPL 	:= cDatXInsc
			    Dados->NOMPRO   := BI3->BI3_NREDUZ
				Dados->SUSEP 	:= Iif(BI3->BI3_APOSRG == "1",BI3->BI3_SUSEP,BI3->BI3_SCPA)
				
			EndIf
						
			Dados->(MsUnlock())
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё caso o usuario esteja marcado como alterado, marca o    	Ё
			//Ё como cartao gerado         					             	Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if !lImpressao .Or. _nTipo == 2
				If  BA1->(FieldPos("BA1_EMICAR")) > 0 .and. BA1->BA1_EMICAR == "1"
					If  BA1->(RecLock("BA1",.F.))
						BA1->BA1_EMICAR := "2" // preparado
						BA1->(msUnLock())
					Endif
				Endif
			endIf	
			
			PLSEXP2->(dbSkip())
		EndDo
		PLSEXP2->(dbCloseArea())
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁImprime dependente que esta sem titular no arquivo	Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Else
		nTemTit   := aScan(aTitular, bProcTit)          
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se o titular esta bloqueado (para gerar cartao de  Ё
	    //Ё dependente que nao esta bloqueado.                          Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	   	lTitBloq := .F. //Reinicializa variavel    
	   	aArea 	 := BA1->(GetArea())
		BA1->(DbSetOrder(2))
		BA1->(msSeek(xFilial("BA1")+PLSEXP1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))    
		While BA1->BA1_MATRIC == PLSEXP1->BA1_MATRIC .And. !BA1->( Eof())
		   If BA1->BA1_TIPREG == cTipReg .Or. BA1->BA1_TIPUSU == cTipUsu      
				If UsuBlq264(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),BA1->BA1_TIPREG,dDatabase, BA1->BA1_DATBLO, BA1->BA1_MOTBLO, BA1->BA1_CONSID)
		          lTitBloq := .T.
		          Exit
		       EndIf       
		   EndIf    
		   BA1->(DbSkip())
      	EndDo
		RestArea(aArea)	 
		
		If nTemTit == 0 .Or. lTitBloq
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Alimenta Mensagem...										Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If _nTipo <> 2
				IncProc(STR0035 + Str(nQtd,10)) 		 //"Selecionando inf. para cartЦo magnetico. "
			Else
				IncProc(STR0035 + AllTrim(Str(nQtd,10)) + "/" + AllTrim(Str(nTotal,10))) //"Selecionando inf. para cartЦo magnetico. "
			EndIf
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Para qualquer exportacao ou emissao atualizar como modelo abaixo... Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			BA1->(DbGoTo(PLSEXP1->BA1REG))
			BA3->(DbGoTo(PLSEXP1->BA3REG))

			If lCartaoVirtual
				If !ChckProdCardVirtual(BA3->BA3_CODPLA, BA3->BA3_VERSAO, BA3->BA3_CODINT, BA3->BA3_CODEMP, BA3->BA3_CONEMP,;
										BA3->BA3_VERCON, BA3->BA3_SUBCON, BA3->BA3_VERSUB)
					PLSEXP1->(DbSkip())
					Loop
				EndIf
			EndIf

			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifica CPT                                                        Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			BF3->(dbSetOrder(1))
			BF3->(msSeek(xFilial("BF3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)))
			dDatCpt := ctod("  /  /  ")
			While ! BF3->(eof()) .and. BF3->(BF3_FILIAL+BF3_CODINT+BF3_CODEMP+BF3_MATRIC+BF3_TIPREG) == ;
				xFilial("BF3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)
				If  ! empty(BF3->BF3_CODDOE)
					If BF3->BF3_UNAGR == "3" //"Meses"
						If  Empty(BF3->BF3_DATCPT)
							If  Empty(BA1->BA1_DATCPT)
								nDias	:=	Abs(( date() -MonthSum( date() , 0 )))
								dDatCPt:= date()+nDias
							Else
								nDias	:=	Abs((BA1->BA1_DATCPT -MonthSum(BA1->BA1_DATCPT , BF3->BF3_MESAGR )))
								dDatCPt:= BA1->BA1_DATCPT+nDias
							Endif
						Else
							nDias	:=	Abs((BF3->BF3_DATCPTT -MonthSum(BF3->BF3_DATCPTT , BF3->BF3_MESAGR )))
							dDatCPt:= BF3->BF3_DATCPT+nDias
						Endif	
					Else			
					nDias   := PLSCarDias(BF3->BF3_MESAGR,BF3->BF3_UNAGR)
						dDatFim := BF3->BF3_DATCPT + nDias
					If  dDatFim > dDatCpt
						dDatCpt := dDatFim
						Endif
					Endif
				Endif
				BF3->(dbSkip())
			Enddo
			
			If BA3->BA3_TIPOUS <> "1"
				
				If  BT5->(BT5_FILIAL+BT5_CODINT+BT5_CODIGO+BT5_NUMCON+BT5_VERSAO) <> ;
					xFilial("BT5")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON)
					BT5->(DbSetOrder(1))
					BT5->(msSeek(xFilial("BT5")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON)))
					If ! BT5->(Found())
						If lPLS264E2
							Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0013}) //"Contrato nЦo Cadastrado."
							PLSEXP1->(DbSkip())
							Loop
						Else
							cMsgCri := AllTrim(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)) + " - "
							cMsgCri += STR0013 //"Contrato nЦo Cadastrado."
							If !lweb
								If Aviso(STR0036,cMsgCri,{STR0006,STR0007},3,STR0038) == 1 //"CrМtica!"###"&Sim"###"&NЦo"###"Deseja Continuar?"
									PLSEXP1->(DbSkip())
									Loop
								Else
									PLSEXP1->(DbCloseArea())
									PLApag(cTrb)
									Return({.F.,{nQtd},aCriticas,aDados})
								EndIf
							Else
								PLSEXP1->(dbCloseArea())
								PLApag(cTrb)
								Aadd(aCriticas, {STR0036,cMsgCri}) 	
								Return({.F.,{nQtd},aCriticas,aDados})							
							Endif
							
						EndIf
					Endif
				Endif
				
				If  BQC->(BQC_FILIAL+BQC_CODIGO+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB) <> ;
					xFilial("BQC")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)
					BQC->(DbSetOrder(1))
					BQC->(msSeek(xFilial("BQC")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))
					If ! BQC->(Found())
						If lPLS264E2
							Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0014}) //"Sub-Contrato nЦo Cadastrado."
							PLSEXP1->(DbSkip())
							Loop
						Else
							cMsgCri := AllTrim(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)) + " - "
							cMsgCri += STR0014 //"Sub-Contrato nЦo Cadastrado."
							If !lweb
								If Aviso(STR0036,cMsgCri,{STR0006,STR0007},3,STR0038) == 1 //"CrМtica!"###"&Sim"###"&NЦo"###"Deseja Continuar?"
									PLSEXP1->(DbSkip())
									Loop
								Else
									PLSEXP1->(DbCloseArea())
									PLApag(cTrb)
									Return({.F.,{nQtd},aCriticas,aDados})
								EndIf
							Else
								PLSEXP1->(dbCloseArea())
								PLApag(cTrb)
								Aadd(aCriticas, {STR0036,cMsgCri}) 	
								Return({.F.,{nQtd},aCriticas,aDados})
							Endif
							
						EndIf
					Endif
				Endif
				
				If  BQC->BQC_EMICAR == "0" // indica que nao deve gerar cartao para este subcontrato
					PLSEXP1->(DbSkip())
					Loop
				Endif
			Endif
			
			If  BG9->(BG9_FILIAL+BG9_CODINT+BG9_CODIGO) <> ;
				xFilial("BG9")+PLSEXP1->(BA3_CODINT+BA3_CODEMP)
				BG9->(DbSetOrder(1))
				BG9->(msSeek(xFilial("BG9")+PLSEXP1->(BA3_CODINT+BA3_CODEMP)))
			Endif
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Posiciona Produto do usuario... 									Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If  ! empty(BA1->(BA1_CODPLA+BA1_VERSAO))
				If  BI3->(BI3_FILIAL+BI3_CODINT+BI3_CODIGO+BI3_VERSAO) <> ;
					xFilial("BI3")+BA1->(BA1_CODINT+BA1_CODPLA+BA1_VERSAO)
					BI3->(DbSetOrder(1))
					If  ! BI3->(msSeek(xFilial("BI3")+BA1->(BA1_CODINT+BA1_CODPLA+BA1_VERSAO)))
						If lPLS264E2
							Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0015}) //"Plano do usuАrio nЦo cadastrado."
							PLSEXP1->(DbSkip())
							Loop
						Else
							cMsgCri := AllTrim(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)) + " - "
							cMsgCri += STR0015 //"Plano do usuАrio nЦo cadastrado."
							If !lweb
								If Aviso(STR0036,cMsgCri,{STR0006,STR0007},3,STR0038) == 1 //"CrМtica!"###"&Sim"###"&NЦo"###"Deseja Continuar?"
									PLSEXP1->(DbSkip())
									Loop
								Else
									PLSEXP1->(DbCloseArea())
									PLApag(cTrb)
									Return({.F.,{nQtd},aCriticas,aDados})
								EndIf
							Else
								PLSEXP1->(dbCloseArea())
								PLApag(cTrb)
								Aadd(aCriticas, {STR0036,cMsgCri}) 	
								Return({.F.,{nQtd},aCriticas,aDados})							

							Endif
						EndIf
					Endif
				Endif
			Else
				If  BI3->(BI3_FILIAL+BI3_CODINT+BI3_CODIGO+BI3_VERSAO) <> ;
					xFilial("BI3")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)
					BI3->(DbSetOrder(1))
					If ! BI3->(msSeek(xFilial("BI3")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)))
						If lPLS264E2
							Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0016})   //"Plano da famМlia nЦo cadastrado."
							PLSEXP1->(DbSkip())
							Loop
						Else
							cMsgCri := AllTrim(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)) + " - "
							cMsgCri += STR0016 //"Plano da famМlia nЦo cadastrado."
							If !lweb
								If Aviso(STR0036,cMsgCri,{STR0006,STR0007},3,STR0038) == 1 //"CrМtica!"###"&Sim"###"&NЦo"###"Deseja Continuar?"
									PLSEXP1->(DbSkip())
									Loop
								Else
									PLSEXP1->(DbCloseArea())
									PLApag(cTrb)
									Return({.F.,{nQtd},aCriticas,aDados})
								EndIf
							Else
								PLSEXP1->(dbCloseArea())
								PLApag(cTrb)
								Aadd(aCriticas, {STR0036,cMsgCri}) 	
								Return({.F.,{nQtd},aCriticas,aDados})							

							Endif
							
						EndIf
					Endif
				Endif
			Endif
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifica se foi selecionado produto na tela de lote de carteirinha  Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If  ! empty(cProduto)
				If  BI3->BI3_CODIGO <> cProduto
					PLSEXP1->(DbSkip())
					Loop
				Endif
			Endif
			nRegBTS := BTS->(Recno())
			BA1->(DbSetOrder(2))
			BA1->(DbSeek(xFilial()+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+GetNewPar('MV_PLTRTIT','00'))))
			BTS->(DbSetOrder(1))
			BTS->(DbSeek(xFilial()+BA1->BA1_MATVID))
			cNomTit := BTS->BTS_NOMCAR
			cUniver := BTS->BTS_UNIVER
			BTS->(DbGoto(nRegBTS))
			BA1->(DbGoTo(PLSEXP1->BA1REG))
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Posiciona BED...										 			Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If _nTipo == 4
				BED->(DbSetOrder(1))
				BED->(msSeek(xFilial("BED")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)))
				While BED->(BED_CODINT+BED_CODEMP+BED_MATRIC+BED_TIPREG) == BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)
					If BA1->BA1_VIACAR ==  BED->BED_VIACAR
						Exit
					Endif
					BED->(DbSkip())
				Enddo
				
				If BED->(BED_CODINT+BED_CODEMP+BED_MATRIC+BED_TIPREG) <> BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)
					If lPLS264E2
						Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),;
						STR0017+strzero(BA1->BA1_VIACAR,2)+STR0018})     //"Via de cartЦo "###" nЦo encontrada."
						PLSEXP1->(DbSkip())
						Loop
					Else
						cMsgCri := AllTrim(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)) + " - "
						cMsgCri += STR0017+strzero(BA1->BA1_VIACAR,2)+STR0018 //"Via de cartЦo "###" nЦo encontrada."
						If !lweb
							If Aviso(STR0036,cMsgCri,{STR0006,STR0007},3,STR0038) == 1 //"CrМtica!"###"&Sim"###"&NЦo"###"Deseja Continuar?"
								PLSEXP1->(DbSkip())
								Loop
							Else
								PLSEXP1->(DbCloseArea())
								PLApag(cTrb)
								Return({.F.,{nQtd},aCriticas,aDados})
							EndIf
						Else
							PLSEXP1->(dbCloseArea())
							PLApag(cTrb)
							Aadd(aCriticas, {STR0036,cMsgCri}) 	
							Return({.F.,{nQtd},aCriticas,aDados})				
						Endif
						
					EndIf
				Endif
			Endif
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Nao imprime Via com Titulo em aberto...						Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If lReemissao
				If BED->BED_FATUR == "2"
					If lPLS264E2
						Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0019}) //"TМtulo da via de cartЦo em aberto."
						PLSEXP1->(DbSkip())
						Loop
					Else
						cMsgCri := AllTrim(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)) + " - "
						cMsgCri += STR0019 //"TМtulo da via de cartЦo em aberto."
						If !lweb
							If Aviso(STR0036,cMsgCri,{STR0006,STR0007},3,STR0038) == 1 //"CrМtica!"###"&Sim"###"&NЦo"###"Deseja Continuar?"
								PLSEXP1->(DbSkip())
								Loop
							Else
								PLSEXP1->(DbCloseArea())
								PLApag(cTrb)
								Return({.F.,{nQtd},aCriticas,aDados})
							EndIf
						Else
							PLSEXP1->(dbCloseArea())
							PLApag(cTrb)
							Aadd(aCriticas, {STR0036,cMsgCri}) 	
							Return({.F.,{nQtd},aCriticas,aDados})							

						Endif
						
					EndIf
				Endif
			Endif
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifica se usuario esta bloqueado...					 			Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If UsuBlq264(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),BA1->BA1_TIPREG,dDatabase, BA1->BA1_DATBLO, BA1->BA1_MOTBLO, BA1->BA1_CONSID)
				PLSEXP1->(DbSkip())
				Loop
			Endif
			aRetCar := {}
			If lPLS264CA
				aRetCar := ExecBlock("PLS264CA",.F.,.F.,{BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),BA1->BA1_TIPREG})
			EndIf
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifica se usuario possui Via de Cartao para emitir... 			Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			nRegBED := BED->(Recno())
			nOrdBED := BED->(IndexOrd())
			
			BED->(DbSetOrder(1))
			BED->(msSeek(xFilial("BED")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),.T.))
			
			nUltViaV := 0
			nRegBEDV := 0
			If BED->(FieldPos("BED_USRDEL"))> 0
				While BED->(BED_CODINT+BED_CODEMP+BED_MATRIC+BED_TIPREG) == BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)				
					If BED->(FieldPos("BED_USRDEL")) > 0 
						If nUltViaV <= BED->BED_VIACAR  .and. Empty(BED->BED_USRDEL)
							nUltViaV := BED->BED_VIACAR
							nRegBEDV := BED->(Recno())
						Endif                          
					Else
						If nUltViaV <= BED->BED_VIACAR  
							nUltViaV := BED->BED_VIACAR
							nRegBEDV := BED->(Recno())
						Endif                          
					Endif
					BED->(DbSkip())
				Enddo
			EndIf
			
			If nRegBEDV > 0
				BED->(DbGoTo(nRegBEDV))
			EndIf
			
			If BED->(BED_FILIAL+BED_CODINT+BED_CODEMP+BED_MATRIC+BED_TIPREG) == BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG) .and. !lImpressao
				If  BED->BED_STACAR == "1"
					If lPLS264E2
						Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),;
						STR0043+AllTrim(BED->BED_VIACAR)+STR0021+BED->BED_CDIDEN+STR0044})     //"Via de numero "###" gerado pelo lote "###" esta em aberto e precisa ser encerrada."
						PLSEXP1->(DbSkip())
						Loop
					Else
							
						cMsgCri := AllTrim(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)) +" - " + BA1->BA1_NOMUSR + CHR(13) + CHR(10)
						If AllTrim(BED->BED_CDIDEN) <> STR0002 //"AVULSA"
							cMsgCri += STR0020+AllTrim(BED->BED_VIACAR)+STR0021+BED->BED_CDIDEN + CHR(13) + CHR(10) //"Via de nЗmero "###" gerada pelo lote "
							cMsgCri += STR0045 //"EstА em aberto e precisa ser encerrada."
						Else
							cMsgCri += STR0064 //"O LanГamento avulso do beneficiАrio estА em aberto e precisa ser encerrado."
						Endif
							
					  	If !lweb
							If Aviso(STR0036,cMsgCri,{STR0006,STR0007},3,STR0038) == 1 //"CrМtica!"###"&Sim"###"&NЦo"###"Deseja Continuar?"
								BED->(DbSetOrder(nOrdBED))
								BED->(DbGoTo(nRegBED))
								PLSEXP1->(DbSkip())
								Loop
							Else
								PLSEXP1->(DbCloseArea())
								PLApag(cTrb)
								Return({.F.,{nQtd},aCriticas,aDados})
							EndIf
					   	Else								
   							PLSEXP1->(dbCloseArea())
	   						PLApag(cTrb)
							Aadd(aCriticas, {STR0036,cMsgCri}) 	
							Return({.F.,{nQtd},aCriticas,aDados})							

					   	Endif
					EndIf
				Endif
				nUltVia := BED->BED_VIACAR
			Else
				nUltVia := BA1->BA1_VIACAR
			Endif
			
			BED->(DbSetOrder(nOrdBED))
			BED->(DbGoTo(nRegBED))
			
			If ! lReemissao
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Nao permite emitir uma nova Via caso a ultima esteja em aberto...	Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If BA1->BA1_VIACAR <> nUltVia .And. BED->BED_STACAR == "1"
					If lPLS264E2
						Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0023})     //"зltima via do usuАrio encontra-se em aberto."
						PLSEXP1->(DbSkip())
						Loop
					Else
						cMsgCri := AllTrim(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)) + " - "
						cMsgCri += STR0023 //"зltima via do usuАrio encontra-se em aberto."
						If !lweb
							If Aviso(STR0036,cMsgCri,{STR0006,STR0007},3,STR0038) == 1 //"CrМtica!"###"&Sim"###"&NЦo"###"Deseja Continuar?"
								PLSEXP1->(DbSkip())
								Loop
							Else
								PLSEXP1->(DbCloseArea())
								PLApag(cTrb)
								Return({.F.,{nQtd},aCriticas,aDados})
							EndIf
						Else
							PLSEXP1->(dbCloseArea())
							PLApag(cTrb)
							Aadd(aCriticas, {STR0036,cMsgCri}) 	
							Return({.F.,{nQtd},aCriticas,aDados})
						Endif
						
					EndIf
				Endif
				
			Else
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Verifica se a via do cartao esta bloqueada...						Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If BED->( FieldPos("BED_CODBLO") ) = 0 .or. BED->( FieldPos("BED_BLOIDE") ) = 0
					If lPLS264E2
						Aadd(aCriticas, {'',STR0057})     //"DicionАrio de dados desatualizado!"
						PLSEXP1->(DbSkip())
						Loop
					Else
						If !lweb
							If Aviso(STR0036,STR0057,{STR0006,STR0007},3,STR0038) == 1 //"CrМtica!"###"DicionАrio de dados desatualizado!"###"&Sim"###"&NЦo"###"Deseja Continuar?"
								PLSEXP1->(DbSkip())
								Loop
							Else
								PLSEXP1->(DbCloseArea())
								PLApag(cTrb)
								Return({.F.,{nQtd},aCriticas,aDados})
							EndIf
						Else
							PLSEXP1->(dbCloseArea())
							PLApag(cTrb)
							Aadd(aCriticas, {STR0036,cMsgCri}) 	
							Return({.F.,{nQtd},aCriticas,aDados})
						Endif
						
					EndIf
				Else
					If BED->BED_BLOIDE == "1"
						If lPLS264E2
							Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0024})     //"Via de cartЦo bloqueada."
							PLSEXP1->(DbSkip())
							Loop
						Else
							cMsgCri := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG) + " - "
							cMsgCri += STR0024 //"Via de cartЦo bloqueada."
							If !lweb
								If Aviso(STR0036,cMsgCri,{STR0006,STR0007},3,STR0038) == 1 //"CrМtica!"###"&Sim"###"&NЦo"###"Deseja Continuar?"
									PLSEXP1->(DbSkip())
									Loop
								Else
									PLSEXP1->(DbCloseArea())
									PLApag(cTrb)
									Return({.F.,{nQtd},aCriticas,aDados})
								EndIf
							Else
								PLSEXP1->(dbCloseArea())
								PLApag(cTrb)
								Aadd(aCriticas, {STR0036,cMsgCri}) 	
								Return({.F.,{nQtd},aCriticas,aDados})							
							Endif
							
						EndIf
					Endif
				Endif
				
			Endif
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Ponto de Entrada antes da Emissao... 								Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If lPLS264EM
				If ! ExecBlock("PLS264EM",.F.,.F.,{_nTipo})
					PLSEXP1->(DbSkip())
					Loop
				Endif
			Endif
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Ponto de Entrada antes da Emissao... enviando dados para manipular as criticas Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If lPLS264E2
				aRetPto := ExecBlock("PLS264E2",.F.,.F.,{_nTipo,aCriticas})
				If ! aRetPto[1]
					aCriticas := aClone(aRetPto[2])
					PLSEXP1->(DbSkip())
					Loop
				Endif
			Endif

			If lCartaoVirtual
				aRetVlrCar := {0, "0", "", "", "", "", 0, .T., 0, "", BA1->BA1_CODINT, BA1->BA1_CODEMP, BA1->BA1_MATRIC, BA1->BA1_TIPREG}
			Else
				aRetVlrCar := PLSEXPIVL(BA1->BA1_CODINT	,	BA1->BA1_CODEMP,	BA1->BA1_CONEMP,	BA1->BA1_VERCON,;
										BI3->BI3_CODIGO,	BI3->BI3_VERSAO,	BG9->BG9_TIPO,		BA1->BA1_VIACAR,;
										BA1->BA1_TIPUSU,	BA1->BA1_GRAUPA,	BA1->BA1_MATRIC,	BA1->BA1_TIPREG,;
										BA1->BA1_SUBCON,	BA1->BA1_VERSUB,	If(nUltVia = 0,GetNewPar("MV_PLSMP1V","4"),cMotivo))
			EndIf
			
			If lOK .and. ! aRetVlrCar[8]
				MostraErro()
				lOK := .F.
			Endif
			
			If !lReemissao
				If aRetVlrCar[8]
					
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Calcula Nova Data de Validade... 									Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If cMudaVal == "1"
						If Empty(dDatVal)
							If BA3->BA3_TIPOUS == "1"
								nPerRen := nPeRePF
							Else
								nPerRen := BQC->BQC_NPERRN
							Endif
							dDtVali := BA1->BA1_DTVLCR
							While nPerRen > 12
								dDtVali := stod(strzero((val(substr(dtos(dDtVali),1,4))+1),4)+substr(dtos(dDtVali),5,4))
								nPerRen := nPerRen-12
							EndDo
							dDtVali := stod(substr(dtos(stod(substr(dtos(dDtVali),1,6)+"15")+(nPerRen*30)),1,6)+substr(dtos(dDtVali),7,2))
						Else
							dDtVali := dDatVal
						Endif
						If  lPLS264DT
							dDtVali := ExecBlock("PLS264DT",.F.,.F.,{dDtVali})
						Endif
						
						//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    			    	//Ё So atualiza data no sub-contrato se for geracao por lote            Ё
	    		     	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		     			If FunName() == "PLSA262" .And. TYPE("M->BDE_DTRNCR") == "D"
		     			 
						    If  BA3->BA3_TIPOUS <> "1" .and.  BDE->(fieldpos("BDE_DTRNCR")) > 0 .And. ! Empty(M->BDE_DTRNCR) .And. BQC->BQC_VALID <> M->BDE_DTRNCR
							    BQC->(RecLock("BQC",.F.))
							    	BQC->BQC_VALID := M->BDE_DTRNCR
							    BQC->(MsUnLock())
						    Endif
						    
						EndIf    
						
					Else
						dDtVali := BA1->BA1_DTVLCR
					Endif
					If BA1->BA1_TIPUSU <> cTipUsu
						If cMaior == "1" .And.;
							BDE->(FieldPos("BDE_MAIORI")) > 0 .And.;
							BDE->(FieldPos("BDE_GFILHO")) > 0 .And.;
							BDE->(FieldPos("BDE_GFILUN")) > 0 .And.;
							BDE->(FieldPos("BDE_GFILHA")) > 0 .And.;
							BDE->(FieldPos("BDE_GFILAU")) > 0 .And.;
							BDE->BDE_MAIORI == "1" .And.;
							BA1->BA1_GRAUPA $ (M->BDE_GFILHO,M->BDE_GFILUN,M->BDE_GFILHA,M->BDE_GFILAU)
							
							BT0->(DbSetOrder(1))
							BT1->(DbSetOrder(1))
							If BT0->(MsSeek(xFilial("BT0") + BA1->(BA1_CODINT + BA1_CODEMP + BA1_NUMCON + BA1_VERCON + BA1_SUBCON + BA1_VERSUB) + BI3->(BI3_CODIGO + BI3_VERSAO)))
								While BT0->(BT0_FILIAL + BT0_CODIGO + BT0_NUMCON + BT0_VERCON + BT0_SUBCON + BT0_VERSUB + BT0_CODPRO + BT0_VERSAO) ==;
									(xFilial("BT0") + BA1->(BA1_CODINT + BA1_CODEMP + BA1_NUMCON + BA1_VERCON + BA1_SUBCON + BA1_VERSUB)+BI3->(BI3_CODIGO + BI3_VERSAO))
									If BT0->BT0_GRAUPA == BA1->BA1_GRAUPA .And.;
										BT0->BT0_TIPUSR == BA1->BA1_TIPUSU .And.;
										BT0->BT0_ESTCIV == BA1->BA1_ESTCIV .And.;
										BT0->BT0_SEXO == BA1->BA1_SEXO
										
										_nIdMAXm := BT0->BT0_IDAMAX
									EndIf
									BT0->(DbSkip())
								EndDo
							ElseIf BT1->(MsSeek(xFilial("BT1")+ BI3->(BI3_CODINT + BI3_CODIGO + BI3_VERSAO)))
								While BT1->(BT1_FILIAL + BT1_CODIGO + BT1_VERSAO + BT1_TIPUSR) ==;
									(xFilial("BT1") + BI3->(BI3_CODINT + BI3_CODIGO + BI3_VERSAO) + BA1->(BA1_TIPUSU))
									If BT1->BT1_GRAUPA == BA1->BA1_GRAUPA .And.;
										BT1->BT1_TIPUSR == BA1->BA1_TIPUSU .And.;
										BT1->BT1_ESTCIV == BA1->BA1_ESTCIV .And.;
										BT1->BT1_SEXO == BA1->BA1_SEXO
										
										_nIdMAXm := BT1->BT1_IDAMAX
									EndIf
									BT1->(DbSkip())
								EndDo
							EndIf
							If Empty(_nIdMAXm)
								Do Case
									Case BA1->BA1_SEXO == "1" .And. cUniver == "1"
										//BA1->BA1_SEXO == 1 - Masculino // BTS->BTS_UNIVER == 1 - Sim
										_nIdMAXm := IIF(BDE->BDE_IMFOUN > 0, BDE->BDE_IMFOUN, cMvPLSFIOU)
									Case BA1->BA1_SEXO == "1" .And. cUniver == "0"
										//BA1->BA1_SEXO == 1 - Masculino // BTS->BTS_UNIVER == 0 - Nao
										_nIdMAXm := IIF(BDE->BDE_IMFILO > 0, BDE->BDE_IMFILO, cMvPLSFILO)
									Case BA1->BA1_SEXO == "2" .And. cUniver == "1"
										//BA1->BA1_SEXO == 2 - Feminino // BTS->BTS_UNIVER == 1 - Sim
										_nIdMAXm := IIF(BDE->BDE_IMFAUN > 0, BDE->BDE_IMFAUN, cMvPLSFIAU)
									Case BA1->BA1_SEXO == "2" .And. cUniver == "0"
										//BA1->BA1_SEXO == 2 - Feminino // BTS->BTS_UNIVER == 0 - Nao
										_nIdMAXm := IIF(BDE->BDE_IMFIHA > 0, BDE->BDE_IMFIHA, cMvPLSFILA)
								EndCase
							EndIf
							_nAno := Year(BA1->BA1_DATNAS) + _nIdMaxm
							_sMesDia := SUBSTR(DTOS(BA1->BA1_DATNAS),5,4)
							If _sMesDia  == '0229' .or. _sMesDia  == '0228'
								_sMesDia := '0301'
							Endif
							If _sMesDia  == '1231'
								_nAno  := _nAno +1
							Endif
							If (STOD(Str(_nAno,4) + _sMesDia ) + 1) < dDtVali
								dDtVali := STOD(Str(_nAno,4) + _sMesDia ) + 1
							EndIf
						EndIf
					EndIf
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Se nao teve cobranca ou nao foi cobrado direto do usuario... Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					if !lImpressao .Or. _nTipo == 2
					
						If  aRetVlrCar[1] == 0 .or. aRetVlrCar[2] <> "2"
							
							BA1->(RecLock("BA1",.F.))
								BA1->BA1_VIACAR 	:= BA1->BA1_VIACAR + 1
								cCodAnt				:= BA1->BA1_CDIDEN
								BA1->BA1_CDIDEN 	:= cCodigo
								If  ! empty(dDtVali)
									BA1->BA1_DTVLCR := dDtVali
								Endif
							BA1->(MsUnLock())
							
							If lPLS264FAM
								If ! ExecBlock("PLS264FAM",.F.,.F.) .Or. ExecBlock("PLS264FAM",.F.,.F.,{BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)})
									GrvVldCarUsr(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),dDtVali)
								Endif
							Else
								GrvVldCarUsr(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),dDtVali)
							EndIf
						Endif
					
						If  lPLS264VL  // PONTO DE ENTRADA PARA GRAVAR DATA DE VALIDADE EM OUTRAS TABELAS RELACIONADAS
							ExecBlock("PLS264VL",.F.,.F.,{dDtVali})
						Endif
						
						BED->(RecLock("BED",.T.))
							BED->BED_FILIAL := xFilial("BED")
							BED->BED_CODINT := BA1->BA1_CODINT
							BED->BED_CODEMP := BA1->BA1_CODEMP
							BED->BED_MATRIC := BA1->BA1_MATRIC
							BED->BED_TIPREG := BA1->BA1_TIPREG
							BED->BED_DIGITO := BA1->BA1_DIGITO
							BED->BED_MATANT := BA1->BA1_MATANT
							BED->BED_TIPANT := BA1->BA1_TIPANT
							BED->BED_NOMUSR := BA1->BA1_NOMUSR
							BED->BED_VALOR  := aRetVlrCar[1]
							BED->BED_DTSOLI := dDataBase
							BED->BED_CDIDEN := cCodigo
							BED->BED_DATVAL := dDtVali	
							BED->BED_CODANT := cCodAnt
							BED->BED_ORIGEM := AllTrim(FunName())

							If   BED->( FieldPos("BED_PROTOC") ) <> 0 .and. LWeb
								BED->BED_PROTOC := cProtoc
							Endif
							//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//Ё Tratamento para verificar se o sistema ira imprimir o cartao Ё
							//Ё com o nome do cartao ou do usuario quando a rotina for       Ё
							//Ё chamada pelo Call-Center.                                    Ё
							//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							If BED->( FieldPos("BED_NOMCAR") ) <> 0
							   If FunName() == "TMKA271" 
							      If GetNewPar("MV_PLCATMK","0") == "1"
							         BED->BED_NOMCAR := "1"
							      Else
							         BED->BED_NOMCAR := "0"
							      EndIf
							   Else
							      BED->BED_NOMCAR := M->BDE_NOMCAR
							   EndIf   
						    EndIf  
							
							If BED->( FieldPos("BED_BLOIDE") ) <> 0
								BED->BED_BLOIDE := "0"
							Endif
							//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//Ё Se nao teve cobranca ou nao foi cobrado direto do usuario... Ё
							//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							If aRetVlrCar[1] == 0 .or. aRetVlrCar[2] <> "2"
								BED->BED_VIACAR := BA1->BA1_VIACAR
							Else
								BED->BED_VIACAR := BA1->BA1_VIACAR + 1
							Endif
							
							If BED->BED_VIACAR==1
								BED->BED_MOTIVO := GetNewPar("MV_PLSMP1V","4")
							Else
								BED->BED_MOTIVO := cMotivo
							EndIf
							
							If aRetVlrCar[2] == "2" //Aguardando liquidacao do titulo...
								BED->BED_FATUR := "2"
							Elseif aRetVlrCar[2] == "1" //Faturado para proxima cobranca...
								BED->BED_FATUR  := If(BED->BED_VALOR==0,"0","1")
							Elseif aRetVlrCar[2] == "0" //Nao Faturado...
								BED->BED_FATUR := "0"
							Endif
							
							If BED->BED_FATUR $ "1,2"
								BED->BED_ANMSFT := subs(dtos(dDataBase),1,6)
							Else
								BED->BED_ANMSFT := ""
							Endif
							
							BED->BED_NUMCOB := IIf(lCartaoVirtual, "VIRTUAL", STR0002) //"AVULSA"
							BED->BED_COBRAR := aRetVlrCar[2]
							BED->BED_PREFIX := aRetVlrCar[3]
							BED->BED_NUMTIT := aRetVlrCar[4]
							BED->BED_PARCEL := aRetVlrCar[5]
							BED->BED_TIPTIT := aRetVlrCar[6]
							
							BED->BED_STACAR := "1"
						
						BED->(MsUnLock())
					endIf
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Acumula quantidade de registros criados...					Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					nQtd ++
				Endif
			EndIf
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Valida via do Cartao...										Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If BA1->BA1_VIACAR == 0 .And. aRetVlrCar[2] <> "2"  .and. !lImpressao

				If lPLS264E2
					Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0025}) //"Via do cartЦo do usuАrio invАlida."
					PLSEXP1->(DbSkip())
					Loop
				Else
					cMsgCri := AllTrim(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)) + " - "
					cMsgCri += STR0025  //"Via do cartЦo do usuАrio invАlida."

					If !lweb
						If Aviso(STR0036,cMsgCri,{STR0006,STR0007},3,STR0038) == 1 //"CrМtica!"###"&Sim"###"&NЦo"###"Deseja Continuar?"
							PLSEXP1->(DbSkip())
							Loop
						Else
							PLSEXP1->(DbCloseArea())
							PLApag(cTrb)
							Return({.F.,{nQtd},aCriticas,aDados})
						EndIf
					Else
						PLSEXP1->(dbCloseArea())
						PLApag(cTrb)
						Aadd(aCriticas, {STR0036,cMsgCri}) 	
						Return({.F.,{nQtd},aCriticas,aDados})							
					Endif
					
				EndIf
			Endif
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Alimenta Data de Validade e Via do Cartao...						Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If lReemissao
				nViaCar := BED->BED_VIACAR
				dDtVali := BED->BED_DATVAL
			Else
				nViaCar := BA1->BA1_VIACAR
				dDtVali := BA1->BA1_DTVLCR
			Endif
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Mensagens para cabecalho...									Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aCabCar := PLSM02TEXT( BA1->BA1_CODINT, 3, BA3->BA3_TIPOUS, BI3->BI3_MODPAG, BA1->BA1_CODEMP, BA1->BA1_CONEMP, BA1->BA1_SUBCON,	BA1->BA1_MATRIC, BI3->BI3_CODIGO, substr(dtos(dDataBase),1,6))
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Mensagens para rodape...									Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aRodCar := PLSM02TEXT( BA1->BA1_CODINT, 4, BA3->BA3_TIPOUS, BI3->BI3_MODPAG, BA1->BA1_CODEMP, BA1->BA1_CONEMP, BA1->BA1_SUBCON,	BA1->BA1_MATRIC, BI3->BI3_CODIGO, substr(dtos(dDataBase),1,6))
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё LayOut PLS... 						                                Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If nLayOut == 1
				cDataNasc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATNAS),2), cMes := StrZero(Month(BA1->BA1_DATNAS),2), cAno := StrZero(Year(BA1->BA1_DATNAS),4), cDia+"/"+cMes+"/"+cAno })
				cDataInsc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATINC),2), cMes := StrZero(Month(BA1->BA1_DATINC),2), cAno := StrZero(Year(BA1->BA1_DATINC),4), cDia+"/"+cMes+"/"+cAno })
				cDataValid:= Eval({ || cDia := StrZero(Day(dDtVali),2), cMes := StrZero(Month(dDtVali),2), cAno := StrZero(Year(dDtVali),4), cDia+"/"+cMes+"/"+cAno })
				cDatXInsc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATINC),2), cMes := StrZero(Month(BA1->BA1_DATINC),2), cAno := StrZero(Year(BA1->BA1_DATINC),4), cDia+"/"+cMes+"/"+cAno })			

				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё LayOut PTU... 						                                Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			ElseIf nLayOut == 2
				cDataNasc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATNAS),2), cMes := StrZero(Month(BA1->BA1_DATNAS),2), cAno := StrZero(Year(BA1->BA1_DATNAS),4), cDia+"/"+cMes+"/"+cAno })
				cDataInsc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATINC),2), cMes := StrZero(Month(BA1->BA1_DATINC),2), cAno := StrZero(Year(BA1->BA1_DATINC),4), cDia+cMes+SubStr(cAno,3) })
				cDatXInsc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATINC),2), cMes := StrZero(Month(BA1->BA1_DATINC),2), cAno := StrZero(Year(BA1->BA1_DATINC),4), cDia+"/"+cMes+"/"+cAno })						
				cDataValid:= Eval({ || cDia := StrZero(Day(dDtVali),2), cMes := StrZero(Month(dDtVali),2), cAno := StrZero(Year(dDtVali),4), cDia+"/"+cMes+"/"+cAno })
			ElseIf nLayOut == 3
				cDataNasc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATNAS),2), cMes := StrZero(Month(BA1->BA1_DATNAS),2), cAno := StrZero(Year(BA1->BA1_DATNAS),4), cDia+"/"+cMes+"/"+cAno })
				cDataInsc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATINC),2), cMes := StrZero(Month(BA1->BA1_DATINC),2), cAno := StrZero(Year(BA1->BA1_DATINC),4), cDia+cMes+SubStr(cAno,3) })
				cDataValid:= Eval({ || cDia := StrZero(Day(dDtVali),2), cMes := StrZero(Month(dDtVali),2), cAno := StrZero(Year(dDtVali),4), cDia+"/"+cMes+"/"+cAno })
				cDatXInsc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATINC),2), cMes := StrZero(Month(BA1->BA1_DATINC),2), cAno := StrZero(Year(BA1->BA1_DATINC),4), cDia+"/"+cMes+"/"+cAno })			
			elseIf nLayOut == 4
				cDataNasc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATNAS),2), cMes := StrZero(Month(BA1->BA1_DATNAS),2), cAno := StrZero(Year(BA1->BA1_DATNAS),4), cDia+"/"+cMes+"/"+cAno })
				cDataInsc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATINC),2), cMes := StrZero(Month(BA1->BA1_DATINC),2), cAno := StrZero(Year(BA1->BA1_DATINC),4), cDia+"/"+cMes+"/"+cAno })
				cDataValid:= Eval({ || cDia := StrZero(Day(dDtVali),2), cMes := StrZero(Month(dDtVali),2), cAno := StrZero(Year(dDtVali),4), cDia+"/"+cMes+"/"+cAno })
				cDatXInsc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATINC),2), cMes := StrZero(Month(BA1->BA1_DATINC),2), cAno := StrZero(Year(BA1->BA1_DATINC),4), cDia+"/"+cMes+"/"+cAno })			

			Endif
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Retorna a carencia dos produtos...							Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aDadCar := PLSLISMSGC(	PLSEXP1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO), BI3->(BI3_CODINT+BI3_CODIGO),;
									PLSEXP1->BA3_VERSAO,PLSEXP1->BA1_DATCAR,PLSEXP1->BA1_SEXO)
			
			aRetNome:= PLSAVERNIV(	PLSEXP1->BA1_CODINT, PLSEXP1->BA1_CODEMP, PLSEXP1->BA1_MATRIC,	IF(PLSEXP1->BA3_TIPOUS=="1","F","J"),;
									PLSEXP1->BA3_CONEMP, PLSEXP1->BA3_VERCON, PLSEXP1->BA3_SUBCON, PLSEXP1->BA3_VERSUB, 1,;
									PLSEXP1->BA1_TIPREG)
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifica RegulamentaГЦo do Plano                                    Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды		
			BI3->(dbSetOrder(1))
			BI3->(msSeek(xFilial("BF3")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)))

			Do Case
				Case BI3->BI3_APOSRG == '0'
					cTipPlan := 'Plano Nao Regulamentado'
				Case BI3->BI3_APOSRG == '1'
					cTipPlan := 'Plano Regulamentado'
				Case BI3->BI3_APOSRG == '2'
					cTipPlan := 'Plano Adaptado'
			EndCase
			
			cNumPlan := BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifica Prazo Maximo de carencia                                   Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
			aVetCarenc := {}
			aRetCarenc := PLSCLACAR(BA1->BA1_CODINT,BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),/*dDataBase*/)
		
			If Len(aRetCarenc) > 0 .And. aRetCarenc[1]
			cMaxCarenc := aRetCarenc[2][1][3]
				For nCont := 1 to len(aRetCarenc[2])
					If Len(aRetCarenc[2][nCont]) > 7 
						If aRetCarenc[2][nCont][3] > cMaxCarenc
							cMaxCarenc := aRetCarenc[2][nCont][3]
						Endif	
					Endif	
				Next    
			Endif
		
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Alimenta arquivo com os dados para arquivo texto...			Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			Dados->(RecLock("Dados",.T.))
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Ponto de Entrada para impressao com LayOut diferente...             Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If lPLS264L2
				nOriDad := 0
				cAlias := "PLSEXP1"
				ExecBlock("PLS264L2",.F.,.F.,{cAlias})
				nSeqCar++
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё LayOut PLS... 						                                Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			ElseIf nLayOut == 1
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Tarja magnetica... 						                            Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				Dados->TARJAMAG1 :=	PLSEXP1->BA1_CODINT+;
									PLSEXP1->BA1_CODEMP+;
									PLSEXP1->BA1_MATRIC+;
									PLSEXP1->BA1_TIPREG+;
									PLSEXP1->BA1_DIGITO+;
									"="+; //Campo separador
									Strzero(nViaCar,2)+;
									SubStr(cDataValid,9,2)+SubStr(cDataValid,4,2)+;
									"="+; //Campo separador
									PLSEXP1->BA1_OPERES+;
									BI3->BI3_IDECAR+; //Codigo do produto no Intercambio
									SubStr(BI3->BI3_ABRANG,Len(BI3->BI3_ABRANG),1)+;
									PLSEXP1->BA3_TIPCON
				
				Dados->TARJAMAG2 := PLSEXP1->BTS_NOMCAR
				
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Frente do Cartao... 						                        Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				Dados->MATRICULA := PLSEXP1->BA1_CODINT + " " +;
				PLSEXP1->BA1_CODEMP + " " +;
				PLSEXP1->BA1_MATRIC + " " +;
				PLSEXP1->BA1_TIPREG + " " +;
				PLSEXP1->BA1_DIGITO
				
				If  BA3->BA3_TIPOUS == "1"
					Do Case
						Case BI3->BI3_NATJCO = "2"
							Dados->CONTRATACA := BI3->BI3_NATJCO + STR0048 //"-FISICA"
						Case BI3->BI3_NATJCO = "3"
							Dados->CONTRATACA := BI3->BI3_NATJCO + STR0049 //"-EMPRESARIAL"
						Case BI3->BI3_NATJCO = "4"
							Dados->CONTRATACA := BI3->BI3_NATJCO + STR0050 //"-ADESAO"
						Case BI3->BI3_NATJCO = "5"
							Dados->CONTRATACA := BI3->BI3_NATJCO + STR0051 //"-BENEFICENTE"
					EndCase
				Else
					If  BQC->BQC_ENTFIL == "1"
						Dados->CONTRATACA := STR0052   // Beneficente //"5-BENEFICENTE"
					Else
						If  BT5->BT5_TIPCON $ "3,4"
							Dados->CONTRATACA := STR0053   // Adesao //"4-ADESAO"
						Else
							Dados->CONTRATACA := STR0054   // Empresarial //"3-EMPRESARIAL"
						Endif
					Endif
				Endif
				
				Dados->NOMEUSUARI := PLSEXP1->BTS_NOMCAR
				Dados->DTNACTO    := cDataNasc
				Dados->DTVALID    := cDataValid
				Dados->DTINC      := cDataInsc
				Dados->PLANO      := BI3->BI3_CODIGO
				Dados->TPCONTRATO := BI3->BI3_NATJCO
				
				//Para customizar campos como por exemplo "BQC_YNOMCA" e BQC_YINFCA
				If lPL264INFO
					aRetInfo:= ExecBlock("PL264INFO",.F.,.F.,{Dados->NOMEUSUARI,Dados->DTNACTO,Dados->DTVALID,Dados->DTINC,Dados->PLANO,Dados->TPCONTRATO,BA3->BA3_TIPOUS,aRetNome[1][3]})
					Dados->RZSOCIAL   := aRetInfo[1]
					Dados->INFORMACOE := aRetInfo[2]
				Else
					Dados->RZSOCIAL   := aRetNome[1][3]
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Verso do Cartao... 						                        	Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					Dados->INFORMACOE := STR0055 //"InformaГУes"
				EndIf
				
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//ЁCarrega informacoes das mensagens dinamicamente...					Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				For nI := 1 To Len(aCabCar)
					If nI > 8
						Exit
					EndIf
					Dados->&("MENSAGEM"+strzero(nI,1)) := Alltrim(aCabCar[nI])
				Next nI
				
				For nCarencia := 1 To Len(aDadCar)
					If nI > 8
						Exit
					EndIf
					Dados->&("MENSAGEM"+strzero(nI,1)) := Alltrim(Alltrim(aDadCar[nCarencia][2])+"-"+dtoc(aDadCar[nCarencia][3]))
					nI++
				Next nCarencia
				
				For nRodape := 1 To Len(aRodCar)
					If nI>8
						Exit
					EndIf
					Dados->&("MENSAGEM"+strzero(nI,1)) := Alltrim(aRodCar[nRodape])
					nI++
				Next nRodape
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё LayOut PTU... 						                                Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			ElseIf nLayOut == 2
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Linha 1       						                                Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды								
				Dados->SEP01     := "#DCC##EMB#"
				Dados->CODSISCOP := "0"
				Dados->UNIBENEF  := SubStr(PLSEXP1->BA1_CODINT,2)
				Dados->EMPRESA   := PLSEXP1->BA1_CODEMP
				Dados->INSCRICAO := PLSEXP1->BA1_MATRIC
				Dados->GRAUDEPEN := PLSEXP1->BA1_TIPREG
				Dados->DIGITO    := PLSEXP1->BA1_DIGITO
				Dados->CRLF01 	 := '"'
				
				Dados->CNESUSU   :=  AllTrim(PLSEXP1->BTS_NRCRNA)               
				Dados->SEGASSPL  :=  padr(substr(POSICIONE("BI6",1,XFILIAL("BI6")+ BI3->BI3_CODSEG,"BI6_DESCRI"),1,56),56)
				If BQC->(FieldPos('BQC_SEASPL')) > 0 .and. BA3->BA3_TIPOUS <> '1'
					Dados->SEASPL  :=  BQC->BQC_SEASPL
				Endif
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Linha 2       						                                Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды				
				Dados->DTNACTO   := cDataNasc				
				If  BA3->BA3_TIPOUS == "1"
					Do Case
						Case BI3->BI3_NATJCO = "2"
							Dados->CONTRATACA := 'INDIVIDUAL OU FAMILIAR'
						Case BI3->BI3_NATJCO = "3"
							Dados->CONTRATACA := 'COLETIVO EMPRESARIAL'
						Case BI3->BI3_NATJCO = "4"
							Dados->CONTRATACA := 'COLETIVO POR ADESAO'
						Case BI3->BI3_NATJCO = "5"
							Dados->CONTRATACA := 'BENEFICIENTE'
						Otherwise
							Dados->CONTRATACA := "SEM CONTRATACAO"
					EndCase
				Else
					If  AllTrim(BQC->BQC_ENTFIL) == "1"
						Dados->CONTRATACA := 'BENEFICIENTE'
					Else
						BII->(DbSetOrder(1))
						If lTpCtrBI3 .AND. BII->( msSeek(xFilial("BII")+BI3->BI3_TIPCON) ) .AND. !EMPTY(BII->BII_TIPPLA)
							If  AllTrim(BII->BII_TIPPLA) $ "1,3"
								Dados->CONTRATACA := 'COLETIVO POR ADESAO'
							Else
								Dados->CONTRATACA := 'COLETIVO EMPRESARIAL'
							Endif
						Else
							If BII->( msSeek(xFilial("BII")+BT5->BT5_TIPCON) ) .AND. !EMPTY(BII->BII_TIPPLA)
								If  AllTrim(BII->BII_TIPPLA) $ "1,3"
									Dados->CONTRATACA := 'COLETIVO POR ADESAO'
								Else
									Dados->CONTRATACA := 'COLETIVO EMPRESARIAL'
								Endif
							Endif
						EndIf
					Endif
				Endif
				
				BI4->(dbSetOrder(1))      			
				If Empty(BI3->BI3_CODACO)
					Dados->TPACOMODA := PadR(STR0061, 13)	// "NAO SE APLICA"								
				Else
					If BI4->(MsSeek(xFilial("BI4")+AllTrim(BI3->(BI3_CODACO)))) .And.;
						BI4->(FieldPos("BI4_CODEDI")) > 0
						If Empty(BI4->BI4_CODEDI)
							Dados->TPACOMODA := PadR(STR0061, 13)	// "NAO SE APLICA"
						Else
							If AllTrim(BI4->BI4_CODEDI) == "1"
								Dados->TPACOMODA := PadR(STR0062,13)	// "Individual"
							ElseIf AllTrim(BI4->BI4_CODEDI) == "2"
								Dados->TPACOMODA := PadR(STR0063,13)	// "Coletiva"
							Else
								Dados->TPACOMODA := PadR(STR0061, 13) 	// "NAO SE APLICA"     
							EndIf
						EndIf   
					Else 
						Dados->TPACOMODA := PadR(STR0061, 13)	// "NAO SE APLICA"     
					EndIf
				EndIf			
				
				Dados->DTVIGPL    := cDatXInsc
				Dados->DTVALID    := cDataValid
				Dados->CRLF02	  := '"'	
				
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Linha 3       						                                Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If BDE->( FieldPos("BDE_NOMCAR") ) > 0 .And. TYPE("M->BDE_NOMCAR") <> "U" 
					If M->BDE_NOMCAR == "1"
						Dados->NOMEUSUARI := PadR(PLSEXP1->BTS_NOMCAR,25)
					Else
						Dados->NOMEUSUARI := PadR(PLSEXP1->BTS_NOMUSR,25)
					EndIf
				Else
					Dados->NOMEUSUARI := PadR(PLSEXP1->BTS_NOMCAR,25)
				EndIf
				Dados->VIACAR     := strzero(nViaCar,2)
				
				If BI3->(FieldPos("BI3_REDEDI")) > 0 
					Dados->REDATE := BI3->BI3_REDEDI			
				EndIf
				
				Dados->CRLF03     := '"'               
			
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Linha 4       						                                Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды								
				Dados->DESPLA     := BI3->BI3_DESCAR
				
				If  ! empty(BA1->BA1_LOCCOB)
					If  BA1->BA1_LOCCOB == "1" // origem
						cLocCob := BA1->BA1_OPEORI
					Else
						cLocCob := BA1->BA1_OPEDES
					Endif
				Else
					cLocCob     := PlsIntPad()
				Endif
				
				Dados->LOCALCOB := cLocCob
				
				Do Case
					Case BI3->BI3_ABRANG == "01"
						Dados->ABRANG := "NACIONAL"
					Case BI3->BI3_ABRANG == "02"
						Dados->ABRANG := "GRUPO DE ESTADOS"
					Case BI3->BI3_ABRANG == "03"
						Dados->ABRANG := "ESTADUAL"
					Case BI3->BI3_ABRANG == "04"
						Dados->ABRANG := "GRUPO DE MUNICмPIOS"
					Case BI3->BI3_ABRANG == "05"
						Dados->ABRANG := "LOCAL"
					Otherwise
						Dados->ABRANG := BI3->BI3_ABRANG
				EndCase
				
				Dados->CRLF04    := '"'				
								                    
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Linha 5       						                                Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				Dados->CPT       := IIF(empty(dDatCpt),PadR("NцO Hа",12),substr(dtos(dDatCpt),7,2)+"/"+substr(dtos(dDatCpt),5,2)+"/"+substr(dtos(dDatCpt),1,4))				
				Dados->NREDUZ    := IIF(BA3->BA3_TIPOUS=="1",BI3->BI3_NREDUZ,BQC->BQC_NREDUZ)
                Dados->NOMPRO    := BI3->BI3_NREDUZ
                Dados->CRLF05    := '"'	
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Trilha 1       						                                Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды								
				Dados->SEP02     := '#ENC#'
				Dados->SS01		 := '%'				
				If BDE->( FieldPos("BDE_NOMCAR") ) > 0 .And. TYPE("M->BDE_NOMCAR") <> "U"  
					If M->BDE_NOMCAR == "1"
						Dados->TARJAMAG1 :=	SubStr(PLSEXP1->BTS_NOMCAR,1,25)
					Else
						Dados->TARJAMAG1 :=	SubStr(PLSEXP1->BTS_NOMUSR,1,25)
					EndIf
				Else
					Dados->TARJAMAG1 :=	SubStr(PLSEXP1->BTS_NOMCAR,1,25)
				EndIf
				Dados->ES01		 := '?'								
				
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Trilha 2       						                                Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды												
				If  AllTrim(BA3->BA3_TIPOUS) == "1"
					cNatJco := BI3->BI3_NATJCO
				Else
					If  AllTrim(BQC->BQC_ENTFIL) == "1"
						cNatJco := "5"   // Beneficente
					Else
						BII->(DbSetOrder(1))
						If lTpCtrBI3 .AND. BII->( msSeek(xFilial("BII")+BI3->BI3_TIPCON) ) .AND. !EMPTY(BII->BII_TIPPLA)
							If  AllTrim(BII->BII_TIPPLA) $ "1,3"
								cNatJco := "4"   // Adesao
							Else
								cNatJco := "3"   // Empresarial
							Endif
						Else
							If BII->( msSeek(xFilial("BII")+BT5->BT5_TIPCON) ) .AND. !EMPTY(BII->BII_TIPPLA)
								If  AllTrim(BII->BII_TIPPLA) $ "1,3"
									cNatJco := "4"   // Adesao
								Else
									cNatJco := "3"   // Empresarial
								Endif
							Endif
						EndIf
					Endif
				Endif
				
				Dados->SS02	 := ';'								
				Dados->TARJAMAG2 := PLSEXP1->BA1_CODINT+;
									PLSEXP1->BA1_CODEMP+;
									PLSEXP1->BA1_MATRIC+;
									PLSEXP1->BA1_TIPREG+;
									PLSEXP1->BA1_DIGITO+;
									"="+; //Campo separador
									Strzero(nViaCar,2)+;
									SubStr(cDataValid,9,2)+SubStr(cDataValid,4,2)+;
									"="+; //Campo separador
									cLocCob+; //Local de Atendimento (Operadora)
							    	BI3->BI3_IDECAR+;//Produto
							     	SubStr(BI3->BI3_ABRANG,Len(BI3->BI3_ABRANG),1)+;//Abrangencia
							     	cNatJco+;//Natureza JurМdica da ContrataГЦo
							    	"1"+;// "1" - Fixo
							    	CodRedeRef()//CСdigo da Rede Referenciada
				Dados->ES02	 := "?"
				Dados->SEP03 := "#END#@@@@@@"
				If GetNewPar("MV_PLSIMCL","0") == "1" // Imprime classe de carencia no cartao ?
					Dados->CLSCAR := ClsCar(PLSEXP1->BA1_CODINT,PLSEXP1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),PLSEXP1->BA1_DATCAR)
				EndIf
				If BI3->(FieldPos('BI3_ABRCAR')) > 0
					Dados->ABRCAR := BI3->BI3_ABRCAR
				Endif
				Dados->SUSEP := Iif(BI3->BI3_APOSRG == "1",BI3->BI3_SUSEP,BI3->BI3_SCPA)

				If BTS->(fieldpos("BTS_NOMSOC")) > 0
					Dados->NOMSOC := PadR(PLSEXP1->BTS_NOMSOC,25) // Nome social do beneficiario
				EndIf
				// QRCODE
				Dados->QRCODE := "1"+;					// Indicador de cartЦo - Fixo ⌠1■ - cartЦo fМsico	 
								 "="+; 					// Field Separator
								 "01"+;					// Versionamento das informaГУes do QR Code do Manual do CartЦo √ fixo: ⌠01■
								 "="+;					// Field Separator
								 PLSEXP1->BA1_CODINT+; 	
								 PLSEXP1->BA1_CODEMP+;
								 PLSEXP1->BA1_MATRIC+;	// CСdigo do beneficiАrio com 17 posiГУes
								 PLSEXP1->BA1_TIPREG+;
								 PLSEXP1->BA1_DIGITO+;
								 "="+;					// Field Separator
								 Dados->NOMEUSUARI+;	// Nome reduzido do beneficiАrio
								 "="+;					// Field Separator
								 cDataNasc+;			// Data de nascimento
								 "="+;					// Field Separator
								 IIF(PLSEXP1->BA1_SEXO == "1","M","F")+; // Sexo
								 "="+; 					// Field Separator
								 Padr(PLSEXP1->BTS_NRCRNA,15)+; // CartЦo Nacional de SaЗde
								 "="+; 					// Field Separator
								 cDataValid+; 			// Data de validade
								 "="+; 					// Field Separator
								 strzero(nViaCar,2)+; 	// Via do cartЦo
								 "="+; 					// Field Separator
								 Substr(BI3->BI3_REDEDI,1,4)+; // Rede de Atendimento
								 "="+; 					// Field Separator
								 PadR(Dados->SUSEP,20)+;// registro ANS do produto
								 "="+; 					// Field Separator
								 Dados->NOMSOC			// Nome social do beneficiАrio
				
			ElseIf nLayOut == 3  // GRAVACAO layout samed
				Dados->CODEMP     := PLSEXP1->BA1_CODEMP
				Dados->DESEMP     := IIF(BA3->BA3_TIPOUS=="1",BI3->BI3_DESCRI,BQC->BQC_DESCRI)
				Dados->VALIDADE   := cDataValid
				Dados->TITULAR    := cNomTit  // buscar nome do titular
				
				If BDE->( FieldPos("BDE_NOMCAR") ) > 0 .And. TYPE("M->BDE_NOMCAR") <> "U"
					If M->BDE_NOMCAR == "1"
						Dados->DEPENDENTE := PLSEXP1->BTS_NOMCAR
					Else
						Dados->DEPENDENTE := PLSEXP1->BTS_NOMUSR
					EndIf
				Else
					Dados->DEPENDENTE := PLSEXP1->BTS_NOMCAR
				EndIf
				
				Dados->MATRICULA  := 	PLSEXP1->BA1_CODINT+"."+;
										PLSEXP1->BA1_CODEMP+"."+;
										PLSEXP1->BA1_MATRIC+"-"+;
										PLSEXP1->BA1_TIPREG+"."+;
										PLSEXP1->BA1_DIGITO
										Dados->PLANO      := BI3->BI3_CODIGO
										Dados->DESPLANO   := BI3->BI3_DESCRI
										Dados->REDE       := If(Len(aRetCar)>=1,aRetCar[1],"") // STANDARD
										Dados->CONSULTA   := If(Len(aRetCar)>=2,aRetCar[2],"")
										Dados->EXAME      := If(Len(aRetCar)>=3,aRetCar[3],"")
										Dados->INTERN     := If(Len(aRetCar)>=4,aRetCar[4],"")
										Dados->PARTO      := If(Len(aRetCar)>=5,aRetCar[5],"")
										Dados->PADRAO     := If(Len(aRetCar)>=6,aRetCar[6],"") // ENFERMARIA
										Dados->NASCIMENTO := cDataNasc
										Dados->EXAMEESP   := If(Len(aRetCar)>=7,aRetCar[7],"")
										Dados->VIACAR     := strzero(nViaCar,2)
										Dados->BADGET     := If(Len(aRetCar)>=8,aRetCar[8],"") //"Uliana"
										Dados->OBS        := If(Len(aRetCar)>=9,aRetCar[9],"")
				
			elseIf nLayOut = 4
			
				Dados->TARJAMAG1 :=	PLSEXP1->BA1_CODINT+;
									PLSEXP1->BA1_CODEMP+;
									PLSEXP1->BA1_MATRIC+;
									PLSEXP1->BA1_TIPREG+;
									PLSEXP1->BA1_DIGITO+;
									"="+; //Campo separador
									Strzero(nViaCar,2)+;
									SubStr(cDataValid,9,2)+SubStr(cDataValid,4,2)+;
									"="+; //Campo separador
									PLSEXP1->BA1_OPERES+;
									BI3->BI3_IDECAR+; //Codigo do produto no Intercambio
									SubStr(BI3->BI3_ABRANG,Len(BI3->BI3_ABRANG),1)+;
									PLSEXP1->BA3_TIPCON
									
				if BDE->( FieldPos("BDE_NOMCAR") ) > 0 .And. TYPE("M->BDE_NOMCAR") <> "U" 
					if M->BDE_NOMCAR == "1"
						Dados->TARJAMAG2 := PLSEXP1->BTS_NOMCAR
					else
						Dados->TARJAMAG2 := PLSEXP1->BTS_NOMUSR
					endIf
				else
					Dados->TARJAMAG2 := PLSEXP1->BTS_NOMCAR
				endIf
	
				Dados->MATRICULA := PLSEXP1->BA1_CODINT + " " +;
									PLSEXP1->BA1_CODEMP + " " +;
									PLSEXP1->BA1_MATRIC + " " +;
									PLSEXP1->BA1_TIPREG + " " +;
									PLSEXP1->BA1_DIGITO
	
	
				If lPL264INFO
					aRetInfo := ExecBlock("PL264INFO",.F.,.F.,{Dados->NOMEUSUARI,Dados->DTNACTO,Dados->DTVALID,Dados->DTINC,Dados->PLANO,Dados->TPCONTRATO,BA3->BA3_TIPOUS,aRetNome[1][3]})
					Dados->RZSOCIAL   := aRetInfo[1]
					Dados->INFORMACOE := aRetInfo[2]
				Else
					If  BA3->BA3_TIPOUS <> "1" .and. !Empty(BQC->BQC_NOMCAR)
						Dados->RZSOCIAL   := BQC->BQC_NOMCAR
					Else
						Dados->RZSOCIAL   := aRetNome[1][3]
					Endif
					Dados->INFORMACOE := STR0055 //"InformaГУes"
				EndIf
									
				Dados->CNESUSU	 :=  AllTrim(PLSEXP1->BTS_NRCRNA)
				Dados->SEGASSPL  :=  padr(substr(POSICIONE("BI6",1,XFILIAL("BI6")+ BI3->BI3_CODSEG,"BI6_DESCRI"),1,56),56)
				
				BA0->(DbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
				BA0->( msSeek(xFilial("BA0")+PLSEXP1->BA1_CODINT) )
				
				Dados->NUMREGOPE  := BA0->BA0_SUSEP
				Dados->NFANTAZOPE := BA0->BA0_NOMINT
	
				BIM->(DbSetOrder(1))//BIM_FILIAL+BIM_CODINT+BIM_CODIGO
				BIM->( msSeek(xFilial("BIM")+PLSEXP1->BA1_CODINT) )
				
				while !BIM->(eof())
				
					if BIM->BIM_SETOR == GetNewPar("MV_PLBIMSE","012")
						Dados->CONTATOOPE  := padR(BIM->BIM_NOME,30) + padR(BIM->BIM_TELCON,15) + padR(BIM->BIM_EMAIL,30)						
						exit 
					endIf
				
				BIM->(dbSkip())
				endDo
				
				BK5->(DbSetOrder(1))//BK5_FILIAL+BK5_NOME
				BK5->( msSeek(xFilial("BK5")) )
	
				Dados->CONTATOANS := padR(BK5->BK5_NOME,40) + padR(BK5->BK5_TEL,15) + padR(BK5->BK5_EMAIL,30) 
				Dados->CPT        := IIF(empty(dDatCpt),PadR("NцO Hа",12),substr(dtos(dDatCpt),7,2)+"/"+substr(dtos(dDatCpt),5,2)+"/"+substr(dtos(dDatCpt),1,4))			
				Dados->NUMCON		:= cNumPlan
				cDTContrat := Eval({ || cDia := StrZero(Day(PLSEXP1->BA1_DATINC),2), cMes := StrZero(Month(PLSEXP1->BA1_DATINC),2), cAno := StrZero(Year(PLSEXP1->BA1_DATINC),4), cDia+"/"+cMes+"/"+cAno })
				Dados->DATCON		:= cDTContrat
				IIF(ValType(cMaxCarenc) == "C",cMaxCarenc := CTOD(cMaxCarenc),) // Se a variavel for um caracter, converte em date
				Dados->DTMAXCON	:= Eval({ || cDia := StrZero(Day(cMaxCarenc),2), cMes := StrZero(Month(cMaxCarenc),2), cAno := StrZero(Year(cMaxCarenc),4), cDia+"/"+cMes+"/"+cAno })
				Dados->INFOPLAN 	:= cTipPlan
				
				BG9->(DbSetOrder(1))//BG9_FILIAL+BG9_CODINT+BG9_CODIGO+BG9_TIPO
				BG9->( msSeek( xFilial("BG9")+PLSEXP1->(BA1_CODINT+BA1_CODEMP) ) )
	
				Dados->NFAADMBENE := BG9->BG9_NREDUZ
				Dados->DTNACTO    := cDataNasc			
	
				If  BA3->BA3_TIPOUS == "1"
					Do Case
						Case BI3->BI3_NATJCO = "2"
							Dados->CONTRATACA := 'INDIVIDUAL OU FAMILIAR'
						Case BI3->BI3_NATJCO = "3"
							Dados->CONTRATACA := 'COLETIVO EMPRESARIAL'
						Case BI3->BI3_NATJCO = "4"
							Dados->CONTRATACA := 'COLETIVO POR ADESAO'
						Case BI3->BI3_NATJCO = "5"
							Dados->CONTRATACA := 'BENEFICIENTE'
						Otherwise
							Dados->CONTRATACA := "SEM CONTRATACAO"
					EndCase
				Else
					If  AllTrim(BQC->BQC_ENTFIL) == "1"
						Dados->CONTRATACA := 'BENEFICIENTE'
					Else
						BII->(DbSetOrder(1))
						If lTpCtrBI3 .AND. BII->( msSeek(xFilial("BII")+BI3->BI3_TIPCON) ) .AND. !EMPTY(BII->BII_TIPPLA)
							If  AllTrim(BII->BII_TIPPLA) $ "1,3"
								Dados->CONTRATACA := 'COLETIVO POR ADESAO'
							Else
								Dados->CONTRATACA := 'COLETIVO EMPRESARIAL'
							Endif
						Else
							If BII->( msSeek(xFilial("BII")+BT5->BT5_TIPCON) ) .AND. !EMPTY(BII->BII_TIPPLA)
								If  AllTrim(BII->BII_TIPPLA) $ "1,3"
									Dados->CONTRATACA := 'COLETIVO POR ADESAO'
								Else
									Dados->CONTRATACA := 'COLETIVO EMPRESARIAL'
								Endif
							Endif
						EndIf
					Endif
				Endif
					
				BI4->(dbSetOrder(1))      			
				If Empty(BI3->BI3_CODACO)
					Dados->TPACOMODA := PadR(STR0061, 13)	// "NAO SE APLICA"								
				Else
					If BI4->(MsSeek(xFilial("BI4")+AllTrim(BI3->(BI3_CODACO)))) .And.;
						BI4->(FieldPos("BI4_CODEDI")) > 0
												
						If Empty(BI4->BI4_CODEDI)
							Dados->TPACOMODA := PadR(STR0061, 13)	// "NAO SE APLICA"
						Else
							If AllTrim(BI4->BI4_CODEDI) == "1"
								Dados->TPACOMODA := PadR(STR0062,13)	// INDIVIDUAL
							ElseIf AllTrim(BI4->BI4_CODEDI) == "2"
								Dados->TPACOMODA := PadR(STR0063,13)	// COLETIVA
							Else
								Dados->TPACOMODA := PadR(STR0061, 13) 	// "NAO SE APLICA"     
							EndIf
						EndIf   
					Else 
						Dados->TPACOMODA := PadR(STR0061, 13)	// "NAO SE APLICA"     
					EndIf
				EndIf		  
	
				If BDE->( FieldPos("BDE_NOMCAR") ) > 0 .And. TYPE("M->BDE_NOMCAR") <> "U" 
					If M->BDE_NOMCAR == "1"
						Dados->NOMEUSUARI := PadR(PLSEXP1->BTS_NOMCAR,25)
					Else
						Dados->NOMEUSUARI := PadR(PLSEXP1->BTS_NOMUSR,25)
					EndIf
				Else
					Dados->NOMEUSUARI := PadR(PLSEXP1->BTS_NOMCAR,25)
				EndIF        			
				
				Do Case
					Case BI3->BI3_ABRANG == "01"
						Dados->ABRANG := "NACIONAL"
					Case BI3->BI3_ABRANG == "02"
						Dados->ABRANG := "GRUPO DE ESTADOS"
					Case BI3->BI3_ABRANG == "03"
						Dados->ABRANG := "ESTADUAL"
					Case BI3->BI3_ABRANG == "04"
						Dados->ABRANG := "GRUPO DE MUNICмPIOS"
					Case BI3->BI3_ABRANG == "05"
						Dados->ABRANG := "LOCAL"
					Otherwise
						Dados->ABRANG := BI3->BI3_ABRANG
				EndCase
	
				Dados->DTVIGPL 	:= cDatXInsc
			    Dados->NOMPRO   := BI3->BI3_NREDUZ
				Dados->SUSEP 	:= Iif(BI3->BI3_APOSRG == "1",BI3->BI3_SUSEP,BI3->BI3_SCPA)
				
			EndIf
			
			Dados->(MsUnlock())
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё caso o usuario esteja marcado como alterado, marca o    	Ё
			//Ё como cartao gerado         					             	Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if !lImpressao .Or. _nTipo == 2
				If  BA1->(FieldPos("BA1_EMICAR")) > 0 .and. BA1->BA1_EMICAR == "1"
					If  BA1->(RecLock("BA1",.F.))
							BA1->BA1_EMICAR := "2" // preparado
						BA1->(msUnLock())
					Endif
				Endif
			endIf	
		EndIf
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Acessa proximo usuario     						            Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	PLSEXP1->(DbSkip())
Enddo


//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Tipo: Re-Imprime lote...									Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If _nTipo <> 5
	
	PLSEXP1->(DbCloseArea())
	
Else
	
	IncProc(STR0035) //"Selecionando inf. para cartЦo magnetico."
	
	BED->(DbSetOrder(4))
	BED->(msSeek(xFilial("BED")+BDE->BDE_CODIGO))
	
	While xFilial("BED") == BED->BED_FILIAL .and. BDE->BDE_CODIGO == BED->BED_CDIDEN .and. ! BED->(Eof())
		
		lErro := .F.          
		
		If BED->(FieldPos("BED_NOMCAR")) <> 0
			lNomCar := (BED->BED_NOMCAR == "1")
		EndIf
		
		
		If  BA3->(BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_MATRIC) <> ;
			xFilial("BA3")+BED->(BED_CODINT+BED_CODEMP+BED_MATRIC)
			BA3->(DbSetOrder(1))
			BA3->(msSeek(xFilial("BA3")+BED->BED_CODINT+BED->BED_CODEMP+BED->BED_MATRIC))
		Endif
		
		BA1->(DbSetOrder(2))
		BA1->(msSeek(xFilial("BA1")+BED->BED_CODINT+BED->BED_CODEMP+BED->BED_MATRIC+BED->BED_TIPREG+BED->BED_DIGITO))
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica CPT                                                        Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		BF3->(dbSetOrder(1))
		BF3->(msSeek(xFilial("BF3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)))
		dDatCpt := ctod("  /  /  ")
		While ! BF3->(eof()) .and. BF3->(BF3_FILIAL+BF3_CODINT+BF3_CODEMP+BF3_MATRIC+BF3_TIPREG) == ;
			xFilial("BF3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)
			If  ! empty(BF3->BF3_CODDOE)
				If BF3->BF3_UNAGR == "3" //"Meses"
					If  Empty(BF3->BF3_DATCPT)
						If  Empty(BA1->BA1_DATCPT)
							nDias	:=	Abs(( date() -MonthSum( date() , 0 )))
							dDatCPt:= date()+nDias
						Else
							nDias	:=	Abs((BA1->BA1_DATCPT -MonthSum(BA1->BA1_DATCPT , BF3->BF3_MESAGR )))
							dDatCPt:= BA1->BA1_DATCPT+nDias
						Endif
						
					Else
						nDias	:=	Abs((BF3->BF3_DATCPTT -MonthSum(BF3->BF3_DATCPTT , BF3->BF3_MESAGR )))
						dDatCPt:= BF3->BF3_DATCPT+nDias
					Endif	
				Else			
				nDias   := PLSCarDias(BF3->BF3_MESAGR,BF3->BF3_UNAGR)
					dDatFim := BF3->BF3_DATCPT + nDias
				If  dDatFim > dDatCpt
					dDatCpt := dDatFim
				Endif
			Endif
			Endif	
			
			BF3->(dbSkip())
		Enddo
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se usuario esta bloqueado...					 			Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If UsuBlq264(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),BA1->BA1_TIPREG,dDatabase, BA1->BA1_DATBLO, BA1->BA1_MOTBLO, BA1->BA1_CONSID)
			lErro := .T.
		Endif
		
		aRetCar := {}
		If lPLS264CA
			aRetCar := ExecBlock("PLS264CA",.F.,.F.,{BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),BA1->BA1_TIPREG})
		EndIf
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Nao imprime Via com Titulo em aberto...						Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If BED->BED_FATUR == "2" .and. ! lErro
			If lPLS264E2
				Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0042}) //"TМtulo da via de cartЦo em aberto."
				lErro := .T.
			Else
				cMsgCri := AllTrim(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)) + " - "
				cMsgCri += STR0042 //"TМtulo da via de cartЦo em aberto."
				If !lweb
					If Aviso(STR0036,cMsgCri,{STR0006,STR0007},3,STR0038) == 1 //"CrМtica!"###"&Sim"###"&NЦo"###"Deseja Continuar?"
						lErro := .T.
					Else
						PLApag(cTrb)
						Return({.F.,{nQtd},aCriticas,aDados})
					EndIf
				Else
					PLApag(cTrb)
					Aadd(aCriticas, {STR0036,cMsgCri}) 	
					Return({.F.,{nQtd},aCriticas,aDados})							

				Endif
				
			EndIf
		Endif
		
		If BA3->BA3_TIPOUS <> "1"
			
			If  BT5->(BT5_FILIAL+BT5_CODINT+BT5_CODIGO+BT5_NUMCON+BT5_VERSAO) <> ;
				xFilial("BT5")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON)
				BT5->(DbSetOrder(1))
				BT5->(msSeek(xFilial("BT5")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON)))
				If  ! BT5->(Found()) .and. ! lErro
					If lPLS264E2
						Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0013}) //"Contrato nЦo Cadastrado."
						lErro := .T.
					Else
						cMsgCri := AllTrim(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)) + " - "
						cMsgCri += STR0013 //"Contrato nЦo Cadastrado."
						If !lweb
							If Aviso(STR0036,cMsgCri,{STR0006,STR0007},3,STR0038) == 1 //"CrМtica!"###"&Sim"###"&NЦo"###"Deseja Continuar?"
								lErro := .T.
							Else
								PLApag(cTrb)
								Return({.F.,{nQtd},aCriticas,aDados})
							EndIf
						Else
							PLApag(cTrb)
							Aadd(aCriticas, {STR0036,cMsgCri}) 	
							Return({.F.,{nQtd},aCriticas,aDados})							
						Endif
						
					EndIf
				Endif
			Endif
			
			If  BQC->(BQC_FILIAL+BQC_CODIGO+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB) <> ;
				xFilial("BQC")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)
				BQC->(DbSetOrder(1))
				BQC->(msSeek(xFilial("BQC")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))
				If  ! BQC->(Found()) .and. ! lErro
					If lPLS264E2
						Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0014}) //"Sub-Contrato nЦo Cadastrado."
						lErro := .T.
					Else
						cMsgCri := AllTrim(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)) + " - "
						cMsgCri += STR0014 //"Sub-Contrato nЦo Cadastrado."
						If !lweb
							If Aviso(STR0036,cMsgCri,{STR0006,STR0007},3,STR0038) == 1 //"CrМtica!"###"&Sim"###"&NЦo"###"Deseja Continuar?"
								lErro := .T.
							Else
								PLApag(cTrb)
								Return({.F.,{nQtd},aCriticas,aDados})
							EndIf
						Else
							PLApag(cTrb)
							Aadd(aCriticas, {STR0036,cMsgCri}) 	
							Return({.F.,{nQtd},aCriticas,aDados})							
						Endif
						
					EndIf
				Endif
			Endif
			
			If  BQC->BQC_EMICAR == "0"
				If lPLS264E2
					Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0025}) //"Via do cartao invАlida. "
					lErro := .T.
				Else
					cMsgCri := AllTrim(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)) + " - "
					cMsgCri += STR0025 //"Via do cartao invАlida: "
					If !lweb
						If Aviso(STR0036,cMsgCri,{STR0006,STR0007},3,STR0038) == 1 //"CrМtica!"###"&Sim"###"&NЦo"###"Deseja Continuar?"
							lErro := .T.
						Else
							PLApag(cTrb)
							Return({.F.,{nQtd},aCriticas,aDados})
						EndIf
					Else
						PLApag(cTrb)
						Aadd(aCriticas, {STR0036,cMsgCri}) 	
						Return({.F.,{nQtd},aCriticas,aDados})							

					Endif
					
				EndIf
			Endif
		Endif
		
		If  BG9->(BG9_FILIAL+BG9_CODINT+BG9_CODIGO) <> ;
			xFilial("BG9")+BA3->(BA3_CODINT+BA3_CODEMP)
			BG9->(DbSetOrder(1))
			BG9->(msSeek(xFilial("BG9")+BA3->(BA3_CODINT+BA3_CODEMP)))
		Endif
		
		nRegBTS := BTS->(Recno())
		nRegBA1 := BA1->(Recno())
		BA1->(DbSetOrder(2))
		BA1->(DbSeek(xFilial()+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+GetNewPar('MV_PLTRTIT','00'))))
		BTS->(DbSetOrder(1))
		BTS->(DbSeek(xFilial()+BA1->BA1_MATVID))
		If BDE->( FieldPos("BDE_NOMCAR") ) > 0
			If BDE->BDE_NOMCAR == "1" .Or. lNomCar
				cNomTit := BTS->BTS_NOMCAR
			Else
				cNomTit := BTS->BTS_NOMUSR
			EndIf
		Else
			cNomTit := BTS->BTS_NOMCAR
		EndIf
		BTS->(DbGoto(nRegBTS))
		BA1->(DbGoTo(nRegBA1))
		
		BTS->(DbSetOrder(1))
		BTS->(msSeek(xFilial("BTS")+BA1->BA1_MATVID))
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Posiciona Produto do usuario... 									Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If  ! empty(BA1->(BA1_CODPLA+BA1_VERSAO))
			If  BI3->(BI3_FILIAL+BI3_CODINT+BI3_CODIGO+BI3_VERSAO) <> ;
				xFilial("BI3")+BA1->(BA1_CODINT+BA1_CODPLA+BA1_VERSAO)
				BI3->(DbSetOrder(1))
				If ! BI3->(msSeek(xFilial("BI3")+BA1->(BA1_CODINT+BA1_CODPLA+BA1_VERSAO)))
					If lPLS264E2
						Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0039}) //"Plano do usuАrio nЦo cadastrado."
						lErro := .T.
					Else
						cMsgCri := AllTrim(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)) + " - "
						cMsgCri += STR0039 //"Plano do usuАrio nЦo cadastrado."
						If !lweb
							If Aviso(STR0036,cMsgCri,{STR0006,STR0007},3,STR0038) == 1 //"CrМtica!"###"&Sim"###"&NЦo"###"Deseja Continuar?"
								lErro := .T.
							Else
								PLApag(cTrb)
								Return({.F.,{nQtd},aCriticas,aDados})
							EndIf
						Else
							PLApag(cTrb)
							Aadd(aCriticas, {STR0036,cMsgCri}) 	
							Return({.F.,{nQtd},aCriticas,aDados})							
						Endif
						
					EndIf
				Endif
			Endif
		Else
			If  BI3->(BI3_FILIAL+BI3_CODINT+BI3_CODIGO+BI3_VERSAO) <> ;
				xFilial("BI3")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)
				If ! BI3->(msSeek(xFilial("BI3")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)))
					If lPLS264E2
						Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0040}) //"Plano da famМlia nЦo cadastrado."
						lErro := .T.
					Else
						cMsgCri := AllTrim(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)) + " - "
						cMsgCri += STR0040 //"Plano da famМlia nЦo cadastrado."
						If !lweb
							If Aviso(STR0036,cMsgCri,{STR0006,STR0007},3,STR0038) == 1 //"CrМtica!"###"&Sim"###"&NЦo"###"Deseja Continuar?"
								lErro := .T.
							Else
								PLApag(cTrb)
								Return({.F.,{nQtd},aCriticas,aDados})
							EndIf
						Else
							PLApag(cTrb)
							Aadd(aCriticas, {STR0036,cMsgCri}) 	
							Return({.F.,{nQtd},aCriticas,aDados})							
						Endif
						
					EndIf
					
				Endif
			Endif
		Endif
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se a via do cartao esta bloqueada...						Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If (BED->( FieldPos("BED_CODBLO") ) = 0) .or. ! lErro .and. (BED->( FieldPos("BED_BLOIDE") ) = 0)
			If lPLS264E2
				Aadd(aCriticas, {'',STR0057}) //"DicionАrio de dados desatualizado."
				lErro := .T.
			Else
				If !lweb
					If Aviso(STR0036,STR0057,{STR0006,STR0007},3,STR0038) == 1 //"CrМtica!"###"DicionАrio de dados desatualizado."###"&Sim"###"&NЦo"###"Deseja Continuar?"
						lErro := .T.
					Else
						PLApag(cTrb)
						Return({.F.,{nQtd},aCriticas,aDados})
					EndIf
				Else
					PLApag(cTrb)
					Aadd(aCriticas, {STR0036,STR0057}) 	
					Return({.F.,{nQtd},aCriticas,aDados})
				Endif
				
			EndIf
		Else
			If BED->BED_BLOIDE == "1" .and. ! lErro
				If lPLS264E2
					Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0024}) //"Via de cartЦo bloqueada. "
					lErro := .T.
				Else
					cMsgCri := AllTrim(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)) + " - "
					cMsgCri += STR0024 //"Via de cartЦo bloqueada. "
					If !lweb
						If Aviso(STR0036,cMsgCri,{STR0006,STR0007},3,STR0038) == 1 //"CrМtica!"###"&Sim"###"&NЦo"###"Deseja Continuar?"
							lErro := .T.
						Else
							PLApag(cTrb)
							Return({.F.,{nQtd},aCriticas,aDados})
						EndIf
					Else
						PLApag(cTrb)
						Aadd(aCriticas, {STR0036,cMsgCri}) 	
						Return({.F.,{nQtd},aCriticas,aDados})
			   		Endif
				EndIf
			Endif
		Endif
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Se desconsidera registro, volta controle...							Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lErro .and. !lImpressao
			nRegAnt := BED->(Recno())
			BED->(DbSkip())
			nRegBED := BED->(Recno())
			
			If lNewLot
				BED->(DbGoTo(nRegAnt))
				
				BED->(RecLock("BED",.F.))
					BED->BED_CDIDEN := STR0002 //"AVULSA"
				BED->(MsUnlock())
				
				BED->(DbGoTo(nRegBED))
				lNenhum := .F.
			Endif
			Loop
		Else
			lNenhum := .T.
		Endif
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Mensagens para cabecalho...									Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		aCabCar := PLSM02TEXT( BA1->BA1_CODINT, 3, BA3->BA3_TIPOUS, BI3->BI3_MODPAG, BA1->BA1_CODEMP, BA1->BA1_CONEMP, BA1->BA1_SUBCON,	BA1->BA1_MATRIC, BI3->BI3_CODIGO, substr(dtos(dDataBase),1,6))
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Mensagens para rodape...									Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		aRodCar := PLSM02TEXT( BA1->BA1_CODINT, 4, BA3->BA3_TIPOUS, BI3->BI3_MODPAG, BA1->BA1_CODEMP, BA1->BA1_CONEMP, BA1->BA1_SUBCON,	BA1->BA1_MATRIC, BI3->BI3_CODIGO, substr(dtos(dDataBase),1,6))
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё LayOut PLS... 						                                Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If nLayOut == 1
			cDataNasc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATNAS),2), cMes := StrZero(Month(BA1->BA1_DATNAS),2), cAno := StrZero(Year(BA1->BA1_DATNAS),4), cDia+"/"+cMes+"/"+cAno })
			cDataInsc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATINC),2), cMes := StrZero(Month(BA1->BA1_DATINC),2), cAno := StrZero(Year(BA1->BA1_DATINC),4), cDia+"/"+cMes+"/"+cAno })
			cDataValid:= Eval({ || cDia := StrZero(Day(BED->BED_DATVAL),2), cMes := StrZero(Month(BED->BED_DATVAL),2), cAno := StrZero(Year(BED->BED_DATVAL),4), cDia+"/"+cMes+"/"+cAno })
			cDatXInsc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATINC),2), cMes := StrZero(Month(BA1->BA1_DATINC),2), cAno := StrZero(Year(BA1->BA1_DATINC),4), cDia+"/"+cMes+"/"+cAno })			

			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё LayOut PTU... 						                                Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		ElseIf nLayOut == 2
			cDataNasc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATNAS),2), cMes := StrZero(Month(BA1->BA1_DATNAS),2), cAno := StrZero(Year(BA1->BA1_DATNAS),4), cDia+"/"+cMes+"/"+cAno })
			cDataInsc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATINC),2), cMes := StrZero(Month(BA1->BA1_DATINC),2), cAno := StrZero(Year(BA1->BA1_DATINC),4), cDia+"/"+cMes+"/"+cAno })
			cDataValid:= Eval({ || cDia := StrZero(Day(BED->BED_DATVAL),2), cMes := StrZero(Month(BED->BED_DATVAL),2), cAno := StrZero(Year(BED->BED_DATVAL),4), cDia+"/"+cMes+"/"+cAno })
			cDatXInsc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATINC),2), cMes := StrZero(Month(BA1->BA1_DATINC),2), cAno := StrZero(Year(BA1->BA1_DATINC),4), cDia+"/"+cMes+"/"+cAno })						
		ElseIf nLayOut == 3
			cDataNasc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATNAS),2), cMes := StrZero(Month(BA1->BA1_DATNAS),2), cAno := StrZero(Year(BA1->BA1_DATNAS),4), cDia+"/"+cMes+"/"+cAno })
			cDataInsc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATINC),2), cMes := StrZero(Month(BA1->BA1_DATINC),2), cAno := StrZero(Year(BA1->BA1_DATINC),4), cDia+"/"+cMes+"/"+cAno })
			cDataValid:= Eval({ || cDia := StrZero(Day(BED->BED_DATVAL),2), cMes := StrZero(Month(BED->BED_DATVAL),2), cAno := StrZero(Year(BED->BED_DATVAL),4), cDia+"/"+cMes+"/"+cAno })
			cDatXInsc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATINC),2), cMes := StrZero(Month(BA1->BA1_DATINC),2), cAno := StrZero(Year(BA1->BA1_DATINC),4), cDia+"/"+cMes+"/"+cAno })			
		elseIf nLayOut == 4
			cDataNasc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATNAS),2), cMes := StrZero(Month(BA1->BA1_DATNAS),2), cAno := StrZero(Year(BA1->BA1_DATNAS),4), cDia+"/"+cMes+"/"+cAno })
			cDataInsc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATINC),2), cMes := StrZero(Month(BA1->BA1_DATINC),2), cAno := StrZero(Year(BA1->BA1_DATINC),4), cDia+"/"+cMes+"/"+cAno })
			cDataValid:= Eval({ || cDia := StrZero(Day(BED->BED_DATVAL),2), cMes := StrZero(Month(BED->BED_DATVAL),2), cAno := StrZero(Year(BED->BED_DATVAL),4), cDia+"/"+cMes+"/"+cAno })
			cDatXInsc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATINC),2), cMes := StrZero(Month(BA1->BA1_DATINC),2), cAno := StrZero(Year(BA1->BA1_DATINC),4), cDia+"/"+cMes+"/"+cAno })			

		EndIf
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁRetorna a carencia dos produtos...									Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		aDadCar := PLSLISMSGC( BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO), BI3->(BI3_CODINT+BI3_CODIGO), BA3->BA3_VERSAO,BA1->BA1_DATCAR,BA1->BA1_SEXO)
		
		aRetNome := PLSAVERNIV(BA1->BA1_CODINT,	BA1->BA1_CODEMP,BA1->BA1_MATRIC,IIF(BA3->BA3_TIPOUS=="1","F","J"),	BA3->BA3_CONEMP,BA3->BA3_VERCON,BA3->BA3_SUBCON,BA3->BA3_VERSUB,1,BA1->BA1_TIPREG)
		
		If lPLS264REE // Ponto de entrada para desconsiderar o usuario na reemissao
			lPtoRee := ExecBlock("PLS264REE",.F.,.F.,{BED->(Recno()),BA1->(Recno())})
	
			If !lPtoRee
				BED->(dbSkip())
				Loop
			EndIf
		EndIf		
		
		nQtd++
		
		Dados->(RecLock("Dados",.T.))
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Ponto de Entrada para impressao com LayOut diferente...             Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lPLS264L2			
			nOriDad := 1
			cAlias :="PLSEXP1"
			ExecBlock("PLS264L2",.F.,.F.,{cAlias})
			nSeqCar++
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё LayOut PLS... 						                                Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		ElseIf nLayOut == 1
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Tarja magnetica... 						                            Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			Dados->TARJAMAG1 := BA1->BA1_CODINT+;
								BA1->BA1_CODEMP+;
								BA1->BA1_MATRIC+;
								BA1->BA1_TIPREG+;
								BA1->BA1_DIGITO+;
								"="+; //Campo separador
								Strzero(BED->BED_VIACAR,2)+;
								SubStr(cDataValid,9,2)+SubStr(cDataValid,4,2)+;
								"="+; //Campo separador
								BA1->BA1_OPERES+;
								BI3->BI3_IDECAR+; //Codigo do produto no Intercambio
								SubStr(BI3->BI3_ABRANG,Len(BI3->BI3_ABRANG),1)+;
								BA3->BA3_TIPCON
			If BDE->( FieldPos("BDE_NOMCAR") ) > 0
				If BDE->BDE_NOMCAR == "1" .Or. lNomCar
					Dados->TARJAMAG2	:=	BTS->BTS_NOMCAR
				Else
					Dados->TARJAMAG2	:=	BTS->BTS_NOMUSR
				EndIf
			Else
				Dados->TARJAMAG2	:=	BTS->BTS_NOMCAR
			EndIf
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Frente do Cartao... 						                        Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			Dados->MATRICULA :=	BA1->BA1_CODINT + " " +;
								BA1->BA1_CODEMP + " " +;
								BA1->BA1_MATRIC + " " +;
								BA1->BA1_TIPREG + " " +;
								BA1->BA1_DIGITO
			
			If  BA3->BA3_TIPOUS == "1"
				Do Case
					Case BI3->BI3_NATJCO = "2"
						Dados->CONTRATACA := BI3->BI3_NATJCO + STR0048 //"-FISICA"
					Case BI3->BI3_NATJCO = "3"
						Dados->CONTRATACA := BI3->BI3_NATJCO + STR0049 //"-EMPRESARIAL"
					Case BI3->BI3_NATJCO = "4"
						Dados->CONTRATACA := BI3->BI3_NATJCO + STR0050 //"-ADESAO"
					Case BI3->BI3_NATJCO = "5"
						Dados->CONTRATACA := BI3->BI3_NATJCO + STR0051 //"-BENEFICENTE"
					Otherwise
						Dados->CONTRATACA := BI3->BI3_NATJCO + STR0058 //" SEM CONTRATACAO"
				EndCase
			Else
				If  AllTrim(BQC->BQC_ENTFIL) == "1"
					Dados->CONTRATACA := STR0052 //"5-BENEFICENTE"
				Else
					BII->(DbSetOrder(1))
					If lTpCtrBI3 .AND. BII->( msSeek(xFilial("BII")+BI3->BI3_TIPCON) ) .AND. !EMPTY(BII->BII_TIPPLA)
						If  AllTrim(BII->BII_TIPPLA) $ "1,3"
							Dados->CONTRATACA := STR0053 //"4-ADESAO"
						Else
							Dados->CONTRATACA := STR0054 //"3-EMPRESARIAL"
						Endif
					Else
						If BII->( msSeek(xFilial("BII")+BT5->BT5_TIPCON) ) .AND. !EMPTY(BII->BII_TIPPLA)
							If  AllTrim(BII->BII_TIPPLA) $ "1,3"
								Dados->CONTRATACA := STR0053 //"4-ADESAO"
							Else
								Dados->CONTRATACA := STR0054 //"3-EMPRESARIAL"
							Endif
						Endif
					EndIf
				Endif
			Endif
			If BDE->( FieldPos("BDE_NOMCAR") ) > 0
				If BDE->BDE_NOMCAR == "1" .Or. lNomCar
					Dados->NOMEUSUARI	:=	BTS->BTS_NOMCAR
				Else
					Dados->NOMEUSUARI	:=	BTS->BTS_NOMUSR
				EndIf
			Else
				Dados->NOMEUSUARI	:=	BTS->BTS_NOMCAR
			EndIf
			Dados->DTNACTO		:=	cDataNasc
			Dados->DTVALID		:=	cDataValid
			Dados->DTINC		:=  cDataInsc
			Dados->PLANO		:=	BI3->BI3_CODIGO
			Dados->TPCONTRATO	:=	BI3->BI3_NATJCO
			
			//Para customizar campos como por exemplo "BQC_YNOMCA" e BQC_YINFCA
			If lPL264INFO
				aRetInfo:= ExecBlock("PL264INFO",.F.,.F.,{Dados->NOMEUSUARI,Dados->DTNACTO,Dados->DTVALID,Dados->DTINC,Dados->PLANO,Dados->TPCONTRATO,BA3->BA3_TIPOUS,aRetNome[1][3]})
				Dados->RZSOCIAL   := aRetInfo[1]
				Dados->INFORMACOE := aRetInfo[2]
			Else
				Dados->RZSOCIAL   := aRetNome[1][3]
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Verso do Cartao... 						                        	Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				Dados->INFORMACOE := STR0055 //"InformaГУes"
			EndIf
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁCarrega informacoes das mensagens dinamicamente...					Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			For nI := 1 To Len(aCabCar)
				If nI > 8
					Exit
				EndIf
				Dados->&("MENSAGEM"+strzero(nI,1)) := Alltrim(aCabCar[nI])
			Next nI
			
			For nCarencia := 1 To Len(aDadCar)
				If nI > 8
					Exit
				EndIf
				Dados->&("MENSAGEM"+strzero(nI,1)) := Alltrim(Alltrim(aDadCar[nCarencia][2])+"-"+dtoc(aDadCar[nCarencia][3]))
				nI++
			Next nCarencia
			
			For nRodape := 1 To Len(aRodCar)
				If nI > 8
					Exit
				EndIf
				Dados->&("MENSAGEM"+strzero(nI,1)) := Alltrim(aRodCar[nRodape])
				nI++
			Next nRodape
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё LayOut PTU... 						                                Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		ElseIf nLayOut == 2
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Linha 1       						                                Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды									
			Dados->SEP01     := "#DCC##EMB#"
			Dados->CODSISCOP := "0"
			Dados->UNIBENEF  := SubStr(BA1->BA1_CODINT,2)
			Dados->EMPRESA   := BA1->BA1_CODEMP
			Dados->INSCRICAO := BA1->BA1_MATRIC
			Dados->GRAUDEPEN := BA1->BA1_TIPREG
			Dados->DIGITO    := BA1->BA1_DIGITO
			Dados->CRLF01    := '"'
			                                                     
			Dados->CNESUSU	 :=  alltrim(BTS->BTS_NRCRNA)
			Dados->SEGASSPL  := padr(substr(POSICIONE("BI6",1,XFILIAL("BI6")+ BI3->BI3_CODSEG,"BI6_DESCRI"),1,56),56)
			If BQC->(FieldPos('BQC_SEASPL')) > 0 .and. BA3->BA3_TIPOUS <> '1'
				Dados->SEASPL  :=  BQC->BQC_SEASPL
			Endif
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Linha 2       						                                Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды			
			Dados->DTNACTO   := cDataNasc			
			If  BA3->BA3_TIPOUS == "1"
					Do Case
						Case BI3->BI3_NATJCO = "2"
							Dados->CONTRATACA := 'INDIVIDUAL OU FAMILIAR'
						Case BI3->BI3_NATJCO = "3"
							Dados->CONTRATACA := 'COLETIVO EMPRESARIAL'
						Case BI3->BI3_NATJCO = "4"
							Dados->CONTRATACA := 'COLETIVO POR ADESAO'
						Case BI3->BI3_NATJCO = "5"
							Dados->CONTRATACA := 'BENEFICIENTE'
						Otherwise
							Dados->CONTRATACA := "SEM CONTRATACAO"
					EndCase
				Else
					If  AllTrim(BQC->BQC_ENTFIL) == "1"
						Dados->CONTRATACA := 'BENEFICIENTE'
					Else
						BII->(DbSetOrder(1))
						If lTpCtrBI3 .AND. BII->( msSeek(xFilial("BII")+BI3->BI3_TIPCON) ) .AND. !EMPTY(BII->BII_TIPPLA)
							If  AllTrim(BII->BII_TIPPLA) $ "1,3"
								Dados->CONTRATACA := 'COLETIVO POR ADESAO'
							Else
								Dados->CONTRATACA := 'COLETIVO EMPRESARIAL'
							Endif
						Else
							If BII->( msSeek(xFilial("BII")+BT5->BT5_TIPCON) ) .AND. !EMPTY(BII->BII_TIPPLA)
								If  AllTrim(BII->BII_TIPPLA) $ "1,3"
									Dados->CONTRATACA := 'COLETIVO POR ADESAO'
								Else
									Dados->CONTRATACA := 'COLETIVO EMPRESARIAL'
								Endif
							Endif
						EndIf
					Endif
				Endif
				
			BI4->(dbSetOrder(1))      			
			If Empty(BI3->BI3_CODACO)
				Dados->TPACOMODA := PadR(STR0061, 13)	// "NAO SE APLICA"								
			Else
				If BI4->(MsSeek(xFilial("BI4")+AllTrim(BI3->(BI3_CODACO)))) .And.;
					BI4->(FieldPos("BI4_CODEDI")) > 0
					If Empty(BI4->BI4_CODEDI)
						Dados->TPACOMODA := PadR(STR0061, 13)	// "NAO SE APLICA"
					Else
						If AllTrim(BI4->BI4_CODEDI) == "1"
							Dados->TPACOMODA := PadR(STR0062,13)	// "Individual"
						ElseIf AllTrim(BI4->BI4_CODEDI) == "2"
							Dados->TPACOMODA := PadR(STR0063,13)	// "Coletiva"
						Else
							Dados->TPACOMODA := PadR(STR0061, 13) 	// "NAO SE APLICA"     
						EndIf
					EndIf   
				Else 
					Dados->TPACOMODA := PadR(STR0061, 13)	// "NAO SE APLICA"     
				EndIf
			EndIf			
			Dados->DTVIGPL    := cDatXInsc
			Dados->DTVALID    := cDataValid
			Dados->CRLF02    := '"'
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Linha 3       						                                Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If BDE->( FieldPos("BDE_NOMCAR") ) > 0
				If BDE->BDE_NOMCAR == "1" .Or. lNomCar
					Dados->NOMEUSUARI := PadR(BTS->BTS_NOMCAR,25)
				Else
					Dados->NOMEUSUARI := PadR(BTS->BTS_NOMUSR,25)
				EndIf
			Else
				Dados->NOMEUSUARI := PadR(BTS->BTS_NOMCAR,25)
			EndIf
			Dados->VIACAR     := Strzero(BED->BED_VIACAR,2)                        
			
			If BI3->(FieldPos("BI3_REDEDI")) > 0 
				Dados->REDATE := BI3->BI3_REDEDI			
			EndIf
			
			Dados->CRLF03    := '"'
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Linha 4       						                                Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			Dados->DESPLA     := BI3->BI3_DESCAR			
			If  ! empty(BA1->BA1_LOCCOB)
				If  BA1->BA1_LOCCOB == "1" // origem
					cLocCob := BA1->BA1_OPEORI
				Else
					cLocCob := BA1->BA1_OPEDES
				Endif
			Else
				cLocCob     := PlsIntPad()
			Endif
			
			Dados->LOCALCOB := cLocCob
			
			Do Case
				Case BI3->BI3_ABRANG == "01"
					Dados->ABRANG := "NACIONAL"
				Case BI3->BI3_ABRANG == "02"
					Dados->ABRANG := "GRUPO DE ESTADOS"
				Case BI3->BI3_ABRANG == "03"
					Dados->ABRANG := "ESTADUAL"
				Case BI3->BI3_ABRANG == "04"
					Dados->ABRANG := "GRUPO DE MUNICмPIOS"
				Case BI3->BI3_ABRANG == "05"
					Dados->ABRANG := "LOCAL"
				Otherwise
					Dados->ABRANG := BI3->BI3_ABRANG
			EndCase
			Dados->CRLF04    := '"'
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Linha 5       						                                Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды			
			Dados->CPT       := IIF(empty(dDatCpt),PadR("NцO Hа",12),substr(dtos(dDatCpt),7,2)+"/"+substr(dtos(dDatCpt),5,2)+"/"+substr(dtos(dDatCpt),1,4))			
			Dados->NREDUZ    := IIF(BA3->BA3_TIPOUS=="1",BI3->BI3_NREDUZ,BQC->BQC_NREDUZ)
			Dados->NOMPRO    := BI3->BI3_NREDUZ
			Dados->CRLF05    := '"'	
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Trilha 1       						                                Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды								
			Dados->SEP02   	:= '#ENC#'
			Dados->SS01		:= "%"
			If BDE->( FieldPos("BDE_NOMCAR") ) > 0
				If BDE->BDE_NOMCAR == "1" .Or. lNomCar
					Dados->TARJAMAG1 :=	SubStr(BTS->BTS_NOMCAR,1,25)
				Else
					Dados->TARJAMAG1 :=	SubStr(BTS->BTS_NOMUSR,1,25)
				EndIf
			Else
				Dados->TARJAMAG1 :=	SubStr(BTS->BTS_NOMCAR,1,25)
			EndIf
			Dados->ES01		:= "?"			        
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Trilha 2       						                                Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды											
			If  AllTrim(BA3->BA3_TIPOUS) == "1"
				cNatJco := BI3->BI3_NATJCO
			Else
				If  AllTrim(BQC->BQC_ENTFIL) == "1"
					cNatJco := "5"   // Beneficente
				Else
					BII->(DbSetOrder(1))
					If lTpCtrBI3 .AND. BII->( msSeek(xFilial("BII")+BI3->BI3_TIPCON) ) .AND. !EMPTY(BII->BII_TIPPLA)
						If  AllTrim(BII->BII_TIPPLA) $ "1,3"
							cNatJco := "4"   // Adesao
						Else
							cNatJco := "3"   // Empresarial
						Endif
					Else
						If BII->( msSeek(xFilial("BII")+BT5->BT5_TIPCON) ) .AND. !EMPTY(BII->BII_TIPPLA)
							If  AllTrim(BII->BII_TIPPLA) $ "1,3"
								cNatJco := "4"   // Adesao
							Else
								cNatJco := "3"   // Empresarial
							Endif
						Endif
					EndIf
				Endif
			Endif
			
			Dados->SS02		:= ";"			
			Dados->TARJAMAG2 := BA1->BA1_CODINT+;
								BA1->BA1_CODEMP+;
								BA1->BA1_MATRIC+;
								BA1->BA1_TIPREG+;
								BA1->BA1_DIGITO+;
								"="+;//Campo separador
								Strzero(BED->BED_VIACAR,2)+;
								SubStr(cDataValid,9,2)+SubStr(cDataValid,4,2)+;
								"="+;//Campo separador
							    cLocCob+; //Local de Atendimento (Operadora)
								BI3->BI3_IDECAR+;//Produto
								SubStr(BI3->BI3_ABRANG,Len(BI3->BI3_ABRANG),1)+;//Abrangencia
								cNatJco+;//Natureza JurМdica da ContrataГЦo
								"1"+;// "1" - Fixo
								CodRedeRef()//CСdigo da Rede Referenciada  
			Dados->ES02	:= "?"
			Dados->SEP03 := "#END#@@@@@@"
			If GetNewPar("MV_PLSIMCL","0") == "1" // Imprime classe de carencia no cartao ?
				Dados->CLSCAR := ClsCar(BA1->BA1_CODINT,BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),BA1->BA1_DATCAR)
			EndIf
			If BI3->(FieldPos('BI3_ABRCAR')) > 0
				Dados->ABRCAR := BI3->BI3_ABRCAR
			Endif
			Dados->SUSEP := Iif(BI3->BI3_APOSRG == "1",BI3->BI3_SUSEP,BI3->BI3_SCPA)

			If BTS->(fieldpos("BTS_NOMSOC")) > 0
				Dados->NOMSOC := PadR(BTS->BTS_NOMSOC,25) // Nome social do beneficiario
			EndIf
			// QRCODE
			Dados->QRCODE := "1"+; 					// Indicador de cartЦo - Fixo ⌠1■ - cartЦo fМsico	 
							 "="+; 					// Field Separator
							 "01"+; 				// Versionamento das informaГУes do QR Code do Manual do CartЦo √ fixo: ⌠01■
							 "="+; 					// Field Separator
							 BA1->BA1_CODINT+; 	
							 BA1->BA1_CODEMP+;
							 BA1->BA1_MATRIC+;		// CСdigo do beneficiАrio com 17 posiГУes
							 BA1->BA1_TIPREG+;
							 BA1->BA1_DIGITO+;
							 "="+; 					// Field Separator
							 Dados->NOMEUSUARI+; 	// Nome reduzido do beneficiАrio
							 "="+; 					// Field Separator
							 cDataNasc+; 			// Data de nascimento
							 "="+; 					// Field Separator
							 IIF(BA1->BA1_SEXO == "1","M","F")+; // Sexo
							 "="+; 					// Field Separator
							 Padr(BTS->BTS_NRCRNA,15)+; // CartЦo Nacional de SaЗde
							 "="+; 					// Field Separator
							 cDataValid+; 			// Data de validade
							 "="+; 					// Field Separator
							 strzero(nViaCar,2)+; 	// Via do cartЦo
							 "="+; 					// Field Separator
							 Substr(BI3->BI3_REDEDI,1,4)+; // Rede de Atendimento
							 "="+; 					// Field Separator
							 PadR(Dados->SUSEP,20)+;// registro ANS do produto
							 "="+; 					// Field Separator
							 Dados->NOMSOC			// Nome social do beneficiАrio	

		ElseIf nLayOut == 3
			Dados->CODEMP     := BA1->BA1_CODEMP
			Dados->DESEMP     := IIF(BA3->BA3_TIPOUS=="1",BI3->BI3_DESCRI,BQC->BQC_DESCRI)
			Dados->VALIDADE   := cDataValid
			Dados->TITULAR    := cNomTit  // buscar nome do titular
			
			If BDE->( FieldPos("BDE_NOMCAR") ) > 0
				If BDE->BDE_NOMCAR == "1" .Or. lNomCar
					Dados->DEPENDENTE := BTS->BTS_NOMCAR
				Else
					Dados->DEPENDENTE := BTS->BTS_NOMUSR
				EndIf
			Else
				Dados->DEPENDENTE := BTS->BTS_NOMCAR
			EndIf
			
			Dados->MATRICULA  := BA1->BA1_CODINT+"."+;
								 BA1->BA1_CODEMP+"."+;
								 BA1->BA1_MATRIC+"-"+;
								 BA1->BA1_TIPREG+"."+;
								 BA1->BA1_DIGITO
			Dados->PLANO      := BI3->BI3_CODIGO
			Dados->DESPLANO   := BI3->BI3_DESCRI
			Dados->REDE       := If(Len(aRetCar)>=1,aRetCar[1],"") // STANDARD
			Dados->CONSULTA   := If(Len(aRetCar)>=2,aRetCar[2],"")
			Dados->EXAME      := If(Len(aRetCar)>=3,aRetCar[3],"")
			Dados->INTERN     := If(Len(aRetCar)>=4,aRetCar[4],"")
			Dados->PARTO      := If(Len(aRetCar)>=5,aRetCar[5],"")
			Dados->PADRAO     := If(Len(aRetCar)>=6,aRetCar[6],"") // ENFERMARIA
			Dados->NASCIMENTO := cDataNasc
			Dados->EXAMEESP   := If(Len(aRetCar)>=7,aRetCar[7],"")
			Dados->VIACAR     := strzero(BED->BED_VIACAR,2)
			Dados->BADGET     := If(Len(aRetCar)>=8,aRetCar[8],"") //"Uliana"
			Dados->OBS        := If(Len(aRetCar)>=9,aRetCar[9],"")
		
		elseIf nLayOut = 4
			
				Dados->TARJAMAG1 :=	BA1->BA1_CODINT+;
									BA1->BA1_CODEMP+;
									BA1->BA1_MATRIC+;
									BA1->BA1_TIPREG+;
									BA1->BA1_DIGITO+;
									"="+; //Campo separador
									Strzero(BED->BED_VIACAR,2)+;
									SubStr(cDataValid,9,2)+SubStr(cDataValid,4,2)+;
									"="+; //Campo separador
									BA1->BA1_OPERES+;
									BI3->BI3_IDECAR+; //Codigo do produto no Intercambio
									SubStr(BI3->BI3_ABRANG,Len(BI3->BI3_ABRANG),1)+;
									BA3->BA3_TIPCON

				if BDE->( FieldPos("BDE_NOMCAR") ) > 0 .And. TYPE("M->BDE_NOMCAR") <> "U" 
					if M->BDE_NOMCAR == "1"
						Dados->TARJAMAG2 := BTS->BTS_NOMCAR
					else
						Dados->TARJAMAG2 := BTS->BTS_NOMUSR
					endIf
				else
					Dados->TARJAMAG2 := BTS->BTS_NOMCAR
				endIf
	
				Dados->MATRICULA := BA1->BA1_CODINT + " " +;
									BA1->BA1_CODEMP + " " +;
									BA1->BA1_MATRIC + " " +;
									BA1->BA1_TIPREG + " " +;
									BA1->BA1_DIGITO
	
	
				If lPL264INFO
					aRetInfo := ExecBlock("PL264INFO",.F.,.F.,{Dados->NOMEUSUARI,Dados->DTNACTO,Dados->DTVALID,Dados->DTINC,Dados->PLANO,Dados->TPCONTRATO,BA3->BA3_TIPOUS,aRetNome[1][3]})
					Dados->RZSOCIAL   := aRetInfo[1]
					Dados->INFORMACOE := aRetInfo[2]
				Else
					If  BA3->BA3_TIPOUS <> "1" .and. !Empty(BQC->BQC_NOMCAR)
						Dados->RZSOCIAL   := BQC->BQC_NOMCAR
					Else
						Dados->RZSOCIAL   := aRetNome[1][3]
					Endif
					Dados->INFORMACOE := STR0055 //"InformaГУes"
				EndIf
									
				Dados->CNESUSU	 :=  AllTrim(BTS->BTS_NRCRNA)
				Dados->SEGASSPL  :=  padr(substr(POSICIONE("BI6",1,XFILIAL("BI6")+ BI3->BI3_CODSEG,"BI6_DESCRI"),1,56),56)
				
				BA0->(DbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
				BA0->( msSeek(xFilial("BA0")+BA1->BA1_CODINT) )
				
				Dados->NUMREGOPE  := BA0->BA0_SUSEP
				Dados->NFANTAZOPE := BA0->BA0_NOMINT
					
				BIM->(DbSetOrder(1))//BIM_FILIAL+BIM_CODINT+BIM_CODIGO
				BIM->( msSeek(xFilial("BIM")+BA1->BA1_CODINT) )
				
				while !BIM->(eof())
				
					if BIM->BIM_SETOR == GetNewPar("MV_PLBIMSE","012")
						Dados->CONTATOOPE  := padR(BIM->BIM_NOME,30) + padR(BIM->BIM_TELCON,15) + padR(BIM->BIM_EMAIL,30)
						exit 
					endIf
				
				BIM->(dbSkip())
				endDo
				
				BK5->(DbSetOrder(1))//BK5_FILIAL+BK5_NOME
				BK5->( msSeek(xFilial("BK5")) )
	
				Dados->CONTATOANS := padR(BK5->BK5_NOME,40) + padR(BK5->BK5_TEL,15) + padR(BK5->BK5_EMAIL,30) 
				Dados->CPT        := IIF(empty(dDatCpt),PadR("NцO Hа",12),substr(dtos(dDatCpt),7,2)+"/"+substr(dtos(dDatCpt),5,2)+"/"+substr(dtos(dDatCpt),1,4))			
	
				BG9->(DbSetOrder(1))//BG9_FILIAL+BG9_CODINT+BG9_CODIGO+BG9_TIPO
				BG9->( msSeek( xFilial("BG9")+BA1->(BA1_CODINT+BA1_CODEMP) ) )
	
				Dados->NFAADMBENE := BG9->BG9_NREDUZ
				Dados->DTNACTO    := cDataNasc			
	
				If  BA3->BA3_TIPOUS == "1"
					Do Case
						Case BI3->BI3_NATJCO = "2"
							Dados->CONTRATACA := 'INDIVIDUAL OU FAMILIAR'
						Case BI3->BI3_NATJCO = "3"
							Dados->CONTRATACA := 'COLETIVO EMPRESARIAL'
						Case BI3->BI3_NATJCO = "4"
							Dados->CONTRATACA := 'COLETIVO POR ADESAO'
						Case BI3->BI3_NATJCO = "5"
							Dados->CONTRATACA := 'BENEFICIENTE'
						Otherwise
							Dados->CONTRATACA := "SEM CONTRATACAO"
					EndCase
				Else
					If  AllTrim(BQC->BQC_ENTFIL) == "1"
						Dados->CONTRATACA := 'BENEFICIENTE'
					Else
						BII->(DbSetOrder(1))
						If lTpCtrBI3 .AND. BII->( msSeek(xFilial("BII")+BI3->BI3_TIPCON) ) .AND. !EMPTY(BII->BII_TIPPLA)
							If  AllTrim(BII->BII_TIPPLA) $ "1,3"
								Dados->CONTRATACA := 'COLETIVO POR ADESAO'
							Else
								Dados->CONTRATACA := 'COLETIVO EMPRESARIAL'
							Endif
						Else
							If BII->( msSeek(xFilial("BII")+BT5->BT5_TIPCON) ) .AND. !EMPTY(BII->BII_TIPPLA)
								If  AllTrim(BII->BII_TIPPLA) $ "1,3"
									Dados->CONTRATACA := 'COLETIVO POR ADESAO'
								Else
									Dados->CONTRATACA := 'COLETIVO EMPRESARIAL'
								Endif
							Endif
						EndIf
					Endif
				Endif
					
				BI4->(dbSetOrder(1))      			
				If Empty(BI3->BI3_CODACO)
					Dados->TPACOMODA := PadR(STR0061, 13)	// "NAO SE APLICA"								
				Else
					If BI4->(MsSeek(xFilial("BI4")+AllTrim(BI3->(BI3_CODACO)))) .And.;
						BI4->(FieldPos("BI4_CODEDI")) > 0
												
						If Empty(BI4->BI4_CODEDI)
							Dados->TPACOMODA := PadR(STR0061, 13)	// "NAO SE APLICA"
						Else
							If AllTrim(BI4->BI4_CODEDI) == "1"
								Dados->TPACOMODA := PadR(STR0062,13)	// INDIVIDUAL
							ElseIf AllTrim(BI4->BI4_CODEDI) == "2"
								Dados->TPACOMODA := PadR(STR0063,13)	// COLETIVA
							Else
								Dados->TPACOMODA := PadR(STR0061, 13) 	// "NAO SE APLICA"     
							EndIf
						EndIf   
					Else 
						Dados->TPACOMODA := PadR(STR0061, 13)	// "NAO SE APLICA"     
					EndIf
				EndIf		  
	
				If BDE->( FieldPos("BDE_NOMCAR") ) > 0 .And. TYPE("M->BDE_NOMCAR") <> "U" 
					If M->BDE_NOMCAR == "1"
						Dados->NOMEUSUARI := PadR(BTS->BTS_NOMCAR,30)
					Else
						Dados->NOMEUSUARI := PadR(BTS->BTS_NOMUSR,70)
					EndIf
				Else
					Dados->NOMEUSUARI := PadR(BTS->BTS_NOMCAR,30)
				EndIF        			
				
				Do Case
					Case BI3->BI3_ABRANG == "01"
						Dados->ABRANG := "NACIONAL"
					Case BI3->BI3_ABRANG == "02"
						Dados->ABRANG := "GRUPO DE ESTADOS"
					Case BI3->BI3_ABRANG == "03"
						Dados->ABRANG := "ESTADUAL"
					Case BI3->BI3_ABRANG == "04"
						Dados->ABRANG := "GRUPO DE MUNICмPIOS"
					Case BI3->BI3_ABRANG == "05"
						Dados->ABRANG := "LOCAL"
					Otherwise
						Dados->ABRANG := BI3->BI3_ABRANG
				EndCase
	
				Dados->DTVIGPL 	:= cDatXInsc
			    Dados->NOMPRO   := BI3->BI3_NREDUZ
				Dados->SUSEP 	:= Iif(BI3->BI3_APOSRG == "1",BI3->BI3_SUSEP,BI3->BI3_SCPA)
				
		EndIf		
		Dados->( MsUnlock() )
		
		If lNewLot .and. (!lImpressao .Or. _nTipo == 2)
			BA1->(RecLock("BA1",.F.))
				BA1->BA1_CDIDEN := BDE->BDE_CODIGO
			BA1->(MsUnlock())
		Endif
		
		BED->( DbSkip() )
	EndDo
	
	
EndIf

DbSelectArea("Dados")

If !EOF() .And. lOK .And. lImp .And. lNenhum

	if lImpressao
	
		DADOS->(dbGoTop())

		while !DADOS->(eof())
		
			aadd(aDados, {	DADOS->NOMEUSUARI,;
							DADOS->MATRICULA,;
							iif(empty(DADOS->DTNACTO),'NцO Hа',DADOS->DTNACTO),;
							iif(empty(DADOS->CNESUSU),'NцO Hа',DADOS->CNESUSU),;
							iif(empty(DADOS->SUSEP),'NцO Hа',DADOS->SUSEP),;
							iif(empty(DADOS->SEGASSPL),'NцO Hа',DADOS->SEGASSPL),;
							iif(empty(DADOS->NUMREGOPE),'NцO Hа',DADOS->NUMREGOPE),;
							iif(empty(DADOS->CONTATOOPE),'NцO Hа',DADOS->CONTATOOPE),;
							iif(empty(DADOS->CONTATOANS),'NцO Hа',DADOS->CONTATOANS),;
							iif(empty(DADOS->CPT),'NцO Hа',DADOS->CPT),;
							iif(empty(DADOS->TPACOMODA),'NцO Hа',DADOS->TPACOMODA),;
							iif(empty(DADOS->CONTRATACA),'NцO Hа',DADOS->CONTRATACA),;
							iif(empty(DADOS->ABRANG),'NцO Hа',DADOS->ABRANG),;
							iif(empty(DADOS->NOMPRO),'NцO Hа',DADOS->NOMPRO),;
							iif(empty(DADOS->NFANTAZOPE),'NцO Hа',DADOS->NFANTAZOPE),;
							iif(empty(DADOS->NFAADMBENE),'NцO Hа',DADOS->NFAADMBENE),;
							iif(empty(DADOS->RZSOCIAL),'NцO Hа',DADOS->RZSOCIAL),;
							iif(empty(DADOS->DTVIGPL),'NцO Hа',DADOS->DTVIGPL),;							
							iif(empty(DADOS->NUMCON),'NцO Hа',DADOS->NUMCON),;
							iif(empty(DADOS->DATCON),'NцO Hа',DADOS->DATCON),;
							iif(empty(DADOS->DTMAXCON),'NцO Hа',DADOS->DTMAXCON),;
							iif(empty(DADOS->INFOPLAN),'NцO Hа',DADOS->INFOPLAN),;
							iif(empty(DADOS->INFORMACOE),'NцO Hа',DADOS->INFORMACOE) })
		
		DADOS->(dbSkip())
		endDo
		
		//para impressao em PDF
		if !lWeb
			if existBlock("PLRRN360")
				execBlock("PLRRN360",.F.,.F.,{'', aDados, lWeb,getMV("MV_RELT")})
			endIf
		endIf	
	
	else
		If !lAutoma .And. !lCartaoVirtual // AutomaГЦo
			//Ponto de Entrada para criacao do arquivo...
			If ExistBlock("PLS264L3")
				ExecBlock("PLS264L3",.F.,.F.)
			ElseIf nLayOut == 1
				Copy To &cArquivo DELIMITED
			ElseIf nLayOut == 3
				Copy To &cArquivo DELIMITED
			Else
				Copy To &cArquivo SDF
			EndIf
			
			//Copia o temporario para o local selecionado pelo usuario...     
			If ExistBlock("PLS264ARQ")
				cArquivo := ExecBlock( "PLS264ARQ",.F.,.F.,{cArquivo} )
			Endif
			
			//Cria arquivo de apoio ao processamento...                         
			nW := fCreate(cDirGrava+cArquivo)
		
			//Teste se foi criado o arquivo                                     
			If nW == -1
				Help("",1,"PLSA264ARQ",,cDirGrava+cArquivo,1,0)
				Dados->( DbCloseArea() )
				Return({.F.,{nQtd},aCriticas,aDados})
			Endif
			
			//Abre o arquivo                                                     
			nHIn := FT_FUse(cArquivo)
			FT_FGotop()
			cNLin := ""
			
			//Ponto de entrada                                                    
			If ExistBlock( "PLS264CB" )
				ExecBlock( "PLS264CB",.F.,.F.,{nW} )
			EndIf
			
			lImp := .F.
		
			//Verifica se o arquivo foi aberto									
			If  nHIn <> -1
				
				//Inicio do arquivo													
				FT_FGoTop()
				
				//Le todo o arquivo linha por linha conforme fim de linha chr(13)+Chr(10) Ё
				While (!FT_fEof())
					//Posiciona no inicio do arquivo e le as linhas											 
					lImp 		:= .T.
					cBufferIn 	:= ""
					
					while( .T. )
						cBufferIn += FT_fReadLn()
						
						//Verifica se encontrou o final da linha para gravar                                                               
						If Len(FT_fReadLn()) < 1023           
							Exit                              
						Else                                    
							Ft_fSkip()                             
						EndIf                                   
					EndDo
		
					//Retira delimitadores																	 
					If lPLS264L4
						cNLin := ""
						aRet := ExecBlock("PLS264L4",.F.,.F.)
						If aRet[2]
							cNLin := aRet[3]
							lPriCar := .F.
						Endif
						cNLin += StrTran(cBufferIn,',',aRet[1])
					ElseIf nLayOut == 1
						cNLin := StrTran(cBufferIn,'"',"")
					ElseIf nLayOut == 3
						cNLin := StrTran(cBufferIn,'"',"")
					Else
						cNLin := cBufferIn
					EndIf
		
					//Concatena quebra de linha.                             				
					cNLin += chr(13)+Chr(10)

					//Grava string no arquivo temporario...                  				
					//Ponto de entrada                                                    
					If lPLS264FW
						cNLin	:= ExecBlock( "PLS264FW",.F.,.F.,{cNLin} )
						FWrite( nW, cNLin , Len(cNLin) )
					Else
						FWrite( nW, cNLin , Len(cNLin) )
					EndIf
					
				FT_fSkip()
				EndDo
			Else
				Help("",1,"PLSA264ARQ",,cDirGrava+cArquivo,1,0)
				Return({.F.,{nQtd},aCriticas,aDados})
			EndIf

			FClose(nW)
		
			FT_FUse()

			If lImp
				MsgInfo(STR0029+cDirGrava+cArquivo) //"Dados gerados com sucesso. Arquivo: "
			Endif
		
			If _nTipo = 2
				If ValType(oDlg) == "O"
					oDlg:End()
				EndIf
			EndIf
		EndIf // AutomaГЦo
	endIf	
else
	If !lOk .Or. !lNenhum

		If !lNenhum
			lOk := lNenhum
		EndIf

		Help("",1,"PLSA264003")
		
	Endif
endIf

//Erase																
IF !lAutoma .And. !lCartaoVirtual
	PLApag(cTrb)
EndIf

//Criticas															
If ExistBlock("PLS264E2")
	aRetPto   := ExecBlock("PLS264E2",.F.,.F.,{_nTipo,aCriticas})
	aCriticas := aRetPto [2]
	lOk		  := aRetPto [1]	
	
	If Len(aCriticas) > 0 .And. !lOk

		If !lweb
			Aviso(STR0031,STR0032,{STR0033}) //"CrМticas"###"Houveram crМticas no processamento!"###"Visualizar"
			PLSCRIGEN(aCriticas,{ {STR0059,"@!", 70},{STR0060,"@!", 300 }},STR0031) //"MatrМcula"###"CrМtica"###"CrМticas"
		Else
			Return {lOk,{nQtd},aCriticas,aDados}
		Endif
	Endif
EndIf

If nQtd > 0 .And. _nTipo == 2 .And. lImp .And. M->BDE_TIPGER =="2" .And. Len(aDados) > 0

	Store Header "BDE" TO aCabBDE For ! ( alltrim(SX3->X3_CAMPO) $ "BDE_FILIAL,BDE_CODINT,BDE_CODIGO,BDE_PROTOC,BDE_STACAR,BDE_UNILOC" )
	cCodigo := PLSA262NUM(cCodInt)
	BDE->(DbSetOrder(1))
	BDE->(RecLock("BDE",.T.))
		BDE->BDE_FILIAL := xFilial("BDE")
		BDE->BDE_CODINT := cCodInt
		BDE->BDE_CODIGO := cCodigo
		BDE->BDE_UNILOC := "1"
		BDE->BDE_STACAR := "1"
		If  BDE->( FieldPos("BDE_PROTOC") ) > 0 .and. LWeb 
			BDE->BDE_PROTOC := cProtoc
		Endif
		For nX := 1 To Len(aCabBDE)
			If aCabBDE[nX][10] != "V"
				&("BDE->" + aCabBDE[nX][2]) := &("M->" + aCabBDE[nX][2])
			EndIf
		Next
	BDE->(MsUnlock())

EndIf

Return( {lOK,{nQtd},{},aDados} )

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLApag    ╨Autor  ЁMicrosiga           ╨ Data Ё  04/08/08   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Apaga arquivos temporarios                                 ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function PLApag(cTrb)
if( select( "Dados" ) > 0 )
	oTempTable:Delete()
endIf

FT_FUse()
FErase(cArquivo)
Return


/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Funcao    ЁUPLSRETGET╨Autor  ЁRafael M. Quadrotti ╨ Data Ё  02/11/04   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Retorna o diretorio para geracao do arquivo                ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP6                                                        ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function Plsa264Dir()
Return cDirPls
/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммямммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Funcao    ЁPLSM02TEXT╨Autor  ЁThiago Machado Correa╨ Data Ё  17/11/04   ╨╠╠
╠╠лммммммммммьммммммммммймммммммомммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Retorna as mensagens para impressao.                        ╨╠╠
╠╠╨          Ё                                                             ╨╠╠
╠╠╨          Ё                                                             ╨╠╠
╠╠лммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё PLS                                                         ╨╠╠
╠╠хммммммммммоммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function PLSM02TEXT( cCodInt, nTipo, cTipCon, cModCob, cCodEmp, cConEmp, cSubCon, cMatric, cCodPro, cDatBas )

Local cQuery   := ""
Local cChave   := ""
Local nConta   := 0
Local nTotal   := Iif(cTipCon=="1",4,6)
Local aMsg     := {}
Local lAchou   := .F.
Local cNTable1 := RetSqlName("BH1")

BH2->(DbSetOrder(1))

While ! lAchou .and. nConta <= nTotal
	
	cQuery := " SELECT BH1_CODIGO FROM " + cNTable1
	cQuery += " WHERE BH1_FILIAL = '" + xFilial("BH1") + "' AND "
	cQuery += "       BH1_CODINT = '" + cCodInt + "' AND "
	cQuery += "       BH1_TIPO = '" + Transform(nTipo,"9") + "' AND "
	cQuery += "      (BH1_TIPCON = '" + cTipCon + "' OR BH1_TIPCON = '3') AND "
	cQuery += "      (BH1_MODPAG = '" + cModCob + "' OR BH1_MODPAG = '3') AND "
	cQuery += "       BH1_ATIVO = '1' AND "
	
	If cTipCon == "1"
		
		If nConta >= 1
			cQuery += "(( '"+cDatBas +"' BETWEEN BH1_BASEIN AND BH1_BASEFI) OR (BH1_BASEIN = ' ' AND BH1_BASEFI = ' ') ) AND "
		Else
			cQuery += "( '" +cDatBas +"' BETWEEN BH1_BASEIN AND BH1_BASEFI ) AND "
		Endif
		
		If nConta >= 2
			cQuery += "(( '"+cCodPro +"' BETWEEN BH1_PLAINI AND BH1_PLAFIM) OR (BH1_PLAINI = ' ' AND BH1_PLAFIM = ' ') ) AND "
		Else
			cQuery += "( '" +cCodPro +"' BETWEEN BH1_PLAINI AND BH1_PLAFIM ) AND "
		Endif
		
		If nConta >= 3
			cQuery += "(( '"+cMatric +"' BETWEEN BH1_MATDE AND BH1_MATATE) OR (BH1_MATATE = ' ' AND BH1_MATDE = ' ') ) AND "
		Else
			cQuery += "( '" +cMatric +"' BETWEEN BH1_MATDE AND BH1_MATATE ) AND "
		Endif
		
		If nConta >= 4
			cQuery += "(( '"+cCodEmp +"' BETWEEN BH1_EMPDE AND BH1_EMPATE) OR (BH1_EMPATE = ' ' AND BH1_EMPDE = ' ') ) AND "
		Else
			cQuery += "( '" +cCodEmp +"' BETWEEN BH1_EMPDE AND BH1_EMPATE ) AND "
		Endif
		
	Else
		
		If nConta >= 1
			cQuery += "(( '"+cDatBas +"' BETWEEN BH1_BASEIN AND BH1_BASEFI) OR (BH1_BASEIN = ' ' AND BH1_BASEFI = ' ') ) AND "
		Else
			cQuery += "( '" +cDatBas +"' BETWEEN BH1_BASEIN AND BH1_BASEFI ) AND "
		Endif
		
		If nConta >= 2
			cQuery += "(( '"+cCodPro +"' BETWEEN BH1_PLAINI AND BH1_PLAFIM) OR (BH1_PLAINI = ' ' AND BH1_PLAFIM = ' ') ) AND "
		Else
			cQuery += "( '" +cCodPro +"' BETWEEN BH1_PLAINI AND BH1_PLAFIM ) AND "
		Endif
		
		If nConta >= 3
			cQuery += "(( '"+cMatric +"' BETWEEN BH1_MATDE AND BH1_MATATE) OR (BH1_MATATE = ' ' AND BH1_MATDE = ' ') ) AND "
		Else
			cQuery += "( '" +cMatric +"' BETWEEN BH1_MATDE AND BH1_MATATE ) AND "
		Endif
		
		If nConta >= 4
			cQuery += "(( '"+cSuBCon +"' BETWEEN BH1_SUBDE AND BH1_SUBATE) OR (BH1_SUBATE = ' ' AND BH1_SUBDE = ' ') ) AND "
		Else
			cQuery += "( '" +cSuBCon +"' BETWEEN BH1_SUBDE AND BH1_SUBATE ) AND "
		Endif
		
		If nConta >= 5
			cQuery += "(( '"+cConEmp +"' BETWEEN BH1_CONDE AND BH1_CONATE) OR (BH1_CONATE = ' ' AND BH1_CONDE = ' ') ) AND "
		Else
			cQuery += "( '" +cConEmp +"' BETWEEN BH1_CONDE AND BH1_CONATE ) AND "
		Endif
		
		If nConta >= 6
			cQuery += "(( '"+cCodEmp +"' BETWEEN BH1_EMPDE AND BH1_EMPATE) OR (BH1_EMPATE = ' ' AND BH1_EMPDE = ' ') ) AND "
		Else
			cQuery += "( '" +cCodEmp +"' BETWEEN BH1_EMPDE AND BH1_EMPATE ) AND "
		Endif
		
	Endif
	
	cQuery += " D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY " + StrTran(BH1->(IndexKey()),"+",",")
	
	PLSQuery(cQuery,"MSG")
	
	If ! MSG->(Eof())
		lAchou := .T.
	Else
		MSG->(DbCloseArea())
	Endif
	
	nConta++
Enddo

If lAchou
	
	While ! MSG->(Eof())
		
		cChave := MSG->BH1_CODIGO
		
		BH2->(msSeek(xFilial("BH2")+cChave))
		
		While BH2->BH2_FILIAL==xFilial("BH2") .and. BH2->BH2_CODIGO==cChave .and. ! BH2->(Eof())
			
			Aadd(aMSG,BH2->BH2_MSG01)
			
			BH2->(DbSkip())
		EndDo
		
		MSG->(DbSkip())
	EndDo
	MSG->(DbCloseArea())
	
Else
	Aadd(aMSG,"")
Endif

Return aMsg
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Funcao    ЁPLSA264GET╨Autor  ЁThiago Machado Correa ╨ Data Ё  02/11/04   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Apresenta cGetFile para selecao do arquivo.                  ╨╠╠
╠╠╨          Ё                                                              ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP6                                                          ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PLSA264GET()
cDirPls := cGetFile("*.*",STR0034,0,"SERVIDOR\",.T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_RETDIRECTORY) // //"Selecione o diretСrio"
If Empty(cDirPls) //Caso o usuario cancele, retorna .F. para cancelar a rotina
   Return (.F.)
EndIf
Return .T.
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Funcao    ЁUsuBlq264 ╨Autor  ЁThiago Machado Correa ╨ Data Ё  02/11/04   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Verifica se usuario esta bloqueado no periodo.               ╨╠╠
╠╠╨          Ё                                                              ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP6                                                          ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function UsuBlq264(cMatricula,cTipoReg,dFim, dDatBlo, cMotBlo, cNivBlo)
LOCAL cBlqCar
LOCAL lRet := .F.

If Alltrim(DtoS(dDatBlo)) <> "" .and. dDatBlo <= dDataBase
	
	// Usuario bloqueado.
	lRet := .T.
	
	// Analiza o motivo do bloqueio.
	Do Case
		Case cNivBlo == "U" //Usuario
			cBlqCar := Posicione("BG3",1,xFilial("BG3")+cMotBlo,"BG3_BLQCAR")
		Case cNivBlo == "F" //Familia
			cBlqCar := Posicione("BG1",1,xFilial("BG1")+cMotBlo,"BG1_BLQCAR")
		Case cNivBlo == "S" //Sub-Contrato
			cBlqCar := Posicione("BQU",1,xFilial("BQU")+cMotBlo,"BQU_BLQCAR")
	EndCase
	
	// O motivo do bloqueio nao bloqueia emissao do cartao.
	If cBlqCar == "0"
		lRet := .F.
	Endif
	
Endif

Return(lRet)
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммммкммммммямммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Funcao    ЁGrvVldCarUsr╨Autor ЁThiago Machado Correa╨ Data Ё  16/12/04   ╨╠╠
╠╠лммммммммммьммммммммммммйммммммомммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     ЁAtualiza data de validade na familia.                         ╨╠╠
╠╠╨          Ё                                                              ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       ЁAP6                                                           ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function GrvVldCarUsr(cMatricula,dDatVal)

BA3->(DbSetOrder(1))

If BA3->(msSeek(xFilial("BA3")+cMatricula))
	BA3->(RecLock("BA3",.F.))
		BA3->BA3_VALID := dDatVal
	BA3->(MsUnLock())
Endif

Return
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Funcao    ЁPL264VAL  ╨Autor  ЁDaher               ╨ Data Ё  12/02/05   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     ЁVerifica se ja existem lotes gerados nao encerrados para o  ╨╠╠
╠╠╨          |os parametros informados                                    ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP6                                                        ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
function Pl264Val(cOperadora,nUniLocal,cTipoGrupo,cEmpDe,cEmpAte,cDeCont,cAteCont,cDeSubCont,cAteSubCont,cMatrDe,cMatrAte,cDirGrava,dData1,dData2,cMudaVal,dDatVal,cMotivo,cCodGruDe,cCodGruAte)

Local cSql     := ""
Local cBDEName := RetSQLName("BDE")
Local lRet     := .F.
Default cTipoGrupo := ""

cSql  := " SELECT COUNT(*) NCOUNT FROM " + cBDEName
cSql  += " WHERE BDE_FILIAL = '" + xFilial("BDE")  + "' AND"
cSql  += "       BDE_CODINT = '" + cOperadora      + "' AND"
cSql  += "       BDE_MOTIVO = '" + cMotivo         + "' AND"
cSql  += "       BDE_QTD <> 0 AND "
cSql  += "       BDE_TIPGRU = '" + cTipoGrupo      + "' AND "
cSql  += "     ((BDE_EMPDE BETWEEN '"+cEmpDe    +"' AND '"+cEmpAte    +"') OR (BDE_EMPATE BETWEEN '"+cEmpDe    +"' AND '"+cEmpAte    +"')) AND"
cSql  += "     ((BDE_CONDE BETWEEN '"+cDeCont   +"' AND '"+cAteCont   +"') OR (BDE_CONATE BETWEEN '"+cDeCont   +"' AND '"+cAteCont   +"')) AND"
cSql  += "     ((BDE_SUBDE BETWEEN '"+cDeSubCont+"' AND '"+cAteSubCont+"') OR (BDE_SUBATE BETWEEN '"+cDeSubCont+"' AND '"+cAteSubCont+"')) AND"
cSql  += "     ((BDE_MATDE BETWEEN '"+cMatrDe   +"' AND '"+cMatrAte   +"') OR (BDE_MATATE BETWEEN '"+cMatrDe   +"' AND '"+cMatrAte   +"')) AND"
If BED->( FieldPos("BED_GRPDE") ) > 0 .AND. BED->( FieldPos("BED_GRPATE") ) > 0
	cSql  += "     ((BDE_GRPDE BETWEEN '"+cCodGruDe +"' AND '"+cCodGruAte +"') OR (BDE_GRPATE BETWEEN '"+cCodGruDe +"' AND '"+cCodGruAte +"')) AND"
EndIf
cSql  += "       BDE_STACAR = '1' AND"
cSql  += "       D_E_L_E_T_ <> '*' "
PLSQuery(cSql,"Pl264Val")

if  Pl264Val->NCOUNT > 0
	// se encontrou alguma coisa eh porque existem lotes em aberto
	lRet := .T.
endif
Pl264Val->(DbCloseArea())
Return (lRet)             
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммммкммммммямммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Funcao    ЁPlGrauTit   ╨Autor Ё Microsiga           ╨ Data Ё  28/01/10   ╨╠╠
╠╠лммммммммммьммммммммммммйммммммомммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     ЁVerifica o TIPREG do titular.                                 ╨╠╠
╠╠╨          Ё                                                              ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       ЁAP6                                                           ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/                   
Function PlGrauTit    
Local cGrauTit  := GetNewPar("MV_PLCDTGP","01") 
Local cCodTit   := GetNewPar("MV_PLCDTIT","T")
Local cModelo   := GetNewPar("MV_PLTITCD","1")
Local cTipReg   := GetNewPar("MV_PLTRTIT","00")    

If cModelo == "1"
   BT2->(DbSetOrder(1))
   If BT2->(DbSeek(xFilial("BT2")+cGrauTit))
      cTipReg := BT2->BT2_SEQDE
   EndIf  
ElseIf cModelo == "2"
   BF2->(DbSetOrder(1))
   If BF2->(DbSeek(xFilial("BF2")+cCodTit))
      cTipReg := BF2->BF2_SEQDE
   EndIf   
EndIf
   
Return (cTipReg)

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммммкммммммямммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Funcao    ЁCodRedeRef  ╨Autor Ё Microsiga           ╨ Data Ё  12/11/10   ╨╠╠
╠╠лммммммммммьммммммммммммйммммммомммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Retorna o codigo da Rede Referenciada de Atendimento de um   ╨╠╠
╠╠╨          Ё plano Unimed (somente para layout "2 - Ptu"                  ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       ЁAP6                                                           ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/      
Static Function CodRedeRef()
Local cRet     := ""
Local nCont    := 0

If BI3->(fieldpos("BI3_REDEDI")) > 0       
    For nCont := 1 to Len(Alltrim(BI3->BI3_REDEDI))
        If Substr(BI3->BI3_REDEDI,nCont,1) $ "0123456789"
            cRet += Substr(BI3->BI3_REDEDI,nCont,1)
        EndIf
    Next
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Em caso de erro de cadastro, caso exista mais de dois    Ё 
   //Ё caracteres no cRet, retorna somente os dois primeiros    Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддды   
   If len(cRet) > 2
       cRet := Substr(cRet,1,2)
   EndIf

Else
    cRet := Space(2)
EndIf    

Return(cRet)

//Classe de Carencia do beneficiario
Static Function ClsCar(cClsInt,cClsMatr,dClsData)
Local aClsCar := {} // matriz com as classes de carencia
Local nClsCar := 0  // contador das classes de carencia
Local cClsCar := "" // string das classes de carencias 

aClsCar := PlsClaCar(cClsInt,cClsMatr,dClsData)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁPonto de entrada para efetuar o tratamento das mensagens na geraГУa do arquivo de cartЦoЁ
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды			
If ExistBlock("PL264CLS")
	aRetCar := ExecBlock("PL264CLS",.F.,.F.,aClsCar)
	aClsCar	:=If(Valtype(aRetCar[1])='L',aRetCar,aClsCar)
EndIf

If Len(aClsCar) > 0 .And. aClsCar[1]

	For nClsCar := 1 To Len(aClsCar[2])
		If ! aClsCar[2,nClsCar,5] .And. aClsCar[2,nClsCar,6] // Cumpriu carencia? e Imprime carencia? .F. .And. .T.
			//Vou formatar a data em dd/mm/aa e imprimir o dia anterior que e o vencimento da carencia
			aClsCar[2,nClsCar,3] := Trim( SubStr(DtoS(aClsCar[2,nClsCar,3]-1),7,2) +"/"+ SubStr(DtoS(aClsCar[2,nClsCar,3]-1),5,2) +"/"+ SubStr(DtoS(aClsCar[2,nClsCar,3]-1),3,2) ) 
			cClsCar += Iif(!Empty(aClsCar[2,nClsCar,7]),aClsCar[2,nClsCar,7],aClsCar[2,nClsCar,2]) + " " + aClsCar[2,nClsCar,3] + GetNewPar("MV_PLSCRDE","")
		EndIf
	Next
Else
	cClsCar := "SEM CARйNCIAS A CUMPRIR"
EndIf                                                                         
		

Return Iif(!Empty(cClsCar),cClsCar,"SEM CARйNCIAS A CUMPRIR")


//-----------------------------------------------------------------
/*/{Protheus.doc} ChckProdCardVirtual
Verifica se o Produto saЗde do beneficiАrio nЦo utiliza CartЦo Virtual
 
@author Vinicius Queiros Teixeira
@since 29/03/2022
@version Protheus 12
/*/
//-----------------------------------------------------------------
Static Function ChckProdCardVirtual(cCodPlano, cVersao, cOperadora, cCodEmpresa, cContrato,;
									cVersaoContrato, cSubContrato, cVersaoSubContrato)

	Local lCheck := .T.
	Local aAreaBG9 := BG9->(GetArea())
	Local aAreaBT6 := BT6->(GetArea())
	Local aAreaBI3 := BI3->(GetArea())

	Default cCodPlano := ""
	Default cVersao := ""
	Default cCodEmpresa := ""
	Default cContrato := ""
	Default cVersaoContrato := ""
	Default cSubContrato := ""
	Default cVersaoSubContrato := ""

	BG9->(DBSetOrder(1))
	If BG9->(MsSeek(xFilial("BG9")+cOperadora+cCodEmpresa))
		// Pessoa Juridica
		If BG9->BG9_TIPO == "2"

			BT6->(DbSetOrder(1))
			If BT6->(MsSeek(xFilial("BT6")+cOperadora+cCodEmpresa+cContrato+cVersaoContrato+cSubContrato+cVersaoSubContrato+cCodPlano+cVersao))
				If BT6->(FieldPos("BT6_CARVIR")) > 0 .And. BT6->BT6_CARVIR == "0" // 0 = NЦo utiliza cartЦo virtual
					lCheck := .F.
				EndIf 
			Endif		
		Else // Pessoa Fisica

			BI3->(DBSetOrder(1))
			If BI3->(MsSeek(xFilial("BI3")+cOperadora+cCodPlano+cVersao))
				If BI3->(FieldPos("BI3_CARVIR")) > 0 .And. BI3->BI3_CARVIR == "0" // 0 = NЦo utiliza cartЦo virtual
					lCheck := .F.
				EndIf 
			EndIf 					
		Endif
	EndIf

	RestArea(aAreaBG9)
	RestArea(aAreaBT6)
	RestArea(aAreaBI3)

Return lCheck
