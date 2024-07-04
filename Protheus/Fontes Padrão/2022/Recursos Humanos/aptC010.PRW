#INCLUDE "aptC010.ch"
#INCLUDE "protheus.ch"
#INCLUDE "COLORS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAPTC010      บ Autor ณ Andreia Santos     บ Data ณ  05/08/2004 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Agenda de acompanhamento do processo                          บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Processos Trabalhistas                                        บฑฑ
ฑฑวฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤถฑฑ
ฑฑบ         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                บฑฑ
ฑฑวฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤถฑฑ
ฑฑบProgramador ณ Data     ณ BOPS ณ  Motivo da Alteracao                      บฑฑ
ฑฑวฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤถฑฑ
ฑฑณCecilia Car.ณ12/08/2014ณTQEQCCณIncluido o fonte da 11 para a 12 e efetuadaณฑฑ
ฑฑณ            ณ          ณ      ณa limpeza.                                 ณฑฑ
ฑฑณOswaldo L    ณ08-05-17ณDRHPONTP12  ณProjeto SOYUZ ajuste Ctree          ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function APTC010( cAlias , nReg , nOpc , lExecAuto , lMaximized )

Local aArea 	:= GetArea()
Local oDlg
Local oGet01
Local oGet02
Local oGetFilDe
Local oGetFilAte
Local oGetAdvDe
Local oGetAdvAte
Local oGetProDe
Local oGetProAte
Local oGetDtDe
Local oGetDtAte
Local oGetEve
Local oFont
Local oGroup
Local oRadio

Local nHandle
Local cLog 			:= Space(100)
Local nOffSet 		:= 0

Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

Local aAdv1Size		:= {}
Local aInfo1AdvSize	:= {}
Local aObj1Size		:= {}
Local aObj1Coords	:= {}

Local nOpcA			:= 1
Local nValor		:= 0
Local aGrupo1		:= {}
Local aGrupo2		:= {}
Local aGrupo3		:= {}
Local bSet15		:= { || NIL }
Local bSet24		:= { || NIL }

Private lAdvogado 	:= .T.
Private lProcesso	:= .T.
Private lData 		:= .T.
Private lConsFil	:= .T.
Private lEvento		:= .T.

Private cFilDe    	:= Space(FwSizeFilial())
Private cFilAte   	:= Replicate("Z", FwSizeFilial())
Private cAdvDe  	:= space(6)
Private cAdvAte   	:= "999999"
Private cProcDe 	:= space(06)
Private cProcAte  	:= "999999"
Private dDataDe		:= cToD("")
Private dDataAte 	:= dDatabase
Private nOpcOrd		:= 1
Private cEvento		:= "123456"
Private cOcorrLit	:= OemToAnsi(STR0029)	//"Ocorrencias"
Private cAudieLit	:= OemToAnsi(STR0030)	//"Audiencias"
Private cSenteLit	:= OemToAnsi(STR0031)	//"Sentenca"
Private cRecurLit	:= OemToAnsi(STR0032)	//"Recurso"
Private cPericLit	:= OemToAnsi(STR0033)	//"Pericia"
Private cDespeLit	:= OemToAnsi(STR0034)	//"Despesa"

If File("APTC010.PAR")
	nHandle := fOpen("APTC010.PAR",2)
	If A010VerUsu(nHandle,@cLog,@nOffSet) // Pesquisa o usuario atual
		lConsFil	:= Substr(cLog,21,1)=="S"
		If lConsFil
			cFilDe	:= Substr(cLog,22,FwSizeFilial())
			cFilAte	:= Substr(cLog,22+FwSizeFilial(),FwSizeFilial())
		Endif
		nValor:= 22+2*(FwSizeFilial())
		lAdvogado 	:= Substr(cLog,nValor,1)=="S"
		If lAdvogado
			cAdvDe	:= Substr(cLog,nValor+1,6)
			cAdvAte	:= Substr(cLog,nValor+7,6)
		Endif
		nValor+=13
		lProcesso	:= Substr(cLog,nValor,1)=="S"
		If lProcesso
			cProcDe	:= Substr(cLog,nValor+1,6)
			cProcAte:= Substr(cLog,nValor+7,6)
		Endif
		nValor+=13
		lData 		:= Substr(cLog,nValor,1)=="S"
		If lData
			dDataDe	:= cTod(Substr(cLog,nValor+1,10))
			dDataAte:= cTod(Substr(cLog,nValor+11,10))
		Endif
		nValor+=21
		lEvento		:= Substr(cLog,nValor,1)=="S"
		If lEvento
			cEvento	:= Substr(cLog,nValor+1,6)
		Endif
	Endif
Endif
fClose(nHandle)

/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Monta as Dimensoes dos Objetos         					   ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
aAdvSize		:= MsAdvSize(,.T.,390)
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5}
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )				//1-espaco
aAdd( aObjCoords , { 000 , 015 , .T. , .F. } )				//2-Filiais
aAdd( aObjCoords , { 000 , 015 , .T. , .F. } )				//3-Advogados
aAdd( aObjCoords , { 000 , 015 , .T. , .F. } )				//4-Processos
aAdd( aObjCoords , { 000 , 015 , .T. , .F. } )				//5-Datas
aAdd( aObjCoords , { 000 , 015 , .T. , .F. } )				//6-Eventos
aAdd( aObjCoords , { 000 , 030 , .T. , .F. } )				//7-Ordem
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )				//8-espaco
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

aAdv1Size		:= aClone(aObjSize[2])
aInfo1AdvSize	:= { aAdv1Size[2] , aAdv1Size[1] , aAdv1Size[4] , aAdv1Size[3] , 5 , 5 }
aAdd( aObj1Coords , { 000 , 000 , .f. , .T. } )				//8-espaco
aAdd( aObj1Coords , { 060 , 000 , .F. , .T. } )				//1-Checkbox
aAdd( aObj1Coords , { 005 , 000 , .F. , .T. } )				//2-Espaco
aAdd( aObj1Coords , { 035 , 000 , .F. , .T. } )				//3-Say de:
aAdd( aObj1Coords , { 035 , 000 , .F. , .T. } )				//4-Get de:
aAdd( aObj1Coords , { 005 , 000 , .F. , .T. } )				//5-Espaco
aAdd( aObj1Coords , { 010 , 000 , .F. , .T. } )				//6-Say Ate:
aAdd( aObj1Coords , { 030 , 000 , .F. , .T. } )				//7-Get Ate:
aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )				//8-espaco
aObj1Size		:= MsObjSize( aInfo1AdvSize , aObj1Coords,,.T. )


DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
DEFINE MSDIALOG oDlg TITLE STR0001 FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL FONT oMainWnd:oFont  //"Selecione as Opcoes da Agenda de Acompanhamento do Processo"

	@ aObjSize[1,1], aObjSize[1,2] GROUP oGroup TO  aObjSize[8,3], aObjSize[8,4] LABEL OemToAnsi(STR0002) OF oDlg PIXEL	  //"Parametros"
	oGroup:oFont:= oFont

	@ aObjSize[2,1] , aObj1Size[2,2]	CHECKBOX oGet01  VAR lConsFil PROMPT STR0003 FONT oDlg:oFont PIXEL OF oDlg SIZE 70,9 ON CLICK(oGetFilAte:SetFocus(),oGetFilDe:SetFocus()) //"Considera Filiais:"
	@ aObjSize[2,1] , aObj1Size[4,2]	SAY STR0004 FONT oDlg:oFont   PIXEL OF oDlg  //"Filial de"
	@ aObjSize[2,1] , aObj1Size[5,2]	MSGET oGetFilDe  VAR cFilDe   FONT oDlg:oFont PIXEL SIZE 10, 9 OF oDlg PICTURE "@!" WHEN lConsFil F3 "XM0" HASBUTTON
	@ aObjSize[2,1] , aObj1Size[7,2]   SAY STR0005 FONT oDlg:oFont   PIXEL OF oDlg  //"Ate"
	@ aObjSize[2,1] , aObj1Size[8,2]   MSGET oGetFilAte VAR cFilAte  FONT oDlg:oFont PIXEL SIZE 10, 9 OF oDlg PICTURE "@!" WHEN lConsFil F3 "XM0" HASBUTTON

	@ aObjSize[3,1] , aObj1Size[2,2]	CHECKBOX oGet01  VAR lAdvogado      PROMPT STR0006 FONT oDlg:oFont PIXEL OF oDlg SIZE 80,9 ON CLICK( oGetAdvAte:SetFocus(),oGetAdvDe:SetFocus()) //"Considera Advogados:"
	@ aObjSize[3,1] , aObj1Size[4,2]	SAY STR0007 FONT oDlg:oFont PIXEL OF oDlg  //"Advogado de"
	@ aObjSize[3,1] , aObj1Size[5,2] 	MSGET oGetAdvDe  VAR cAdvDe FONT oDlg:oFont PIXEL SIZE 10, 9 OF oDlg PICTURE "@!" WHEN lAdvogado F3 "RD0ADV" HASBUTTON
	@ aObjSize[3,1] , aObj1Size[7,2] 	SAY STR0005 FONT oDlg:oFont PIXEL OF oDlg  //"Ate"
	@ aObjSize[3,1] , aObj1Size[8,2]	MSGET oGetAdvAte VAR cAdvAte FONT oDlg:oFont PIXEL SIZE 10, 9 OF oDlg PICTURE "@!" WHEN lAdvogado F3 "RD0ADV" HASBUTTON

	@ aObjSize[4,1] , aObj1Size[2,2] 	CHECKBOX oGet01  VAR lProcesso  PROMPT STR0008 FONT oDlg:oFont PIXEL OF oDlg SIZE 80,9 ON CLICK(oGetProAte:SetFocus(),oGetProDe:SetFocus()) //"Considera Processos:"
	@ aObjSize[4,1] , aObj1Size[4,2] 	SAY STR0009 FONT oDlg:oFont PIXEL OF oDlg  //"Processo de"
	@ aObjSize[4,1] , aObj1Size[5,2] 	MSGET oGetProDe  VAR cProcDe FONT oDlg:oFont PIXEL SIZE 10, 9 OF oDlg PICTURE "@!" WHEN lProcesso F3 "RE0" HASBUTTON
	@ aObjSize[4,1] , aObj1Size[7,2] 	SAY STR0005 FONT oDlg:oFont PIXEL OF oDlg  //"Ate"
	@ aObjSize[4,1] , aObj1Size[8,2] 	MSGET oGetProAte  VAR cProcAte FONT oDlg:oFont PIXEL SIZE 10, 9 OF oDlg PICTURE "@!" WHEN lProcesso F3 "RE0" HASBUTTON

	@ aObjSize[5,1] , aObj1Size[2,2] 	CHECKBOX oGet01  VAR lData  PROMPT STR0010 FONT oDlg:oFont PIXEL OF oDlg SIZE 80,9 ON CLICK(oGetDtAte:SetFocus(),oGetDtDe:SetFocus()) //"Considera Datas:"
	@ aObjSize[5,1] , aObj1Size[4,2] 	SAY STR0011 FONT oDlg:oFont PIXEL OF oDlg  //"Data de"
	@ aObjSize[5,1] , aObj1Size[5,2] 	MSGET oGetDtDe   VAR dDataDe FONT oDlg:oFont PIXEL SIZE 45, 9 OF oDlg  WHEN lData  HASBUTTON
	@ aObjSize[5,1] , aObj1Size[7,2] 	SAY STR0005 FONT oDlg:oFont PIXEL OF oDlg  //"Ate"
	@ aObjSize[5,1] , aObj1Size[8,2] 	MSGET oGetDtAte  VAR dDataAte FONT oDlg:oFont PIXEL SIZE 45, 9 OF oDlg  WHEN lData HASBUTTON

	@ aObjSize[6,1] , aObj1Size[2,2] CHECKBOX oGet01  VAR lEvento  PROMPT STR0012 FONT oDlg:oFont PIXEL OF oDlg SIZE 70,9 ON CLICK(oGetEve:SetFocus()) //"Considera Eventos:"
	@ aObjSize[6,1] , aObj1Size[4,2] SAY STR0013 FONT oDlg:oFont PIXEL OF oDlg  //"Eventos:"
	@ aObjSize[6,1] , aObj1Size[5,2] MSGET oGetEve  VAR cEvento FONT oDlg:oFont PIXEL SIZE 10, 9 OF oDlg  WHEN lEvento valid fEvento() HASBUTTON

	@ aObjSize[7,1] , aObj1Size[2,2]  GROUP oGroup TO aObjSize[8,3]-10, aObj1Size[3,4] LABEL OemToAnsi(STR0014) OF oDlg PIXEL	  //"Ordem"
	oGroup:oFont:= oFont

	@ aObjSize[7,1]+10 , aObj1Size[2,2]+10	RADIO oRadio VAR nOpcOrd ITEMS 	OemToAnsi(STR0015),; //"Processos/Data"
													OemToAnsi(STR0016),; //"Data/Processo"
													OemToAnsi(STR0017); //"Data"
													SIZE 115,010 OF oDlg PIXEL

	bSet15 := {||nOpcA := 1, oDlg:End()}
	bSet24 := {||nOpcA := 0, oDlg:End()}

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 ) CENTERED

If nOpcA == 1
	If File("APTC010.PAR")
		nHandle := fOpen("APTC010.PAR",2)
	Else
		nHandle := fCreate("APTC010.PAR")
	Endif
	fSeek(nHandle,nOffSet-75,0) // Posiciona na linha a ser gravada
	cLog := Pad(Left(cUserName,19),20)
	cLog += If(lConsFil,"S","N")
	cLog += cFilDe+cFilAte
	cLog += If(lAdvogado,"S","N")
	cLog += cAdvDe+cAdvAte
	cLog += If(lProcesso,"S","N")
	cLog += cProcDe+cProcAte
	cLog += If(lData,"S","N")
	cLog += dToC(dDatade)
	cLog += dToC(dDataAte)
	cLog += If(lEvento,"S","N")
	cLog += cEvento
	fWrite(nHandle,cLog+Chr(13)+Chr(10))
	fClose(nHandle)


	Processa({|lEnd| ac010Proc()})

Endif
RestArea( aArea )

If !Empty(cAlias)
   DbSelectArea(cAlias)
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณAc010Proc บAutor  ณMicrosiga           บ Data ณ  09/08/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ac010Proc(nOpcx)

Local aKeys			:=GetKeys()
Local bDelOk 		:= {|| .T. }
Local bGdRE0Seek	:= { || NIL }
Local aAltera		:= {}
Local aButtons		:= {}
Local aAvFields		:= {} //campos exibidos em tela a serem avaliados pelo gerenciamento de dados sensiveis
Local aPDFields		:= {} //campos que estao classificados como dados sensiveis
Local aOfuscaCpo	:= {.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.}
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), {.T.,.F.}) //[1] Acesso; [2]Ofusca
Local cOrdem		:= ''
Local nX			:= 0
Local nPos			:= 0
Local oFont
Local oFontBig

Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

Private aTRBHeader := {}
Private aTRBCols   := {}

Private oTRBTmp

Private oGetDados
Private aRotina := {	{ STR0018	, "        ", 0 , 1},;	// //"Pesquisar"
						{ STR0019	, "        ", 0 , 2},;	// //"Visualizar"
						{ STR0020	, "        ", 0 , 3},;	// //"Incluir"
						{ STR0021	, "        ", 0 , 4},;	// //"Alterar"
						{ STR0022	, "        ", 0 , 5} }	// //"Excluir"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMontar arquivo temporarioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

c010MontaTRB()

aTRBHeader := {	{ 'Data'         , 'TRB_DATA'  ,'@!', 08, 0, '','๛', 'C', '  ', ' ' },; //REO_DATA,REA_DATA,RES_JULGAM,REM_DATA,REH_DTPERI,RC1_VENCTO
				{ 'Evento'       , 'TRB_EVENTO','@!', 03, 0, '','๛', 'C', '  ', ' ' },; //string
				{ 'Descricao'    , 'TRB_DESCEV','@!', 30, 0, '','๛', 'C', '  ', ' ' },; //RE5_DESCR,REO_TPDESC,REA_TPDESC,RES_TPDESC,REM_TPDESC,REH_TPDESC,RC1_TPDESC
				{ 'Processo'     , 'TRB_NUMPRO','@!', 06, 0, '','๛', 'C', '  ', ' ' },; //RE0_NUM
				{ 'Descricao'    , 'TRB_DSPROC','@!', 50, 0, '','๛', 'C', '  ', ' ' },; //RE0_DESCR
				{ 'Cod.Reclam.'  , 'TRB_CRECLA','@!', 06, 0, '','๛', 'C', '  ', ' ' },; //REL_RECLAM,RE0_RECLAM
				{ 'Reclamante'   , 'TRB_NRECLA','@!', 30, 0, '','๛', 'C', '  ', ' ' },; //RD0_NOME,RE0_RECNOM
				{ 'Cod.Adv.'     , 'TRB_CADVOG','@!', 06, 0, '','๛', 'C', '  ', ' ' },; //REO_CODADV,REA_ADRDAC
				{ 'Nome Advogado', 'TRB_NADVOG','@!', 30, 0, '','๛', 'C', '  ', ' ' };  //RD0_NOME,REA_ADRDAN,REO_ADVNOM
			}

dbSelectArea( 'TRB' )
If TRB->( RecCount() ) = 0
	Aviso( STR0023, STR0024, { "OK" } ) //"Atencao"###"Nao ha dados para apresentar"
Else

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Monta matriz de visualizacao.											ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	TRB->( dbGoTop() )
	While TRB->( !Eof() )
		Aadd( aTRBCols, { TRB->TRB_DATA, TRB->TRB_EVENTO, TRB->TRB_DESCEV,TRB->TRB_NUMPRO,TRB->TRB_DSPROC, TRB->TRB_CRECLA, TRB->TRB_NRECLA,TRB->TRB_CADVOG,TRB->TRB_NADVOG, .f. } )
		TRB->( dbSkip() )
	Enddo

	If Len( aTRBCols ) = 0
		Aviso( STR0023, STR0024, { "OK" } ) //"Atencao"###"Nao ha dados para apresentar"
	Else

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Exibe a Consulta   			ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

		nOpca := 0

		cOrdem	:= If( nOpcOrd == 1,STR0015,If(nOpcOrd ==2,STR0016,STR0017)) //"Processos/Data"###"Data/Processo"###"Data"

 		SetaPilha()

  		/*
		ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		ณ Monta as Dimensoes dos Objetos         					   ณ
		ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
		aAdvSize		:= MsAdvSize(,.T.,380)
		aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 10 , 5 }
		aAdd( aObjCoords , { 000 , 030 , .T. , .F. } )
		aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
		aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

		DEFINE FONT oFontBig NAME "Arial" SIZE 7,20 BOLD
		DEFINE MSDIALOG oDlg TITLE STR0025  From aAdvSize[7],0 To aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL	// //"Agenda"

		@ aObjSize[1,1], aObjSize[1,2] GROUP oGroup TO  aObjSize[1,3], aObjSize[1,4] LABEL '' OF oDlg PIXEL

		@aObjSize[1,1]+5 , aObjSize[1,2]+5 SAY STR0025 SIZE 0200,10 OF oDlg PIXEL FONT oFontBig //COLOR CLR_HBLUE  //"Agenda"
		@aObjSize[1,1]+16, aObjSize[1,2]+5 SAY STR0026 +cOrdem SIZE 0250,10 OF oDlg PIXEL FONT oFontBig //COLOR CLR_HBLUE //"Ordem: "

		/*/
		ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		ณ Define o Botao de Visualizacao do Processo			 	   ณ
		ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
		bGdRe0Seek := { || GdRe0Seek()	}
		SetKey( VK_F4 , bGdRe0Seek )

		aAdd(;
				aButtons	,;
								{;
									"Pesquisa" 							,;
		   							bGdRE0Seek							,;
		       	   					OemToAnsi( STR0035 + " <F4>")	,;	//"Detalhe"
		       	   					OemToAnsi( STR0036 + " <F4>")				 ;	//"Exibe Detalhe Processo"
		           				};
		     )

		/*
		ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		ณ Monta o Objeto GetDados para o RD4						   ณ
		ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
		oGetDados	:= MsNewGetDados():New(	aObjSize[2,1]		,;//nTop
											aObjSize[2,2]		,;//nLeft
											aObjSize[2,3]		,;//nBottom
											aObjSize[2,4]		,;//nRight
											0				    ,;//nStyle (nOpc)
											"AlWaysTrue"		,;//LinhaOk
											"AlWaysTrue"		,;//TudoOk
											""					,;//cIniCpos
											nil					,;//aAlter
											nil					,;//nFreeze
											9999				,;//nMax
											NIL					,;//cFieldOk
											NIL					,;//uSuperDel
											nil					,;//uDelOk
											oDlg				,;//oWnd
											aTRBHeader			,;//aHeader
											aTRBCols		 	 ;//aCols
										  )

		//Protecao de Dados Sensiveis
		If aOfusca[2]
			aAvFields := {"REO_DATA","REA_DATA","RES_JULGAM","REM_DATA","REH_DTPERI","RC1_VENCTO",; //TRB_DATA
						  "RE5_DESCR","REO_TPDESC","REA_TPDESC","RES_TPDESC","REM_TPDESC","REH_TPDESC","RC1_TPDESC",; //TRB_DESCEV
						  "RE0_NUM",; //TRB_NUMPRO
						  "RE0_DESCR",; //TRB_DSPROC
						  "REL_RECLAM","RE0_RECLAM",; //TRB_CRECLA
						  "RD0_NOME","RE0_RECNOM",; //TRB_NRECLA
						  "REO_CODADV","REA_ADRDAC",; //TRB_CADVOG
						  "RD0_NOME","REA_ADRDAN","REO_ADVNOM" } //TRB_NADVOG
			aPDFields := FwProtectedDataUtil():UsrNoAccessFieldsInList(aAvFields)
			oGetDados:oBrowse:lObfuscate := .T.
			For nX := 1 to Len(aPDFields)
				nPos := aScan(aAvFields, {|x| x == aPDFields[nX]:cField})
				If nPos < 7 //TRB_DATA
					aOfuscaCpo[1] := .T.
				ElseIf nPos > 6 .AND. nPos < 14 //TRB_DESCEV
					aOfuscaCpo[3] := .T.
				ElseIf nPos == 14 //TRB_NUMPRO
					aOfuscaCpo[4] := .T.
				ElseIf nPos == 15 //TRB_DSPROC
					aOfuscaCpo[5] := .T.
				ElseIf nPos == 16 .OR. nPos == 17 //TRB_CRECLA
					aOfuscaCpo[6] := .T.
				ElseIf nPos == 18 //TRB_NRECLA ou TRB_NADVOG
					aOfuscaCpo[7] := .T.
					aOfuscaCpo[9] := .T.
				ElseIf nPos == 19 //TRB_NRECLA
					aOfuscaCpo[7] := .T.
				ElseIf nPos == 20 .OR. nPos == 21 //TRB_CADVOG
					aOfuscaCpo[8] := .T.
				ElseIf nPos > 21 //TRB_NADVOG
					aOfuscaCpo[9] := .T.
				EndIf
			Next nX
			oGetDados:oBrowse:aObfuscatedCols := aOfuscaCpo
		EndIf

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nopca:=1,RestKeys(aKeys,.T.),oDlg:End()},{||RestKeys(aKeys,.T.),oDlg:End()},Nil,aButtons) CENTERED

   		SetaPilha()
  	Endif

EndIf

dbSelectArea("TRB")
dbCloseArea()

If oTRBTmp <> Nil
	oTRBTmp:Delete()
	Freeobj(oTRBTmp)
EndIf

RestKeys(aKeys,.T.)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบFuncao    ณc010MontaTRBบAutor  ณAndreia dos Santos บ Data ณ  09/08/04  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณMonta tabela temporaria para apresentacao na consulta       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function c010MontaTRB()

Local cIndCond	:= ''
Local aFilIni	:=	Array(07,03)
Local aFields	:= {}
Local lOcorren	:= 	If(lEvento,If("1"$cEvento,.T.,.F.),.T.)
Local lAudienc	:= 	If(lEvento,If("2"$cEvento,.T.,.F.),.T.)
Local lSentenc	:= 	If(lEvento,If("3"$cEvento,.T.,.F.),.T.)
Local lRecurso	:= 	If(lEvento,If("4"$cEvento,.T.,.F.),.T.)
Local lPericia	:= 	If(lEvento,If("5"$cEvento,.T.,.F.),.T.)
Local lDespesa	:= 	If(lEvento,If("6"$cEvento,.T.,.F.),.T.)
Local nPosArq	:=	0
Local cProcRange := ""
Local cEmpUndFil := ""
Local aLstIndices := {}

AADD(aFields,{ 'TRB_FILIAL', 'C', FwSizeFilial(), 0 } )
AADD(aFields,{ 'TRB_DATA'  , 'D', 08, 0 } )
AADD(aFields,{ 'TRB_EVENTO', 'C', 05, 0 } )
AADD(aFields,{ 'TRB_DESCEV', 'C', 30, 0 } )
AADD(aFields,{ 'TRB_NUMPRO', 'C', 06, 0 } )
AADD(aFields,{ 'TRB_DSPROC', 'C', 50, 0 } )
AADD(aFields,{ 'TRB_CRECLA', 'C', 06, 0 } )
AADD(aFields,{ 'TRB_NRECLA', 'C', 30, 0 } )
AADD(aFields,{ 'TRB_CADVOG', 'C', 06, 0 } )
AADD(aFields,{ 'TRB_NADVOG', 'C', 30, 0 } )
AADD(aFields,{ 'TRB_TPOCOR', 'C', 06, 0 } )

If nOpcOrd == 1  //Processo/Data
	Aadd(aLstIndices , {'TRB_FILIAL','TRB_NUMPRO','TRB_DATA'})
ElseIf nOpcOrd == 2 //Data/Processo
	Aadd(aLstIndices , {'TRB_FILIAL','TRB_DATA','TRB_NUMPRO'})
Else //	Data
	Aadd(aLstIndices , {'TRB_FILIAL','TRB_DATA'})
EndIf


oTRBTmp := RhCriaTrab("TRB", aFields, aLstIndices)


If !lAdvogado
	cAdvDe  	:= space(06)
	cAdvAte   	:= "999999"
EndIf

If !lProcesso
	cProcDe 	:= space(06)
	cProcAte  	:= "999999"
EndIf

If !lConsFil
	cFilDe    	:= Space(FwSizeFilial())
	cFilAte   	:= Replicate("Z", FwSizeFilial())
EndIf

aFilIni[1,1] := "RE0"
aFilIni[2,1] := "REO"
aFilIni[3,1] := "REA"
aFilIni[4,1] := "RES"
aFilIni[5,1] := "REM"
aFilIni[6,1] := "REH"
aFilIni[7,1] := "RC1"

aEval( aFilIni, { |X| X[2] := If( !Empty( FWxFilial(X[1]) ), .T., .F. )  } )//.T.-Exclusivo;.F.-Compartilhado

dbSelectArea("RE0")
dbSetOrder(1)
dbGoTop()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTomar cuidado quando der manutencao, pois sao duas             ณ
//ณtabelas distintas, RE0( zero no final) e REO( letra O no final)ณ
//ณProcessos e Ocorrencias.                                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//Processo

nPosArq := aScan( aFilIni, { |Y| Y[1] == "RE0" } )


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//Verifica modo de compartilhamento e a op็ใo escolhida pelo usuแrio,
//para ajustar conforme o que estแ gravado no banco de dados.
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cEmpUndFil := FWxFilial("RE0")

If len(trim(cFilDe)) <> len(Trim(cEmpUndFil)) .AND. Trim(cEmpUndFil) == SubStr(cFilDe,1,len(Trim(cEmpUndFil)))
	cFilDe := cEmpUndFil
EndIf


RE0->( dBSeek(If(aFilIni[1,2],cFilDe,Space(FwSizeFilial()))+cProcDe,.T.))


While RE0->( !EOF() ) .And. RE0->RE0_FILIAL >= cFilDe .and. RE0->RE0_FILIAL <= cFilAte;
						.and. RE0->RE0_NUM >= cProcDe .and. RE0->RE0_NUM <= cProcAte

  	aFilIni[1,3] := RE0->RE0_FILIAL  //Atribui a filial corrente para a geracao dos resultados
	aFilIni[2,3] := RE0->RE0_FILIAL
	aFilIni[3,3] := RE0->RE0_FILIAL
	aFilIni[4,3] := RE0->RE0_FILIAL
	aFilIni[5,3] := RE0->RE0_FILIAL
	aFilIni[6,3] := RE0->RE0_FILIAL
	aFilIni[7,3] := RE0->RE0_FILIAL

    //Ocorrencias
	If lOcorren
		nPosArq := aScan( aFilIni, { |Y| Y[1] == "REO" } )
		REO->(dbGoTop())
		REO->( dBSeek(If(aFilIni[nPosArq,2],aFilIni[nPosArq,3],Space(FwSizeFilial()))+RE0->RE0_NUM))
		While REO->( !EOF()) .And. REO->REO_FILIAL >= cFilDe .and. REO->REO_FILIAL <= cFilAte;
								.and. REO->REO_PRONUM == RE0->RE0_NUM

			//Colocada consistencia para filtro de datas das ocorrencias
		  	If lData
				If REO->REO_DATA < dDataDe .OR.	REO->REO_DATA > dDataAte
					REO->( dbskip())
					loop
				EndIf
			EndIf

			RECLOCK("TRB",.T.)
			TRB->TRB_FILIAL	:= 	REO->REO_FILIAL
			TRB->TRB_DATA	:=	REO->REO_DATA
			TRB->TRB_TPOCOR	:= 	REO->REO_TIPO
			TRB->TRB_EVENTO	:= 	Left(cOcorrLit,5)	//"Ocorr"
			TRB->TRB_DESCEV	:= 	fDesc("RE5","REO "+REO->REO_TIPO,"RE5_DESCR",,RE0->RE0_FILIAL)
			TRB->TRB_NUMPRO	:= 	RE0->RE0_NUM
			TRB->TRB_DSPROC	:= 	RE0->RE0_DESCR
			TRB->TRB_CRECLA	:= 	If(RE0->RE0_TPACAO#"1","",fDesc("REL",RE0->RE0_NUM,"REL_RECLAM",,RE0->RE0_FILIAL))
			TRB->TRB_NRECLA	:= 	If(RE0->RE0_TPACAO#"1",STR0028,fDesc("RD0",TRB->TRB_CRECLA,"RD0_NOME")) //"Diversos"
			TRB->TRB_CADVOG	:= 	REO->REO_CODADV
			TRB->TRB_NADVOG	:= 	fDesc("RD0",REO->REO_CODADV,"RD0_NOME")

			REO->( dbSkip() )
	    EndDo
	EndIf

  	//Audiencias
	If lAudienc
		nPosArq := aScan( aFilIni, { |Y| Y[1] == "REA" } )
		REA->(dbGoTop())
		REA->( dbSeek(If(aFilIni[nPosArq,2],aFilIni[nPosArq,3],Space(FwSizeFilial()))+ RE0->RE0_NUM ) )
		While REA->( !Eof()) .and. REA->REA_FILIAL >= cFilDe .and. REA->REA_FILIAL <= cFilAte;
								.and. REA->REA_PRONUM == RE0->RE0_NUM

			//Colocada consistencia para filtro de datas das audiencias
		  	If lData
				If REA->REA_DATA < dDataDe .OR.	REA->REA_DATA > dDataAte
					REA->( dbskip())
					loop
				EndIf
			EndIf

			RECLOCK("TRB",.T.)
			TRB->TRB_FILIAL	:= 	REA->REA_FILIAL
			TRB->TRB_DATA	:=	REA->REA_DATA
			TRB->TRB_TPOCOR := 	REA->REA_TIPO
			TRB->TRB_EVENTO	:= 	Left(cAudieLit,5)	//"Audie"
			TRB->TRB_DESCEV	:= 	fDesc("RE5","REA "+REA->REA_TIPO,"RE5_DESCR",,RE0->RE0_FILIAL)
			TRB->TRB_NUMPRO	:= 	RE0->RE0_NUM
			TRB->TRB_DSPROC	:= 	RE0->RE0_DESCR
			TRB->TRB_CRECLA	:= 	If(RE0->RE0_TPACAO#"1","",fDesc("REL",RE0->RE0_NUM,"REL_RECLAM",,RE0->RE0_FILIAL))
			TRB->TRB_NRECLA	:= 	If(RE0->RE0_TPACAO#"1",STR0028,fDesc("RD0",TRB->TRB_CRECLA,"RD0_NOME")) //"Diversos"
			TRB->TRB_CADVOG	:= 	REA->REA_ADRDAC
			TRB->TRB_NADVOG	:= 	fDesc("RD0",REA->REA_ADRDAC,"RD0_NOME")

			REA->( dbSkip() )
		EndDo
	EndIf

	//Sentenca
	If lSentenc
		nPosArq := aScan( aFilIni, { |Y| Y[1] == "RES" } )
		RES->(dbGoTop())
		RES->( dbSeek(If(aFilIni[nPosArq,2],aFilIni[nPosArq,3],Space(FwSizeFilial()))+ RE0->RE0_NUM ) )
		While RES->( !Eof()) .and. RES->RES_FILIAL >= cFilDe .and. RES->RES_FILIAL <= cFilAte;
								.and. RES->RES_PRONUM == RE0->RE0_NUM

			//Colocada consistencia para filtro de datas das sentencas
		  	If lData
				If RES->RES_JULGAM < dDataDe .OR.	RES->RES_JULGAM > dDataAte
					RES->( dbskip())
					loop
				EndIf
			EndIf

			RECLOCK("TRB",.T.)
			TRB->TRB_FILIAL	:= 	RES->RES_FILIAL
			TRB->TRB_DATA	:=	RES->RES_JULGAM
			TRB->TRB_TPOCOR := 	RES->RES_TIPO
			TRB->TRB_EVENTO	:= 	Left(cSenteLit,5)	//"Sente"
			TRB->TRB_DESCEV	:= 	fDesc("RE5","RES "+RES->RES_TIPO,"RE5_DESCR",,RE0->RE0_FILIAL)
			TRB->TRB_NUMPRO	:= 	RE0->RE0_NUM
			TRB->TRB_DSPROC	:= 	RE0->RE0_DESCR
			TRB->TRB_CRECLA	:= 	If(RE0->RE0_TPACAO#"1","",fDesc("REL",RE0->RE0_NUM,"REL_RECLAM",,RE0->RE0_FILIAL))
			TRB->TRB_NRECLA	:= 	If(RE0->RE0_TPACAO#"1",STR0028,fDesc("RD0",TRB->TRB_CRECLA,"RD0_NOME")) //"Diversos"
			TRB->TRB_CADVOG	:= 	""
			TRB->TRB_NADVOG	:= 	""

			RES->( dbSkip() )
		EndDo

	EndIf

	//Recurso
	If lRecurso
		nPosArq := aScan( aFilIni, { |Y| Y[1] == "REM" } )
		REM->(dbGoTop())
		REM->( dbSeek(If(aFilIni[nPosArq,2],aFilIni[nPosArq,3],Space(FwSizeFilial()))+ RE0->RE0_NUM ) )
		While REM->( !Eof()) .and. REM->REM_FILIAL >= cFilDe .and. REM->REM_FILIAL <= cFilAte;
								.and. REM->REM_PRONUM == RE0->RE0_NUM

			//Colocada consistencia para filtro de datas dos recursos
		  	If lData
				If REM->REM_DATA < dDataDe .OR.	REM->REM_DATA > dDataAte
					REM->( dbskip())
					loop
				EndIf
			EndIf

			RECLOCK("TRB",.T.)
			TRB->TRB_FILIAL	:= 	REM->REM_FILIAL
			TRB->TRB_DATA	:=	REM->REM_DATA
			TRB->TRB_TPOCOR := 	REM->REM_TIPO
			TRB->TRB_EVENTO	:= 	Left(cRecurLit,5)	//"Recur"
			TRB->TRB_DESCEV	:= 	fDesc("RE5","REM "+REM->REM_TIPO,"RE5_DESCR",,RE0->RE0_FILIAL)
			TRB->TRB_NUMPRO	:= 	RE0->RE0_NUM
			TRB->TRB_DSPROC	:= 	RE0->RE0_DESCR
			TRB->TRB_CRECLA	:= 	If(RE0->RE0_TPACAO#"1","",fDesc("REL",RE0->RE0_NUM,"REL_RECLAM",,RE0->RE0_FILIAL))
			TRB->TRB_NRECLA	:= 	If(RE0->RE0_TPACAO#"1",STR0028,fDesc("RD0",TRB->TRB_CRECLA,"RD0_NOME")) //"Diversos"
			TRB->TRB_CADVOG	:= 	""
			TRB->TRB_NADVOG	:= 	""

			REM->( dbSkip() )
		EndDo
	EndIf

	//Pericias
	If lPericia
		nPosArq := aScan( aFilIni, { |Y| Y[1] == "REH" } )
		REH->(dbGoTop())
		REH->( dbSeek(If(aFilIni[nPosArq,2],aFilIni[nPosArq,3],Space(FwSizeFilial()))+ RE0->RE0_NUM ) )
		While REH->( !Eof()) .and. REH->REH_FILIAL >= cFilDe .and. REH->REH_FILIAL <= cFilAte;
								.and. REH->REH_PRONUM == RE0->RE0_NUM

			//Colocada consistencia para filtro de datas das pericias
		  	If lData
				If REH->REH_DTPERI < dDataDe .OR.	REH->REH_DTPERI > dDataAte
					REH->( dbskip())
					loop
				EndIf
			EndIf

			RECLOCK("TRB",.T.)
			TRB->TRB_FILIAL	:= 	REH->REH_FILIAL
			TRB->TRB_DATA	:=	REH->REH_DTPERI
			TRB->TRB_TPOCOR := 	REH->REH_TIPO
			TRB->TRB_EVENTO	:= 	Left(cPericLit,5)	//"Per"
			TRB->TRB_DESCEV	:= 	fDesc("RE5","REH "+REH->REH_TIPO,"RE5_DESCR",,RE0->RE0_FILIAL)
			TRB->TRB_NUMPRO	:= 	RE0->RE0_NUM
			TRB->TRB_DSPROC	:= 	RE0->RE0_DESCR
			TRB->TRB_CRECLA	:= 	If(RE0->RE0_TPACAO#"1","",fDesc("REL",RE0->RE0_NUM,"REL_RECLAM",,RE0->RE0_FILIAL))
			TRB->TRB_NRECLA	:= 	If(RE0->RE0_TPACAO#"1",STR0028,fDesc("RD0",TRB->TRB_CRECLA,"RD0_NOME")) //"Diversos"
			TRB->TRB_CADVOG	:= 	""
			TRB->TRB_NADVOG	:= 	""

			REH->( dbSkip() )
		EndDo
	EndIf

	//Despesas
	If lDespesa
		nPosArq := aScan( aFilIni, { |Y| Y[1] == "RC1" } )
		RC1->( dbSetOrder(3) )
		RC1->(dbGoTop())
		RC1->( dbSeek(If(aFilIni[nPosArq,2],aFilIni[nPosArq,3],Space(FwSizeFilial()))+ RE0->RE0_NUM ) )
		While RC1->( !Eof()) .and. RC1->RC1_FILIAL >= cFilDe .and. RC1->RC1_FILIAL <= cFilAte;
								.and. RC1->RC1_PRONUM == RE0->RE0_NUM ;
								.and. RC1->RC1_CODTIT == "APT"

			//Colocada consistencia para filtro de datas das despesas
		  	If lData
				If RC1->RC1_VENCTO < dDataDe .OR.	RC1->RC1_VENCTO > dDataAte
					RC1->( dbskip())
					loop
				EndIf
			EndIf

			RECLOCK("TRB",.T.)
			TRB->TRB_FILIAL	:= 	RC1->RC1_FILIAL
			TRB->TRB_DATA	:=	RC1->RC1_VENCTO
			TRB->TRB_TPOCOR := 	RC1->RC1_TPDESP
			TRB->TRB_EVENTO	:= 	Left(cDespeLit,5)	//"Despe"
			TRB->TRB_DESCEV	:= 	fDesc("RE5","RC1 "+RC1->RC1_TPDESP,"RE5_DESCR",,RE0->RE0_FILIAL)
			TRB->TRB_NUMPRO	:= 	RE0->RE0_NUM
			TRB->TRB_DSPROC	:= 	RE0->RE0_DESCR
			TRB->TRB_CRECLA	:= 	If(RE0->RE0_TPACAO#"1","",fDesc("REL",RE0->RE0_NUM,"REL_RECLAM",,RE0->RE0_FILIAL))
			TRB->TRB_NRECLA	:= 	If(RE0->RE0_TPACAO#"1",STR0028,fDesc("RD0",TRB->TRB_CRECLA,"RD0_NOME")) //"Diversos"
			TRB->TRB_CADVOG	:= 	""
			TRB->TRB_NADVOG	:= 	""

			RC1->( dbSkip() )
		EndDo

	EndIf

	RE0->( dbSkip() )
EndDo
RC1->( dbSetOrder(1) )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณa010VerUsuบAutor  ณAndreia Santos      บ Data ณ  05/08/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Pesquisa usuario no arquivo de param. da rotina            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAAPT                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function a010VerUsu(nHandle,cLog,nOffSet)
Local lAchou := .F.

While fReadLn(nHandle,@cLog,100)
	nOffSet := fSeek(nHandle,0,1) // Retorna o offset atual (posicao do arquivo)
	If Left(cLog,20)==Pad(Left(cUserName,19),20)
		lAchou := .T.
		Exit
	Endif
EndDo

Return lAchou


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfEvento   บAutor  ณAndreia Santos      บ Data ณ  13/08/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                 	      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fEvento()

Local cTitulo	:=	""
Local MvParDef	:=	""
Local l1Elem 	:= .F.
Local MvPar		:= ""
Local oWnd
Local cTipoAu

Private aResul	:={}

oWnd := GetWndDefault()
MvPar	:=	&(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
mvRet	:=	Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno

cTitulo := STR0013 //"Eventos"

aResul  := {STR0029,STR0030,STR0031,STR0032,STR0033,STR0034} //"Ocorrencias"###"Audiencias"###"Sentenca"###"Recurso"###"Pericia"###"Despesa"

MvParDef	:=	"123456"

//f_Opcoes(@MvPar,cTitulo,aResul,MvParDef,12,49,l1Elem,,5)		// Chama funcao f_Opcoes
f_Opcoes(@MvPar,cTitulo,aResul,MvParDef,12,49,l1Elem,,6)		// Chama funcao f_Opcoes
&MvRet := mvpar 					   	// Devolve Resultado

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณGdRe0seek บAutor  ณTania Bronzeri      บ Data ณ 11/05/2006  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPesquisa tabela RE0 para apresentar detalhes do Processo    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ APTC010                                            	      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GdRe0Seek()

Local cRe0Chave	:=	xFilial("RE0")+GdFieldGet("TRB_NUMPRO",oGetDados:nAt,,oGetDados:aHeader,oGetDados:aCols)

dbSelectArea("REL")
dbSetOrder(1)

dbSelectArea("REH")
dbSetOrder(1)

dbSelectArea("RE4")
dbSetOrder(1)

dbSelectArea("REA")
dbSetOrder(1)

dbSelectArea("RE9")
dbSetOrder(1)

dbSelectArea("REO")
dbSetOrder(1)

dbSelectArea("RES")
dbSetOrder(1)

dbSelectArea("REP")
dbSetOrder(1)

dbSelectArea("REM")
dbSetOrder(1)

dbSelectArea("RC1")
dbSetOrder(3)

dbSelectArea("REG")
dbSetOrder(1)

dbSelectArea("RE0")
dbSetOrder(1)
dbGoTop()

If RE0->(DbSeek(cRe0Chave))
	MsAguarde( { || INCLUI := .F. , Apt100Rot( "RE0", Recno(), 2 ) }, OemToAnsi(STR0027), OemToAnsi(STR0037) )
	//"Aguarde" ### "Montando tela do Processo para Consulta."
EndIf

Return Nil
