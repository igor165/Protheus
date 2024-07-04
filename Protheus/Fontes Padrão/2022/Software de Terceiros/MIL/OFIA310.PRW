#INCLUDE "PROTHEUS.CH"
#Include "OFIXDEF.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OFIA310.CH"

Static lInconveniente := (GetNewPar("MV_INCORC","N") == "S")

/*/{Protheus.doc} OFIA310()
Oficina - Requisitar Peças de outras OSs - Rotina chamada pelo OFIOM020

@author Andre Luis Almeida
@since 30/03/2021
@return NIL
/*/
Function OFIA310( cOSDestino )
Private cCadastro  := STR0001 // Requisitar Peças de outras OSs
Default cOSDestino := ""

DbSelectArea("VO1")

If !Empty( cOSDestino )

	DbSetOrder(1)
	If DbSeek( xFilial("VO1") + cOSDestino )
		OA3100011_Requisitar_Pecas_de_outras_OSs() // Tela para Requisitar as Pecas
	EndIf

Else

	oBrwVO1 := FWMBrowse():New()
	oBrwVO1:SetAlias("VO1")
	oBrwVO1:SetDescription(STR0001) // Requisitar Peças de outras OSs
	oBrwVO1:SetFilterDefault( "@ VO1_STATUS='A'" ) // Ordens de Serviço com Status Em Aberto
	oBrwVO1:ForceQuitButton(.T.)
	oBrwVO1:DisableDetails()
	oBrwVO1:Activate()

EndIf

Return NIL

/*/{Protheus.doc} OA3100011_Requisitar_Pecas_de_outras_OSs
Monta tela para digitar as Pecas a serem transferidas de outras Ordens de servico
Atenção: VO1 da OS destino tem que estar posicionado

@author Andre
@since 30/03/2021
/*/
Function OA3100011_Requisitar_Pecas_de_outras_OSs()
Local aSizeAut   := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local aObjects   := {}
Local aInfo      := {}
Local aPosObj    := {}
Local aNewBot    := {}
Local aALLCampos := {}
Local aAltCampos := {}
Local nCntFor    := 0
Private aRotina  := MenuDef()
Private aHeader  := {} , aCols := {}
Private cReqDev  := "1" // Requisicao
Private N        := 1
Private nUsado   := 0
Private lOM020Auto := .t. // Necessario para utilizar as funções de validações do OFIOM020 - Compatibilidade com OFIOM020
Private cTpTpoPEVM := space(GetSX3Cache("VO3_TIPTEM","X3_TAMANHO")) // Tipo de Tempo Pecas - Compatibilidade com OFIOM020
Private cProdPEVM  := space(GetSX3Cache("VO3_PROREQ","X3_TAMANHO")) // Codigo do Produtivo - Compatibilidade com OFIOM020
Private OFP8600016 := ExistFunc("OFP8600016_VerificacaoFormula") // Compatibilidade com OFIOM020

If VO1->VO1_STATUS <> "A"
	MsgStop(STR0003,STR0002) // Ordem de Serviço com Status diferente de Em Aberto. Impossivel continuar. / Atenção
	Return
EndIf

If lInconveniente
	aALLCampos := { "VO3_GRUINC" , "VO3_CODINC" , "VO3_DESINC" , "VO3_SEQINC" , "VO3_TIPTEM" , "VO3_FATPAR" , "VO3_LOJA" , "VO3_NOMCLI" , "VO3_GRUITE" , "VO3_CODITE", "VO3_DESITE" , "VO3_QTDREQ" , "VO3_NUMOSV" , "VO3_QTDEST" , "VO3_OPER" , "VO3_CODTES" , "VO3_PROREQ" , "VO3_DEPINT" , "VO3_DEPGAR" , "VO3_IMPORC" }
Else
	aALLCampos := { "VO3_TIPTEM" , "VO3_FATPAR" , "VO3_LOJA" , "VO3_NOMCLI" , "VO3_GRUITE" , "VO3_CODITE", "VO3_DESITE" , "VO3_QTDREQ" , "VO3_NUMOSV" , "VO3_QTDEST" , "VO3_OPER" , "VO3_CODTES" , "VO3_PROREQ" , "VO3_DEPINT" , "VO3_DEPGAR" , "VO3_IMPORC" }
EndIf
aAltCampos := { "VO3_TIPTEM" , "VO3_GRUITE" , "VO3_CODITE" , "VO3_QTDREQ" , "VO3_PROREQ" , "VO3_CODTES" , "VO3_OPER" , "VO3_DEPINT" , "VO3_DEPGAR" }

aAdd(aNewBot,{"HISTORIC"  ,{|| OA3100071_Selecione_OS_Origem_F4() }, "<F4> "+STR0004 }) // Selecionar a Ordem de Serviço e Tipo de Tempo de Origem
aAdd(aNewBot,{"PARAMETROS",{|| OA3100141_Inserir_Pecas_de_outra_OS_F5() }, "<F5> "+STR0005 }) // Inserir Peças de outra OS
aAdd(aNewBot,{"ANALITICO" ,{|| OA3100151_Visualiza_OS_Destino_F6() }, "<F6> "+STR0006 }) // Visualiza OS Destino

// Configura os tamanhos dos objetos
AAdd( aObjects, { 315, 70 , .T., .F. } ) // EnchoiceBar
AAdd( aObjects, { 315, 100, .T., .T. } ) // GetDados Pecas
aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects, .t.)

nOpc   := 3
INCLUI := .t.
ALTERA := .f.
OA3100061_HeaderCols(aALLCampos) // Cria aHeader e aCols em branco
For nCntFor := 1 to Len(aHeader)
	&( "M->"+aHeader[nCntFor,2] ) := aCols[1,nCntFor] // M->VO3_... usado nas validações do OFIOM020
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("VO1",.f.)

OA3100091_TeclasF("F4",.t.)
OA3100091_TeclasF("F5",.t.)
OA3100091_TeclasF("F6_OS_Destino",.t.)

DEFINE MSDIALOG oOFIA310 FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE STR0001 OF oMainWnd PIXEL // Requisitar Peças de outras OSs

oGetMGet:= MsMGet():New("VO1",VO1->(RecNo()), 2,,,, {/*aCpoEnchoice*/}, aPosObj[1],, 3,,, oOFIA310,,, .T., .F.,)

oFolderReq := TFolder():New(aPosObj[2,1], aPosObj[2,2],       ;
	{STR0007},; // Informe as Pecas a serem Requisitadas na Ordem de Serviço
	{STR0007},; // Informe as Pecas a serem Requisitadas na Ordem de Serviço
	oOFIA310,,,, .t.,, aPosObj[2,4], aPosObj[2,3] - aPosObj[2,1])

oGetOA310 := MsNewGetDados():New( 0,0,300,300,;
			3,; // Operacao - 2 Visualizar / 3 Incluir / 4 Alterar / 5 Excluir
			"OA3100031_LinhaOK()",;
			"OA3100041_TudoOK()",;
			,;		// Nome dos campos do tipo caracter que utilizacao incremento automatico
			aAltCampos ,; 	// Campos alteraveis da GetDados
			/*nFreeze*/,;	// Campos estaticos da GetDados
			999,;
			"OA3100171_ValidCposVO3()",;
			/*cSuperDel*/,; 	// Funcao executada quando pressionado <Ctrl>+<Del>
			/*cDelOk*/ ,; 		// Funcao executada para validar a exclusao de uma linha
			oFolderReq:aDialogs[1],;
			aHeader,;
			aCols)
oGetOA310:oBrowse:Align   := CONTROL_ALIGN_ALLCLIENT
oGetOA310:oBrowse:bChange := {|| OA3100051_ChangeLinha() }
oGetOA310:oBrowse:bDelete := {|| OA3100111_DeletaLinha() }

ACTIVATE MSDIALOG oOFIA310 ON INIT EnchoiceBar(oOFIA310,{|| Processa( {|| IIf(OA3100131_Executa_Dev_e_Req(),oOFIA310:End(),.t.) } , STR0008 , "", .T.) },{|| oOFIA310:End() },,aNewBot) // Processando

OA3100091_TeclasF("F4",.f.)
OA3100091_TeclasF("F5",.f.)
OA3100091_TeclasF("F6_OS_Destino",.f.)

Return

/*/{Protheus.doc} OA3100021_ValidQTD
Validacao da Qtde digitada que será transferida de uma OS para outra

@author Andre
@since 31/03/2021
/*/
Function OA3100021_ValidQTD()
Local lRet     := .t.
Local aOSsIte  := {}
Local cFiltAux := ""
Do Case
	Case M->VO3_QTDREQ < 0
		lRet := .f.
	Case M->VO3_QTDREQ == 0
		OA3100121_Relaciona_OS_Origem_na_aCols( oGetOA310:nAt , "" , 0 ) // Limpar relacionamento de Origem
 	Case M->VO3_QTDREQ > 0
		If !Empty(oGetOA310:aCols[oGetOA310:nAt,FG_POSVAR("VO3_NUMOSV","aHeader")])
			cFiltAux := " AND VO3.VO3_NUMOSV = '"+left(oGetOA310:aCols[oGetOA310:nAt,FG_POSVAR("VO3_NUMOSV","aHeader")],GetSX3Cache("VO3_NUMOSV","X3_TAMANHO"))+"'"
			cFiltAux += " AND VO3.VO3_TIPTEM = '"+right(oGetOA310:aCols[oGetOA310:nAt,FG_POSVAR("VO3_NUMOSV","aHeader")],GetSX3Cache("VO3_TIPTEM","X3_TAMANHO"))+"'"
			aOSsIte := OA3100081_SaldoVO3(	oGetOA310:aCols[oGetOA310:nAt,FG_POSVAR("VO3_GRUITE","aHeader")],;
											oGetOA310:aCols[oGetOA310:nAt,FG_POSVAR("VO3_CODITE","aHeader")],;
											0,;
											"",;
											cFiltAux)
			If len(aOSsIte) > 0
				OA3100121_Relaciona_OS_Origem_na_aCols( oGetOA310:nAt , aOSsIte[1,2]+"-"+aOSsIte[1,5] , aOSsIte[1,6] )
				If aOSsIte[1,6] < M->VO3_QTDREQ
					If MsgYesNo(STR0009,STR0002) // Quantidade digitada é maior que a contida na OS de Origem. Deseja retirar o relacionamento com a OS de Origem? / Atencao
						OA3100121_Relaciona_OS_Origem_na_aCols( oGetOA310:nAt , "" , 0 ) // Limpar relacionamento de Origem
					Else
						lRet := .f.
					EndIf
				EndIf
			Else
				MsgStop(STR0010,STR0002) // OS de Origem não possui saldo. Será retirado o relacionamento. / Atencao
				OA3100121_Relaciona_OS_Origem_na_aCols( oGetOA310:nAt , "" , 0 ) // Limpar relacionamento de Origem
			EndIf
		EndIf
EndCase
Return lRet

/*/{Protheus.doc} OA3100031_LinhaOK
Linha OK -> aCols do VO3

@author Andre
@since 31/03/2021
/*/
Function OA3100031_LinhaOK(nLinha,lBlqProc)
Local lRet     := .t.
Local cMsg     := ""
Local cTipTem  := ""
Local cGruIte  := ""
Local cCodIte  := ""
Local nQtdIte  := 0
Local cOSTTpo  := ""
Local cOpeTES  := ""
Local cCodTES  := ""
Local cProReq  := ""
Local nTamOSV  := GetSX3Cache("VO3_NUMOSV","X3_TAMANHO")
Local nTamTTp  := GetSX3Cache("VO3_TIPTEM","X3_TAMANHO")
Default nLinha := oGetOA310:nAt // Linha a validar
Default lBlqProc := .f. // Bloqueia processo na Validação ?
//
If oGetOA310:aCols[nLinha,len(oGetOA310:aCols[nLinha])] // Linha deletada - NAO validar
	Return .t.
EndIf
//
cTipTem := oGetOA310:aCols[nLinha,FG_POSVAR("VO3_TIPTEM","aHeader")]
cGruIte := oGetOA310:aCols[nLinha,FG_POSVAR("VO3_GRUITE","aHeader")]
cCodIte := oGetOA310:aCols[nLinha,FG_POSVAR("VO3_CODITE","aHeader")]
nQtdIte := oGetOA310:aCols[nLinha,FG_POSVAR("VO3_QTDREQ","aHeader")]
cOSTTpo := oGetOA310:aCols[nLinha,FG_POSVAR("VO3_NUMOSV","aHeader")]
cOpeTES := oGetOA310:aCols[nLinha,FG_POSVAR("VO3_OPER"  ,"aHeader")]
cCodTES := oGetOA310:aCols[nLinha,FG_POSVAR("VO3_CODTES","aHeader")]
cProReq := oGetOA310:aCols[nLinha,FG_POSVAR("VO3_PROREQ","aHeader")]
//
If Empty(cTipTem) .or. Empty(cGruIte) .or. Empty(cCodIte) .or. nQtdIte<=0 .or. Empty(cOSTTpo) .or. Empty(cOpeTES+cCodTES) .or. Empty(cProReq)
	//
	cMsg := STR0011+": "+Alltrim(str(nLinha))+CHR(13)+CHR(10)+CHR(13)+CHR(10) // Linha
	//
	cMsg += GetSX3Cache("VO3_TIPTEM","X3_TITULO")+": "+IIf(!Empty(cTipTem),cTipTem,"--> "+STR0012)+CHR(13)+CHR(10) // inválido
	cMsg += GetSX3Cache("VO3_GRUITE","X3_TITULO")+": "+IIf(!Empty(cGruIte),cGruIte,"--> "+STR0012)+CHR(13)+CHR(10) // inválido
	cMsg += GetSX3Cache("VO3_CODITE","X3_TITULO")+": "+IIf(!Empty(cCodIte),cCodIte,"--> "+STR0012)+CHR(13)+CHR(10) // inválido
	cMsg += STR0013+": "+IIf(nQtdIte>0,Alltrim(str(nQtdIte)),"--> "+STR0012)+CHR(13)+CHR(10) // Qtd.Transf. / inválido
	cMsg += STR0014+": "+IIf(!Empty(cOSTTpo),cOSTTpo,"--> "+STR0012)+CHR(13)+CHR(10) // OS/Tp.Tempo Origem / inválido
	cMsg += GetSX3Cache("VO3_CODTES","X3_TITULO")+": "+IIf(!Empty(cCodTES+cOpeTES),cCodTES+" "+cOpeTES,"--> "+STR0012)+CHR(13)+CHR(10) // inválido
	cMsg += GetSX3Cache("VO3_PROREQ","X3_TITULO")+": "+IIf(!Empty(cProReq),cProReq,"--> "+STR0012)+CHR(13)+CHR(10) // inválido
	//
	Aviso(STR0015,cMsg,{STR0018},3) // Necessário informar corretamente os campos / OK
	//
	If lBlqProc // Bloqueia processo na Validação ?
		lRet := .f.
	EndIf
	//
EndIf
//
// Verificar Atendimento Externo
If lRet .and. !Empty(cTipTem) .and. !Empty(cGruIte) .and. !Empty(cCodIte)
	// OS e Tipo de Tempo de Destino
	lRet := OA3100161_Validar_Atendimento_Externo( 0 , VO1->VO1_NUMOSV , cTipTem , cGruIte , cCodIte )
	If lRet .and. !Empty(cOSTTpo)
		// OS e Tipo de Tempo de Origem
		lRet := OA3100161_Validar_Atendimento_Externo( nLinha , left(cOSTTpo,nTamOSV) , right(cOSTTpo,nTamTTp) , cGruIte , cCodIte )
	EndIf
EndIf
//
Return lRet

/*/{Protheus.doc} OA3100041_TudoOK
Tudo OK -> aCols do VO3

@author Andre
@since 31/03/2021
/*/
Function OA3100041_TudoOK()
Local lRet    := .t.
Local nCntFor := 0
Local nPosOut := 0
Local aAux    := aClone(oGetOA310:aCols)
Local nPosGrp := FG_POSVAR("VO3_GRUITE","aHeader")
Local nPosCod := FG_POSVAR("VO3_CODITE","aHeader")
Local nPosOSV := FG_POSVAR("VO3_NUMOSV","aHeader")
Local cCompar := "INICIAL"
Local cMsg    := ""
// Verificar o preenchimento dos campos nas linhas
For nCntFor := 1 to len(oGetOA310:aCols)
	lRet := OA3100031_LinhaOK(nCntFor,.t.)
	If !lRet
		Exit
	EndIf
Next
// Verificar duplicidade de Item e OS origem
Asort(aAux,1,,{ |x,y| x[nPosGrp]+x[nPosCod]+x[nPosOSV] < y[nPosGrp]+y[nPosCod]+y[nPosOSV] })
For nCntFor := 1 to len(aAux)
	If !aAux[nCntFor,len(aAux[nCntFor])] // Verificar somente nao deletado
		If cCompar <> ("["+aAux[nCntFor,nPosGrp]+"|"+aAux[nCntFor,nPosCod]+"|"+aAux[nCntFor,nPosOSV]+"]")
			cCompar := ("["+aAux[nCntFor,nPosGrp]+"|"+aAux[nCntFor,nPosCod]+"|"+aAux[nCntFor,nPosOSV]+"]")
		Else
			cMsg := STR0016+": "+CHR(13)+CHR(10)+CHR(13)+CHR(10) // Item e OS de Origem duplicados
			cMsg += GetSX3Cache("VO3_GRUITE","X3_TITULO")+": "+aAux[nCntFor,nPosGrp]+CHR(13)+CHR(10)
			cMsg += GetSX3Cache("VO3_CODITE","X3_TITULO")+": "+aAux[nCntFor,nPosCod]+CHR(13)+CHR(10)
			cMsg += STR0014+": "+aAux[nCntFor,nPosOSV]+CHR(13)+CHR(10) // OS/Tp.Tempo Origem
			Aviso(STR0017,cMsg,{STR0018},3) // Impossivel continuar / OK
			lRet := .f.
			Exit
		EndIf
	EndIf
Next
Return lRet

/*/{Protheus.doc} OA3100051_ChangeLinha
Change da linha na aCols do VO3

@author Andre
@since 31/03/2021
/*/
Static Function OA3100051_ChangeLinha()
Local nCntFor := 0
If n > Len(oGetOA310:aCols)
	aAdd(oGetOA310:aCols,Array(nUsado+1))
	oGetOA310:nAt := Len(oGetOA310:aCols)
	For nCntFor := 1 to Len(aHeader)
		oGetOA310:aCols[oGetOA310:nAt,nCntFor] := &(aHeader[nCntFor,12])
	Next
	oGetOA310:aCols[oGetOA310:nAt,nUsado+1] := .F.
	oGetOA310:Refresh()
Endif
For nCntFor := 1 to len(aHeader)
	&( "M->"+aHeader[nCntFor,2] ) := oGetOA310:aCols[oGetOA310:nAt,nCntFor]
Next
If !Empty(M->VO3_TIPTEM)
	VOI->(DbSetOrder(1))
	VOI->(DbSeek(xFilial("VOI")+M->VO3_TIPTEM)) // Utilizado no SX3 (WHEN) dos campos de Departamentos
EndIf
Return .t.

/*/{Protheus.doc} OA3100061_HeaderCols
Monta aHeader e aCols em branco - VO3

@author Andre
@since 31/03/2021
/*/
Static Function OA3100061_HeaderCols(aALLCampos)
Local nCntFor    := 0
Local cTitulSX3  := ""
Local cRelacSX3  := ""
Local cTipSX3    := ""
Local nTamSX3    := 0
nUsado := 0
For nCntFor := 1 to len(aALLCampos)
	cTitulSX3 := GetSX3Cache(aALLCampos[nCntFor],"X3_TITULO")
	nTamSX3   := GetSX3Cache(aALLCampos[nCntFor],"X3_TAMANHO")
	cTipSX3   := GetSX3Cache(aALLCampos[nCntFor],"X3_TIPO")
	Do Case
		Case aALLCampos[nCntFor] == "VO3_QTDREQ"
			cTitulSX3 := STR0019 // Qtd.Transferir
		Case aALLCampos[nCntFor] == "VO3_QTDEST"
			cTitulSX3 := STR0020 // Qtd.Disp.OS/Tp.Tempo Origem
		Case aALLCampos[nCntFor] == "VO3_NUMOSV"
			cTitulSX3 := STR0014 // OS/Tp.Tempo Origem
			nTamSX3   := 20
	EndCase
	Do Case
		Case cTipSX3 == "N"
			cRelacSX3 := "0"
		Otherwise
			cRelacSX3 := "space("+Alltrim(str(nTamSX3))+")"
	EndCase
	nUsado++
	Aadd(aHeader,{	cTitulSX3,;
					aALLCampos[nCntFor],;
					GetSX3Cache(aALLCampos[nCntFor],"X3_PICTURE"),;
					nTamSX3,;
					GetSX3Cache(aALLCampos[nCntFor],"X3_DECIMAL"),;
					GetSX3Cache(aALLCampos[nCntFor],"X3_VALID"),;
					GetSX3Cache(aALLCampos[nCntFor],"X3_USADO"),;
					cTipSX3,;
					GetSX3Cache(aALLCampos[nCntFor],"X3_F3"),;
					GetSX3Cache(aALLCampos[nCntFor],"X3_CONTEXT"),;
					GetSX3Cache(aALLCampos[nCntFor],"X3_CBOX") ,;
					cRelacSX3})
Next
aCols := {Array(nUsado+1)}
For nCntFor := 1 to Len(aHeader)
	aCols[1,nCntFor] := &(aHeader[nCntFor,12])
Next
aCols[1,nUsado+1] := .F.
Return

/*/{Protheus.doc} OA3100071_Selecione_OS_Origem_F4
Seleciona a OS e Tipo de Tempo de Origem para fazer a Devolução das Peças

@author Andre
@since 31/03/2021
/*/
Function OA3100071_Selecione_OS_Origem_F4()
Local aSizeAut := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nPosVet  := 0
Local aAreaVO1 := VO1->(GetArea()) // Salvar Area VO1
Local cGruIte  := oGetOA310:aCols[oGetOA310:nAt,FG_POSVAR("VO3_GRUITE","aHeader")]
Local cCodIte  := oGetOA310:aCols[oGetOA310:nAt,FG_POSVAR("VO3_CODITE","aHeader")]
Local nQtdIte  := oGetOA310:aCols[oGetOA310:nAt,FG_POSVAR("VO3_QTDREQ","aHeader")]
Local cOSJaSel := oGetOA310:aCols[oGetOA310:nAt,FG_POSVAR("VO3_NUMOSV","aHeader")]
Local oOkTik   := LoadBitmap( GetResources() , "LBTIK" )
Local oNoTik   := LoadBitmap( GetResources() , "LBNO" )
Local lOkTela  := .f.
Local cFiltAux := ""
Local aNewBot  := { {"ANALITICO",    {|| OA3100101_Visualiza_OS_Origem_F6() }, "<F6> "+STR0021 } } // Visualiza OS Origem
Private aOSsIte   := {}
Private cCadastro := STR0004 // Selecionar a Ordem de Serviço e Tipo de Tempo de Origem
//
If oGetOA310:aCols[oGetOA310:nAt,len(oGetOA310:aCols[oGetOA310:nAt])] // Linha deletada - NAO deixar
	Return
EndIf
If Empty(cGruIte) .or. Empty(cCodIte)
	MsgStop(STR0022,STR0002) // Necessário informar o Grupo e Código da Peça para selecionar a Ordem de Serviço e Tipo de Tempo de Origem. / Atenção
	OA3100121_Relaciona_OS_Origem_na_aCols( oGetOA310:nAt , "" , 0 ) // Limpar relacionamento de Origem
	Return
EndIf
cFiltAux := " AND VO3.VO3_NUMOSV <> '"+VO1->VO1_NUMOSV+"'" // Desconsiderar a OS Destino
aOSsIte := OA3100081_SaldoVO3(cGruIte,cCodIte,nQtdIte,cOSJaSel,cFiltAux)
OA3100091_TeclasF("F4",.f.)
OA3100091_TeclasF("F5",.f.)
OA3100091_TeclasF("F6_OS_Destino",.f.)
If len(aOSsIte) > 0
	OA3100091_TeclasF("F6_OS_Origem",.t.)
	DEFINE MSDIALOG oSelOSOrig FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE STR0004 OF oMainWnd PIXEL // Selecionar a Ordem de Serviço e Tipo de Tempo de Origem
		oLbItensOS := TWBrowse():New(1,1,100,100,,,,oSelOSOrig,,,,,{ || IIf( aOSsIte[oLbItensOS:nAt,1] , aOSsIte[oLbItensOS:nAt,1] := .f. , ( aEval( aOSsIte , { |x| x[1] := .f. } ) , aOSsIte[oLbItensOS:nAt,1] := .t. , oLbItensOS:Refresh() ) ) },,,,,,,.F.,,.T.,,.F.,,,)
		oLbItensOS:AddColumn( TCColumn():New( "", { || IIf(aOSsIte[oLbItensOS:nAt,1],oOkTik,oNoTik) } ,,,,"LEFT" ,05,.T.,.F.,,,,.F.,) ) // Tik
		oLbItensOS:AddColumn( TCColumn():New( STR0023 , { || aOSsIte[oLbItensOS:nAt,2] } ,,,,"LEFT" ,45,.F.,.F.,,,,.F.,) ) // OS
		oLbItensOS:AddColumn( TCColumn():New( STR0024 , { || Transform(stod(aOSsIte[oLbItensOS:nAt,3]),"@D") } ,,,,"LEFT" ,40,.F.,.F.,,,,.F.,) ) // Data
		oLbItensOS:AddColumn( TCColumn():New( STR0025 , { || Transform(aOSsIte[oLbItensOS:nAt,4],"@R 99:99") } ,,,,"RIGHT" ,35,.F.,.F.,,,,.F.,) ) // Hora
		oLbItensOS:AddColumn( TCColumn():New( STR0026 , { || aOSsIte[oLbItensOS:nAt,5] } ,,,,"LEFT" ,40,.F.,.F.,,,,.F.,) ) // Tp.Tempo
		oLbItensOS:AddColumn( TCColumn():New( STR0027 , { || Transform(aOSsIte[oLbItensOS:nAt,6],GetSX3Cache("VO3_QTDREQ","X3_PICTURE")) } ,,,,"RIGHT" ,60,.F.,.F.,,,,.F.,) ) // Qtde na OS / Tipo de Tempo
		oLbItensOS:setArray( aOSsIte )
		oLbItensOS:Align := CONTROL_ALIGN_ALLCLIENT
	ACTIVATE MSDIALOG oSelOSOrig ON INIT EnchoiceBar(oSelOSOrig,{|| lOkTela := .t. , oSelOSOrig:End() },{|| oSelOSOrig:End() },,aNewBot)
	OA3100091_TeclasF("F6_OS_Origem",.f.)
	If lOkTela
		nPosVet := aScan(aOSsIte, {|x| x[1] })
		If nPosVet > 0
			OA3100121_Relaciona_OS_Origem_na_aCols( oGetOA310:nAt , aOSsIte[nPosVet,2]+"-"+aOSsIte[nPosVet,5] , aOSsIte[nPosVet,6] )
			If nQtdIte == 0
				oGetOA310:aCols[oGetOA310:nAt,FG_POSVAR("VO3_QTDREQ","aHeader")] := aOSsIte[nPosVet,6] // Preencher com o Saldo da OS / Tipo de Tempo Origem
			EndIf
		Else
			OA3100121_Relaciona_OS_Origem_na_aCols( oGetOA310:nAt , "" , 0 ) // Limpar relacionamento de Origem
		EndIf
	EndIf
Else
	MsgStop(STR0028+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
	cGruIte+" "+cCodIte+IIf(nQtdIte>0," ( "+STR0029+": "+Alltrim(str(nQtdIte))+" )",""),;
	STR0002) // Nenhuma Ordem de Serviço encontrada com o Status Em Aberto para este Item/Quantidade. / Quantidade Minima / Atenção
EndIf
OA3100091_TeclasF("F4",.t.)
OA3100091_TeclasF("F5",.t.)
OA3100091_TeclasF("F6_OS_Destino",.t.)
RestArea(aAreaVO1) // Voltar Area VO1
RegToMemory("VO1",.f.)
Return

/*/{Protheus.doc} OA3100081_SaldoVO3
Retorna vetor com Saldo do Item VO3 - separado por OS e Tipo de Tempo

@author Andre
@since 01/04/2021
/*/
Static Function OA3100081_SaldoVO3(cGruIte,cCodIte,nQtdIte,cOSJaSel,cFiltAux)
Local aVetRet := {}
Local cQuery  := ""
Local cQAlVO3 := "SQLVO3"
//
cQuery := "SELECT VO3.VO3_NUMOSV , VO1.VO1_DATABE , VO1.VO1_HORABE , VO3.VO3_TIPTEM , VO3.VO3_GRUITE , VO3.VO3_CODITE , "
cQuery += " SUM(CASE VO2_DEVOLU WHEN '1' THEN VO3_QTDREQ ELSE VO3_QTDREQ * -1 END) VO3_QTDREQ "
cQuery += "  FROM " + RetSQLName("VO3") + " VO3 "
cQuery += "  JOIN " + RetSQLName("VO2") + " VO2 ON VO2.VO2_FILIAL = '" + xFilial("VO2") + "' AND VO3.VO3_NOSNUM = VO2.VO2_NOSNUM AND VO3.VO3_NUMOSV = VO2.VO2_NUMOSV AND VO2.VO2_TIPREQ = 'P' AND VO2.D_E_L_E_T_ = ' '"
cQuery += "  JOIN " + RetSQLName("VO1") + " VO1 ON VO1.VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1.VO1_NUMOSV = VO3.VO3_NUMOSV AND VO1.VO1_STATUS = 'A' AND VO1.D_E_L_E_T_ = ' ' "
cQuery += "  JOIN " + RetSQLName("SF4") + " SF4 ON  SF4.F4_FILIAL = '" + xFilial("SF4") + "' AND SF4.F4_CODIGO  = VO3.VO3_CODTES AND SF4.F4_ESTOQUE = 'S' AND SF4.D_E_L_E_T_ = ' ' "
cQuery += " WHERE VO3.VO3_FILIAL = '"+xFilial("VO3")+"'"
If !Empty(cGruIte)
	cQuery += "   AND VO3.VO3_GRUITE = '" + cGruIte + "'"
EndIf
If !Empty(cCodIte)
	cQuery += "   AND VO3.VO3_CODITE = '" + cCodIte + "'"
EndIf
cQuery += "   AND VO3.VO3_DATDIS = ' '"
cQuery += "   AND VO3.VO3_DATFEC = ' '"
cQuery += "   AND VO3.VO3_DATCAN = ' '"
If !Empty(cFiltAux)
	cQuery += cFiltAux // Filtro Auxiliar do SQL
EndIf
cQuery += "   AND VO3.D_E_L_E_T_ = ' ' "
// Desconsiderar Atendimento Externo
cQuery += "   AND NOT EXISTS "
cQuery += "     ( SELECT VDR.VDR_NUMOSV "
cQuery += "         FROM " + RetSQLName("VDR")+" VDR "
cQuery += "        WHERE VDR.VDR_FILIAL = '" + xFilial("VDR") + "'"
cQuery += "          AND VDR.VDR_NUMOSV = VO3.VO3_NUMOSV "
cQuery += "          AND VDR.VDR_TIPTEM = VO3.VO3_TIPTEM "
cQuery += "          AND VDR.VDR_GRUITE = VO3.VO3_GRUITE "
cQuery += "          AND VDR.VDR_CODITE = VO3.VO3_CODITE "
cQuery += "          AND VDR.VDR_NFENUM = '         '" // Somente notas que nao foram devolvidas
cQuery += "          AND VDR.D_E_L_E_T_ = ' '"
cQuery += "     ) "
cQuery += " GROUP BY VO3.VO3_NUMOSV , VO1.VO1_DATABE , VO1.VO1_HORABE , VO3.VO3_TIPTEM , VO3.VO3_GRUITE , VO3.VO3_CODITE "
cQuery += "HAVING SUM(CASE VO2_DEVOLU WHEN '1' THEN VO3_QTDREQ ELSE VO3_QTDREQ * -1 END) " 
If nQtdIte == 0 // Se o usuario não preencheu qtde
	cQuery += " > 0 " // traz todos os registros que possuem QTDREQ > 0
Else // > 0 // Se o usuario preencheu qtde
	cQuery += " >= "+alltrim(str(nQtdIte)) // traz somente os registros que possuem QTDREQ suficiente
EndIf
cQuery += " ORDER BY VO1.VO1_DATABE , VO1.VO1_HORABE , VO3.VO3_TIPTEM"
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cQAlVO3, .T., .T. )
Do While !( cQAlVO3 )->( Eof() )
	aAdd(aVetRet,{ 	(cOSJaSel==( cQAlVO3 )->( VO3_NUMOSV )+"-"+( cQALVO3 )->( VO3_TIPTEM )) ,;
					( cQAlVO3 )->( VO3_NUMOSV ) ,;
					( cQAlVO3 )->( VO1_DATABE ) ,;
					( cQAlVO3 )->( VO1_HORABE ) ,;
					( cQALVO3 )->( VO3_TIPTEM ) ,;
					( cQAlVO3 )->( VO3_QTDREQ ) ,;
					( cQAlVO3 )->( VO3_GRUITE ) ,;
					( cQAlVO3 )->( VO3_CODITE ) })
	( cQAlVO3 )->(DbSkip())
EndDo
( cQAlVO3 )->(dbCloseArea())
DbSelectArea("VO1")
Return aClone(aVetRet)

/*/{Protheus.doc} OA3100091_TeclasF
Habilita / Desabilita Teclas F4/F5/F6

@author Andre
@since 01/04/2021
/*/
Static Function OA3100091_TeclasF(cTecla,lHabilita)
If lHabilita
	Do Case
		Case cTecla == "F4" // Selecionar OS e Tipo de Tempo de Origem
			SetKey(VK_F4,{|| OA3100071_Selecione_OS_Origem_F4() })
		Case cTecla == "F5" // Inserir Pecas de outra OS
			SetKey(VK_F5,{|| OA3100141_Inserir_Pecas_de_outra_OS_F5() })
		Case cTecla == "F6_OS_Destino" // Visualizar OS de Destino (Posicionada no Browse)
			SetKey(VK_F6,{|| OA3100151_Visualiza_OS_Destino_F6() })
		Case cTecla == "F6_OS_Origem" // Visualizar OS de Origem
			SetKey(VK_F6,{|| OA3100101_Visualiza_OS_Origem_F6() })
	EndCase
Else
	Do Case
		Case cTecla == "F4"
			SetKey(VK_F4, Nil )
		Case cTecla == "F5"
			SetKey(VK_F5, Nil )
		Case cTecla == "F6_OS_Destino"
			SetKey(VK_F6, Nil )
		Case cTecla == "F6_OS_Origem"
			SetKey(VK_F6, Nil )
	EndCase
EndIf
Return

/*/{Protheus.doc} OA3100101_Visualiza_OS_Origem_F6
Visualiza a OS de Origem pelo F6

@author Andre
@since 01/04/2021
/*/
Static Function OA3100101_Visualiza_OS_Origem_F6()
DbSelectArea("VO1")
DbSetOrder(1)
If DbSeek(xFilial("VO1")+aOSsIte[oLbItensOS:nAt,2])
	OA3100091_TeclasF("F6_OS_Origem",.f.)
	OA3100191_Visualizar_OS() // Chamada do OFIOC060 - Consulta de OS
	OA3100091_TeclasF("F6_OS_Origem",.t.)
EndIf
Return

/*/{Protheus.doc} OA3100111_DeletaLinha
Delele linha da aCols VO3

@author Andre
@since 01/04/2021
/*/
Function OA3100111_DeletaLinha()
If !oGetOA310:aCols[oGetOA310:nAt,len(oGetOA310:aCols[oGetOA310:nAt])]
	OA3100121_Relaciona_OS_Origem_na_aCols( oGetOA310:nAt , "" , 0 ) // Limpar relacionamento de Origem
EndIf
oGetOA310:aCols[oGetOA310:nAt,len(oGetOA310:aCols[oGetOA310:nAt])] := !oGetOA310:aCols[oGetOA310:nAt,len(oGetOA310:aCols[oGetOA310:nAt])]
oGetOA310:Refresh()
Return

/*/{Protheus.doc} OA3100121_Relaciona_OS_Origem_na_aCols
Relaciona/atribui a OS + Tipo de Tempo de Origem na aCols de Pecas - VO3 

@author Andre
@since 01/04/2021
/*/
Function OA3100121_Relaciona_OS_Origem_na_aCols( nLinha , cOSTpTpo , nQtdSaldo )
	oGetOA310:aCols[nLinha,FG_POSVAR("VO3_NUMOSV","aHeader")] := cOSTpTpo  // Nro.OS + Tipo de Tempo
	oGetOA310:aCols[nLinha,FG_POSVAR("VO3_QTDEST","aHeader")] := nQtdSaldo // Qtde.Saldo
Return

/*/{Protheus.doc} OA3100131_Executa_Dev_e_Req
Executa via execauto a Devolucao das Peças na OS de Origem e Requista as mesmas Peças na OS de Destino

@author Andre
@since 05/04/2021
/*/
Function OA3100131_Executa_Dev_e_Req()
Local aAreaVO1   := VO1->(GetArea()) // Salvar Area VO1
Local nCntFor    := 0
Local nCntPec    := 0
Local aPeca      := {}
Local aIteVO3    := {}
Local aAuxIteVO3 := {}
Local nPosGrI    := FG_POSVAR("VO3_GRUINC","aHeader")
Local nPosCdI    := FG_POSVAR("VO3_CODINC","aHeader")
Local nPosDsI    := FG_POSVAR("VO3_DESINC","aHeader")
Local nPosSqI    := FG_POSVAR("VO3_SEQINC","aHeader")
Local nPosTTp    := FG_POSVAR("VO3_TIPTEM","aHeader")
Local nPosCli    := FG_POSVAR("VO3_FATPAR","aHeader")
Local nPosLoj    := FG_POSVAR("VO3_LOJA"  ,"aHeader")
Local nPosGrp    := FG_POSVAR("VO3_GRUITE","aHeader")
Local nPosCod    := FG_POSVAR("VO3_CODITE","aHeader")
Local nPosOSV    := FG_POSVAR("VO3_NUMOSV","aHeader")
Local nPosPro    := FG_POSVAR("VO3_PROREQ","aHeader")
Local nPosDpI    := FG_POSVAR("VO3_DEPINT","aHeader")
Local nPosDpG    := FG_POSVAR("VO3_DEPGAR","aHeader")
Local nPosQtd    := FG_POSVAR("VO3_QTDREQ","aHeader")
Local nPosOpe    := FG_POSVAR("VO3_OPER"  ,"aHeader")
Local nPosTES    := FG_POSVAR("VO3_CODTES","aHeader")
Local cOSOrigem  := ""
Local cOSDestino := VO1->VO1_NUMOSV
Local nQtdAcumul := 0
Local nQtdDevolv := 0
Local nTamOSV    := GetSX3Cache("VO3_NUMOSV","X3_TAMANHO")
Local nTamTTp    := GetSX3Cache("VO3_TIPTEM","X3_TAMANHO")
Private aAvCredPec := {} // Variavel utilizada no OFIOM020
Private aPecaOrc   := {} // Variavel utilizada no OFIOM020 para baixa do VSJ

ProcRegua( 0 )
IncProc(STR0008) // Processando

If !oGetOA310:TudoOk() // Tudo OK da Tela - Validacoes
	Return .f.
EndIf

Begin Transaction

For nCntFor := 1 to len(oGetOA310:aCols)

	If !oGetOA310:aCols[nCntFor,len(oGetOA310:aCols[nCntFor])] // Valido

		cOSOrigem := left(oGetOA310:aCols[nCntFor,nPosOSV],nTamOSV)
		VO1->(DbSetOrder(1))
		VO1->(DbSeek(xFilial("VO1")+cOSOrigem))

		aPeca := FMX_CALPEC(;
			cOSOrigem,;  // cNumOS
			right(oGetOA310:aCols[nCntFor,nPosOSV],nTamTTp),; // cTipTem
			oGetOA310:aCols[nCntFor,nPosGrp],; // cGruIte
			oGetOA310:aCols[nCntFor,nPosCod],; // cCodIte
			.f.,;                              // lMov
			.f.,;                              // lNegoc
			.t.,;                              // lReqZerada - Remove itens com qtde zerada
			.t.,;                              // lRetAbe
			.f.,;                              // lRetLib
			.f.,;                              // lRetFec
			.f.,;                              // lRetCan
			,;                                 // cLibVOO
			"",;                               // cFiltroSQL
			.f.,;                              // lRetRem
			.f.)                               // lAgrInc

		nQtdAcumul := 0

		For nCntPec := 1 to Len(aPeca)

			If nQtdAcumul < oGetOA310:aCols[nCntFor,nPosQtd] // Qtde.Acumulada < Qtde.Desejada

				If ( oGetOA310:aCols[nCntFor,nPosQtd] - nQtdAcumul ) <= aPeca[ nCntPec , PECA_QTDREQ ] // Devolve apenas a qtde necessaria
					nQtdDevolv := ( oGetOA310:aCols[nCntFor,nPosQtd] - nQtdAcumul )
				Else // Devolve toda qtde deste VO3
					nQtdDevolv := aPeca[ nCntPec , PECA_QTDREQ ]
				EndIf
				nQtdAcumul += nQtdDevolv

				aIteVO3    := {}
				aAuxIteVO3 := {}
				SB1->(DbSetOrder(7))
				SB1->(DbSeek(xFilial("SB1")+oGetOA310:aCols[nCntFor,nPosGrp]+oGetOA310:aCols[nCntFor,nPosCod]))
				AADD(aAuxIteVO3, { "VO3_NUMOSV" , oGetOA310:aCols[nCntFor,nPosOSV] , nil } )
				AADD(aAuxIteVO3, { "VO3_TIPTEM" , aPeca[ nCntPec , PECA_TIPTEM ]   , nil } )
				AADD(aAuxIteVO3, { "VO3_GRUITE" , oGetOA310:aCols[nCntFor,nPosGrp] , nil } )
				AADD(aAuxIteVO3, { "VO3_CODITE" , oGetOA310:aCols[nCntFor,nPosCod] , nil } )
				AADD(aAuxIteVO3, { "VO3_QTDREQ" , nQtdDevolv                       , nil } )
				AADD(aAuxIteVO3, { "VO3_QTDEST" , nQtdDevolv                       , nil } )
				AADD(aAuxIteVO3, { "VO3_PROREQ" , oGetOA310:aCols[nCntFor,nPosPro] , nil } )
				AADD( aIteVO3 , aClone( aAuxIteVO3 ) )
				lMSHelpAuto := .t.
				lMsErroAuto := .f.
				MSExecAuto({|x,y,z| OFIOM020(,,x,y,z)},aIteVO3,3 /* Devolucao */ )
				if lMsErroAuto
					DisarmTransaction()
					RollbackSx8()
					MsUnlockAll()
					MostraErro()
					RestArea(aAreaVO1) // Voltar Area VO1
					Return .f.
				Endif
				lMSHelpAuto := .f.
			
			Else

				Exit // Sair do Laço da Devolucao pois atingiu a qtde desejada
			
			EndIf

		Next

		VO1->(DbSetOrder(1))
		VO1->(DbSeek(xFilial("VO1")+cOSDestino))

		aIteVO3    := {}
		aAuxIteVO3 := {}
		SB1->(DbSetOrder(7))
		SB1->(DbSeek(xFilial("SB1")+oGetOA310:aCols[nCntFor,nPosGrp]+oGetOA310:aCols[nCntFor,nPosCod]))
		AADD(aAuxIteVO3, { "VO3_NUMOSV" , cOSDestino                       , nil } )
		if lInconveniente
			AADD(aAuxIteVO3, { "VO3_GRUINC" , oGetOA310:aCols[nCntFor,nPosGrI] , nil } )
			AADD(aAuxIteVO3, { "VO3_CODINC" , oGetOA310:aCols[nCntFor,nPosCdI] , nil } )
			AADD(aAuxIteVO3, { "VO3_DESINC" , oGetOA310:aCols[nCntFor,nPosDsI] , nil } )
			AADD(aAuxIteVO3, { "VO3_SEQINC" , oGetOA310:aCols[nCntFor,nPosSqI] , nil } )
		endif
		AADD(aAuxIteVO3, { "VO3_TIPTEM" , oGetOA310:aCols[nCntFor,nPosTTp] , nil } )
		AADD(aAuxIteVO3, { "VO3_FATPAR" , oGetOA310:aCols[nCntFor,nPosCli] , nil } )
		AADD(aAuxIteVO3, { "VO3_LOJA"   , oGetOA310:aCols[nCntFor,nPosLoj] , nil } )
		AADD(aAuxIteVO3, { "VO3_GRUITE" , oGetOA310:aCols[nCntFor,nPosGrp] , nil } )
		AADD(aAuxIteVO3, { "VO3_CODITE" , oGetOA310:aCols[nCntFor,nPosCod] , nil } )
		AADD(aAuxIteVO3, { "VO3_QTDREQ" , oGetOA310:aCols[nCntFor,nPosQtd] , nil } )
		AADD(aAuxIteVO3, { "VO3_QTDEST" , oGetOA310:aCols[nCntFor,nPosQtd] , nil } )
		AADD(aAuxIteVO3, { "VO3_PROREQ" , oGetOA310:aCols[nCntFor,nPosPro] , nil } )
		If !Empty(oGetOA310:aCols[nCntFor,nPosDpI])
			AADD(aAuxIteVO3, { "VO3_DEPINT" , oGetOA310:aCols[nCntFor,nPosDpI] , nil } )
		EndIf
		If !Empty(oGetOA310:aCols[nCntFor,nPosDpG])
			AADD(aAuxIteVO3, { "VO3_DEPGAR" , oGetOA310:aCols[nCntFor,nPosDpG] , nil } )
		EndIf
		If !Empty(oGetOA310:aCols[nCntFor,nPosOpe])
			AADD(aAuxIteVO3, { "VO3_OPER"   , oGetOA310:aCols[nCntFor,nPosOpe] , nil } )
		EndIf
		If !Empty(oGetOA310:aCols[nCntFor,nPosTES])
			AADD(aAuxIteVO3, { "VO3_CODTES" , oGetOA310:aCols[nCntFor,nPosTES] , nil } )
		EndIf
		AADD( aIteVO3 , aClone( aAuxIteVO3 ) )
		lMSHelpAuto := .t.
		lMsErroAuto := .f.
		MSExecAuto({|x,y,z| OFIOM020(,,x,y,z)},aIteVO3,2 /* Requisita */ )
		if lMsErroAuto
			DisarmTransaction()
			RollbackSx8()
			MsUnlockAll()
			MostraErro()
			RestArea(aAreaVO1) // Voltar Area VO1
			Return .f.
		Endif
		lMSHelpAuto := .f.

	EndIf

Next

End Transaction

RestArea(aAreaVO1) // Voltar Area VO1

MsgInfo(STR0030,STR0002) // Tranferência de Peças entre as Ordens de Serviço realizada com sucesso! / Atencao

//Executa RdMake da Ordem de Busca de Transferencia de Pecas entre Ordens de Serviço
if ExistBlock("ORDBUSCC")
	ExecBlock("ORDBUSCC",.f.,.f.,{ cOSDestino , oGetOA310:aCols , oGetOA310:aHeader })
Endif

Return .t.

/*/{Protheus.doc} OA3100141_Inserir_Pecas_de_outra_OS_F5
Inserir na aCols as Peças de outra OS <F5>

@author Andre
@since 07/04/2021
/*/
Function OA3100141_Inserir_Pecas_de_outra_OS_F5()
Local aAreaVO1 := VO1->(GetArea()) // Salvar Area VO1
Local aRet      := {}
Local aParamBox := {}
Local aOSsIte   := {}
Local cFiltAux  := ""
Local nCntPec   := 0
Local nLinha    := 0
Local nPosTTp   := FG_POSVAR("VO3_TIPTEM","aHeader")
Local nPosCli   := FG_POSVAR("VO3_FATPAR","aHeader")
Local nPosLoj   := FG_POSVAR("VO3_LOJA"  ,"aHeader")
Local nPosNom   := FG_POSVAR("VO3_NOMCLI","aHeader")
Local nPosGrp   := FG_POSVAR("VO3_GRUITE","aHeader")
Local nPosCod   := FG_POSVAR("VO3_CODITE","aHeader")
Local nPosDes   := FG_POSVAR("VO3_DESITE","aHeader")
Local nPosOSV   := FG_POSVAR("VO3_NUMOSV","aHeader")
Local nPosPro   := FG_POSVAR("VO3_PROREQ","aHeader")
Local nPosDpI   := FG_POSVAR("VO3_DEPINT","aHeader")
Local nPosDpG   := FG_POSVAR("VO3_DEPGAR","aHeader")
Local nPosQtd   := FG_POSVAR("VO3_QTDREQ","aHeader")
Local nPosEst   := FG_POSVAR("VO3_QTDEST","aHeader")
Local nPosOpe   := FG_POSVAR("VO3_OPER"  ,"aHeader")
Local nPosTES   := FG_POSVAR("VO3_CODTES","aHeader")
Private cNumOSV := VO1->VO1_NUMOSV
//
OA3100091_TeclasF("F4",.f.)
OA3100091_TeclasF("F5",.f.)
OA3100091_TeclasF("F6_OS_Destino",.f.)
//
aAdd(aParamBox,{1,STR0032,Space(GetSX3Cache("VO3_NUMOSV","X3_TAMANHO")),"@!",'FG_Seek("VO1","MV_PAR01",1,.f.) .and. MV_PAR01<>cNumOSV .and. VO1->VO1_STATUS="A"',"VO1ABE","",0,.T.}) // Origem: Numero OS
aAdd(aParamBox,{1,STR0033,Space(GetSX3Cache("VO3_TIPTEM","X3_TAMANHO")),"@!",'vazio() .or. FG_Seek("VOI","MV_PAR02",1,.f.)',"VOIPAB","",0,.F.}) // Origem: Tipo Tempo
aAdd(aParamBox,{1,STR0034,Space(GetSX3Cache("VO3_TIPTEM","X3_TAMANHO")),"@!",'vazio() .or. FG_Seek("VOI","MV_PAR03",1,.f.)',"VOI","",0,.F.}) // Requisição: Tipo Tempo
aAdd(aParamBox,{1,STR0035,Space(GetSX3Cache("VO3_OPER","X3_TAMANHO")),"@!",'vazio() .or. Existcpo("SX5","DJ"+MV_PAR04)',"DJ","Empty(MV_PAR05)",0,.F.}) // Requisição: Operação
aAdd(aParamBox,{1,STR0036,Space(GetSX3Cache("VO3_CODTES","X3_TAMANHO")),"@!",'vazio() .or. ( FG_Seek("SF4","MV_PAR05",1,.f.) .and. MaAvalTes("S",MV_PAR05) )',"SF4","Empty(MV_PAR04)",0,.F.}) // Requisição: TES
aAdd(aParamBox,{1,STR0037,Space(GetSX3Cache("VO3_PROREQ","X3_TAMANHO")),"@!",'vazio() .or. ( FG_StrZero("MV_PAR06",6) .AND. FG_Seek("VAI","MV_PAR06") .AND. IF(VAI->VAI_PROFIL<>"1",VAI->VAI_FILPRO==FWCodFil(),.T.) )',"V1A","",0,.F.}) // Requisição: Produtivo
aAdd(aParamBox,{1,STR0043,Space(GetSX3Cache("VO3_DEPINT","X3_TAMANHO")),"@!",'vazio() .or. FG_Seek("SX5","'+"'VD'"+'+MV_PAR07",1,.f.)',"VD","",0,.F.}) // Requisição: Dep.Interno
aAdd(aParamBox,{1,STR0044,Space(GetSX3Cache("VO3_DEPGAR","X3_TAMANHO")),"@!",'vazio() .or. FG_Seek("SX5","'+"'VF'"+'+MV_PAR08",1,.f.)',"VF","",0,.F.}) // Requisição: Dep.Garantia
//
If ParamBox(aParamBox,"<F5> "+STR0005,@aRet,,,,,,,,.f.) // Inserir Peças de outra OS
	VO1->(DbSeek(xFilial("VO1")+cNumOSV))
	cFiltAux := " AND VO3.VO3_NUMOSV = '"+aRet[1]+"'" // Filtrar OS de Origem
	If !Empty(aRet[2])
		cFiltAux += " AND VO3.VO3_TIPTEM = '"+aRet[2]+"'" // Filtrar Tipo de Tempo da OS de Origem
	EndIf
	aOSsIte := OA3100081_SaldoVO3("","",0,"",cFiltAux)
	If len(aOSsIte) > 0
		For nCntPec := 1 to len(aOSsIte)
			nLinha := Len(oGetOA310:aCols)
			If	!Empty(oGetOA310:aCols[nLinha,nPosTTp]) .or.;
				!Empty(oGetOA310:aCols[nLinha,nPosCod])
				aAdd(oGetOA310:aCols,Array(nUsado+1))
				nLinha++
			EndIf
			oGetOA310:aCols[nLinha,nUsado+1] := .F.
			aCols := oGetOA310:aCols // Compatibilidade com o OFIOM020 - validações
			oGetOA310:nAt := N := nLinha
			oGetOA310:aCols[nLinha,nPosTTp] := M->VO3_TIPTEM := aRet[3]
			oGetOA310:aCols[nLinha,nPosCli] := M->VO3_FATPAR := ""
			oGetOA310:aCols[nLinha,nPosLoj] := M->VO3_LOJA   := ""
			oGetOA310:aCols[nLinha,nPosNom] := M->VO3_NOMCLI := ""
			oGetOA310:aCols[nLinha,nPosQtd] := M->VO3_QTDREQ := 0
			If !Empty(M->VO3_TIPTEM)
				__ReadVar := "M->VO3_TIPTEM"
				If OA3100171_ValidCposVO3() // Executa valid do Campo
					&(aHeader[nPosTTp,6]) // Preencher Descrições automaticamente com o valid padrao do campo
				Else
					oGetOA310:aCols[nLinha,nPosTTp] := M->VO3_TIPTEM := space(GetSX3Cache("VO3_TIPTEM","X3_TAMANHO"))
				EndIf
			EndIf
			oGetOA310:aCols[nLinha,nPosGrp] := M->VO3_GRUITE := aOSsIte[nCntPec,7]
			oGetOA310:aCols[nLinha,nPosCod] := M->VO3_CODITE := aOSsIte[nCntPec,8]
			oGetOA310:aCols[nLinha,nPosDes] := M->VO3_DESITE := ""
			If !Empty(M->VO3_CODITE)
				__ReadVar := "M->VO3_CODITE"
				If OA3100171_ValidCposVO3() // Executa valid do campo
					&(aHeader[nPosCod,6]) // Preencher Descrições automaticamente com o valid padrao do campo
				Else
					oGetOA310:aCols[nLinha,nPosGrp] := M->VO3_GRUITE := space(GetSX3Cache("VO3_GRUITE","X3_TAMANHO"))
					oGetOA310:aCols[nLinha,nPosCod] := M->VO3_CODITE := space(GetSX3Cache("VO3_CODITE","X3_TAMANHO"))
				EndIf
			EndIf
			oGetOA310:aCols[nLinha,nPosOSV] := M->VO3_NUMOSV := aOSsIte[nCntPec,2]+"-"+aOSsIte[nCntPec,5]
			oGetOA310:aCols[nLinha,nPosPro] := M->VO3_PROREQ := aRet[6]
			oGetOA310:aCols[nLinha,nPosQtd] := M->VO3_QTDREQ := aOSsIte[nCntPec,6]
			oGetOA310:aCols[nLinha,nPosEst] := M->VO3_QTDEST := aOSsIte[nCntPec,6]
			oGetOA310:aCols[nLinha,nPosOpe] := M->VO3_OPER   := aRet[4]
			oGetOA310:aCols[nLinha,nPosTES] := M->VO3_CODTES := aRet[5]
			If !Empty(M->VO3_OPER)
				__ReadVar := "M->VO3_OPER"
				If !OA3100171_ValidCposVO3() // Executa valid do campo
					oGetOA310:aCols[nLinha,nPosTES] := M->VO3_CODTES := space(GetSX3Cache("VO3_CODTES","X3_TAMANHO"))
				EndIf
			EndIf
			oGetOA310:aCols[nLinha,nPosDpI] := M->VO3_DEPINT := aRet[7]
			oGetOA310:aCols[nLinha,nPosDpG] := M->VO3_DEPGAR := aRet[8]
			oGetOA310:Refresh()
		Next
	Else
		MsgStop(STR0031+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
			STR0032+" - "+aRet[1]+;
			IIf(!Empty(aRet[2]),CHR(13)+CHR(10)+STR0033+" - "+aRet[2],""),;
			STR0002) // Nenhum Item encontrado. / Origem: Numero OS / Origem: Tipo Tempo / Atencao
	EndIf
EndIf
//
OA3100091_TeclasF("F4",.t.)
OA3100091_TeclasF("F5",.t.)
OA3100091_TeclasF("F6_OS_Destino",.t.)
//
RestArea(aAreaVO1) // Voltar Area VO1
RegToMemory("VO1",.f.)
Return

/*/{Protheus.doc} OA3100151_Visualiza_OS_Destino_F6
Visualiza a OS de Destino ( tecla F6 )

@author Andre
@since 08/04/2021
/*/
Static Function OA3100151_Visualiza_OS_Destino_F6()
OA3100091_TeclasF("F4",.f.)
OA3100091_TeclasF("F5",.f.)
OA3100091_TeclasF("F6_OS_Destino",.f.)
OA3100191_Visualizar_OS() // Chamada do OFIOC060 - Consulta de OS
OA3100091_TeclasF("F4",.t.)
OA3100091_TeclasF("F5",.t.)
OA3100091_TeclasF("F6_OS_Destino",.t.)
Return


/*/{Protheus.doc} OA3100161_Validar_Atendimento_Externo
NAO DEIXAR passar se existir Atendimento Externo para a OS + Tipo de Tempo + Grupo + Codigo do Item

@author Andre
@since 12/04/2021
/*/
Static Function OA3100161_Validar_Atendimento_Externo( nLinha , cNumOS , cTipTem , cGruIte , cCodIte )
Local lRet   := .t.
Local cQuery := ""
Local cMsg   := ""
cQuery := "SELECT COUNT(*) "
cQuery +=  " FROM " + RetSQLName("VDR")
cQuery += " WHERE VDR_FILIAL = '" + xFilial("VDR") + "'"
cQuery += "   AND VDR_NUMOSV = '" + cNumOS + "'"
cQuery += "   AND VDR_TIPTEM = '" + cTipTem + "'"
cQuery += "   AND VDR_GRUITE = '" + cGruIte + "'"
cQuery += "   AND VDR_CODITE = '" + cCodIte + "'"
cQuery += "   AND VDR_NFENUM = '         '" // Somente notas que nao foram devolvidas
cQuery += "   AND D_E_L_E_T_ = ' '"
If FM_SQL(cQuery) > 0
	//
	If nLinha == 0
		cMsg := STR0040+": "+cNumOS+CHR(13)+CHR(10) // OS Destino
	Else
		cMsg := STR0011+": "+Alltrim(str(nLinha))+CHR(13)+CHR(10)+CHR(13)+CHR(10) // Linha
		cMsg := STR0039+": "+cNumOS+CHR(13)+CHR(10) // OS Origem
	EndIf
	cMsg += GetSX3Cache("VO3_TIPTEM","X3_TITULO")+": "+cTipTem+CHR(13)+CHR(10)
	cMsg += GetSX3Cache("VO3_GRUITE","X3_TITULO")+": "+cGruIte+CHR(13)+CHR(10)
	cMsg += GetSX3Cache("VO3_CODITE","X3_TITULO")+": "+cCodIte+CHR(13)+CHR(10)
	//
	Aviso(STR0038,cMsg,{STR0018},3) // Ordem de Serviço em Remessa para Atendimento Externo / OK
	//
	lRet := .f.
	//
EndIf
Return lRet

/*/{Protheus.doc} OA3100171_ValidCposVO3
Validacao dos campos VO3

@author Andre
@since 13/04/2021
/*/
Function OA3100171_ValidCposVO3()
Local lRet    := .t.
If ReadVar() == "M->VO3_QTDREQ"
	lRet := OA3100021_ValidQTD() // Valdicao da Qtde.Desejada
Else
	aCols := oGetOA310:aCols // Compatibilidade com OFIOM020
	lRet := FS_FIELD020(,.f.) // Validacao do OFIOM020 .f. não utilizar campos que nao existem na aCols
	oGetOA310:aCols := aCols // Compatibilidade com OFIOM020
	If lRet
		If ReadVar() $ "M->VO3_GRUITE/M->VO3_CODITE/"
			OA3100121_Relaciona_OS_Origem_na_aCols( oGetOA310:nAt , "" , 0 ) // Limpa relacionamento de Origem
		ElseIf ReadVar() $ "M->VO3_TIPTEM"
			If !Empty(M->VO3_TIPTEM)
				VOI->(DbSetOrder(1))
				VOI->(DbSeek(xFilial("VOI")+M->VO3_TIPTEM)) // Utilizado no SX3 (WHEN) dos campos de Departamentos
			EndIf
		EndIf
	EndIf
EndIf
Return lRet

/*/{Protheus.doc} OA3100181_F3_TpTempo_Pecas_EmAberto_da_OS
F3 dos Tipos de Tempo de PECAS em Aberto da OS selecionada - funcao chamada dentro do SXB: VOIPAB

@author Andre
@since 14/04/2021
/*/
Function OA3100181_F3_TpTempo_Pecas_EmAberto_da_OS()
Local lRet      := .f.
Local aAux      := {}
Local aRet      := {}
Local cQuery    := ""
Local cQAlias   := "SQLAUX"
Local aParamBox := {}
Local aSlvPAR   := { MV_PAR01 , MV_PAR02 , MV_PAR03 , MV_PAR04 , MV_PAR05 , MV_PAR06 } // Salvar MV_PAR devido a Parambox anterior
//
cQuery := "SELECT DISTINCT VO3.VO3_TIPTEM , VOI.VOI_DESTTE "
cQuery += "  FROM "+RetSQLName("VO3")+" VO3 "
cQuery += "  LEFT JOIN "+RetSQLName("VOI")+" VOI ON ( VOI.VOI_FILIAL='"+xFilial("VOI")+"' AND VOI.VOI_TIPTEM=VO3.VO3_TIPTEM AND VOI.D_E_L_E_T_=' ' ) "
cQuery += " WHERE VO3.VO3_FILIAL='"+VO1->VO1_FILIAL+"'"
cQuery += "   AND VO3.VO3_NUMOSV='"+VO1->VO1_NUMOSV+"'"
cQuery += "   AND VO3.VO3_DATDIS = ' '"
cQuery += "   AND VO3.VO3_DATFEC = ' '"
cQuery += "   AND VO3.VO3_DATCAN = ' '"
cQuery += "   AND VO3.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
Do While !( cQAlias )->( Eof() )
	aAdd(aAux,( cQAlias )->( VO3_TIPTEM )+"="+( cQAlias )->( VOI_DESTTE ))
	( cQAlias )->( DbSkip() )
EndDo
( cQAlias )->( dbCloseArea() )
If len(aAux) > 0
	aAdd(aParamBox,{2,STR0041,"",aAux,90,".t.",.f.}) // Tp.Tempo Em Aberto
	DbSelectArea("VOI")
	DbSetOrder(1) // VOI_FILIAL+VOI_TIPTEM
	If ParamBox(aParamBox,STR0023+": "+VO1->VO1_NUMOSV,@aRet,,,,,,,,.f.) // OS
		VOI->(DbSeek(xFilial("VOI")+aRet[1]))
		lRet := .t.
	EndIf
EndIf
// Voltar MV_PAR devido a Parambox anterior
MV_PAR01 := aSlvPAR[1]
MV_PAR02 := aSlvPAR[2]
MV_PAR03 := aSlvPAR[3]
MV_PAR04 := aSlvPAR[4]
MV_PAR05 := aSlvPAR[5]
MV_PAR06 := aSlvPAR[6]
Return lRet

/*/{Protheus.doc} OA3100191_Visualizar_OS
Visualizar VO1 ( Consulta da OS - OFIOC060 )

@author Andre
@since 30/03/2021
/*/
Function OA3100191_Visualizar_OS()
Private nOpc := 2 // variavel necessaria no OFIOC060
OFIOC060(.t.)
Return

/*/{Protheus.doc} MenuDef
MenuDef - montagem do aRotina no Browse do VO1

@author Andre
@since 30/03/2021
/*/
Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE STR0001 ACTION 'OA3100011_Requisitar_Pecas_de_outras_OSs()' OPERATION 4 ACCESS 0 // Requisitar Peças de outras OSs
	ADD OPTION aRotina TITLE STR0042 ACTION 'OA3100191_Visualizar_OS()' OPERATION 2 ACCESS 0 // Visualizar OS
Return aRotina