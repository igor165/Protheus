
#include "PROTHEUS.CH"
Function PLSSQLEXEC(cSQL, lGerarLOG,cArqLog)
LOCAL nRet := 0
DEFAULT lGerarLOG := .F.                       
DEFAULT cArqLog   := "PLSLOGQRY.LOG"  
 
If ! lGerarLOG .And. GetNewPar("MV_PLSQURY","0") == "1"
   lGerarLOG := .T.
Endif   

cSQL := PLSConSQL(cSQL)

If lGerarLOG
   nHorIni := Seconds()
   PlsLogFil(+"",cArqLog)
   PlsLogFil(Space(10)+"Log de Execucao de Query - Chamadas "+ProcName(1)+" - "+ProcName(2)+" - "+ProcName(3)+" - "+ProcName(4)+" - "+ProcName(5),cArqLog)
   PlsLogFil("",cArqLog)
   PlsLogFil(Space(10)+cSQL,cArqLog)
   PlsLogFil("",cArqLog)
Endif   
       
nRet := TCSQLExec(cSQL)

If lGerarLog
   PlsLogFil(Space(10)+"Tempo da query "+Str(Seconds()-nHorIni,10,3),cArqLog)
   PlsLogFil("",cArqLog)
Endif   

Return(nRet)


Function PLSConSQL(cSQL)

LOCAL cDataBase:= AllTrim(TCGetDB())

If cDataBase $ "ORACLE,DB2"
   cSQL := StrTran(cSQL,"SUBSTRING","SUBSTR")
   cSQL := StrTran(cSQL,"+","||")
   cSQL := StrTran(cSQL,"(||)","(+)")  // Outer join(+) oracle que era prejudicado pelo parce da linha acima.
   cSQL := StrTran(cSQL,"''","' '")
ElseIf cDataBase $ "POSTGRES"
   cSQL := StrTran(cSQL,"+","||")
Endif   

// Trata DTOS() retornado pela funcao de filtro padrao da microsiga...
cSql := StrTran(cSQL,"DTOS(","(")

Return(cSQL)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSCRIGEN  ³ Autor ³ Tulio Cesar         ³ Data ³ 18.03.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exibe uma critica generica                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSCRIGEN(aDados,aCabec,cTitulo,lRel,cRodape,nFreeze,;
 				   aButtons, bLDblClick,cRdmake,cTpRel,nTmRel,;
 				   bBlickUser,aArrayAux,lAmbAtv,;
 				   cLin1,cLin2,cCol1,cCol2,cHoriz,;
 				   aCores,aCdCores,aLegenda,oFont,lSilCrigen,lResize,aTipoCab)
LOCAL oDlg              
LOCAL nOpca      := 0
LOCAL bOK        := { || nOpca := 1, nLinSel := oCritica:nAt, oDlg:End() }
LOCAL bCancel    := { || nOpca := 0, oDlg:End() }
LOCAL nFor                                                   
LOCAL oCritica   
LOCAL nLinSel    
LOCAL lRoda      := .F.
LOCAL lBotoesPad
DEFAULT lRel     := .T.                                            
DEFAULT cRodape  := ""
DEFAULT nFreeze  := 0 
DEFAULT aButtons := {}
DEFAULT bLDblClick := bOk
DEFAULT cRdmake    := ""
DEFAULT cTpRel     := "M"
DEFAULT nTmRel     := 132
DEFAULT bBlickUser := { || }
DEFAULT aArrayAux  := {}	
DEFAULT lAmbAtv    := .T.  // indica se ja existe um ambiente ativo
                           // no PLSXUPT, por exemplo, ainda nao existe ambiente inicalizado e da erro no ExistBlock
                           // porque algumas variaveis de ambiente nao foram inicializadas
DEFAULT cLin1 := 008.0
DEFAULT cLin2 := 036.4
DEFAULT cCol1 := 010.3
DEFAULT cCol2 := 100.3
DEFAULT cHoriz:= 345
DEFAULT aCores   := {}
DEFAULT aCdCores := {}
DEFAULT aLegenda := { "Legenda", "Status" }
DEFAULT lSilCrigen := .F.
DEFAULT lResize  := .F.
DEFAULT aTipoCab := {}

If lSilCrigen
	return PSILCRIGEN(aDados	, aCabec	, cTitulo	, lRel		, cRodape	,;
						nFreeze	, aButtons	, bLDblClick, cRdmake	, cTpRel	,;
						nTmRel	, bBlickUser, aArrayAux	, lAmbAtv	, cLin1		,;
						cLin2	, cCol1		, cCol2		, cHoriz	, aCores	,;
						aCdCores, aLegenda	, oFont , nil ,lResize, aTipoCab)
Endif
// Define fonte para alihar informacoes no plscrigen.
If oFont == NIL
	Define FONT oFont NAME "Courier New" Size 0,-10 BOLD
Endif

lBotoesPad := Len(aButtons) > 0 .Or. Len(aCdCores) > 0
                 
If  lAmbAtv .and. ! empty(cRdmake) .and. ExistBlock(cRdmake)
    Aadd(aButtons, {"RELATORIO",{ || ExecBlock(cRdmake,.F.,.F.,{aDados,aCabec,cTitulo,cTpRel,nTmRel}) },"Imprimir"} )
Else
    If lAmbAtv .and. ExistBlock("PLSCRIGB")                    
       Aadd(aButtons, {"RELATORIO",{ || ExecBlock("PLSCRIGB",.F.,.F.,{aDados,aCabec,cTitulo,cTpRel,nTmRel}) },"Imprimir"} )        
    Else
       If lRel
          Aadd(aButtons, {"RELATORIO",{ || ImpCriGen(aDados,aCabec,cTitulo,cTpRel,nTmRel) },"Imprimir"} )
       Endif   
    Endif   
Endif    

If Len(aCdCores) > 0
	aAdd(aButtons,{"RELATORIO",{||BrwLegenda(aLegenda[1], aLegenda[2] ,aCdCores)},"Legenda","Legenda"})
EndIf

lRoda := !Empty(cRodaPe)
If Len(aDados) == 0
   Help("",1,"PLSCRIGEN")
   Return
Endif

If ! lRel .And. ! lBotoesPad
   aButtons := {}                                                           
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize    := MsAdvSize()
	aObjects := {}
	AAdd( aObjects, { 100, 100, .t., .t.,.t. } )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects,.T. )

If lResize
	cLin1 := aSize[7]
	cCol1 := 0
	cLin2 := aSize[6]
	cCol2 := aSize[5]	

	DEFINE MSDIALOG oDlg TITLE cTitulo FROM cLin1,cCol1 TO cLin2,cCol2 of oMainWnd pixel 
Else
	DEFINE MSDIALOG oDlg TITLE cTitulo FROM cLin1,cCol1 TO cLin2,cCol2 
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o browse...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ            
If lResize
	If Val(GetVersao(.F.)) >= 12//caso a versão seja maior ou igual a 12 altera a linha de início
		oCritica := TcBrowse():New( 032, 005, aPosObj[1][3], aPosObj[1][4]*0.97,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )    
	Else
		oCritica := TcBrowse():New( 022, 005, aPosObj[1][3], aPosObj[1][4]*0.97,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
	Endif		
Else
	If Val(GetVersao(.F.)) >= 12//caso a versão seja maior ou igual a 12 altera a linha de início
		oCritica := TcBrowse():New( 032, 005, cHoriz, IF(lRoda,160,170),,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )    
	Else
		oCritica := TcBrowse():New( 022, 005, cHoriz, IF(lRoda,160,170),,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
	Endif		
Endif
oCritica:bLDblClick := { || Eval(bBlickUser,oCritica,aArrayAux), bLDblClick }
oCritica:oFont := IIf(oFont == Nil, oCritica:oFont, oFont)
	
	If nFreeze <> 0
		oCritica:nFreeze := nFreeze
	Endif

If Len(aCores) > 0          
    bBlock := '{ || '
	For nFor := 1 To Len(aCores)
	   bBlock += 'IIf(' + aCores[nFor, 1] + ',LoadBitMap( GetResources(), "' + aCores[nFor, 2] + '" ),'
	Next nFor
	bBlock += Replicate(')',Len(aCores)) + ' }'
	bBlock := &bBlock
	oCritica:AddColumn(TcColumn():New("",bBlock,;
                  "@!",nil,nil,nil,15,.T.,.T.,nil,nil,nil,.T.,nil))     
EndIf


For nFor := 1 To Len(aCabec)

     bBlock := "{ || aDados[oCritica:nAt, "+Str(nFor,4)+"] }"
     bBlock := &bBlock
     If aCabec[nFor,1] = 'Justificar'
     	aCabec[nFor,3] *= 3
     EndIf
     oCritica:AddColumn(TcColumn():New(aCabec[nFor,1],bBlock,;
                    aCabec[nFor,2],nil,nil,nil,aCabec[nFor,3],.F.,.F.,nil,nil,nil,.F.,nil))     

Next
oCritica:SetArray(aDados)         

If lRoda
   @ 199,005 SAY oSay PROMPT cRodape  SIZE 400,010 OF oDlg PIXEL 
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa dialogo....                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlg ON INIT Eval( { || EnChoiceBar(oDlg,bOK,bCancel,.F.,aButtons) } ) Center

If  lAmbAtv
    DbSelectArea("BA0")
Endif
    
Return({(nOpca==1),nLinSel})
           

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PSILCRIGEN ³ Autor ³ Eduardo Folly       ³ Data ³ 18.03.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Modificações na rotina padrão do sistema PlsCriGen para    ³±±
±±³          | exibir críticas de um determinado processo, com a opção    ³±±
±±³          | de imprimir através do componente tReport.                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

static Function PSILCRIGEN(aDados	, aCabec	, cTitulo	, lRel		, cRodape	,;
						nFreeze	, aButtons	, bLDblClick, cRdmake	, cTpRel	,;
						nTmRel	, bBlickUser, aArrayAux	, lAmbAtv	, cLin1		,;
						cLin2	, cCol1		, cCol2		, cHoriz	, aCores	,;
						aCdCores, aLegenda	, oFont , cObsoleto , lResize, aTipoCab)

	Local oDlg
	Local nOpca  := 0
	Local bOK  := {|| nOpca := 1, nLinSel := oCritica:nAt, oDlg:End()}
	Local bCancel := {|| nOpca := 0, oDlg:End()}
	Local lRoda  := .F.
	Local nFor
	Local oCritica
	Local nLinSel
	Local lBotoesPad

	Default lRel		:= .T.
	Default cRodape		:= ""
	Default nFreeze		:= 0 
	Default aButtons	:= {}
	Default bLDblClick	:= bOk
	Default cRdmake		:= ""
	Default cTpRel		:= "M"
	Default nTmRel		:= 132
	Default bBlickUser	:= { || }
	Default aArrayAux	:= {}
	Default lAmbAtv		:= .T. // Parametro desativado
	Default cLin1		:= 008.0
	Default cLin2		:= 034.4
	Default cCol1		:= 010.3
	Default cCol2		:= 100.3
	Default cHoriz		:= 345
	Default aCores		:= {}
	Default aCdCores	:= {}
	Default aLegenda	:= {"Legenda", "Status"}
	Default aTipoCab    := {}

	// Define fonte para alihar informacoes.
//	If oFont == NIL
//		Define FONT oFont NAME "Courier New" Size 0,-10 BOLD
//	Endif

	lBotoesPad := Len(aButtons) > 0 .Or. Len(aCdCores) > 0

	If  /*lAmbAtv .and.*/ !Empty(cRdmake) .and. ExistBlock(cRdmake)
		Aadd(aButtons, {"RELATORIO", {|| ExecBlock(cRdmake,.F.,.F.,{aDados,aCabec,cTitulo,cTpRel,nTmRel}) }, "Imprimir"})
	Else
		If lRel
			aAdd(aButtons, {"RELATORIO", {|| SilImpCri(aDados, aCabec, cTitulo, aTipoCab)}, "Imprimir"})
		EndIf
	EndIf

	If Len(aCdCores) > 0
		aAdd(aButtons,{"RELATORIO",{||BrwLegenda(aLegenda[1], aLegenda[2] ,aCdCores)},"Legenda","Legenda"})
	EndIf

	lRoda := !Empty(cRodaPe)
	If Len(aDados) == 0
		Help("",1,"PLSCRIGEN")
		Return
	EndIf

	If !lRel .And. !lBotoesPad
		aButtons := {}
	EndIf

	aSize    := MsAdvSize()
	aObjects := {}
	AAdd( aObjects, { 100, 100, .t., .t.,.t. } )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects,.T. )
	
	If lResize
		cLin1 := aSize[7]
		cCol1 := 0 
		cLin2 := aSize[6]
		cCol2 := aSize[5]	
	
		DEFINE MSDIALOG oDlg TITLE cTitulo FROM cLin1,cCol1 TO cLin2,cCol2 of oMainWnd pixel 
	Else
		DEFINE MSDIALOG oDlg TITLE cTitulo FROM cLin1,cCol1 TO cLin2,cCol2 
	Endif
	
	If lResize
		oCritica := TcBrowse():New( 31, 002, aPosObj[1][3], aPosObj[1][4]*0.97,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )    
	Else
		oCritica := TcBrowse():New( 022, 005, cHoriz, IF(lRoda,160,170),,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )    
	Endif
   	oCritica:bLDblClick := { || Eval(bBlickUser,oCritica,aArrayAux), bLDblClick }

	If nFreeze <> 0
		oCritica:nFreeze := nFreeze
	EndIf

	If Len(aCores) > 0
		bBlock := '{ || '
		For nFor := 1 To Len(aCores)
			bBlock += 'IIf(' + aCores[nFor, 1] + ',LoadBitMap( GetResources(), "' + aCores[nFor, 2] + '" ),'
		Next nFor
		bBlock += Replicate(')',Len(aCores)) + ' }'
		bBlock := &bBlock
		oCritica:AddColumn(TcColumn():New("",bBlock,"@!",nil,nil,nil,15,.T.,.T.,nil,nil,nil,.T.,nil))
	EndIf

	For nFor := 1 To Len(aCabec)
		bBlock := "{ || aDados[oCritica:nAt, "+Str(nFor,4)+"] }"
		bBlock := &bBlock
		oCritica:AddColumn(TcColumn():New(aCabec[nFor,1],bBlock,aCabec[nFor,2],nil,nil,nil,aCabec[nFor,3],.F.,.F.,nil,nil,nil,.F.,nil))
	Next

	oCritica:SetArray(aDados)

	If lRoda
		@ 189,005 Say oSay Prompt cRodape Size 400,010 Of oDlg Pixel
	EndIf

	Activate MsDialog oDlg On Init Eval({|| EnChoiceBar(oDlg,bOK,bCancel,.F.,aButtons)}) Center

Return({(nOpca==1),nLinSel})

Static Function SilImpCri(aDados, aCabec, cTitulo,aTipoCab)
	Local aCampos := {}
	Local oReport := TReport():New("SILIMPCRI", cTitulo, /*cPerg*/, {|oReport| PrintReport(oReport)}, cTitulo)
	LOCAL x  
	LOCAL j
	LOCAL i
	Default aTipoCab := {}

	Private cImpCri := GetNextAlias()

	For x := 1 To Len(aCabec)
		aAdd(aCampos, {"CAMPO_" + AllTrim(Str(x)), IIF(len(aTipoCab) > 0,aTipoCab[x],ValType(aDados[1][x])), aCabec[x][3], 0})
	Next

	//--< Criação do objeto FWTemporaryTable >---
	oTempTRB := FWTemporaryTable():New( cImpCri )
	oTempTRB:SetFields( aCampos )
	oTempTRB:AddIndex( "INDTRB",{ "CAMPO_1" } )
	
	if( select( cImpCri ) > 0 )
		( cImpCri )->( dbCloseArea() )
	endIf
	
	oTempTRB:Create()

	For i := 1 To Len(aDados)
		RecLock(cImpCri, .T.)
		For j := 1 To Len(aCabec)
			mCampo := "(cImpCri)->" + aCampos[j][1]
			&mCampo := aDados[i][j]
		Next
		(cImpCri)->(MsUnlock())
	Next
	
	oSection1 := TRSection():New(oReport, "Dados", {cImpCri})
	

	For i := 1 To Len(aCabec)
		TRCell():New(oSection1, aCampos[i][1], cImpCri, aCabec[i][1], aCabec[i][2], aCabec[i][3])
	Next

	oReport:PrintDialog()

	if( select( cImpCri ) > 0 )
		oTempTRB:delete()
	endIf
Return .T.


Static Function PrintReport(oReport)
	Local oSection1 := oReport:Section(1)

	nRegs := 0
	(cImpCri)->(dbGoTop())
	(cImpCri)->(dbEval({||nRegs++}))
	(cImpCri)->(dbGoTop())

	oReport:SetMeter(nRegs)

	oSection1:Init()
	While !oReport:Cancel() .And. (cImpCri)->(!Eof())
		If oReport:Cancel()
			Exit
		EndIf
		oSection1:PrintLine()
		(cImpCri)->(dbSkip())
	EndDo
	oSection1:Finish()
	
Return

/*/{Protheus.doc} PLSSQLNAME
Retorna o nome da tabela conforme o alias

**************************
Apos compilar o fonte com o novo PLSMGER.CH esta funcao nao é mais necessaria.
**************************

@author PLSTEAM
@since 207/12/2016
@version P12
/*/
function PLSSQLNAME(cAlias)
return RetSqlName(cAlias)

