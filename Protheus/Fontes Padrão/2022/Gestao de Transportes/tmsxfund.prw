#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSXFUND.CH"
#INCLUDE "FWMVCDEF.CH"

Static lTMViaCol := ExistBlock("TMVIACOL")
Static lTMSDIVQY := ExistBlock("TMSDIVQY")
Static lTMSVLDYD := ExistBlock("TMSVLDYD")
Static aStruct   := {}
Static aDadosRem := {}
Static aDadosDes := {}
Static aDadosCol := {}
Static cProcesso := ""
Static aLocaliza := {}
Static aTransito := {}
Static lIncDocto := .T.
Static nSeqCarga := 0

//-- Mapa do vetor aStruct
//-- 01 - Código da fonte
//-- 02 - Código do registro
//-- 03 - Alias do registro
//-- 04 - Indice do registro
//-- 05 - Prioridade de envio
//-- 06 - Registro do qual o alias do registro é dependente
//-- 07 - Comando de posicionamento no alias de dependência
//-- 08 - Condição de repetição (loop) dos registros
//-- 09 - Condição de uso do registro do alias de dependência
//-- 10 - Indica se o registro já foi processado
//-- 11 - Fonte do registro adicional
//-- 12 - Registro adicional

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSTcLk   ºAutor  ³Telso Carneiro      º Data ³  23/08/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza o TCLINK  e TCUNLINK atraves do parametro           º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSTcLk(nCon,lRotAuto)

Local cTMSTCLK	 := GetMv('MV_TMSTCLK',,'') //'ddabase';'ip or named';porta
Local	aTCLINK   := {}

Default lRotAuto := .F.

If ValType(nCon) == 'U'
	If !Empty(cTMSTCLK)
		While AT(";",cTMSTCLK) > 0
			Aadd(aTCLINK,Subs(cTMSTCLK,1,AT(";",cTMSTCLK)-1))
			cTMSTCLK :=	Stuff(cTMSTCLK,1,AT(";",cTMSTCLK),"")
		EndDo
		Aadd(aTCLINK,cTMSTCLK)
		nCon := TCLink(aTCLINK[1],aTCLINK[2],Val(aTCLINK[3]))
		If (nCon < 0) .And. !lRotAuto //--So mostra a tela se nao for chamada automaticamente
			MsgAlert(STR0004+Str(nCon,10,0)) //'Falha Conexao TOPCONN 1 - Erro: '
		EndIf
	EndIf
Else
	If !Empty(cTMSTCLK) .And. (nCon > 0)
		TCUnLink(nCon)
	EndIf
EndIf

Return(nCon)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSF3TcLk ºAutor  ³Telso Carneiro      º Data ³  23/08/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza F3 Para TCLINK e TCUNLINK atraves da funcao TMSTcLk º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSF3TcLk(cAlias)
Local nCon1     := 0
Local lRet      := .F.
Local cCadastro := STR0001 //"Funcionários"
Local aRotOld   := aClone(aRotina)
Local aCampos   := {}
Local aRotina   := {}

Private nOpcSel := 0

SRA->(DbClosearea())
nCon1 := TMSTcLk()
If (nCon1 > 0)

	ChkFile("SRA")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define os campos do Browse.                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aCampos, "RA_MAT")
	Aadd(aCampos, "RA_NOME")

	Aadd( aRotina, { STR0002,"TMSConfSel",0,2,,,.T.} )   //"&Confirmar"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE.                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	MaWndBrowse(0,0,300,600,cCadastro,"SRA",aCampos,aRotina,,,,.T.)
	aRotina := aClone(aRotOld)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retorna codigo posicionado                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpcSel == 1
		lRet    := .T.
		VAR_IXB := SRA->RA_MAT
	EndIf

	TMSTclK(nCon1)
	ChkFile("SRA")

EndIf



Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSSelField ºAutor  ³Richard Anderson  º Data ³  30/10/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Seleciona um ou mais documentos de transporte               º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSSelField(cCampo,cCpoGet)

Local   lSetKey := (Type('aSetKey') == 'A')
Local   aOpcoes := {}
Local   aItens  := {}
Local   lValid  := .F.
Local   lConsF3 := .F.
Local   lArray  := .T.
Local   aMem    := {}
Local   lInv    := .F.
Local   lAll    := .T.
Local   aRet    := {}
Local   cRet    := ''
Local   cCpoSep := ''
Local   cCpoTit := ''
Local   cTitulo := STR0005 //-- "Seleção de Itens"

Default cCampo  := ''
Default cCpoGet := ''

If Empty(cCpoGet) .And. '->' $ cCampo
	cCpoGet := cCampo
EndIf

If !Empty(cCpoGet)
	cCpoSep := ';'+StrTran(&cCpoGet,' ','')
	cCpoTit := Right(cCpoGet,10)
	cTitulo := FwX3Titulo(cCpoTit)
EndIf

If lSetKey
	//-- Finaliza Teclas de Atalhos
	TmsKeyOff(aSetKey)
EndIf

aOpcoes := TMSValField(cCampo,lValid,,lConsF3,lArray)

aEval(aOpcoes, {| e, nI | Aadd(aItens, {4, "", "*" $ cCpoSep .Or. ";" + e[1] $ cCpoSep, e[1] + "-" + e[2], 80,,.F.}), Aadd(aMem, MemVarBlock("MV_PAR" + StrZero(nI, 2)))})

If ParamBox( aItens, cTitulo, @aRet, , {{ 5, { |oPanel| TMSMrkField(aMem, @lInv),oPanel:Refresh() }, STR0003 }} , .T.) //"Marca/Desmarca Todos"
	aEval(aRet, {|z,w| If(z, cRet += If(Len(cRet) > 0, ";","") + aOpcoes[w,1],lAll := .F.)})
	If !Empty(cCpoGet)
		&cCpoGet := Padr(Iif(lAll,'*',cRet),Len(&cCpoGet))
	EndIf
EndIf

If lSetKey
	//-- Inicializa Teclas de Atalhos
	TmsKeyOn(aSetKey)
EndIf

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSMrkField  ³ Autor ³ Richard Anderson  ³ Data ³30.10.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca/Desmarca todos os CheckBox do PARAMBOX()             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSMrkField(aMem,lInv)

lInv := !lInv
aEval(aMem, {|z| Eval(z, lInv)})

Return

//===========================================================================================================
/* Função TmsX6Valid - Valida os parâmetros do SIGATMS.
@author  	Rafael Souza
@version 	P12
@build
@since 	02/09/2013
@return 	*/
//===========================================================================================================

Function TmsX6Valid (cFil, cPar, cTipo, xContPor, xContSpa, xContEng)

Local lRet		  := .T.
Local aArea 	  := GetArea()
Local aConteudo	  := {}
Local nCont		  := 1
Local cLanguage	  := " "
Local lMostraErr  := .T. //-- Variavel usada para controlar validacoes que exibem mensagem de help.
Local xConteudo	  := Nil
Local nX
Local aContPar	  := {}
Local cTmsmfat   := SuperGetMv("MV_TMSMFAT", , " ")
Local cTmserp    := SuperGetMv("MV_TMSERP" , , "0")

Default cFil	  := " "
Default cPar	  := " "
Default cTipo	  := " "


Aadd( aConteudo , { xContPor , "PORTUGUES" } )
Aadd( aConteudo , { xContSpa , "ESPANHOL" } )
Aadd( aConteudo , { xContEng , "INGLES" }  )


While lRet .And. nCont <= Len(aConteudo)

	xConteudo 	:= aConteudo[nCont,1]
	cLanguage   := aConteudo[nCont,2]

	Do Case
		Case AllTrim(cPar) == 'MV_ABAST'
			lRet:= Empty(xConteudo) .Or. VldExistCp( "DT7",xConteudo, @lMostraErr, TamSX3("DT7_CODDES")[1] )
		Case AllTrim (cPar) == 'MV_ABTSVG'
			lRet:= Empty(xConteudo) .Or. VldExistCp( "DT7",xConteudo, @lMostraErr, TamSX3("DT7_CODDES")[1] )
		Case AllTrim (cPar) == 'MV_AMZSVG'
			lRet:= Empty(xConteudo) .Or. VldExistCp( "DT7",xConteudo, @lMostraErr, TamSX3("DT7_CODDES")[1])
		Case AllTrim (cPar) == 'MV_ATIVCHG'
			lRet:= Empty(xConteudo) .Or. VldExistCp( "SX5","L3" + xConteudo, @lMostraErr, TamSX3("X5_CHAVE")[1] )
		Case AllTrim (cPar) == 'MV_ATIVCHP'
			lRet:= Empty(xConteudo) .Or. VldExistCp( "SX5","L3" + xConteudo, @lMostraErr, TamSX3("X5_CHAVE")[1] )
		Case AllTrim (cPar) == 'MV_ATIVDCA'
			lRet:= Empty(xConteudo) .Or. VldExistCp ( "SX5","L3" + xConteudo, @lMostraErr, TamSX3("X5_CHAVE")[1] )
		Case AllTrim (cPar) == 'MV_ATIVDES'
			lRet:= Empty(xConteudo) .Or. VldExistCp ( "SX5", "L3" + xConteudo, @lMostraErr, TamSX3("X5_CHAVE")[1] )
		Case AllTrim (cPar) == 'MV_ATIVISP'
			lRet:= Empty(xConteudo) .Or. VldExistCp ( "SX5", "L3" + xConteudo, @lMostraErr, TamSX3("X5_CHAVE")[1] )
		Case AllTrim (cPar) == 'MV_ATIVPSG'
			lRet:= Empty(xConteudo) .Or. VldExistCp ( "SX5", "L3" + xConteudo, @lMostraErr, TamSX3("X5_CHAVE")[1] )
		Case AllTrim (cPar) == 'MV_ATIVRDP'
			lRet:= Empty(xConteudo) .Or. VldExistCp ( "SX5", "L3" + xConteudo, @lMostraErr, TamSX3("X5_CHAVE")[1] )
		Case AllTrim (cpar) == 'MV_ATIVREF'
			lRet:= Empty(xConteudo) .Or. VldExistCp ( "SX5", "L3" + xConteudo, @lMostraErr, TamSX3("X5_CHAVE")[1] )
		Case AllTrim (cpar) == 'MV_ATIVRTA'
			lRet:= Empty(xConteudo) .Or. VldExistCp ( "SX5", "L3" + xConteudo, @lMostraErr, TamSX3("X5_CHAVE")[1] )
		Case AllTrim (cpar) == 'MV_ATIVRTP'
			lRet:= Empty(xConteudo) .Or. VldExistCp ( "SX5", "L3" + xConteudo, @lMostraErr, TamSX3("X5_CHAVE")[1] )
		Case AllTrim (cpar) == 'MV_ATIVSAI'
			lRet:= Empty(xConteudo) .Or. VldExistCp ( "SX5", "L3" + xConteudo, @lMostraErr, TamSX3("X5_CHAVE")[1] )
		Case AllTrim (cpar) == 'MV_BLQPES'
			lRet:= Empty(xConteudo) .Or. AllTrim (xConteudo) $ '1;2;3'
		Case AllTrim(cPar) == 'MV_CDRMUN'
			lRet := Empty (xConteudo) .Or. VldExistCp( "DUY", xConteudo, @lMostraErr, TamSX3("DUY_GRPVEN")[1] )
		Case AllTrim(cPar) == 'MV_CDRORI'
			lRet := Empty (xConteudo) .Or. VldExistCp( "DUY", xConteudo, @lMostraErr, TamSX3("DUY_GRPVEN")[1] )
		Case AllTrim(cPar) == 'MV_CLIGEN'
			lRet := Empty (xConteudo) .Or. VldExistCp( "SA1", xConteudo, @lMostraErr, TamSX3("A1_COD")[1] + TamSX3("A1_LOJA")[1] )
		Case AllTrim(cPar) == 'MV_COMPAER'
			lRet := Empty (xConteudo) .Or. VldExistCp( "DT3", xConteudo, @lMostraErr, TamSX3("DT3_CODPAS")[1] )
		Case AllTrim(cPar) == 'MV_COMPCTC'
			lRet := Empty (xConteudo) .Or. VldExistCp( "DT3", xConteudo, @lMostraErr, TamSX3("DT3_CODPAS")[1] )
		Case AllTrim(cPar) == 'MV_COMPENT'
			lRet := Empty (xConteudo) .Or. VldExistCp( "DT3", xConteudo, @lMostraErr, TamSX3("DT3_CODPAS")[1] )
		Case AllTrim(cPar) == 'MV_COMPFLU'
			lRet := Empty (xConteudo) .Or. VldExistCp( "DT3", xConteudo, @lMostraErr, TamSX3("DT3_CODPAS")[1] )
		Case AllTrim(cPar) == 'MV_COMPIMP'
			lRet := Empty (xConteudo) .Or. VldExistCp( "DT3", xConteudo, @lMostraErr, TamSX3("DT3_CODPAS")[1] )
		Case AllTrim(cPar) == 'MV_COMPROD'
			lRet := Empty (xConteudo) .Or. VldExistCp( "DT3", xConteudo, @lMostraErr, TamSX3("DT3_CODPAS")[1] )
		Case AllTrim(cPar) == 'MV_DEPSVG'
			lRet := Empty(xConteudo) .Or. VldExistCp( "DT7",xConteudo, @lMostraErr, TamSX3("DT7_CODDES")[1] )
		Case AllTrim(cPar) == 'MV_DESABA'
			lRet := Empty(xConteudo) .Or. VldExistCp( "DT7",xConteudo, @lMostraErr, TamSX3("DT7_CODDES")[1] )
		Case AllTrim(cPar) == 'MV_DESADF'
			lRet := Empty(xConteudo) .Or. VldExistCp( "DT7",xConteudo, @lMostraErr, TamSX3("DT7_CODDES")[1] )
		Case AllTrim(cPar) == 'MV_DESAWB'
			lRet := Empty(xConteudo) .Or. VldExistCp( "DT7",xConteudo, @lMostraErr, TamSX3("DT7_CODDES")[1] )
		Case AllTrim(cPar) == 'MV_DESCTC'
			lRet := Empty(xConteudo) .Or. VldExistCp( "DT7",xConteudo, @lMostraErr, TamSX3("DT7_CODDES")[1] )
		Case AllTrim(cPar) == 'MV_DESDEP'
			lRet := Empty(xConteudo) .Or. VldExistCp( "DT7",xConteudo, @lMostraErr, TamSX3("DT7_CODDES")[1] )
		Case AllTrim(cPar) == 'MV_DESMOT'
			lRet := Empty(xConteudo) .Or. VldExistCp( "DT7",xConteudo, @lMostraErr, TamSX3("DT7_CODDES")[1] )
		Case AllTrim(cPar) == 'MV_DESPDG'
			lRet := Empty(xConteudo) .Or. VldExistCp( "DT7",xConteudo, @lMostraErr, TamSX3("DT7_CODDES")[1] )
		Case AllTrim(cPar) == 'MV_DESPRE'
			lRet := Empty(xConteudo) .Or. VldExistCp( "DT7",xConteudo, @lMostraErr, TamSX3("DT7_CODDES")[1] )
		Case AllTrim(cPar) == 'MV_DESABST'
			lRet := Empty(xConteudo) .Or. VldExistCp( "DT7",xConteudo, @lMostraErr, TamSX3("DT7_CODDES")[1] )
		Case AllTrim(cPar) == 'MV_DESSALD'
			lRet := Empty(xConteudo) .Or. VldExistCp( "DT7",xConteudo, @lMostraErr, TamSX3("DT7_CODDES")[1] )
		Case AllTrim(cPar) == 'MV_DESSAQ'
			lRet := Empty(xConteudo) .Or. VldExistCp( "DT7",xConteudo, @lMostraErr, TamSX3("DT7_CODDES")[1] )
		Case AllTrim(cPar) == 'MV_DESSEG'
			lRet := Empty(xConteudo) .Or. VldExistCp( "DT7",xConteudo, @lMostraErr, TamSX3("DT7_CODDES")[1] )
		Case AllTrim(cPar) == 'MV_DESVEI'
			lRet := Empty(xConteudo) .Or. VldExistCp( "DT7",xConteudo, @lMostraErr, TamSX3("DT7_CODDES")[1] )
		Case AllTrim(cPar) == 'MV_DOMFERI'
			lRet := Empty(xConteudo) .Or. AllTrim (xConteudo) $ 'S;N'
		Case AllTrim(cPar) == 'MV_EDIDIRE'
			lRet := Empty(xConteudo) .Or. ExistDir (AllTrim (xConteudo))
		Case AllTrim(cPar) == 'MV_EDIDIRR'
			lRet := Empty(xConteudo) .Or. ExistDir (AllTrim (xConteudo))
		Case AllTrim(cPar) == 'MV_EDIRMOV'
			lRet := Empty(xConteudo) .Or. ExistDir (AllTrim (xConteudo))
		Case AllTrim(cPar) == 'MV_ENCVIAG'
			lRet := Empty(xConteudo) .Or. AllTrim (xConteudo) $ '1;2'
		Case AllTrim(cPar) == 'MV_ENREPOM'
			lRet := Empty(xConteudo) .Or. AllTrim (xConteudo) $ '1;2;3;4'
		Case AllTrim(cPar) == 'MV_ENTAER'
			lRet := Empty(xConteudo) .Or. AllTrim (xConteudo) $ '1;2'
		Case AllTrim(cPar) == 'MV_FORGEN'
			lRet := Empty(xConteudo) .Or. VldExistCp( "SA2", xConteudo, @lMostraErr, TamSX3("A2_COD")[1] + TamSX3("A2_LOJA")[1] )
		Case AllTrim(cPar) == 'MV_FORSEG'
			lRet := Empty(xConteudo) .Or. VldExistCp( "SA2", xConteudo, @lMostraErr, TamSX3("A2_COD")[1] + TamSX3("A2_LOJA")[1] )
		Case AllTrim(cPar) == 'MV_MNTSVG'
			lRet := Empty(xConteudo) .Or. VldExistCp( "DT7", xConteudo, @lMostraErr, TamSX3("DT7_CODDES")[1] )
		Case AllTrim(cPar) == 'MV_MOTGEN'
			lRet := Empty(xConteudo) .Or. VldExistCp( "DA4", xConteudo, @lMostraErr, TamSX3("DA4_COD")[1] )
		Case AllTrim(cPar) == 'MV_MOTSVG'
			lRet := Empty(xConteudo) .Or. VldExistCp( "DT7", xConteudo, @lMostraErr, TamSX3("DT7_CODDES")[1] )
		Case AllTrim(cPar) == 'MV_NATCTC'
			lRet := Empty(xConteudo) .Or. VldExistCp( "SED", xConteudo, @lMostraErr, TamSX3("ED_CODIGO")[1] )
		Case AllTrim(cPar) == 'MV_NATDEB'
			lRet := Empty(xConteudo) .Or. VldExistCp( "SED", xConteudo, @lMostraErr, TamSX3("ED_CODIGO")[1] )
		Case AllTrim(cPar) == 'MV_NATPDG'
			lRet := Empty(xConteudo) .Or. VldExistCp( "SED", xConteudo, @lMostraErr, TamSX3("ED_CODIGO")[1] )
		Case AllTrim(cPar) == 'MV_NATTXBA'
			lRet := Empty(xConteudo) .Or. VldExistCp( "SED", xConteudo, @lMostraErr, TamSX3("ED_CODIGO")[1] )
		Case AllTrim(cPar) == 'MV_NGMNTMS'
			lRet := Empty(xConteudo) .Or. AllTrim (xConteudo) $ 'S;N'
		Case AllTrim(cPar) == 'MV_NTLAWB'
			lRet := Empty(xConteudo) .Or. VldExistCp( "SED", xConteudo, @lMostraErr, TamSX3("ED_CODIGO")[1] )
		Case AllTrim(cPar) == 'MV_OCORAUT'
			If !Empty(xConteudo)
				DT2->(dbSetOrder(1))
				If DT2->(DbSeek(xFilial("DT2") + xConteudo)) .And. !(DT2->DT2_TIPOCO $ '01,04, 05')
					lRet:=.F.
					Alert(STR0059) //-- "A ocorrencia preenchida só pode ser dos tipos 01, 04 ou 05"
				EndIf
			EndIf
		Case AllTrim(cPar) == 'MV_OCORARM'
			lRet := Empty(xConteudo) .Or. VldExistCp( "DT2", xConteudo, @lMostraErr, TamSX3("DT2_CODOCO")[1] )
		Case AllTrim(cPar) == 'MV_OCORCAN'
			lRet := Empty(xConteudo) .Or. VldExistCp( "DT2", xConteudo, @lMostraErr, TamSX3("DT2_CODOCO")[1] )
		Case AllTrim(cPar) == 'MV_OCORCFE'
			lRet := Empty(xConteudo) .Or. VldExistCp( "DT2", xConteudo, @lMostraErr, TamSX3("DT2_CODOCO")[1] )
		Case AllTrim(cPar) == 'MV_OCORCOL'
			lRet := Empty(xConteudo) .Or. VldExistCp( "DT2", xConteudo, @lMostraErr, TamSX3("DT2_CODOCO")[1] )
		Case AllTrim(cPar) == 'MV_OCORENT'
			lRet := Empty(xConteudo) .Or. VldExistCp( "DT2", xConteudo, @lMostraErr, TamSX3("DT2_CODOCO")[1] )
		Case AllTrim(cPar) == 'MV_OCORREE'
			lRet := Empty(xConteudo) .Or. VldExistCp( "DT2", xConteudo, @lMostraErr, TamSX3("DT2_CODOCO")[1] )
		Case AllTrim(cPar) == 'MV_PAPTOJF'
			lRet := Empty(xConteudo) .Or. AllTrim (xConteudo) $ '0;1'
		Case AllTrim(cPar) == 'MV_PESCOB'
			lRet := Empty(xConteudo) .Or. VldExistCp( "DT3", xConteudo, @lMostraErr, TamSX3("DT3_CODPAS")[1] )
		Case AllTrim(cPar) == 'MV_PRLAWB'
			lRet := Empty (xConteudo) .Or. VldExistCp( "SX5", "05" + xConteudo, @lMostraErr, TamSX3("X5_CHAVE")[1] )
		Case AllTrim(cPar) == 'MV_PRODINS'
			lRet := Empty(xConteudo) .Or. VldExistCp( "SB1", xConteudo, @lMostraErr, TamSX3("B1_COD")[1] )
		Case AllTrim(cPar) == 'MV_PROGEN'
			lRet := Empty(xConteudo) .Or. VldExistCp( "SB1", xConteudo, @lMostraErr, TamSX3("B1_COD")[1] )
		Case AllTrim(cPar) == 'MV_ROTGCOL'
			lRet := Empty(xConteudo) .Or. VldExistCp( "DA8", xConteudo, @lMostraErr, TamSX3("DA8_COD")[1] )
		Case AllTrim(cPar) == 'MV_ROTGENT'
			lRet := Empty (xConteudo) .Or. VldExistCp( "DA8", xConteudo, @lMostraErr, TamSX3("DA8_COD")[1] )
		Case AllTrim(cPar) == 'MV_ROTGTAB'
			lRet := Empty (xConteudo) .Or. VldExistCp( "DA8", xConteudo, @lMostraErr, TamSX3("DA8_COD")[1] )
		Case AllTrim(cPar) == 'MV_SABFERI'
			lRet := Empty (xConteudo) .Or. AllTrim (xConteudo) $ 'S;N'
		Case AllTrim(cPar) == 'MV_SELDOC'
			lRet := Empty(xConteudo) .Or. AllTrim (xConteudo) $ '1;2'
		Case AllTrim(cPar) == 'MV_SERARM'
			lRet := Empty (xConteudo) .Or. VldExistCp( "SX5", "L4" + xConteudo, @lMostraErr, TamSX3("X5_CHAVE")[1] )
		Case AllTrim(cPar) == 'MV_SERISP'
			lRet := Empty (xConteudo) .Or. VldExistCp( "ST4", xConteudo, @lMostraErr, TamSX3("T4_SERVICO")[1] )
		Case AllTrim(cPar) == 'MV_SRVALI'
			lRet := Empty (xConteudo) .Or. VldExistCp( "SX5", "L4" + xConteudo, @lMostraErr, TamSX3("X5_CHAVE")[1] )
		Case AllTrim(cPar) == 'MV_SVCENT'
			lRet := Empty (xConteudo) .Or. VldExistCp( "SX5", "L4" + xConteudo, @lMostraErr, TamSX3("X5_CHAVE")[1] )
		Case AllTrim(cPar) == 'MV_SVCLOT'
			lRet :=Empty (xConteudo) .Or. VldExistCp( "SX5", "L4" + xConteudo, @lMostraErr, TamSX3("X5_CHAVE")[1]  )
		Case AllTrim(cPar) == 'MV_TESANUL'
			lRet := Empty (xConteudo) .Or. VldExistCp( "SF4", xConteudo, @lMostraErr, TamSX3("F4_CODIGO")[1] )
		Case AllTrim(cPar) == 'MV_TESAWB'
			lRet := Empty (xConteudo) .Or. VldExistCp( "SF4", xConteudo, @lMostraErr, TamSX3("F4_CODIGO")[1] )
		Case AllTrim(cPar) == 'MV_TMSADCV'
			lRet := Empty (xConteudo) .Or. VldExistCp( "DD0", xConteudo, @lMostraErr, TamSX3("DD0_CODDOC")[1] )
		Case AllTrim(cPar) == 'MV_TMSBL70'
			lRet := Empty(xConteudo) .Or. AllTrim (xConteudo) $ '1;2'
		Case AllTrim(cPar) == 'MV_TMSCRET'
			lRet := Empty (xConteudo) .Or. VldExistCp( "SX5","37"+xConteudo, @lMostraErr, TamSX3("X5_CHAVE")[1] )
		Case AllTrim(cPar) == 'MV_TMSDTVC'
			lRet := Empty(xConteudo) .Or. AllTrim (xConteudo) $ '1;2'
		Case AllTrim(cPar) == 'MV_TMSLOCP'
			lRet := Empty (xConteudo) .Or. VldExistCp( "NNR", xConteudo, @lMostraErr, TamSX3("NNR_CODIGO")[1] )
		Case AllTrim(cPar) == 'MV_TMSMFAT'
			lRet := Empty(xConteudo) .Or. AllTrim (xConteudo) $ '1;2'
			If lRet .And. AllTrim (cTmserp) == "1" .And. AllTrim (xConteudo) != "2"
				lRet       := .F.
				lMostraErr := .F.
				//-- Nao e possivel definir um modo de faturamento diferente de 2 (atraves do DT6)
				//-- enquanto a integracao com o ERP Datasul estiver parametrizada (MV_TMSERP = 1).
				Help("", 1, "TMSXFUND04")
			EndIf
		Case AllTrim(cPar) == 'MV_TMSOPDG'
			lRet := Empty(xConteudo) .Or. AllTrim (xConteudo) $ '0;1;2'
		Case AllTrim(cPar) == 'MV_TMSREST'
			lRet := Empty (xConteudo) .Or. VldExistCp( "DT2", xConteudo, @lMostraErr, TamSX3("DT2_CODOCO")[1] )
		Case AllTrim(cPar) == 'MV_TMSTIPT'
			lRet := Empty (xConteudo) .Or. VldExistCp( "SX5","05"+xConteudo, @lMostraErr, TamSX3("X5_CHAVE")[1], AllTrim(cPar) )
		Case AllTrim(cPar) == 'MV_TPDCARM'
			lRet := Empty (xConteudo) .Or. AllTrim (xConteudo) $ 'E;F'
		Case AllTrim(cPar) == 'MV_TPDCREE'
			lRet :=	 Empty (xConteudo) .Or. AllTrim (xConteudo) $ '2;5'
		Case AllTrim(cPar) == 'MV_PCANOP'
			lRet := Empty (xConteudo) .Or. AllTrim (xConteudo) $ '0,1,2,3'
		Case AllTrim(cPar) == 'MV_TPTCTC'
			lRet := Empty (xConteudo) .Or. VldExistCp( "SX5","05"+xConteudo, @lMostraErr, TamSX3("X5_CHAVE")[1] )
		Case AllTrim(cPar) == 'MV_TPTPDG'
			lRet := Empty (xConteudo) .Or. VldExistCp( "SX5","05"+xConteudo, @lMostraErr, TamSX3("X5_CHAVE")[1] )
		Case AllTrim(cPar) == 'MV_TPTPRE'
			lRet :=Empty (xConteudo) .Or. VldExistCp( "SX5","05"+xConteudo, @lMostraErr, TamSX3("X5_CHAVE")[1] )
		Case AllTrim(cPar) == 'MV_TPTTAX'
			lRet :=Empty (xConteudo) .Or. VldExistCp( "SX5","05"+xConteudo, @lMostraErr, TamSX3("X5_CHAVE")[1] )
		Case AllTrim(cPar) == 'MV_VEIGEN'
			lRet := Empty (xConteudo) .Or. VldExistCp( "DA3", xConteudo , @lMostraErr, TamSX3("DA3_COD")[1] )
		Case AllTrim(cPar) == 'MV_VERBMOT'
			lRet := Empty (xConteudo) .Or. VldExistCp( "SRV", xConteudo , @lMostraErr, TamSX3("RV_COD")[1] )
		Case AllTrim(cPar) == 'MV_VSREPOM'
			lRet := Empty (xConteudo) .Or. AllTrim (xConteudo) $ '0|1|2|2.2'
		Case AllTrim(cPar) == 'MV_CDHISAP'
			lRet := Empty (xConteudo) .Or. VldExistCp( "DVI", xConteudo , @lMostraErr, TamSX3("DVI_CODHIS")[1])
		Case AllTrim (cPar) == 'MV_PRDCTC'
			lRet := Empty(xConteudo) .Or. VldExistCp( "SB1", xConteudo, @lMostraErr, TamSX3("B1_COD")[1] )
		Case AllTrim(cPar) == 'MV_DOCNAVB'
			If !Empty(xConteudo)
				aContPar := StrTokArr (xConteudo, ",")
				For nX := 1 to Len(aContPar)

				If !AllTrim(aContPar[nX]) $ '256789ABCDEFGHIJKLMNOP'
					lRet := .F.
					Exit
				EndIf

				Next nX
			EndIf
		Case AllTrim(cPar) == 'MV_UMOVENT'
			If !Empty(xConteudo)
				aContPar := StrTokArr (xConteudo, ";")
				dbSelectArea("DT2")
				dbSetOrder(1)
				For nX:=1  to Len(aContPar)
					//-- Entrega Realizada
					If nX == 1
						If DT2->(dbSeek(xFilial("DT2") + aContPar[nX]))
							If DT2->DT2_TIPOCO != "01" //-- Encerra processo coleta
								lRet:=.F.
								Alert(STR0006) //-- "A ocorrencia tem que ser do tipo encerra processo"
							EndIf
						EndIf
					EndIf
					//-- Entrega Parcial
					If nX == 2 .And. lRet
						If DT2->(dbSeek(xFilial("DT2")+ aContPar[nX]))
							If DT2->DT2_TIPOCO != "06" .And. DT2->DT2_TIPPND != "04" //--Ocorrencia de pendencia de documento
								lRet:=.F.
								Alert(STR0007) //-- "A ocorrencia tem que ser do tipo gera pendencia de documento"
							EndIf
						EndIf
					EndIf
					//-- Entrega nao realizada
					If nX == 3 .And. lRet
						If DT2->(dbSeek(xFilial("DT2") + aContPar[nX]))
							If DT2->DT2_TIPOCO != "04" //--Ocorrencia de Devolução de documento
								lRet:=.F.
								Alert(STR0008) //-- "A ocorrencia tem que ser do tipo devolução de documento"
							EndIf
						EndIf
					EndIf
				Next nX
			EndIf
		Case AllTrim(cPar) == 'MV_UMOVCOL'
			If !Empty(xConteudo)
				nX:=1
				aContPar := StrTokArr (xConteudo, ";")
				dbSelectArea("DT2")
				dbSetOrder(1)
				For nX:=1  to Len(aContPar)
					//-- Coleta Realizada
					If nX == 1
						If DT2->(dbSeek(xFilial("DT2") + aContPar[nX]))
							If DT2->DT2_TIPOCO != "01" //-- Encerra processo coleta
								lRet:=.F.
								Alert(STR0006) //-- "A ocorrencia tem que ser do tipo encerra processo"
							EndIf
						EndIf
					EndIf
					//-- Coleta nao realizada
					If nX == 2 .And. lRet
						If DT2->(dbSeek(xFilial("DT2") + aContPar[nX]))
							If DT2->DT2_TIPOCO != "04" //--Ocorrencia de Devolução de documento
								lRet:=.F.
								Alert(STR0008) //-- "A ocorrencia tem que ser do tipo devolução de documento"
							EndIf
						EndIf
					EndIf
					Next nX
			EndIf
		Case AllTrim(cPar) == 'MV_MODVIAG'
			lRet := Empty (xConteudo) .Or. AllTrim (xConteudo) $ '1,2'
		Case AllTrim(cPar) == 'MV_FATPREF'
			lRet := Len(AllTrim(xConteudo)) <= TamSx3("E1_PREFIXO")[1]
		Case AllTrim(cPar) == 'MV_TMSCGRF'
			lRet := Empty (xConteudo) .Or. AllTrim (xConteudo) $ '1,2'
		Case AllTrim(cPar) == 'MV_TMSERP'
			lRet := Empty(xConteudo) .Or. AllTrim (xConteudo) $ '0;1' //-- 0 - Protheus; 1 - Datasul
			If lRet .And. AllTrim (xConteudo) == "1" .And. AllTrim (cTmsmfat) != "2"
				lRet       := .F.
				lMostraErr := .F.
				//-- Integracao com o ERP Datasul (MV_TMSERP = 1) so podera ser parametrizada
				//-- caso o modo de faturamento seja a partir da DT6 (MV_TMSMFAT = 2).
				Help("", 1, "TMSXFUND03")
			EndIf
		Case AllTrim(cPar) == 'MV_COMPSER'
			lRet := Empty (xConteudo) .Or. VldExistCp( "DT3", xConteudo, @lMostraErr, TamSX3("DT3_CODPAS")[1] )
		Case AllTrim(cPar) == 'MV_TMSRDPU'
			lRet := Empty (xConteudo) .Or. AllTrim (xConteudo) $ 'F,S,C,N'
		Case AllTrim(cPar) == 'MV_TMS3GFE'
			lRet := Empty (xConteudo) .Or. AllTrim (xConteudo) $ 'F,S,C,N'
		Case AllTrim(cPar) == 'MV_CPLINT2'
			lRet := Empty (xConteudo) .Or. AllTrim (xConteudo) $ '1234' .And. Len(AllTrim(xConteudo)) <= TamSx3("DT6_FIMP")[1]
		Case AllTrim(cPar) == 'MV_TMSANTT'
			lRet := Empty (xConteudo) .Or. Len(AllTrim(xConteudo)) = 8  //Pela ANtt o RNTRC deve conter 8 dígitos
		Case AllTrim(cPar) == 'MV_MDFEAUT'
			lRet := Empty (xConteudo) .Or. AllTrim(Upper(xConteudo)) $ 'F||T||.T.||.F.'
		Case AllTrim(cPar) == 'MV_MDFEENC'
			lRet := Empty (xConteudo) .Or. AllTrim(AllToChar(xConteudo)) $ '0||1'
		Case AllTrim(cPar) == 'MV_SOLIAUT'
			lRet := Empty(xConteudo) .Or. AllTrim(xConteudo) $ '0;1;2'
		Case AllTrim(cPar) == 'MV_ATVCHPA'
			lRet := Empty(xConteudo) .Or. VldExistCp( "SX5","L3" + xConteudo, @lMostraErr, TamSX3("X5_CHAVE")[1] )
		Case AllTrim(cPar) == 'MV_ATVSAPA'
			lRet := Empty(xConteudo) .Or. VldExistCp( "SX5","L3" + xConteudo, @lMostraErr, TamSX3("X5_CHAVE")[1] )
		Case AllTrim(cPar) == 'MV_COLGFE'
			lRet := Empty(xConteudo) .Or. AllTrim(xConteudo) $ '0;1'
		Case AllTrim(cPar) == 'MV_MDFESRV'
			lRet := Empty(xConteudo) .Or. AllTrim(xConteudo) $ '2;3'			
	EndCase
	nCont++
EndDo

If !lRet .And. lMostraErr
	Help("",1,"TMSXFUND01")// Conteudo informado inválido! Informe um registro válido.
EnDIf

RestArea(aArea)
Return(lRet)


//===========================================================================================================
/* Função VldExistCp - Valida o ExistCpo
@author  	Rafael
@version 	P12
@build
@since 	04/09/2013
@return 	*/
//===========================================================================================================
Static Function VldExistCp( cAliasTab , xConteudo , lMostraErr, nTamKey, cPar )

Local lRet := .T.

Default cAliasTab 	:= " "
Default xConteudo 	:= " "
Default lMostraErr	:= .T.
Default nTamKey		:= 0
Default cPar        := ""

If cPar == "MV_TMSTIPT"
	lRet := !Empty(Tabela(SubStr(xConteudo,1,2),AllTrim(SubStr(xConteudo,At("=",xConteudo) + 1))))
ElseIf Len(Rtrim(xConteudo)) > nTamKey
	Help("",1,"TMSXFUND01")
	lRet := .F.
Else
	If Upper(cAliasTab) == 'SX5'
		lRet := !Empty(Tabela(SubStr(xConteudo,1,2), SubStr(xConteudo,3),.T.))
	Else
		lRet := ExistCpo(cAliasTab,xConteudo,1)
	EndIf
EndIf

If !lRet
	lMostraErr := .F.
EndIf

Return lRet

//-------------------------------------------------------------------------------------------------
/* {Protheus.doc} TmsClrQb
@autor		: Eduardo Alberti
@descricao	: Retorna As Classes De Risco e Grupos de Embalagens Incompativeis Com o Codigo Do
@descricao	: Produto, Numero da Nota Fiscal e Serie Passados Por Parametro.
@since		: Oct./2014
@using		: Divergencias Das Classes De Risco/Grupo Embalagens
@review	: Ao Final Do Desenvolvimento Mover Para TMSXFUND
*/
//-------------------------------------------------------------------------------------------------
Function TmsClrQb(aVetDiv,lVeNF,cProduto,cNfCli,cSerCli,cNumCTR,cSerCTR,nRecDTC,nRecDY4)

Local aArea		:= GetArea()
Local aArSB5		:= SB5->(GetArea())
Local aArDY3		:= DY3->(GetArea())
Local aSeqs		:= {}
Local aProds		:= {}
Local nI     		:= 0
Local nJ			:= 0
Local nPos     	:= 0
Local cTmp   		:= GetNextAlias()
Local cQuery 		:= ""
Local cQuery2 	:= ""
Local cSeqMax   	:= ""
Local cRet			:= "0001"
Local lRet			:= .t.
Local lSimp		:= .t.
Local lCalc		:= .t.
Local cDbType		:= TCGetDB()
Local cFuncNull	:= ""

Default cNfCli	:= ""
Default cSerCli	:= ""
Default cNumCTR	:= ""
Default cSerCTR	:= ""
Default cProduto	:= ""
Default nRecDTC	:= 0
Default nRecDY4	:= 0
Default aVetDiv	:= {}
Default lVeNf		:= .t.

// Tratamento para ISNULL em diferentes BD's
Do Case
	Case cDbType $ "DB2/POSTGRES"
		cFuncNull	:= "COALESCE"
	Case cDbType $ "ORACLE/INFORMIX"
  		cFuncNull	:= "NVL"
 	Otherwise
 		cFuncNull	:= "ISNULL"
EndCase

// Determina As Sequencias Ja Utilizadas
For nI := 1 To Len(aVetDiv)

		//cCodIn 	+= Iif(!Empty(cCodIn),"|","") + aVetDiv[nI,1] + aVetDiv[nI,2]
	cSeqMax := Iif(cSeqMax > aVetDiv[nI,3],cSeqMax,aVetDiv[nI,3])

	nPos 	 := aScan(aSeqs,aVetDiv[nI,03])
	If nPos == 0
		aAdd(aSeqs,aVetDiv[nI,03])
	EndIf

Next nI

	// Determina Se NF Utilizara Mesma Sequencia Para Todos Itens
If !(lVeNF) .And. ( nRecDTC > 0 .Or. nRecDY4 > 0 )

		// Identifica Se a NF Jah Se Encontra No Vetor De Sequencias De Quebras
	nPos := aScan(aVetDiv,{|x| x[5]+x[6] == cNfCli + cSerCli })

		// Se Aproveitar Mesma Sequencia De NF Já Existente, Nao Precisa Recalcular Incompatibilidades
	If !(lVeNF) .And. nPos > 0
		cRet := aVetDiv[nPos,3]
		lCalc:= .f.
	ElseIf nRecDTC > 0

		DbSelectArea("DTC")
		DTC->(DbGoTo(nRecDTC))

		cQuery := ""
		cQuery += " SELECT      DISTINCT DTC.DTC_CODPRO "
		cQuery += " FROM        " + RetSqlName("DTC") + " DTC "
		cQuery += " WHERE       DTC.DTC_FILIAL =  '" + xFilial("DTC") 		+ "' "
		cQuery += " AND         DTC.DTC_FILORI =  '" + DTC->DTC_FILORI 	+ "' "
		cQuery += " AND         DTC.DTC_LOTNFC =  '" + DTC->DTC_LOTNFC 	+ "' "
		cQuery += " AND         DTC.DTC_CLIREM =  '" + DTC->DTC_CLIREM 	+ "' "
		cQuery += " AND         DTC.DTC_LOJREM =  '" + DTC->DTC_LOJREM 	+ "' "
		cQuery += " AND         DTC.DTC_CLIDES =  '" + DTC->DTC_CLIDES 	+ "' "
		cQuery += " AND         DTC.DTC_LOJDES =  '" + DTC->DTC_LOJDES 	+ "' "
		cQuery += " AND         DTC.DTC_SERVIC =  '" + DTC->DTC_SERVIC 	+ "' "
		cQuery += " AND         DTC.DTC_NUMNFC =  '" + DTC->DTC_NUMNFC 	+ "' "
		cQuery += " AND         DTC.DTC_SERNFC =  '" + DTC->DTC_SERNFC 	+ "' "
		cQuery += " AND         DTC.D_E_L_E_T_ =  ' '	"

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTmp, .F., .T.)

		DbSelectArea(cTmp)
		(cTmp)->(DbGoTop())
		While (cTmp)->(!Eof())

			aAdd(aProds, (cTmp)->DTC_CODPRO)

			DbSelectArea(cTmp)
			(cTmp)->(DbSkip())
		EndDo
	Else

		DbSelectArea("DY4")
		DY4->(DbGoTo(nRecDY4))

		cQuery := ""
		cQuery += " SELECT      DISTINCT DY4.DY4_CODPRO "
		cQuery += " FROM        " + RetSqlName("DY4") + " DY4 "
		cQuery += " WHERE       DY4.DY4_FILIAL =  '" + xFilial("DY4") 		+ "' "
		cQuery += " AND         DY4.DY4_FILORI =  '" + DY4->DY4_FILORI 	+ "' "
		cQuery += " AND         DY4.DY4_LOTNFC =  '" + DY4->DY4_LOTNFC 	+ "' "
		cQuery += " AND         DY4.DY4_CLIREM =  '" + DY4->DY4_CLIREM 	+ "' "
		cQuery += " AND         DY4.DY4_LOJREM =  '" + DY4->DY4_LOJREM 	+ "' "
		cQuery += " AND         DY4.DY4_NUMNFC =  '" + DY4->DY4_NUMNFC 	+ "' "
		cQuery += " AND         DY4.DY4_SERNFC =  '" + DY4->DY4_SERNFC 	+ "' "
		cQuery += " AND         DY4.D_E_L_E_T_ =  ' '	"

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTmp, .F., .T.)

		DbSelectArea(cTmp)
		(cTmp)->(DbGoTop())
		While (cTmp)->(!Eof())

			aAdd(aProds, (cTmp)->DY4_CODPRO)

			DbSelectArea(cTmp)
			(cTmp)->(DbSkip())
		EndDo
	EndIf

	// Fecha Arquivo Temporario
	If Select(cTmp) > 0
		(cTmp)->(DbCloseArea())
	EndIf
Else

	aAdd(aProds,cProduto)

EndIf


If lCalc

	For nJ := 1 To Len(aProds)

		cProduto := aProds[nJ]

		If !Empty(cProduto)

			cQuery := ""
			cQuery += " SELECT	* "
			cQuery += " FROM 		( "

			For nI := 1 To 2

				If nI == 1
						// Pesquisa Incompatibilidade pelos campos DDT_RISCOP e DDT_GREMBP
					cQuery += " SELECT      " + cFuncNull + "(DDT.DDT_RISCOP,'" + Space(TamSx3("DDT_RISCOP")[1]) + "') AS DDT_RISCOP, "
					cQuery += "             " + cFuncNull + "(DDT.DDT_GREMBP,'" + Space(TamSx3("DDT_GREMBP")[1]) + "') AS DDT_GREMBP, "
					cQuery += "             " + cFuncNull + "(DDT.DDT_RISCOI,'" + Space(TamSx3("DDT_RISCOI")[1]) + "') AS DDT_RISCOI, "
					cQuery += "             " + cFuncNull + "(DDT.DDT_GREMBI,'" + Space(TamSx3("DDT_GREMBI")[1]) + "') AS DDT_GREMBI "
				Else
						// Pesquisa Incompatibilidade pelos campos DDT_RISCOI e DDT_GREMBI (Invertido)
					cQuery += " SELECT      " + cFuncNull + "(DDT.DDT_RISCOI,'" + Space(TamSx3("DDT_RISCOI")[1]) + "') AS DDT_RISCOP, "
					cQuery += "             " + cFuncNull + "(DDT.DDT_GREMBI,'" + Space(TamSx3("DDT_GREMBI")[1]) + "') AS DDT_GREMBP, "
					cQuery += "             " + cFuncNull + "(DDT.DDT_RISCOP,'" + Space(TamSx3("DDT_RISCOP")[1]) + "') AS DDT_RISCOI, "
					cQuery += "             " + cFuncNull + "(DDT.DDT_GREMBP,'" + Space(TamSx3("DDT_GREMBP")[1]) + "') AS DDT_GREMBI  "
				EndIf

				cQuery += " FROM        " + RetSqlName("SB1") + " SB1 "
				cQuery += " INNER JOIN  " + RetSqlName("SB5") + " SB5 "
				cQuery += " ON          SB5.B5_FILIAL   =  '" + xFilial("SB5") + "' "
				cQuery += " AND         SB5.B5_COD      =  SB1.B1_COD "
				cQuery += " AND         SB5.D_E_L_E_T_  =  ' ' "
				cQuery += " INNER JOIN  " + RetSqlName("DY3") + " DY3 "
				cQuery += " ON          DY3.DY3_FILIAL  =  '" + xFilial("DY3") + "' "
				cQuery += " AND         DY3.DY3_ONU     =  SB5.B5_ONU "
				cQuery += " AND         DY3.DY3_ITEM    =  SB5.B5_ITEM "
				cQuery += " AND         DY3.D_E_L_E_T_  =  ' ' "
				cQuery += " INNER JOIN  " + RetSqlName("DDT") + " DDT "
				cQuery += " ON          DDT.DDT_FILIAL  =  '" + xFilial("DDT") + "' "

				If nI == 1
					cQuery += " AND         DDT.DDT_RISCOP  =  DY3.DY3_NRISCO "
					cQuery += " AND         ((DDT.DDT_GREMBP  LIKE 	CASE "
					cQuery += "                                  	WHEN DY3.DY3_GRPEMB = '" + Space(TamSx3("DY3_GRPEMB")[1]) + "' THEN '%' "
					cQuery += "                                  	ELSE DY3.DY3_GRPEMB "
					cQuery += "                                  	END ) "
					cQuery += "             OR "
					cQuery += "             (DDT.DDT_GREMBP = '" + Space(TamSx3("DDT_GREMBP")[1]) + "' )) "
				Else
					cQuery += " AND         DDT.DDT_RISCOI  =  DY3.DY3_NRISCO "
					cQuery += " AND         ((DDT.DDT_GREMBI  LIKE	CASE "
					cQuery += "                                  	WHEN DY3.DY3_GRPEMB = '" + Space(TamSx3("DY3_GRPEMB")[1]) + "' THEN '%' "
					cQuery += "                                  	ELSE DY3.DY3_GRPEMB "
					cQuery += "                                  	END ) "
					cQuery += "             OR "
					cQuery += "             (DDT.DDT_GREMBI = '" + Space(TamSx3("DDT_GREMBI")[1]) + "' )) "
				EndIf

				cQuery += " AND         DDT.D_E_L_E_T_  =  ' ' "
				cQuery += " WHERE       SB1.B1_FILIAL   =  '" + xFilial("SB1") + "' "
				cQuery += " AND         SB1.B1_COD      =  '" + cProduto       + "' "
				cQuery += " AND         SB1.D_E_L_E_T_  =  ' ' "

				If nI == 1
					cQuery += " UNION " // Nao Utilizar "Union All"
				EndIf

			Next nI

			cQuery += " ) TRB "
			cQuery += " ORDER BY DDT_RISCOP, DDT_GREMBP, DDT_RISCOI, DDT_GREMBI "

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ponto de entrada utilizado para tratar query executada pela consulta.  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lTMSDIVQY
				cQuery2 := ExecBlock("TMSDIVQY",.F.,.F.,{cProduto,cQuery})
				cQuery	 := Iif(!Empty(cQuery2),cQuery2,cQuery)
			EndIf

			cQuery := ChangeQuery(cQuery)

				// Fecha Arquivo Temporario
			If Select(cTmp) > 0
				(cTmp)->(DbCloseArea())
			EndIf

			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTmp, .F., .T.)

			DbSelectArea(cTmp)
			(cTmp)->(DbGoTop())
			While (cTmp)->(!Eof())

				For nI := 1 To Len(aVetDiv)

					lSimp := Iif(Empty((cTmp)->DDT_GREMBI) .Or. Empty(aVetDiv[nI,2]),.T.,.F.)

					If ((cTmp)->DDT_RISCOI + Iif(lSimp,"",(cTmp)->DDT_GREMBI)) == (aVetDiv[nI,1] + Iif(lSimp,"",aVetDiv[nI,2]) )

						lRet 	:= .f.
						nPos 	:= aScan(aSeqs,aVetDiv[nI,03])

							// Deleta a Sequencia Incompativel
						If nPos > 0
							aDel(aSeqs,nPos)
							aSize(aSeqs,Len(aSeqs) -1)
						EndIf

							// Atualiza Cod. Do Produto Incompativel
						If !(cProduto $ aVetDiv[nI,11])

							aVetDiv[nI,11] += Iif(!Empty(aVetDiv[nI,11]),",","") + cProduto

						EndIf
					EndIf

				Next nI

				DbSelectArea(cTmp)
				(cTmp)->(DbSkip())
			EndDo

				// Se Nao Existe Incompatibilidade Inclui No Grupo '0001'
			If lRet
				cRet := "0001"
			Else
				If Len(aSeqs) > 0 // Se Sobraram Sequencias Compativeis, Inclui Na Primeira Sequencia Disponivel
					cRet := aSeqs[1]
				Else // Se Nao Sobraram Sequencias, Cria Nova Apartir da Ultima Utilizada
					cRet := Soma1(cSeqMax,Len(cSeqMax))
				EndIf
			EndIf

				// Define Se Todos Itens De Uma Mesma NF Terao a Mesma Sequencia (Notas Nao Podem Ser Quebradas Em Varios CTRs)
			If !(lVeNF)

					//-- Procura Dentro Do Vetor Se a NF Ja Existe
				For nI := 1 To Len(aVetDiv)
					If (aVetDiv[nI,5] + aVetDiv[nI,6]) ==  (cNfCli + cSerCli)
								// Se a Sequencia Existente For Maior Que a Calculada, Fica Com a Maior
						If 	aVetDiv[nI,3] >  cRet
							cRet := aVetDiv[nI,3]
						EndIf
					EndIf
				Next nI

					//-- Ajusta Sequencias Da NF Ja Gravada No Vetor
				For nI := 1 To Len(aVetDiv)
					If (aVetDiv[nI,5] + aVetDiv[nI,6]) ==  (cNfCli + cSerCli)
						aVetDiv[nI,3] := cRet
					EndIf
				Next nI

			EndIf
		EndIf

			// Posiciona No Compl. Produto
		DbSelectArea("SB5")
		DbSetOrder(1) //-- B5_FILIAL+B5_COD
		MsSeek(xFilial("SB5") + cProduto , .F.)

			// Posiciona Na Classificação ONU
		DbSelectArea("DY3")
		DbSetOrder(1) //-- DY3_FILIAL+DY3_ONU+DY3_ITEM
		MsSeek(xFilial("DY3") + SB5->B5_ONU + SB5->B5_ITEM, .F.)

			// Adiciona Nova Linha No Vetor Caso Nao Exista.
		nPos := aScan(aVetDiv,{|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6]+x[7]+x[8] == DY3->DY3_NRISCO + DY3->DY3_GRPEMB + cRet + cProduto + cNfCli + cSerCli + cNumCTR + cSerCTR })

		If nPos == 0
			aAdd(aVetDiv,{DY3->DY3_NRISCO, DY3->DY3_GRPEMB, cRet, cProduto, cNfCli, cSerCli, cNumCTR, cSerCTR, nRecDTC,nRecDY4,"" })
		EndIf

	Next nJ
Else
		// Adiciona Nova Linha No Vetor Caso Nao Exista.
	nPos := aScan(aVetDiv,{|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6]+x[7]+x[8] == DY3->DY3_NRISCO + DY3->DY3_GRPEMB + cRet + cProduto + cNfCli + cSerCli + cNumCTR + cSerCTR })

	If nPos == 0
		aAdd(aVetDiv,{DY3->DY3_NRISCO, DY3->DY3_GRPEMB, cRet, cProduto, cNfCli, cSerCli, cNumCTR, cSerCTR, nRecDTC,nRecDY4,"" })
	EndIf
EndIf

	// Ordena Vetor
If Len(aVetDiv) > 1
	aVetDiv := aSort(aVetDiv,,,{ |x,y| ( x[3]+x[1]+x[2] ) < ( y[3]+y[1]+y[2] ) } )
EndIf

	// Fecha Arquivo Temporario
If Select(cTmp) > 0
	(cTmp)->(DbCloseArea())
EndIf

	// Devolve Posicionamento Original Das Tabelas
RestArea(aArDY3)
RestArea(aArSB5)
RestArea(aArea)

Return(cRet)
/*/-----------------------------------------------------------
{Protheus.doc} TMSAgdVgVl()
Valida a data de Agendamento para o documento selecionado na viagem

Uso: SIGATMS

@sample
//TMSAgdVgVl()

@author Paulo Henrique Corrêa Cardoso.
@since 22/08/2014
@version 1.0
-----------------------------------------------------------/*/
Function TMSAgdVgVl(cFilDoc,cDoc,cSerie,dDatViagem,cHorViagem,lNoStop)
Local aRet 			:= {.T.,""}			// Recebe o Retorno
Local dDatAgend		:= STOD("//")		// Recebe a Data do Agendamento
Local cTipPeriod	:= ""				// Recebe o Tipo de Periodo de agendamento
Local nHoraIni		:= 0				// Recebe a Hora de Inicio do Agendamento
Local nHoraFim		:= 0				// Recebe a Hora de Fim do Agendamento
Local nHoraViag		:= 0				// Recebe a Hora da Viagem
Local cHoraIni		:= ""				// Recebe a Hora inicial Formatada
Local cHoraFim		:= ""				// Recebe a Hora final Formatada
Local cCliAgd        := ""				// Recebe o Cliente do documento
Local cLojAgd        := ""				// Recebe a loja do Cliente do documento
Local aAreaDt6       := DT6->(GetArea()) // Recebe a Area do DT6
Local lCarrMod2  := Left(FunName(),7) == "TMSA210"
Local aPERet     := {}

Default cFilDoc 	:= ""				// Recebe a Filial do Documento
Default cDoc		:= ""				// Recebe o Numero do Documento
Default cSerie		:= ""				// Recebe a Serie do Documento
Default dDatViagem	:= STOD("//")		// Recebe a Data da Viagem
Default cHorViagem	:= ""				// Recebe a Hora da Viagem
DEFAULT lNoStop     := !IsBlind()

If lCarrMod2 .And. lNoStop
	aRet := {.T.,""}
Else
	dbSelectArea("DYD")
	DYD->( dbSetOrder(2) )

	// Busca ultimo agendamento do Documento
	If DYD->( dbSeek( FwxFilial("DYD")+ cFilDoc + cDoc + cSerie ))
		DYD->( dbSeek( FwxFilial("DYD")+ cFilDoc + cDoc + cSerie + REPLICATE("Z",TamSx3("DYD_NUMAGD")[1]),.T.))
		DYD->(dbSkip(-1))

		If DYD->DYD_STATUS != '6' .AND. DYD->DYD_FILDOC == cFilDoc .AND. DYD->DYD_DOC == cDoc .AND. DYD->DYD_SERIE  == cSerie

			dDatAgend  := DYD->DYD_DATAGD
			cTipPeriod := DYD->DYD_PRDAGD
			cHoraIni   := TRANSFORM(DYD->DYD_INIAGD, PesqPict("DYD","DYD_INIAGD") )
			cHoraFim   := TRANSFORM(DYD->DYD_FIMAGD, PesqPict("DYD","DYD_FIMAGD") )
			nHoraIni   := DataHora2Str(dDatAgend,cHoraIni )
			nHoraFim   := DataHora2Str(dDatAgend,cHoraFim )
			nHoraViag  := DataHora2Str(dDatViagem,cHorViagem)
			cHoraIni   := TRANSFORM(cHoraIni, PesqPict("DYD","DYD_INIAGD") )
			cHoraFim   := TRANSFORM(cHoraFim, PesqPict("DYD","DYD_FIMAGD") )

			Do Case
				Case lTMSVLDYD 
					aPERet := ExecBlock("TMSVLDYD", .F., .F., {cFilDoc, cDoc, cSerie, DYD->DYD_TIPAGD, dDatAgend, cTipPeriod, cHoraIni, cHoraFim, nHoraIni, nHoraFim, dDatViagem, nHoraViag} )
					If ValType(aPERet) == "A"
						aRet := aPERet
					EndIf

				// Verifica se o tipo de agendamento eh "Pendente Agendamento"
				Case DYD->DYD_TIPAGD == "4"
					aRet := {.F.,STR0042}    //"Este documento está pendente de Agendamento de Entrega. Cliente configurado como uso obrigatório de agendamento."

				// Verifica se Data da Viagem eh diferente da Data de Agendamento
				Case dDatAgend != dDatViagem
					aRet := {.F.,STR0010}  //"Data da viagem diferente da data Agendada"

				// De
				Case cTipPeriod == "1" .AND.  nHoraIni > nHoraViag
					aRet := {.F.,STR0011 + cHoraIni } //"A hora de cadastro da viagem deve ser a partir de: "###

				// Ate
				Case cTipPeriod == "2" .AND.  nHoraFim < nHoraViag
					aRet := {.F.,STR0012 + cHoraFim} //"A hora de cadastro da viagem foi até: ###

				// De / Ate
				Case cTipPeriod == "3" .AND.  !( nHoraIni <= nHoraViag .AND. nHoraFim >= nHoraViag )
					aRet := {.F.,STR0013 + cHoraIni + STR0014 + cHoraFim} // "A hora de cadastro da viagem deve ser entre: "###" e "###

				// Na Hora
				Case cTipPeriod == "4" .AND.  nHoraIni != nHoraViag
					aRet := {.F.,STR0015 + cHoraIni} //"A hora de cadastro da viagem deve ser às: "###

				OtherWise
					aRet := {.T.,""}
			EndCase
		EndIf
	Else
		dbSelectArea("DT6")
		DT6->(DbSetOrder(1))
		DT6->(MsSeek(xFilial('DT6')+cFilDoc+cDoc+cSerie))

		cCliAgd := DT6->DT6_CLIDES
		cLojAgd := DT6->DT6_LOJDES

		If  TMS050Cpt(cCliAgd,cLojAgd) == '3'
			aRet := {.F., STR0044} //"Obrigatorio a digitação do Agendamento de Entrega para o Documento"
		EndIf

	EndIf

	RestArea(aAreaDt6)
EndIf


Return aRet
//-------------------------------------------------------------------------------------------------
/* {Protheus.doc} TmsRetDvP
@autor		: Eduardo Alberti
@descricao	: Retorna Os Produtos Divergentes Dos Produtos Que Foram Passados Por Parametro.
@since		: Jan./2015
@using		: Divergencias Das Classes De Risco/Grupo Embalagens
@review	:
*/
//-------------------------------------------------------------------------------------------------
Function TmsRtDvP(aProds)

	Local aArea		:= GetArea()
	Local nRecTMP		:= 0
	Local cAliasTMP     := ""
	Local cTmp   		:= GetNextAlias()
	Local cQuery		:= ""
	Local cQuery2		:= ""
	Local nI			:= 0
	Local nJ			:= 0
	Local aRet			:= {}
	Local cRet          := ""
	Local cProds		:= ""
	Local nTamProd      := TamSX3("B1_COD")[1]
	Local cDbType		:= TCGetDB()
	Local cFuncNull	    := ""
	Local nCount        := 0
	Local oTempTable    := Nil
	Local lRet          := .F.

	// Tratamento para ISNULL em diferentes BD's
	Do Case
		Case cDbType $ "DB2/POSTGRES"
			cFuncNull	:= "COALESCE"
		Case cDbType $ "ORACLE/INFORMIX"
	  		cFuncNull	:= "NVL"
	 	Otherwise
	 		cFuncNull	:= "ISNULL"
	EndCase

	Begin Sequence

		// Testa Se Vetor De Entrada Existe
		If ValType(aProds) <> "A"
			Break
		EndIf

		// Gera Variável De Pesquisa De Divergencias
		For nJ := 1 To Len(aProds)

			If !Empty(aProds[nJ]) .And. (!PadR(aProds[nJ],nTamProd) $ cProds)
				cProds += Iif(!Empty(cProds),",","") + PadR(aProds[nJ],nTamProd)
			EndIf
		Next nJ

		// Pesquisa Cadastro De Divergencias Conforme Produtos Passados
		If !Empty(cProds)

			cQuery := ""
			cQuery += " SELECT	* "
			cQuery += " FROM 		( "

			For nI := 1 To 2

				If nI == 1
					// Pesquisa Incompatibilidade pelos campos DDT_RISCOP e DDT_GREMBP
					cQuery += " SELECT      SB1.B1_COD, "
					cQuery += "             " + cFuncNull + "(DDT.DDT_RISCOP,'" + Space(TamSx3("DDT_RISCOP")[1]) + "') AS DDT_RISCOP, "
					cQuery += "             " + cFuncNull + "(DDT.DDT_GREMBP,'" + Space(TamSx3("DDT_GREMBP")[1]) + "') AS DDT_GREMBP, "
					cQuery += "             " + cFuncNull + "(DDT.DDT_RISCOI,'" + Space(TamSx3("DDT_RISCOI")[1]) + "') AS DDT_RISCOI, "
					cQuery += "             " + cFuncNull + "(DDT.DDT_GREMBI,'" + Space(TamSx3("DDT_GREMBI")[1]) + "') AS DDT_GREMBI "
				Else
					// Pesquisa Incompatibilidade pelos campos DDT_RISCOI e DDT_GREMBI (Invertido)
					cQuery += " SELECT      SB1.B1_COD, "
					cQuery += "             " + cFuncNull + "(DDT.DDT_RISCOI,'" + Space(TamSx3("DDT_RISCOI")[1]) + "') AS DDT_RISCOP, "
					cQuery += "             " + cFuncNull + "(DDT.DDT_GREMBI,'" + Space(TamSx3("DDT_GREMBI")[1]) + "') AS DDT_GREMBP, "
					cQuery += "             " + cFuncNull + "(DDT.DDT_RISCOP,'" + Space(TamSx3("DDT_RISCOP")[1]) + "') AS DDT_RISCOI, "
					cQuery += "             " + cFuncNull + "(DDT.DDT_GREMBP,'" + Space(TamSx3("DDT_GREMBP")[1]) + "') AS DDT_GREMBI  "
				EndIf

				cQuery += " FROM        " + RetSqlName("SB1") + " SB1 "
				cQuery += " INNER JOIN  " + RetSqlName("SB5") + " SB5 "
				cQuery += " ON          SB5.B5_FILIAL   =  '" + xFilial("SB5") + "' "
				cQuery += " AND         SB5.B5_COD      =  SB1.B1_COD "
				cQuery += " AND         SB5.D_E_L_E_T_  =  ' ' "
				cQuery += " INNER JOIN  " + RetSqlName("DY3") + " DY3 "
				cQuery += " ON          DY3.DY3_FILIAL  =  '" + xFilial("DY3") + "' "
				cQuery += " AND         DY3.DY3_ONU     =  SB5.B5_ONU "
				cQuery += " AND         DY3.DY3_ITEM    =  SB5.B5_ITEM "
				cQuery += " AND         DY3.D_E_L_E_T_  =  ' ' "
				cQuery += " INNER JOIN  " + RetSqlName("DDT") + " DDT "
				cQuery += " ON          DDT.DDT_FILIAL  =  '" + xFilial("DDT") + "' "

				If nI == 1
					cQuery += " AND         DDT.DDT_RISCOP  =  DY3.DY3_NRISCO "
					cQuery += " AND         ((DDT.DDT_GREMBP  LIKE 	CASE "
					cQuery += "                                  	WHEN DY3.DY3_GRPEMB = '" + Space(TamSx3("DY3_GRPEMB")[1]) + "' THEN '%' "
					cQuery += "                                  	ELSE DY3.DY3_GRPEMB "
					cQuery += "                                  	END ) "
					cQuery += "             OR "
					cQuery += "             (DDT.DDT_GREMBP = '" + Space(TamSx3("DDT_GREMBP")[1]) + "' )) "
				Else
					cQuery += " AND         DDT.DDT_RISCOI  =  DY3.DY3_NRISCO "
					cQuery += " AND         ((DDT.DDT_GREMBI  LIKE	CASE "
					cQuery += "                                  	WHEN DY3.DY3_GRPEMB = '" + Space(TamSx3("DY3_GRPEMB")[1]) + "' THEN '%' "
					cQuery += "                                  	ELSE DY3.DY3_GRPEMB "
					cQuery += "                                  	END ) "
					cQuery += "             OR "
					cQuery += "             (DDT.DDT_GREMBI = '" + Space(TamSx3("DDT_GREMBI")[1]) + "' )) "
				EndIf

				cQuery += " AND         DDT.D_E_L_E_T_  =  ' ' "
				cQuery += " WHERE       SB1.B1_FILIAL   =  '" + xFilial("SB1")       + "' "
				cQuery += " AND         SB1.B1_COD      IN  " + FormatIn(cProds,",") + "  "
				cQuery += " AND         SB1.D_E_L_E_T_  =  ' ' "

				If nI == 1
					cQuery += " UNION " // Nao Utilizar "Union All"
				EndIf

			Next nI

			cQuery += " ) TRB "
			cQuery += " ORDER BY B1_COD, DDT_RISCOP, DDT_GREMBP, DDT_RISCOI, DDT_GREMBI "

			//-------------------------------------------------------------------------------------------------
			// Ponto de entrada utilizado para tratar query executada pela consulta.
			//-------------------------------------------------------------------------------------------------
			If ExistBlock("TmsDvPQr")
				cQuery2 := ExecBlock("TmsDvPQr",.F.,.F.,{aProds,cQuery})
				cQuery	 := Iif(!Empty(cQuery2),cQuery2,cQuery)
			EndIf

			cQuery := ChangeQuery(cQuery)

			// Fecha Arquivo Temporario
			If Select(cTmp) > 0
				(cTmp)->(DbCloseArea())
			EndIf

			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTmp, .F., .T.)

			If Len(GetSrcArray("FWTEMPORARYTABLE.PRW")) > 0 .And. !(InTransaction())
				cRet := GetNextAlias()
				oTempTable := FWTemporaryTable():New(cRet)
				oTempTable:SetFields((cTmp)->(DbStruct()))
				oTempTable:AddIndex("01",{"B1_COD"})
				oTempTable:Create()
				cAliasTMP := oTempTable:GetAlias()
			EndIf

			//-- Dentro De Transação Cria Arquivo Temporário Por Job
			If Empty(cAliasTMP)
				cAliasTMP     := CriaTrab(Nil,.F.)

				StartJob("TmsCriaTab",GetEnvServer(),.T.,cEmpAnt,cFilAnt,.T.,{(cTmp)->(DbStruct()),cAliasTMP})

				//-- Aguarda Criação Do Arquivo Temporário
				For nCount := 1 To 10
				    If (cAliasTMP <> NIL) .And. (!Empty(cAliasTMP))
				    	lRet := IIF(TCCanOpen(cAliasTMP), .T., .F.)
				    EndIf

					If !lRet
						If nCount < 10
							Sleep(1000) //-- 01 Segundo
						Else
							cAliasTMP := ""
						EndIf
					Else
						DbUseArea(.T.,"TOPCONN",cAliasTMP,cAliasTMP,.F.,.F.)
						Exit
					EndIf
				Next nCount
			EndIf

			DbSelectArea(cTmp)
			(cTmp)->(DbGoTop())

			//-- Isola Erro Qdo Não Cria Arquivo Temporário
			If !Empty(cAliasTMP)

				Processa({||SqlToTrb(cQuery, (cTmp)->(DbStruct()), cAliasTMP)})

				// Fecha Arquivo Temporario
				If Select(cTmp) > 0
					(cTmp)->(DbCloseArea())
				EndIf

				// Pesquisa Divergencias Com Demais Produtos
				DbSelectArea(cAliasTMP)
				(cAliasTMP)->(DbGoTop())
				While (cAliasTMP)->(!Eof())

					// Guarda Posicionamento Do Arquivo Fisico
					nRecTMP:= (cAliasTMP)->(Recno())

					TmsRtDvPTp((cAliasTMP)->B1_COD,(cAliasTMP)->DDT_RISCOP,(cAliasTMP)->DDT_GREMBP,cAliasTMP,@aRet)

					// Devolve Posicionamento
					DbSelectArea(cAliasTMP)
					(cAliasTMP)->(DbGoTo(nRecTMP))

					DbSelectArea(cAliasTMP)
					(cAliasTMP)->(DbSkip())
				EndDo
			EndIf
		EndIf

	End Sequence

	//-------------------------------------------------------------------------------------------------
	// Deleta Arquivo de Trabalho
	//-------------------------------------------------------------------------------------------------
	If !Empty(cAliasTMP) .And. Select(cAliasTMP) > 0
		(cAliasTMP)->(DbCloseArea())
		Ferase(cAliasTMP  + GetDbExtension())	// Arquivo de trabalho
	EndIf

	RestArea(aArea)

Return(aRet)
//-------------------------------------------------------------------------------------------------
/* {Protheus.doc} TmsRtDvPTp
@autor		: Eduardo Alberti
@descricao	: Calcula Divergencias No Arquivo Temporário
@since		: Jan./2015
@using		: TmsRtDvP - Divergencias Das Classes De Risco/Grupo Embalagens
@review	:
*/
//-------------------------------------------------------------------------------------------------
Static Function TmsRtDvPTp(cProd,cRiscoP,cGrEmbP,cTmp,aRet)

	Local nRecTMP:= (cTmp)->(Recno())
	Local lSimp  := .f.
	Local nPos   := 0

	// Pesquisa Divergencias Com Demais Produtos
	DbSelectArea(cTmp)
	(cTmp)->(DbGoTop())
	While (cTmp)->(!Eof())

		If (cTmp)->B1_COD <> cProd

			lSimp := Iif(Empty((cTmp)->DDT_GREMBI) .Or. Empty(cGrEmbP),.T.,.F.)
			nPos  := aScan(aRet,{|x| x[1] == cProd})

			If ((cTmp)->DDT_RISCOI + Iif(lSimp,"",(cTmp)->DDT_GREMBI)) == (cRiscoP + Iif(lSimp,"",cGrEmbP) )

				If nPos == 0
					aAdd(aRet,{cProd,(cTmp)->B1_COD})
				Else
					If !(cTmp)->B1_COD $ aRet[nPos,2]
						aRet[nPos,2] += Iif(!Empty(aRet[nPos,2]),",","") + (cTmp)->B1_COD
					EndIf
				EndIf
			Else
				If nPos == 0
					aAdd(aRet,{cProd,""})
				EndIf
			EndIf
		EndIf

		DbSelectArea(cTmp)
		(cTmp)->(DbSkip())
	EndDo

	DbSelectArea(cTmp)
	(cTmp)->(DbGoTo(nRecTMP))

Return()


//-------------------------------------------------------------------------------------------------
/* {Protheus.doc} TmsVeiViag
@autor		: Katia
@descricao	: Retorna os Veiculos e Motoristas da Viagem
@descricao	: aVeiViag - Veiculos da Viagem, aMotViag - Motoristas da Viagem
@since		: 23/03/2015
@using		: RRE - Regra de Restricao de Embarque
*/
//-------------------------------------------------------------------------------------------------
Function TmsVeiViag(cFilOri,cViagem,aVeiViag,aMotViag,aTipos)

Local cQuery     := ""
Local cAliasQry  := GetNextAlias()
Local nIdade     := ""
Local nPos       := 0
Local cDbType		:= TCGetDB()
Local cFuncNull  := ""
Local cVeiculos  := ""
Local lDataVld   := .F.
Local dDatIniVge := CtoD(Space(08))
Local dDatFimVge := CtoD(Space(08))
Local cTipMot    := ""
Local lNumVld    := .T.
Local lTercRbq    := DTR->(ColumnPos("DTR_CODRB3")) > 0

Default cFilOri  := ""
Default cViagem  := ""
Default aVeiViag := {}
Default aMotViag := {}
Default aTipos   := {}

// Tratamento para ISNULL em diferentes BD's
Do Case
	Case cDbType $ "DB2/POSTGRES"
		cFuncNull	:= "COALESCE"
	Case cDbType $ "ORACLE/INFORMIX"
  		cFuncNull	:= "NVL"
 	Otherwise
 		cFuncNull	:= "ISNULL"
EndCase

//Composição array aVeiViag
//1- Veiculo
//2- Tipo de Veiculo
//3- Frota do Veiculo
//4- Idade do Veiculo
//5- Dt Inicio Liberacao Seguro
//6- Dt Fim Liberacao Seguro
//7- Indica se Dt Liberacao Seguro é valido
//8- Indica se o Numero de Liberacao é valido
//9- Numero da liberacao
//10- Caracteristicas Veiculo

//Composição array aMotViag
//1.1- Motorista
//1.2- Dt Inicio Liberacao Seguro
//1.3- Dt Fim Liberacao Seguro
//1.4- Indica se Dt Liberacao Seguro é valido
//1.5- Indica se o Numero de Liberação é valido
//1.6- Nro de Liberação
//1.7- Codigo Caracteristicas

cQuery := ""
cQuery += "SELECT DTR_ITEM, DTR_CODVEI, " + cFuncNull + "(DA3.DA3_TIPVEI, '') DA3_TIPVEI, " + cFuncNull + "(DA3.DA3_FROVEI,'') DA3_FROVEI,  " + cFuncNull + "(DA3.DA3_ANOFAB,'')  DA3_ANOFAB, "
cQuery += " DJA.DJA_LIBSEG DJA_LIBSEG, DJA.DJA_DTIVSG DJA_DTIVSG, DJA.DJA_DTFVSG DJA_DTFVSG , DJA.DJA_CHAVE DJA_CHAVE  , "
cQuery += " DTR_CODRB1, " + cFuncNull + "(DA31.DA3_TIPVEI,'') DA31_TIPVEI, " + cFuncNull + "(DA31.DA3_FROVEI,'') DA31_FROVEI , " + cFuncNull + "(DA31.DA3_ANOFAB,'') DA31_ANOFAB, "
cQuery += " DJA1.DJA_LIBSEG DJA1_LIBSEG, DJA1.DJA_DTIVSG DJA1_DTIVSG, DJA1.DJA_DTFVSG DJA1_DTFVSG , DJA1.DJA_CHAVE DJA1_CHAVE  ,"
cQuery += " DTR_CODRB2, " + cFuncNull + "(DA32.DA3_TIPVEI,'') DA32_TIPVEI, " + cFuncNull + "(DA32.DA3_FROVEI,'') DA32_FROVEI, " + cFuncNull + "(DA32.DA3_ANOFAB,'') DA32_ANOFAB, "
cQuery += " DJA2.DJA_LIBSEG DJA2_LIBSEG, DJA2.DJA_DTIVSG DJA2_DTIVSG, DJA2.DJA_DTFVSG DJA2_DTFVSG , DJA2.DJA_CHAVE DJA2_CHAVE  , "

If lTercRbq
	cQuery += " DTR_CODRB3, " + cFuncNull + "(DA33.DA3_TIPVEI,'') DA33_TIPVEI, " + cFuncNull + "(DA33.DA3_FROVEI,'') DA33_FROVEI, " + cFuncNull + "(DA33.DA3_ANOFAB,'') DA33_ANOFAB, "
	cQuery += " DJA3.DJA_LIBSEG DJA3_LIBSEG, DJA3.DJA_DTIVSG DJA3_DTIVSG, DJA3.DJA_DTFVSG DJA3_DTFVSG , DJA3.DJA_CHAVE DJA3_CHAVE  , "
EndIf

cQuery += " DTR_DATINI, DTR_DATFIM "
cQuery += " FROM " + RetSqlName("DTR")+ " DTR "

cQuery += " JOIN " + RetSqlName("DA3")+ " DA3 "
cQuery += " ON DA3.DA3_FILIAL = '" + xFilial('DA3') + "' "
cQuery += " AND DA3.DA3_COD = DTR_CODVEI "
cQuery += " AND DA3.D_E_L_E_T_=' ' "

cQuery += " LEFT JOIN " + RetSqlName("DA3")+ " DA31 "
cQuery += " ON DA31.DA3_FILIAL = '" + xFilial('DA3') + "' "
cQuery += " AND DA31.DA3_COD = DTR_CODRB1 "
cQuery += " AND DA31.D_E_L_E_T_=' ' "

cQuery += " LEFT JOIN " + RetSqlName("DA3")+ " DA32 "
cQuery += " ON DA32.DA3_FILIAL = '" + xFilial('DA3') + "' "
cQuery += " AND DA32.DA3_COD = DTR_CODRB2 "
cQuery += " AND DA32.D_E_L_E_T_=' ' "

If lTercRbq
	cQuery += " LEFT JOIN " + RetSqlName("DA3")+ " DA33 "
	cQuery += " ON DA33.DA3_FILIAL = '" + xFilial('DA3') + "' "
	cQuery += " AND DA33.DA3_COD = DTR_CODRB3 "
	cQuery += " AND DA33.D_E_L_E_T_=' ' "
EndIf

cQuery += " JOIN " + RetSqlName("DJA")+ " DJA "
cQuery += " ON DJA.DJA_FILIAL = '" + xFilial('DJA') + "' "
cQuery += " AND DJA.DJA_FILORI  = '" + cFilOri + "' "
cQuery += " AND DJA.DJA_VIAGEM = '" + cViagem + "' "
cQuery += " AND DJA.DJA_ALIAS = 'DA3' "
cQuery += " AND DJA.DJA_CHAVE = '" + xFilial('DA3') + "' || DTR_CODVEI "
cQuery += " AND DJA.D_E_L_E_T_=' ' "

cQuery += " LEFT JOIN " + RetSqlName("DJA")+ " DJA1 "
cQuery += " ON DJA1.DJA_FILIAL = '" + xFilial('DJA') + "' "
cQuery += " AND DJA1.DJA_FILORI  = '" + cFilOri + "' "
cQuery += " AND DJA1.DJA_VIAGEM = '" + cViagem + "' "
cQuery += " AND DJA1.DJA_ALIAS = 'DA3' "
cQuery += " AND DJA1.DJA_CHAVE = '" + xFilial('DA3')  + "' || DTR_CODRB1 "
cQuery += " AND DJA1.D_E_L_E_T_=' ' "

cQuery += " LEFT JOIN " + RetSqlName("DJA")+ " DJA2 "
cQuery += " ON DJA2.DJA_FILIAL = '" + xFilial('DJA') + "' "
cQuery += " AND DJA2.DJA_FILORI  = '" + cFilOri + "' "
cQuery += " AND DJA2.DJA_VIAGEM = '" + cViagem + "' "
cQuery += " AND DJA2.DJA_ALIAS = 'DA3' "
cQuery += " AND DJA2.DJA_CHAVE = '" + xFilial('DA3') + "' || DTR_CODRB2 "
cQuery += " AND DJA2.D_E_L_E_T_=' ' "

If lTercRbq
	cQuery += " LEFT JOIN " + RetSqlName("DJA")+ " DJA3 "
	cQuery += " ON DJA3.DJA_FILIAL = '" + xFilial('DJA') + "' "
	cQuery += " AND DJA3.DJA_FILORI  = '" + cFilOri + "' "
	cQuery += " AND DJA3.DJA_VIAGEM = '" + cViagem + "' "
	cQuery += " AND DJA3.DJA_ALIAS = 'DA3' "
	cQuery += " AND DJA3.DJA_CHAVE = '" + xFilial('DA3') + "' || DTR_CODRB3 "
	cQuery += " AND DJA3.D_E_L_E_T_=' ' "
EndIf

cQuery += " WHERE DTR_FILIAL = '" + xFilial('DTR') + "' "
cQuery += " AND DTR_FILORI  = '" + cFilOri + "' "
cQuery += " AND DTR_VIAGEM = '" + cViagem + "' "
cQuery += " AND DTR.D_E_L_E_T_=''
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
TcSetField(cAliasQry,"DTR_DATINI", "D", 8, 0)
TcSetField(cAliasQry,"DTR_DATFIM", "D", 8, 0)
TcSetField(cAliasQry,"DJA_DTIVSG", "D", 8, 0)
TcSetField(cAliasQry,"DJA_DTFVSG", "D", 8, 0)
TcSetField(cAliasQry,"DJA1_DTIVSG", "D", 8, 0)
TcSetField(cAliasQry,"DJA1_DTFVSG", "D", 8, 0)
TcSetField(cAliasQry,"DJA2_DTIVSG", "D", 8, 0)
TcSetField(cAliasQry,"DJA2_DTFVSG", "D", 8, 0)

If lTercRbq
	TcSetField(cAliasQry,"DJA3_DTIVSG", "D", 8, 0)
	TcSetField(cAliasQry,"DJA3_DTFVSG", "D", 8, 0)
EndIf

While !(cAliasQry)->(EoF())
	dDatIniVge:= (cAliasQry)->DTR_DATINI
	dDatFimVge:= (cAliasQry)->DTR_DATFIM

	TmsTipos((cAliasQry)->DTR_ITEM,(cAliasQry)->DA3_FROVEI ,cFilOri,cViagem,@aTipos)

	lDataVld:= TmsVldDtSg((cAliasQry)->DJA_DTIVSG, (cAliasQry)->DJA_DTFVSG,dDatIniVge,dDatFimVge,(cAliasQry)->DA3_FROVEI)

	lNumVld:= .T.
	If (cAliasQry)->DA3_FROVEI == '2' //Terceiro
		lNumVld := TmsVldNLib('DA3',(cAliasQry)->DJA_CHAVE,(cAliasQry)->DJA_LIBSEG,cFilOri,cViagem)
	EndIf

	nIdade :=  Year(dDataBase) - Val((cAliasQry)->DA3_ANOFAB)

	aAdd(aVeiViag, {(cAliasQry)->DTR_CODVEI,(cAliasQry)->DA3_TIPVEI,(cAliasQry)->DA3_FROVEI,nIdade,(cAliasQry)->DJA_DTIVSG, (cAliasQry)->DJA_DTFVSG,lDataVld,lNumVld,(cAliasQry)->DJA_LIBSEG,{} })

	If Empty(cVeiculos)
		cVeiculos:= " '" + (cAliasQry)->DTR_CODVEI + "' "
	Else
		cVeiculos+= ", '" + (cAliasQry)->DTR_CODVEI + "' "
	EndIf

	If !Empty((cAliasQry)->DTR_CODRB1)
		lDataVld:= TmsVldDtSg((cAliasQry)->DJA1_DTIVSG, (cAliasQry)->DJA1_DTFVSG,dDatIniVge,dDatFimVge,(cAliasQry)->DA31_FROVEI)

		lNumVld:= .T.
		If (cAliasQry)->DA31_FROVEI == '2' //Terceiro
			lNumVld := TmsVldNLib('DA3',(cAliasQry)->DJA1_CHAVE,(cAliasQry)->DJA1_LIBSEG,cFilOri,cViagem)
		EndIf

		nIdade :=  Year(dDataBase) - Val((cAliasQry)->DA31_ANOFAB)
		aAdd(aVeiViag, {(cAliasQry)->DTR_CODRB1,(cAliasQry)->DA31_TIPVEI,(cAliasQry)->DA31_FROVEI,nIdade,(cAliasQry)->DJA1_DTIVSG, (cAliasQry)->DJA1_DTFVSG,lDataVld,lNumVld,(cAliasQry)->DJA1_LIBSEG,{} })
		cVeiculos+= ", '" + (cAliasQry)->DTR_CODRB1 + "' "

		TmsTipos((cAliasQry)->DTR_ITEM,(cAliasQry)->DA31_FROVEI ,cFilOri,cViagem,@aTipos)
	EndIf

	If !Empty((cAliasQry)->DTR_CODRB2)
		lDataVld:= TmsVldDtSg((cAliasQry)->DJA2_DTIVSG, (cAliasQry)->DJA2_DTFVSG,dDatIniVge,dDatFimVge,(cAliasQry)->DA32_FROVEI)

		lNumVld:= .T.
		If (cAliasQry)->DA32_FROVEI == '2' //Terceiro
			lNumVld := TmsVldNLib('DA3',(cAliasQry)->DJA2_CHAVE,(cAliasQry)->DJA2_LIBSEG,cFilOri,cViagem)
		EndIf

		nIdade :=  Year(dDataBase) - Val((cAliasQry)->DA32_ANOFAB)
		aAdd(aVeiViag, {(cAliasQry)->DTR_CODRB2,(cAliasQry)->DA32_TIPVEI,(cAliasQry)->DA32_FROVEI,nIdade,(cAliasQry)->DJA2_DTIVSG, (cAliasQry)->DJA2_DTFVSG,lDataVld,lNumVld,(cAliasQry)->DJA2_LIBSEG,{} })
		cVeiculos+= ", '" + (cAliasQry)->DTR_CODRB2 + "' "

		TmsTipos((cAliasQry)->DTR_ITEM,(cAliasQry)->DA32_FROVEI ,cFilOri,cViagem,@aTipos)
	EndIf

	If lTercRbq
		If !Empty((cAliasQry)->DTR_CODRB3)
			lDataVld:= TmsVldDtSg((cAliasQry)->DJA3_DTIVSG, (cAliasQry)->DJA3_DTFVSG,dDatIniVge,dDatFimVge,(cAliasQry)->DA33_FROVEI)

			lNumVld:= .T.
			If (cAliasQry)->DA33_FROVEI == '2' //Terceiro
				lNumVld := TmsVldNLib('DA3',(cAliasQry)->DJA3_CHAVE,(cAliasQry)->DJA3_LIBSEG,cFilOri,cViagem)
			EndIf

			nIdade :=  Year(dDataBase) - Val((cAliasQry)->DA33_ANOFAB)
			aAdd(aVeiViag, {(cAliasQry)->DTR_CODRB3,(cAliasQry)->DA33_TIPVEI,(cAliasQry)->DA33_FROVEI,nIdade,(cAliasQry)->DJA3_DTIVSG, (cAliasQry)->DJA3_DTFVSG,lDataVld,lNumVld,(cAliasQry)->DJA3_LIBSEG,{} })
			cVeiculos+= ", '" + (cAliasQry)->DTR_CODRB3 + "' "

			TmsTipos((cAliasQry)->DTR_ITEM,(cAliasQry)->DA33_FROVEI ,cFilOri,cViagem,@aTipos)
		EndIf
	EndIf

	(cAliasQry)->(DbSkip())
EndDo
(cAliasQry)->(dbCloseArea())


//---- Caracteristicas do Veiculo
If !Empty(cVeiculos)
	cAliasQry  := GetNextAlias()
	cQuery := ""
	cQuery += "SELECT DJ8_CODVEI, " + cFuncNull + "(DJ8_CODCAR,'') CODCAR FROM " + RetSqlName("DJ8")+ " DJ8 "
	cQuery += " WHERE DJ8.DJ8_FILIAL = '" + xFilial('DJ8') + "' "
	cQuery += " AND DJ8.DJ8_CODVEI IN (" + cVeiculos + ") "
	cQuery += " AND DJ8.D_E_L_E_T_=' ' "
	cQuery += " ORDER BY DJ8_CODVEI, DJ8_CODCAR "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	While !(cAliasQry)->(EoF())
		nPos := Ascan( aVeiViag, { | e | e[1] == (cAliasQry)->DJ8_CODVEI } )
		If nPos > 0
			Aadd(aVeiViag[nPos][10], (cAliasQry)->CODCAR)
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())

	//---- Motorista da Viagem e Caracteristicas
	cAliasQry  := GetNextAlias()
	cQuery := ""
	cQuery += "SELECT DUP_CODMOT, " + cFuncNull + "(DJ2_CODCAR,'') CODCAR, "
	cQuery += cFuncNull + "(DJA.DJA_LIBSEG,'') DJA_LIBSEG, DJA_DTIVSG,  DJA_DTFVSG, DJA_CHAVE "
	cQuery += " FROM " + RetSqlName("DUP")+ " DUP "
	cQuery += " LEFT JOIN " + RetSqlName("DJ2")+ " DJ2 "
	cQuery += " ON DJ2.DJ2_FILIAL = '" + xFilial('DJ2') + "' "
	cQuery += " AND DJ2.DJ2_CODMOT = DUP_CODMOT "
	cQuery += " AND DJ2.D_E_L_E_T_=' ' "
	cQuery += " LEFT JOIN " + RetSqlName("DJA")+ " DJA "
	cQuery += " ON DJA.DJA_FILIAL = '" + xFilial('DJA') + "' "
	cQuery += " AND DJA.DJA_FILORI  = '" + cFilOri + "' "
	cQuery += " AND DJA.DJA_VIAGEM = '" + cViagem + "' "
	cQuery += " AND DJA.DJA_ALIAS = 'DA4' "
	cQuery += " AND DJA.DJA_CHAVE = '" + xFilial('DA4')  + "' || DUP_CODMOT "
	cQuery += " AND DJA.D_E_L_E_T_=' ' "
	cQuery += " WHERE DUP_FILIAL = '" + xFilial('DUP') +  "' "
	cQuery += " AND DUP_FILORI = '" + cFilOri +   "' "
	cQuery += " AND DUP_VIAGEM = '" + cViagem +   "' "
	cQuery += " AND DUP.D_E_L_E_T_='' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	TcSetField(cAliasQry,"DJA_DTIVSG", "D", 8, 0)
	TcSetField(cAliasQry,"DJA_DTFVSG", "D", 8, 0)
	While !(cAliasQry)->(EoF())
		nPos := Ascan( aMotViag, { | e | e[1] == (cAliasQry)->DUP_CODMOT } )
		If nPos == 0
			cTipMot:= Posicione("DA4",1,xFilial("DA4")+(cAliasQry)->DUP_CODMOT,"DA4_TIPMOT")

			lDataVld:= TmsVldDtSg((cAliasQry)->DJA_DTIVSG,(cAliasQry)->DJA_DTFVSG,dDatIniVge,dDatFimVge,cTipMot)

			lNumVld:= .T.
			If cTipMot == '2' //Terceiro
				lNumVld := TmsVldNLib('DA4',(cAliasQry)->DJA_CHAVE,(cAliasQry)->DJA_LIBSEG,cFilOri,cViagem)
			EndIf

			Aadd( aMotViag, {(cAliasQry)->DUP_CODMOT,(cAliasQry)->DJA_DTIVSG,(cAliasQry)->DJA_DTFVSG,lDataVld,lNumVld,(cAliasQry)->DJA_LIBSEG,{(cAliasQry)->CODCAR}})
		Else
			Aadd(aMotViag[nPos][7], (cAliasQry)->CODCAR)
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
EndIf

Return Nil


//-------------------------------------------------------------------------------------------------
/* {Protheus.doc} TmsRetRRE
@autor		: Katia
@descricao	: Retorna vetor com as Regras de Restrições
@since		: 23/03/2015
@using		: RRE - Regra de Restricao de Embarque
*/
//-------------------------------------------------------------------------------------------------
Function TmsRetRRE(aVetRRE,aVeiculo,aMotorista,cRotRRE,aListChk,cFilOri,cViagem,aTipos)

Local aArea     := GetArea()
Local cQryDJ7   := ""
Local nJ        := 0
Local cData     := DtoS(dDataBase)
Local nX        := 1
Local cMVCliGen := GetMV("MV_CLIGEN",,'')
Local cCliGen   := Left(Alltrim(cMVCliGen),Len(DTC->DTC_CLIDEV))
Local cLojGen   := Right(Alltrim(cMVCliGen),Len(DTC->DTC_LOJDEV))
Local aRet      := {}
Local nY        := 0
Local nPos      := 0
Local nZ        := 0
Local cCodRRE   := ""
Local nVlrRRE   := 0
Local lTabRRE   := AliasIndic("DJ4")
Local cTipMot   := ""
Local lBlqDJ5   := .F.
Local lRegDJ5   := .F.
Local lBlqVge   := DJ5->(FieldPos('DJ5_BLQVLR')) > 0
Local cTipFro   := ""
Local nYY       := 0
Local nTamTipos := 1
Local lViagem   := .f.

Default aVetRRE   := {}
Default aVeiculo  := {}
Default aMotorista:= {}
Default cRotRRE   := ""
Default aListChk  := {}
Default cFilOri   := ""
Default cViagem   := ""
Default aTipos    := {}

//-- Determina Valor Da Variável Após carregamento Do Default
lViagem := !Upper(cRotRRE) $ ("TMSA040|TMSA200|TMSA460")

//Composição array aVeiculo
//1- Veiculo
//2- Tipo de Veiculo
//3- Frota do Veiculo
//4- Idade do Veiculo
//5- Dt Ini Liberacao Seguro
//6- Dt Fim Liberacao Seguro
//7- Indica se Dt Liberacao Seguro é valido
//8- Indica se Nro Liberacao Seguro é valido
//9- Numero de Liberacao
//10- Array com Caracteristicas Veiculo

//Composição array aMotorista
//1.1- Motorista
//1.2- Dt Ini Liberacao Seguro
//1.3- Dt Fim Liberacao Seguro
//1.4- Indica se Dt Liberacao Seguro é valido
//1.5- Indica se Nro Liberacao Seguro é valido
//1.6- Nro Liberacao
//1.7- Array com Caracteristicas Motorista

//Composição array aVetRRE
//1- Cliente
//2- Loja
//3- Produto
//4- Qtde Volume
//5- Peso
//6- Peso Cubado
//7- Valor Total do Produto
//8- Codigo RRE
//9- Valor do RRE

//Composição array aRet
//1- Codigo RRE
//2- Cliente
//3- Loja
//4- Produto ou Gpo de Produto
//5- Tipo Bloqueio RRE  (VLR, LIV, PES, PES3, TIPV, TIPM, TIPF, CARM, CARV)
//6- Texto - Identificação do Bloqueio
//7- Codigo da Caracteristica            //Utilizado para o controle do bloqueio da rotina Motorista x Docto Exigido
//8- Codigo do Motorista e ou Veiculo    //Utilizado para o controle do bloqueio da rotina Motorista x Docto Exigido

//--- Tipo Bloqueio RRE
//VLR - Vlr Mercadoria
//LIV - Limite Idade Veiculo
//PES - PESO
//PES3- PESO CUBADO
//TIPV - Tipo Veiculo
//TIPM - Tipo Motorista
//TIPF - Tipo Frotas
//CARM - Caracteristicas Motorista
//CARV - Caracteristicas Veiculo

//-- Adiciona Vetor Somente Para Testes
//aAdd(aVetRRE,{'000002','01','PRODRRE001     ',01,2001,1300,100000.00,''})
//cRotRRE := 'TMSA200' //TmsRetRRE()

If lTabRRE
	nTamTipos:= IIf(Len(aTipos)>0,Len(aTipos),1)

	aSort(aVetRRE,,, {|x,y| x[1]+x[2] < y[1]+y[2]})  //Ordena por Cliente e Loja

	For nJ := 1 To Len(aVetRRE)

		cCliRRE := aVetRRE[nJ][1]
		cLojRRE := aVetRRE[nJ][2]
		cProduto:= aVetRRE[nJ][3]
		nQtdVol := aVetRRE[nJ][4]
		nPeso   := aVetRRE[nJ][5]
		nPesoM3 := aVetRRE[nJ][6]
		nValor  := aVetRRE[nJ][7]
		nVlrRRE := aVetRRE[nJ][9]
		cCodRRe := ""

		cGrupo  := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_GRUPO")

		If Empty(aVetRRE[nJ][8])   //Faz a pesquisa da RRE do Cliente

			For nYY:=1 To nTamTipos   //Pode ocorrer de ter mais de um veiculo e ou motorista quando a rotina for VIAGEM
				If lViagem .And. Len(aTipos)> 0
					cTipFro:= Right(aTipos[nYY],1)
					cTipMot:= Left(aTipos[nYY],1)
				EndIf

				cQryDJ4:= GetNextAlias()

				//REGRA DE BUSCA:
				//Pesquisa RRE por Cliente + Loja  - Tipo de Frota e Tipo de Motorista Especificos (Terceiro, Proprio, Agregado)
				//Pesquisa RRE por Cliente + Loja - Tipo de Frota e Tipo de Motorista TODOS
				//Pesquisa RRE por Cliente - Tipo de Frota e Tipo de Motorista Especificos (Terceiro, Proprio, Agregado)
				//Pesquisa RRE por Cliente - Tipo de Frota e Tipo de Motorista TODOS
				//Pesquisa RRE por Cliente Generico - Tipo de Frota e Tipo de Motorista Especificos (Terceiro, Proprio, Agregado)
				//Pesquisa RRE por Cliente Generico - Tipo de Frota e Tipo de Motorista TODOS

				For nX:= 1 To 3

					cQuery := " SELECT		DJ4_CODRRE, DJ4_CODCLI, DJ4_LOJCLI, DJ4_ABRANG, DJ4_RREVGE, DJ4_RRECOL, DJ4_RRECOT, DJ4_RRECAL "
					cQuery += " FROM " 		+ RetSqlName("DJ4") + " DJ4 "
					cQuery += " WHERE 		DJ4_FILIAL = '" + xFilial("DJ4") + "' "

					If nX == 1 		//Codigo Cliente + Loja
						cQuery += " AND 		DJ4_CODCLI = '" + cCliRRE + "' "
						cQuery += " AND 		DJ4_LOJCLI = '" + cLojRRE + "' "
						cQuery += " AND 		DJ4_ABRANG = '1' "
						If lViagem
							If  !Empty(cTipFro) .And. !Empty(cTipMot)
								cQuery += " AND	((DJ4_TIPFRO = '" + cTipFro + "'  AND DJ4_TIPMOT = '" + cTipMot + "') "
								cQuery += " OR (DJ4_TIPFRO = '4' AND DJ4_TIPMOT = '4') ) "
							Else  //Se nao informado o Tipo de Frota e Tipo de Motorista, vai procurar a regra TODOS
								cQuery += " AND  DJ4_TIPFRO = '4' AND DJ4_TIPMOT = '4' "
							EndIf
						EndIf


					ElseIf nX == 2	//Codigo Cliente
						cQuery += " AND 		DJ4_CODCLI = '" +  cCliRRE + "' "
						cQuery += " AND 		DJ4_ABRANG = '2' "
						If lViagem
							If  !Empty(cTipFro) .And. !Empty(cTipMot)
								cQuery += " AND	((DJ4_TIPFRO = '" + cTipFro + "'  AND DJ4_TIPMOT = '" + cTipMot + "') "
								cQuery += " OR (DJ4_TIPFRO = '4' AND DJ4_TIPMOT = '4') ) "
							Else  //Se nao informado o Tipo de Frota e Tipo de Motorista, vai procurar a regra TODOS
								cQuery += " AND  DJ4_TIPFRO = '4' AND DJ4_TIPMOT = '4' "
							EndIf
						EndIf

					ElseIf nX == 3	//Cliente Generico
						cQuery += " AND 		DJ4_CODCLI = '" + cCliGen + "' "
						cQuery += " AND 		DJ4_LOJCLI = '" + cLojGen + "' "
						If lViagem
							If  !Empty(cTipFro) .And. !Empty(cTipMot)
								cQuery += " AND	((DJ4_TIPFRO = '" + cTipFro + "'  AND DJ4_TIPMOT = '" + cTipMot + "') "
								cQuery += " OR (DJ4_TIPFRO = '4' AND DJ4_TIPMOT = '4') ) "
							Else //Se nao informado o Tipo de Frota e Tipo de Motorista, vai procurar a regra TODOS
								cQuery += " AND  DJ4_TIPFRO = '4' AND DJ4_TIPMOT = '4' "
							EndIf
						EndIf
					EndIf

					//-- Controla Data Validade Da RRE
					cQuery += " AND 			( 	('" + cData + "' BETWEEN 	DJ4_DATINI AND DJ4_DATFIM 		) OR "
					cQuery += " 					('" + cData + "' >= 			DJ4_DATINI AND DJ4_DATFIM = ' '	)	) "

					If Upper(cRotRRE) $ "TMSA200" //Calculo do Frete
						cQuery += " AND  DJ4_RRECAL = 'T' "
					ElseIf Upper(cRotRRE) $ "TMSA040"   //Cotação de Frete
						cQuery += " AND  DJ4_RRECOT = 'T' "
					ElseIf Upper(cRotRRE) $ "TMSA460"   //Solicitação de Coleta
						cQuery += " AND  DJ4_RRECOL = 'T' "
					Else   //Viagem
						cQuery += " AND  DJ4_RREVGE = 'T' "
					EndIf

					cQuery += " AND DJ4.D_E_L_E_T_ = ' ' "
					cQuery += " ORDER BY DJ4_TIPFRO, DJ4_TIPMOT "

					cQuery := ChangeQuery(cQuery)
					dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cQryDJ4, .F., .T.)

					If (cQryDJ4)->(!Eof())
						cCodRRE:= (cQryDJ4)->DJ4_CODRRE
						Exit
					EndIf
					//-- Fecha Arquivo Temporário
					If Select(cQryDJ4) > 0
						(cQryDJ4)->(dbCloseArea())
					EndIf
				Next nX
				//-- Fecha Arquivo Temporário
				If Select(cQryDJ4) > 0
					(cQryDJ4)->(dbCloseArea())
				EndIf

			Next nYY

			//-- Guarda o codigo da RRE
			If !Empty(cCodRRE)
				For nX := 1 To Len(aVetRRE)
					If aVetRRE[nX][1] + aVetRRE[nX][2] == cCliRRE + cLojRRE
						aVetRRE[nX][8]:= cCodRRE
					Else
						Exit
					EndIf

				Next nX
			EndIf
		Else
			cCodRRE:= aVetRRE[nJ][8]
		EndIf

		If !Empty(cCodRRE)
			DJ4->(DbSetOrder(1))
			If DJ4->(dbSeek(xFilial('DJ4')+cCodRRE))

				//-- Verifica Limite Valor (Total DJ4)
				If nVlrRRE > DJ4->DJ4_LME
					nPos := aScan(aRet,{|x| x[1]+x[2]+x[3]+x[4]+x[5] == DJ4->DJ4_CODRRE + DJ4->DJ4_CODCLI + DJ4->DJ4_LOJCLI + Space(Len(DTC->DTC_CODPRO)) + 'VLR' })
					If nPos == 0
						aAdd(aRet,{;
							DJ4->DJ4_CODRRE,;
							DJ4->DJ4_CODCLI,;
							DJ4->DJ4_LOJCLI,;
							Space(TamSX3('DJ5_CODPRO')[1]),;
							'VLR',;
							(	STR0016 + Alltrim(Transform( nVlrRRE ,PesqPict("DJ4","DJ4_LME"))) + ' ' + ;    //Valor Limite da Mercadoria:
								STR0017 + ': ' + cCodRRE + ' ' + ;   //Maior que Limite da Restrição:
								STR0043 + Alltrim(Transform( DJ4->DJ4_LME ,PesqPict("DJ4","DJ4_LME"))) ),;  //Limite Maximo Embarque:
								'',;
								''})
					EndIf
				EndIf

			    //-- Verifica veiculos (Tipo Frota e Idade Maxima Veiculo)
			   	If !Empty(DJ4->DJ4_TIPFRO)  .Or. !Empty(DJ4->DJ4_LIV)
				   For nY:= 1 To Len(aVeiculo)
						If !Empty(DJ4->DJ4_TIPFRO) .And. DJ4->DJ4_TIPFRO <> '4' //Todos
							If (DJ4->DJ4_TIPFRO == '2' .And. !aVeiculo[nY][3] $ ('2|1')) ;    //Agregado
							.Or. (DJ4->DJ4_TIPFRO == '3' .And. !aVeiculo[nY][3] $ ('3|1'));   //Terceiro
							.Or. (DJ4->DJ4_TIPFRO == '1'  .And. aVeiculo[nY][3] <> '1')	      //Propria

								nPos := aScan(aRet,{|x| x[1]+x[2]+x[3]+x[4]+x[5] == DJ4->DJ4_CODRRE + DJ4->DJ4_CODCLI + DJ4->DJ4_LOJCLI + Space(Len(DTC->DTC_CODPRO)) + 'TIPF' })
								If nPos == 0
									aAdd(aRet,{;
										DJ4->DJ4_CODRRE,;
										DJ4->DJ4_CODCLI,;
										DJ4->DJ4_LOJCLI,;
										Space(Len(DTC->DTC_CODPRO)),;
										'TIPF',;
										(	STR0019 + aVeiculo[nY][3] + ' ' +;    //Tipo de Frota:
										 	STR0020 + DJ4->DJ4_CODRRE + ' ' +;  //Diferente da Restrição:
										 	STR0021 + DJ4->DJ4_TIPFRO ),;   //Tipo:
										 	'',;
											''})
								EndIf
							EndIf
						EndIf
						If !Empty(DJ4->DJ4_LIV) .And. aVeiculo[nY][4] > DJ4->DJ4_LIV
							nPos := aScan(aRet,{|x| x[1]+x[2]+x[3]+x[4]+x[5] == DJ4->DJ4_CODRRE + DJ4->DJ4_CODCLI + DJ4->DJ4_LOJCLI + Space(Len(DTC->DTC_CODPRO))+ 'LIV' })
								If nPos == 0
									aAdd(aRet,{;
										DJ4->DJ4_CODRRE,;
										DJ4->DJ4_CODCLI,;
										DJ4->DJ4_LOJCLI,;
										Space(Len(DTC->DTC_CODPRO)),;
										'LIV',;
										(	STR0022 + Alltrim(Transform( aVeiculo[nY][4] ,PesqPict('DJ4','DJ4_LIV'))) + ' ' +;  //Idade do Veiculo
											STR0023 + Alltrim(DJ4->DJ4_CODRRE) + ' ' +;  //Superior ao Permitido pela Restrição:
											STR0024 + Alltrim(Transform( DJ4->DJ4_LIV ,PesqPict('DJ4','DJ4_LIV')))	 ),;  //Idade
											'',;
											''})
								EndIf
						EndIf
				   Next nY
				EndIf

				//-- Verificar Motoristas (Tipo Motorista)
				If !Empty(DJ4->DJ4_TIPMOT)
				   For nY:= 1 To Len(aMotorista)
						If !Empty(DJ4->DJ4_TIPMOT) .And. DJ4->DJ4_TIPMOT <> '4' //Todos
							cTipMot:= Posicione("DA4",1,xFilial("DA4")+aMotorista[nY][1],"DA4_TIPMOT")

							If (DJ4->DJ4_TIPMOT == '2' .And. !cTipMot $ ('2|1')) ;    //Agregado
							.Or. (DJ4->DJ4_TIPMOT == '3' .And. !cTipMot $ ('3|1'));   //Terceiro
							.Or. (DJ4->DJ4_TIPMOT == '1'  .And. cTipMot <> '1')	      //Propria

								nPos := aScan(aRet,{|x| x[1]+x[2]+x[3]+x[4]+x[5] == DJ4->DJ4_CODRRE + DJ4->DJ4_CODCLI + DJ4->DJ4_LOJCLI + Space(Len(DTC->DTC_CODPRO))+ 'TIPM' })
								If nPos == 0
										aAdd(aRet,{;
											DJ4->DJ4_CODRRE,;
											DJ4->DJ4_CODCLI,;
											DJ4->DJ4_LOJCLI,;
											Space(Len(DTC->DTC_CODPRO)),;
											'TIPM',;
											(	STR0025 + Posicione("DA4",1,xFilial("DA4")+aMotorista[nY][1],"DA4_TIPMOT") +' '+;  //Tipo de Motorista:
												STR0026 + Alltrim(DJ4->DJ4_CODRRE) +' '+;  //Diferente do Permitido pela Restrição:
												STR0021 + DJ4->DJ4_TIPMOT  ),;  //Tipo:
												'',;
												''})
								EndIf
							EndIf
						EndIf
				   Next nY
				EndIf

				lBlqDJ5 := .F.
				lRegDJ5 := .F.
				//--- Buscar o item da DJ5 a partir do valor do DJ5_VALMER
				//--- Pode haver mais de uma faixa de valor para o mesmo produto.
				cQryDJ5:= GetNextAlias()
				cQuery:= " SELECT 	DJ5_CODRRE, DJ5_ITEM, DJ5_CODGRP, DJ5_CODGRP, DJ5_CODPRO, DJ5_LIV, DJ5_VALMER, DJ5_TIPVEI, DJ5_PESO, DJ5_PESOM3 "
				If lBlqVge
					cQuery+= ", DJ5_BLQVLR "
				EndIf
				cQuery+= " FROM 		" +  RetSqlName("DJ5") + " DJ5 "
				cQuery+= " WHERE 		DJ5_FILIAL 	= '" + xFilial("DJ5") 	+ "' "
				cQuery+= " AND 		DJ5_CODRRE 	= '" + DJ4->DJ4_CODRRE 	+ "' "
				If !Empty(cProduto)
					cQuery+= " AND 		(DJ5_CODPRO	= '" + cProduto + "' "
					If !Empty(cGrupo)
						cQuery+= "      		OR DJ5_CODGRP = '" + cGrupo + "')"
					Else
						cQuery+= " ) "
					EndIf
				Else
					cQuery+= " AND DJ5_CODGRP = '" + cGrupo + "'"
				EndIf
				cQuery+= " AND DJ5_VALMER <=  " +  Str(nValor	, TamSX3("DJ5_VALMER")[1],TamSX3("DJ5_VALMER")[2])
				cQuery+= " AND 		DJ5.D_E_L_E_T_= ' ' "
				cQuery+= " ORDER BY DJ5_CODRRE, DJ5_VALMER DESC "
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cQryDJ5, .F., .T.)
				If (cQryDJ5)->(!Eof())
					lRegDJ5:= .T.
				EndIf

				If !lRegDJ5
					(cQryDJ5)->(dbCloseArea())

					cQryDJ5:= GetNextAlias()
					cQuery:= " SELECT 	DJ5_CODRRE, DJ5_ITEM, DJ5_CODGRP, DJ5_CODGRP, DJ5_CODPRO, DJ5_LIV, DJ5_VALMER, DJ5_TIPVEI, DJ5_PESO, DJ5_PESOM3 "
					If lBlqVge
						cQuery+= ", DJ5_BLQVLR "
					EndIf
					cQuery+= " FROM 		" +  RetSqlName("DJ5") + " DJ5 "
					cQuery+= " WHERE 		DJ5_FILIAL 	= '" + xFilial("DJ5") 	+ "' "
					cQuery+= " AND 		DJ5_CODRRE 	= '" + DJ4->DJ4_CODRRE 	+ "' "
					If !Empty(cProduto)
						cQuery+= " AND 		(DJ5_CODPRO	= '" + cProduto + "' "
						If !Empty(cGrupo)
							cQuery+= "      		OR DJ5_CODGRP = '" + cGrupo + "')"
						Else
							cQuery+= " ) "
						EndIf
					Else
						cQuery+= " AND DJ5_CODGRP = '" + cGrupo + "'"
					EndIf
					cQuery+= " AND DJ5_VALMER >=  " + Str(nValor	, TamSX3("DJ5_VALMER")[1],TamSX3("DJ5_VALMER")[2])
					cQuery+= " AND 		DJ5.D_E_L_E_T_= ' ' "
					cQuery+= " ORDER BY DJ5_CODRRE, DJ5_VALMER ASC "

					cQuery := ChangeQuery(cQuery)

					dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cQryDJ5, .F., .T.)
					If (cQryDJ5)->(!Eof())
						lRegDJ5:= .T.
					EndIf
				EndIf

				If lRegDJ5
					lBloqueia:= .T.
					If lBlqVge .And. (cQryDJ5)->DJ5_BLQVLR == '2'  //1=Sim,2=Nao
						lBloqueia:= .F.
					EndIf


					If !Empty((cQryDJ5)->DJ5_VALMER) .And. nValor >= (cQryDJ5)->DJ5_VALMER .And. lBloqueia

						aAdd(aRet,{;
							DJ4->DJ4_CODRRE,;
							DJ4->DJ4_CODCLI,;
							DJ4->DJ4_LOJCLI,;
							Iif(!Empty((cQryDJ5)->DJ5_CODPRO),(cQryDJ5)->DJ5_CODPRO,(cQryDJ5)->DJ5_CODGRP),;
							'VLRDJ5',;
							(	STR0027 + Alltrim(Transform( nValor ,PesqPict('DJ4','DJ4_LME'))) + ' ' +;   //Valor Mercadoria
								STR0017 + cCodRRE + ' '+; //Maior que Limite da Restrição:
								STR0032 + (cQryDJ5)->DJ5_ITEM + ' ' +;  //Item
								Iif(!Empty((cQryDJ5)->DJ5_CODPRO), STR0028 + Alltrim((cQryDJ5)->DJ5_CODPRO) + ' ' + Alltrim(Posicione("SB1",1,xFilial("SB1") + (cQryDJ5)->DJ5_CODPRO,"B1_DESC")) ,;   //Produto:
						       STR0029 + (cQryDJ5)->DJ5_CODGRP + ' ' + Alltrim(Posicione("SBM",1,xFilial("SBM") + (cQryDJ5)->DJ5_CODGRP,"BM_DESC"))) + ' ' +;   //Grupo Prod.:
								STR0018 + ' ' + Alltrim(Transform( (cQryDJ5)->DJ5_VALMER ,PesqPict('DJ5','DJ5_VALMER'))) ) ,;  //De:
							'',;
							''})

							lBlqDJ5:= .T.
					EndIf

					If !Empty((cQryDJ5)->DJ5_PESO) .And.  nPeso >= (cQryDJ5)->DJ5_PESO .And. lBloqueia
						aAdd(aRet,{;
							DJ4->DJ4_CODRRE,;
							DJ4->DJ4_CODCLI,;
							DJ4->DJ4_LOJCLI,;
							Iif(!Empty((cQryDJ5)->DJ5_CODPRO),(cQryDJ5)->DJ5_CODPRO,(cQryDJ5)->DJ5_CODGRP),;
							'PES5',;
							(	STR0030 + Alltrim(Transform( nPeso ,PesqPict('DJ5','DJ5_PESO'))) +' '+;  //Peso:
								STR0017 + DJ4->DJ4_CODRRE +' '+;  //Maior que Limite da Restrição:
								STR0032 + (cQryDJ5)->DJ5_ITEM +' '+;  //Item:
								Iif(!Empty((cQryDJ5)->DJ5_CODPRO), STR0028 + Alltrim((cQryDJ5)->DJ5_CODPRO) + ' ' + Alltrim(Posicione("SB1",1,xFilial("SB1") + (cQryDJ5)->DJ5_CODPRO,"B1_DESC")) ,;   //Produto:
								                                   STR0029 + (cQryDJ5)->DJ5_CODGRP + ' ' + Alltrim(Posicione("SBM",1,xFilial("SBM") + (cQryDJ5)->DJ5_CODGRP,"BM_DESC")))+' '+;  //Grupo Prod:
								STR0018 + Alltrim(Transform( (cQryDJ5)->DJ5_PESO ,PesqPict('DJ5','DJ5_PESO'))) ) ,;  //De:
							'',;
							''})
						lBlqDJ5:= .T.
					EndIf

					If !Empty((cQryDJ5)->DJ5_PESOM3) .And. nPesoM3 >= (cQryDJ5)->DJ5_PESOM3 .And. lBloqueia
						aAdd(aRet,{;
							DJ4->DJ4_CODRRE,;
							DJ4->DJ4_CODCLI,;
							DJ4->DJ4_LOJCLI,;
							Iif(!Empty((cQryDJ5)->DJ5_CODPRO),(cQryDJ5)->DJ5_CODPRO,(cQryDJ5)->DJ5_CODGRP),;
							'PES35',;
							(	STR0031 + Alltrim(Transform( nPesoM3 ,PesqPict('DJ5','DJ5_PESOM3'))) +' '+;  //Peso Cub.:
								STR0017 + DJ4->DJ4_CODRRE +' '+;  //Maior Que Limite Da Restrição:
								STR0032 + (cQryDJ5)->DJ5_ITEM +' '+;  //Item:
								Iif(!Empty((cQryDJ5)->DJ5_CODPRO), STR0028 + Alltrim((cQryDJ5)->DJ5_CODPRO) + ' ' + Alltrim(Posicione("SB1",1,xFilial("SB1") + (cQryDJ5)->DJ5_CODPRO,"B1_DESC")) ,;  //Produto:
								                                   STR0029 + (cQryDJ5)->DJ5_CODGRP + ' ' + Alltrim(Posicione("SBM",1,xFilial("SBM") + (cQryDJ5)->DJ5_CODGRP,"BM_DESC")))+' '+;   //Grupo Prod:
								STR0018 + Alltrim(Transform( (cQryDJ5)->DJ5_PESOM3 ,PesqPict('DJ5','DJ5_PESOM3'))) ) ,;  //De:
							'',;
							''})
						lBlqDJ5:= .T.
					EndIf

					//--- Verifica bloqueio do Tipo do Veiculo e Idade do Veiculo
					If lRegDJ5 .And. lBloqueia
						If (!Empty((cQryDJ5)->DJ5_TIPVEI) .Or. !Empty((cQryDJ5)->DJ5_LIV))
							For nY:= 1 To Len(aVeiculo)
								If !Empty((cQryDJ5)->DJ5_TIPVEI) .And. aVeiculo[nY][2] <> (cQryDJ5)->DJ5_TIPVEI
									nPos := aScan(aRet,{|x| x[1]+x[2]+x[3]+x[4]+x[5] == DJ4->DJ4_CODRRE + DJ4->DJ4_CODCLI + DJ4->DJ4_LOJCLI + Iif(!Empty((cQryDJ5)->DJ5_CODPRO),(cQryDJ5)->DJ5_CODPRO,(cQryDJ5)->DJ5_CODGRP) + 'TIPV' })
									If nPos == 0
										aAdd(aRet,{;
											DJ4->DJ4_CODRRE,;
											DJ4->DJ4_CODCLI,;
											DJ4->DJ4_LOJCLI,;
											Iif(!Empty((cQryDJ5)->DJ5_CODPRO),(cQryDJ5)->DJ5_CODPRO,(cQryDJ5)->DJ5_CODGRP),;
											'TIPV',;
											(	STR0033 + aVeiculo[nY][2] +' '+;   //Tipo de Veiculo:
												STR0026 + DJ4->DJ4_CODRRE +' '+;  //Diferente Do Permitido pela Restrição:
												STR0032 + (cQryDJ5)->DJ5_ITEM +' '+;  //Item:
												Iif(!Empty((cQryDJ5)->DJ5_CODPRO), STR0028 + Alltrim((cQryDJ5)->DJ5_CODPRO) + ' ' + Alltrim(Posicione("SB1",1,xFilial("SB1") + (cQryDJ5)->DJ5_CODPRO,"B1_DESC")) ,;   //Produto:
												                                   STR0029 + (cQryDJ5)->DJ5_CODGRP + ' ' + Alltrim(Posicione("SBM",1,xFilial("SBM") + (cQryDJ5)->DJ5_CODGRP,"BM_DESC")))+' '+;  //Grupo Prod:
												STR0018 + (cQryDJ5)->DJ5_TIPVEI ) ,;  //De:
												'',;
												''})
										lBlqDJ5:= .T.
									EndIf
								EndIf

								If !Empty((cQryDJ5)->DJ5_LIV) .And. aVeiculo[nY][4] > (cQryDJ5)->DJ5_LIV
									nPos := aScan(aRet,{|x| x[1]+x[2]+x[3]+x[4]+x[5] == DJ4->DJ4_CODRRE + DJ4->DJ4_CODCLI + DJ4->DJ4_LOJCLI + Iif(!Empty((cQryDJ5)->DJ5_CODPRO),(cQryDJ5)->DJ5_CODPRO,(cQryDJ5)->DJ5_CODGRP) + 'LIV' })
									If nPos == 0
										aAdd(aRet,{;
											DJ4->DJ4_CODRRE,;
											DJ4->DJ4_CODCLI,;
											DJ4->DJ4_LOJCLI,;
											Iif(!Empty((cQryDJ5)->DJ5_CODPRO),(cQryDJ5)->DJ5_CODPRO,(cQryDJ5)->DJ5_CODGRP),;
											'LIV',;
											(	STR0022 + Alltrim(Transform( aVeiculo[nY][4] ,PesqPict('DJ5','DJ5_LIV'))) +' '+;  //Idade do Veiculo:
												STR0017 + DJ4->DJ4_CODRRE +' '+;  //Maior que Limite da Restrição:
												STR0032 + (cQryDJ5)->DJ5_ITEM +' '+;  //Item:
												Iif(!Empty((cQryDJ5)->DJ5_CODPRO), STR0028 + Alltrim((cQryDJ5)->DJ5_CODPRO) + ' ' + Alltrim(Posicione("SB1",1,xFilial("SB1") + (cQryDJ5)->DJ5_CODPRO,"B1_DESC")) ,;  //Produto:
												                                   STR0029 + (cQryDJ5)->DJ5_CODGRP + ' ' + Alltrim(Posicione("SBM",1,xFilial("SBM") + (cQryDJ5)->DJ5_CODGRP,"BM_DESC")))+' '+; //Grupo Prod:
												STR0018 + Alltrim(Transform( (cQryDJ5)->DJ5_LIV ,PesqPict('DJ5','DJ5_LIV'))) ) ,; //De:
												'',;
												''})
										lBlqDJ5:= .T.
									EndIf
								EndIf
							Next nY
						EndIf
					EndIf

					If 	lRegDJ5 //.And. lBlqDJ5  //Achou Item DJ5
						If (Len(aVeiculo) > 0 .Or. Len(aMotorista) > 0) //.And. lBloqueia
							//--- Verifica Caracteristicas do Veiculo e Motorista
							cQryDJ6:= GetNextAlias()

							cQuery:= " SELECT DJ6_CODRRE, DJ6_ITEM, DJ6_CODCAR, DJ0_TIPO, DJ0_DESCRI, DJ0_CODDOC FROM " +  RetSqlName("DJ6") + " DJ6 "
							cQuery+= " INNER JOIN " + RetSqlName("DJ0") + " DJ0 "
							cQuery+= " ON DJ0_FILIAL = '" + xFilial("DJ0") + "' "
							cQuery+= " AND DJ0_CODIGO = DJ6_CODCAR "
							cQuery+= " AND DJ0.D_E_L_E_T_= ' ' "
							cQuery+= " WHERE DJ6_FILIAL = '" + xFilial("DJ6") + "' "
							cQuery+= " AND DJ6_CODRRE = '" + (cQryDJ5)->DJ5_CODRRE + "' "
							cQuery+= " AND DJ6_ITEM = '" + (cQryDJ5)->DJ5_ITEM + "' "
							cQuery+= " AND DJ6.D_E_L_E_T_=' ' "

							cQuery := ChangeQuery(cQuery)

							dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cQryDJ6, .F., .T.)

							While (cQryDJ6)->(!Eof())

				  			    //-- Em caso de mais de um veiculo na Viagem, todos os veiculos devem possuir as caracteristas da RRE
								If (cQryDJ6)->DJ0_TIPO == '1'  //Veiculo
									For nZ:= 1 To Len(aVeiculo)
										If Len(aVeiculo[nZ][10]) > 0
											If Ascan(aVeiculo[nZ][10], {|x| + x ==  (cQryDJ6)->DJ6_CODCAR }) == 0

												nPos := aScan(aRet,{|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[7]+x[8] == DJ4->DJ4_CODRRE + DJ4->DJ4_CODCLI + DJ4->DJ4_LOJCLI +;
													                                                          Iif(!Empty((cQryDJ5)->DJ5_CODPRO),(cQryDJ5)->DJ5_CODPRO,(cQryDJ5)->DJ5_CODGRP)+;
													                                                          'CARV' + (cQryDJ6)->DJ6_CODCAR + aVeiculo[nZ][1] })
												If nPos == 0
													aAdd(aRet,{;
													DJ4->DJ4_CODRRE,;
													DJ4->DJ4_CODCLI,;
													DJ4->DJ4_LOJCLI,;
													Iif(!Empty((cQryDJ5)->DJ5_CODPRO),(cQryDJ5)->DJ5_CODPRO,(cQryDJ5)->DJ5_CODGRP),;
													'CARV',;
													(	STR0034 + (cQryDJ6)->DJ6_CODCAR + ' - ' + Alltrim((cQryDJ6)->DJ0_DESCRI)+' '+; //Caracteristica Veiculo:
														STR0035 + aVeiculo[nZ][1] +' '+;   //Veiculo:
														STR0032 + (cQryDJ5)->DJ5_ITEM ) ,; //Item: //	Iif(!Empty((cQryDJ5)->DJ5_CODPRO),' Grupo: ' + Alltrim((cQryDJ5)->DJ5_CODGRP),' Produto: ' + Alltrim((cQryDJ5)->DJ5_CODPRO))  ),;
													(cQryDJ6)->DJ6_CODCAR,;
													aVeiculo[nZ][1] })
												EndIf
											EndIf
										Else   //Gera Bloqueio quando o Veiculo nao tem caracteristica
											aAdd(aRet,{;
													DJ4->DJ4_CODRRE,;
													DJ4->DJ4_CODCLI,;
													DJ4->DJ4_LOJCLI,;
													Iif(!Empty((cQryDJ5)->DJ5_CODPRO),(cQryDJ5)->DJ5_CODPRO,(cQryDJ5)->DJ5_CODGRP),;
													'CARV',;
													(	STR0034 + (cQryDJ6)->DJ6_CODCAR + ' - ' + Alltrim((cQryDJ6)->DJ0_DESCRI)+' '+; //Caracteristica Veiculo:
														STR0035 + aVeiculo[nZ][1] +' '+;   //Veiculo:
														STR0032 + (cQryDJ5)->DJ5_ITEM ) ,; //Item: //	Iif(!Empty((cQryDJ5)->DJ5_CODPRO),' Grupo: ' + Alltrim((cQryDJ5)->DJ5_CODGRP),' Produto: ' + Alltrim((cQryDJ5)->DJ5_CODPRO))  ),;
													(cQryDJ6)->DJ6_CODCAR,;
													aVeiculo[nZ][1] })
										EndIf
									Next nZ
								Else    //Motorista
									If Len(aMotorista) > 0
										For nZ:= 1 To Len(aMotorista)
											If Len(aMotorista[nZ][7]) > 0
												If Ascan(aMotorista[nZ][7], {|x| + x ==  (cQryDJ6)->DJ6_CODCAR }) == 0

													nPos := aScan(aRet,{|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[7]+x[8] == DJ4->DJ4_CODRRE + DJ4->DJ4_CODCLI + DJ4->DJ4_LOJCLI + ;
																														 Iif(!Empty((cQryDJ5)->DJ5_CODPRO),(cQryDJ5)->DJ5_CODPRO,(cQryDJ5)->DJ5_CODGRP) +;
																														'CARM' + (cQryDJ6)->DJ6_CODCAR + aMotorista[nZ][1] })
													If nPos == 0
														aAdd(aRet,{;
														DJ4->DJ4_CODRRE,;
														DJ4->DJ4_CODCLI,;
														DJ4->DJ4_LOJCLI,;
														Iif(!Empty((cQryDJ5)->DJ5_CODPRO),(cQryDJ5)->DJ5_CODPRO,(cQryDJ5)->DJ5_CODGRP),;
														'CARM',;
														(	STR0036 + (cQryDJ6)->DJ6_CODCAR + ' - ' + Alltrim((cQryDJ6)->DJ0_DESCRI)+' '+;   //Caracteristica Motorista:
															STR0037 + aMotorista[nZ][1] +' '+;  //Motorista:
															STR0032 + (cQryDJ5)->DJ5_ITEM ),; //Item: //Iif(!Empty((cQryDJ5)->DJ5_CODPRO),' Grupo: ' + Alltrim((cQryDJ5)->DJ5_CODGRP),' Produto: ' + Alltrim((cQryDJ5)->DJ5_CODPRO))  ),;
														(cQryDJ6)->DJ6_CODCAR,;
														aMotorista[nZ][1] })
													EndIf
												EndIf
											Else
												aAdd(aRet,{;
														DJ4->DJ4_CODRRE,;
														DJ4->DJ4_CODCLI,;
														DJ4->DJ4_LOJCLI,;
														Iif(!Empty((cQryDJ5)->DJ5_CODPRO),(cQryDJ5)->DJ5_CODPRO,(cQryDJ5)->DJ5_CODGRP),;
														'CARM',;
														(	STR0036 + (cQryDJ6)->DJ6_CODCAR + ' - ' + Alltrim((cQryDJ6)->DJ0_DESCRI)+' '+;   //Caracteristica Motorista:
															STR0037 + aMotorista[nZ][1] +' '+;  //Motorista:
															STR0032 + (cQryDJ5)->DJ5_ITEM ),; //Item: //Iif(!Empty((cQryDJ5)->DJ5_CODPRO),' Grupo: ' + Alltrim((cQryDJ5)->DJ5_CODGRP),' Produto: ' + Alltrim((cQryDJ5)->DJ5_CODPRO))  ),;
														(cQryDJ6)->DJ6_CODCAR,;
														aMotorista[nZ][1] })
											EndIf
										Next nZ
									EndIf
								EndIf

								(cQryDJ6)->(dbSkip())
							EndDo
							(cQryDJ6)->(dbCloseArea())
						EndIf

						//--- Chek List da RRE (Itens por viagem)
						If cRotRRE $ "TMSA310

							cQryDJ7:= GetNextAlias()
							cQuery:= " SELECT DJ7_CODRRE, DJ7_ITEM, DJ7_IDCHK, DJ7_OBRIGA, DJ3_DESCRI FROM " +  RetSqlName("DJ7") + " DJ7 "
							cQuery+= " INNER JOIN " + RetSqlName("DJ3") + " DJ3 "
							cQuery+= " ON DJ3_FILIAL = '" + xFilial("DJ3") + "' "
							cQuery+= " AND DJ3_CODIGO = DJ7_IDCHK "
							cQuery+= " AND DJ3.D_E_L_E_T_= ' ' "
							cQuery+= " WHERE DJ7_FILIAL = '" + xFilial("DJ6") + "' "
							cQuery+= " AND DJ7_CODRRE = '" + (cQryDJ5)->DJ5_CODRRE + "' "
							cQuery+= " AND DJ7_ITEM = '" + (cQryDJ5)->DJ5_ITEM + "' "
							cQuery+= " AND DJ7.D_E_L_E_T_=' ' "
							cQuery := ChangeQuery(cQuery)

							dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cQryDJ7, .F., .T.)

							While (cQryDJ7)->(!Eof())
								nPos := aScan(aListChk,{|x| x[1] == (cQryDJ7)->DJ7_IDCHK })
								If nPos == 0
									aAdd(aListChk,{(cQryDJ7)->DJ7_IDCHK,(cQryDJ7)->DJ3_DESCRI,(cQryDJ7)->DJ7_OBRIGA,.F.})

									DJ9->(DbSetOrder(1))
									If !DJ9->(DbSeek(xFilial("DJ9") + cFilOri + cViagem + (cQryDJ7)->DJ7_IDCHK  ) )
										RecLock("DJ9",.T.)
										DJ9->DJ9_FILIAL:= xFilial("DJ9")
										DJ9->DJ9_FILORI:= cFilOri
										DJ9->DJ9_VIAGEM:= cViagem
										DJ9->DJ9_IDCHK := (cQryDJ7)->DJ7_IDCHK
										DJ9->DJ9_IDMARK:= .F.
										DJ9->DJ9_OBRIGA:= (cQryDJ7)->DJ7_OBRIGA
										DJ9->(MsUnLock())
									EndIf

								EndIf
								(cQryDJ7)->(dbSkip())
							EndDo
							(cQryDJ7)->(dbCloseArea())

						EndIf

						//Exit
					EndIf
				EndIf
				(cQryDJ5)->(dbCloseArea())
			EndIf
		EndIf
	Next nJ

EndIf

RestArea(aArea)

Return(aRet)


//-------------------------------------------------------------------------------------------------
/* {Protheus.doc} TmsVldDtSg
@autor		: Katia
@descricao	: Valida Data Liberacao da Seguradora
@since		: 23/03/2015
@using		: RRE - Regra de Restricao de Embarque
*/
//-------------------------------------------------------------------------------------------------
Function TmsVldDtSg(dDtIniSg,dDtFimSg,dDatIni,dDatFim,cTipoTer)
Local lRet     := .T.

Default dDtIniSg := CtoD(Space(08))
Default dDtFimSg := CtoD(Space(08))
Default dDatIni  := CtoD(Space(08))
Default dDatFim  := CtoD(Space(08))
Default cTipoTer := ""

If Empty(dDtIniSg) .Or. Empty(dDtFimSg)  //Obrigatorio informar as duas datas
	lRet:= .F.
EndIf

If lRet
	If Empty(dDatFim)
		dDatFim:= dDataBase
	EndIf

	If !Empty(dDtIniSg)
		lRet:= .F.
		If !Empty(dDtFimSg)  //Data Final de Validade de Seguro do Motorista
			If dDatIni >= dDtIniSg .And. dDatFim <= dDtFimSg
				lRet:= .T.
			EndIf
		Else  //Veiculo
			If dDtLibSg >= dDatIni .And. dDtLibSg >= dDatFim
				lRet:= .T.
			EndIf
		EndIf

	EndIf
EndIf

Return lRet



//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsListDiv
@autor		: Eduardo Alberti
@descricao	: Monta Dialog Com Divergencias De Produtos e RRE
@since		: Mar./2015
@using		: Atualização De Bloqueios TMS .
@review	:

Argumentos	:

/*/
//-------------------------------------------------------------------------------------------------
Function TmsListDiv(aDiverg)

Local aArea 			:= GetArea()
Local oDlgDiverg 		:= Nil
Local oDiverg  		:= Nil
Local aCoordenadas	:= MsAdvSize(.T.)
Local lOpcClick 		:= .f.
Local aButtons		:= {}
Local cTitulo			:= STR0038   //"Existem Bloqueios de Divergencias e ou Exigencias da RRE."
Local aCab				:= {STR0028, STR0040, STR0041} // { "Produto","Tp.Bloqueio","Divergencia/Exigencia"}

Default aDiverg      := {}

//oDlgDiverg		:= TDialog():New(000,000,aCoordenadas[6],aCoordenadas[5],OemToAnsi(_cTitulo ),,,,,,,,oMainWnd,.T.)			// Tela Inteira
oDlgDiverg 		:= TDialog():New(000,000,aCoordenadas[6]/1.5,aCoordenadas[5]/1.5,OemToAnsi(cTitulo ),,,,,,,,oMainWnd,.T.) 	// Tela Menor
oDiverg 			:= TWBrowse():New(030,003,oDlgDiverg:nClientWidth/2-5,oDlgDiverg:nClientHeight/2-45,,aCab,,oDlgDiverg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
//oDiverg:lHScroll	:= .F. // Indica se habilita(.T.)/desabilita (.F.) a barra de rolagem horizontal.
//oDiverg:lVScroll	:= .F. // Indica se habilita(.T.)/desabilita(.F.) a barra de rolagem vertical.

oDiverg:SetArray(aDiverg)

oDiverg:bLine := {||{;
aDiverg[oDiverg:nAt][01],;
aDiverg[oDiverg:nAt][02],;
aDiverg[oDiverg:nAt][03]}}

Activate MsDialog oDlgDiverg On Init EnchoiceBar(oDlgDiverg,/*bOk*/ {|| lOpcClick := .t., oDlgDiverg:End()} ,/*bCancel*/ {|| oDlgDiverg:End() },/*lMsgDel*/,aButtons,/*nRecno*/,/*cAlias*/,/*lMashups*/,/*lImpCad*/,.F. /*lPadrao*/,.F. /*lHasOk*/,/*lWalkThru*/,/*cProfileID*/)

RestArea(aArea)

Return(lOpcClick)


//--------------------------------------------------------------------
/*/{Protheus.doc} TmsVLDSIX
VERIFICAÇÃO SE EXISTE INDICE NA SIX

@author Felipe Barbieri
@since  30/07/15
@obs    Valida se índice existe na tabela
@param  Nome da tabela, Ordem do Indice
@version 1.0
/*/
//--------------------------------------------------------------------
Function TmsVLDSIX(cIndice,cOrdem)
Local lRet  := .F.
Local aArea := getArea()

DbSelectArea("SIX")
SIX->(DbSetOrder(1))

If SIX->(MsSeek(cIndice+cOrdem))
   lRet := .T.
EndIf

restArea(aArea)

Return(lRet)

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSPesqSrv
Apresenta serviços para contrato com negociação
@type function
@author Gianni Furlan
@version 12
@since 10/03/2016
@param [cCampo], Caracter, Campo
@return lRet True ou False
@obs Alterado por Guilherme Eduardo Bittencourt em 19/05/2017 (Reestruturação)
/*/
//-------------------------------------------------------------------------------------------------
Function TMSPesqSrv(cCampo)

	Local aArea	     := GetArea()
	Local lRet       := .T.
	Local aItContrat := {}
	Local cSerTMS    := ""
	Local cTipTra    := ""
	Local cCodCli    := ""
	Local cLojCli    := ""
	Local cCodNeg    := ""
	Local cMsgErr    := ""

	Default cCampo := ""

	If Empty(cCampo)
		cCampo := ReadVar()
	EndIf

	Do Case
	//-- Solicitação de Coleta
	Case cCampo == "M->DT5_SERVIC"

		cTipTra := "1"
		cSerTMS := "1"

		If ! Empty(M->DT5_CODNEG) //-- Contrato com negociação DDA/DDC
			cCodNeg := M->DT5_CODNEG
		Else
			cCodNeg := ""
		EndIf

		TMSPesqServ("DT5",;
		            M->DT5_CLIDEV,;
					M->DT5_LOJDEV,;
					cSerTMS,;
					cTipTra,;
					@aItContrat,;
					/* lMostra */,;
					StrZero(1, Len(M->DT5_TIPFRE)),;
					/* lRotAuto */,;
				    /* cDocTms */,;
					/* lChkCliGen */,;
					/* cTabFre */,;
					/* cTipTab */,;
					/* cVigCon */,;
					/* lHelp */,;
					M->DT5_CDRORI,;
					M->DT5_CDRDCA,;
					/* lPortalTMS */,;
				    /* lRateio */,;
					/* cBACRAT */,;
					/* cCRIRAT */,;
					/* cPRORAT */,;
					/* cTABRAT */,;
					/* cTIPRAT */,;
					cCodNeg,;
					/* cCampo */)

		If Empty(aItContrat)
			cMsgErr := chr(10) + STR0049 + ": " + M->DT5_CLIDEV + "/" + M->DT5_LOJDEV + ", "
			cMsgErr += STR0050 + ": " + cSerTMS + ", "
			cMsgErr += STR0051 + ": " + cTipTra + ", "
			cMsgErr += STR0052 + ": " + StrZero(1, Len(M->DT5_TIPFRE)) + ", "
			cMsgErr += STR0053 + ": " + M->DT5_CDRORI + ", "
			cMsgErr += STR0054 + ": " + M->DT5_CDRDCA
			If !Empty(cCodNeg)
				cMsgErr += ", " + STR0055 + ": " + cCodNeg
			EndIf
			Help(" ", , "TMSXFUND07", , cMsgErr, 2, 1) //-- Não há serviços disponíveis. Verifique o contrato do cliente. Parâmetros:
		EndIf

	//-- Solicitação de Coleta
	Case cCampo == "M->DT5_SRVENT"

		cTipTra := "1"
		cSerTMS := "3"

		If ! Empty(M->DT5_CODNEG) //-- Contrato com negociação DDA/DDC
			cCodNeg := M->DT5_CODNEG
		Else
			cCodNeg := ""
		EndIf

		TMSPesqServ("DT5",;
		            M->DT5_CLIDEV,;
					M->DT5_LOJDEV,;
					cSerTMS,;
					cTipTra,;
					@aItContrat,;
					/* lMostra */,;
					StrZero(1, Len(M->DT5_TIPFRE)),;
					/* lRotAuto */,;
				    /* cDocTms */,;
					/* lChkCliGen */,;
					/* cTabFre */,;
					/* cTipTab */,;
					/* cVigCon */,;
					/* lHelp */,;
					M->DT5_CDRORI,;
					M->DT5_CDRDES,;
					/* lPortalTMS */,;
				    /* lRateio */,;
					/* cBACRAT */,;
					/* cCRIRAT */,;
					/* cPRORAT */,;
					/* cTABRAT */,;
					/* cTIPRAT */,;
					cCodNeg,;
					cCampo)

	//-- Itens do Agendamento
	Case cCampo == "M->DF1_SRVCOL"

		cTipTra := "1"
		cSerTMS := "1"

		If ! Empty(GDFieldGet("DF1_CODNEG", n)) //-- Contrato com negociação DDA/DDC
			cCodNeg := GDFieldGet("DF1_CODNEG", n)
		Else
			cCodNeg := ""
		EndIf

		TMSPesqServ("DF1",;
		            GDFieldGet("DF1_CLIDEV", n),;
					GDFieldGet("DF1_LOJDEV", n),;
					cSerTMS,;
					cTipTra,;
					@aItContrat,;
					/* lMostra */,;
					StrZero(1, Len(GDFieldGet("DF1_TIPFRE", n))),;
					/* lRotAuto */,;
				    /* cDocTms */,;
					/* lChkCliGen */,;
					/* cTabFre */,;
					/* cTipTab */,;
					/* cVigCon */,;
					/* lHelp */,;
					GDFieldGet("DF1_CDRORI", n),;
					GDFieldGet("DF1_CDRDES", n),;
					/* lPortalTMS */,;
				    /* lRateio */,;
					/* cBACRAT */,;
					/* cCRIRAT */,;
					/* cPRORAT */,;
					/* cTABRAT */,;
					/* cTIPRAT */,;
					cCodNeg,;
					cCampo)

	Case cCampo == "M->DDD_SRVCOL"

		cTipTra := M->DDD_TIPTRA
		cSerTMS := "1"

		If ! Empty(M->DDD_CODNEG) //-- Contrato com negociação DDA/DDC
			cCodNeg := M->DDD_CODNEG
		Else
			cCodNeg := ""
		EndIf

		TMSPesqServ("DDD",;
		            M->DDD_CLIDEV,;
					M->DDD_LOJDEV,;
					cSerTMS,;
					cTipTra,;
					@aItContrat,;
					/* lMostra */,;
					StrZero(1, Len(M->DDD_TIPFRE)),;
					/* lRotAuto */,;
				    /* cDocTms */,;
					/* lChkCliGen */,;
					/* cTabFre */,;
					/* cTipTab */,;
					/* cVigCon */,;
					/* lHelp */,;
					M->DDD_CDRORI,;
					M->DDD_CDRDES,;
					/* lPortalTMS */,;
				    /* lRateio */,;
					/* cBACRAT */,;
					/* cCRIRAT */,;
					/* cPRORAT */,;
					/* cTABRAT */,;
					/* cTIPRAT */,;
					cCodNeg,;
					/* cCampo */)

	//-- Rentabilidade/Ocorrencia -> Tratamento Campo DUA_SERVIC
	//-- Busca serviço de acordo com a Negociação do Contrato
	Case cCampo == "M->DT4_SERVIC"

		cSerTMS := M->DT4_SERTMS //-- Coleta
		cTipTra := M->DT4_TIPTRA //-- Rodoviario

		If ! Empty(M->DT4_CODNEG) //-- Contrato com negociação DDA/DDC
			cCodNeg := M->DT4_CODNEG
		Else
			cCodNeg := ""
		EndIf

		TMSA040Cli(@cCodCli, @cLojCli) //-- Define o Tomador do Frete
		TMSPesqServ("DT4",;
		            cCodCli,;
					cLojCli,;
					cSerTMS,;
					cTipTra,;
					@aItContrat,;
					/* lMostra */,;
					M->DT4_TIPFRE,;
					/* lRotAuto */,;
				    /* cDocTms */,;
					/* lChkCliGen */,;
					/* cTabFre */,;
					/* cTipTab */,;
					/* cVigCon */,;
					/* lHelp */,;
					M->DT5_CDRORI,;
					M->DT5_CDRDES,;
					/* lPortalTMS */,;
				    /* lRateio */,;
					/* cBACRAT */,;
					/* cCRIRAT */,;
					/* cPRORAT */,;
					/* cTABRAT */,;
					/* cTIPRAT */,;
					cCodNeg,;
					/* cCampo */)

	EndCase

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsRetViag
@autor		: Gianni Furlan
@descricao	: Verifica se a viagem de coleta esta encerrada quando no documento do cliente, a tabela de frete possuir o componente do tipo herda valor
@since		: Maio/2016
@using		:
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Function TmsRetViag(cNumSol,cNumContr,cServic,cCodNeg)

Local lRet			:= .T.
Local aArea    	:= GetArea()
Local lRetquery	:= .F.
Local cFilVia		:= ''
Local cViagem		:= ''
Local cFilCfs		:= cFilAnt
Local lTabDDA		:= Iif(FindFunction("TmsUniNeg"),TmsUniNeg(),.F.)
Local cTabfre		:= ''
Local cTipTab		:= ''

Local lRetPE        := .T.

Default cNumSol 	:= ""
Default cNumContr	:= ""
Default cServic 	:= ""
Default cCodNeg 	:= ""

If lTabDDA .And. !Empty(cNumSol)
	If !Empty(cCodNeg)
		DDA->(DbSetOrder(2))//DDA_FILIAL+DDA_NCONTR+DDA_CODNEG+DDA_SERVIC
		If DDA->(MsSeek(xFilial("DDA")+cNumContr+cCodNeg+cServic))
			cTabfre := DDA->DDA_TABFRE
			cTipTab := DDA->DDA_TIPTAB
		Endif
	Else
		DUX->(DbSetOrder(2))//DUX_FILIAL+DUX_NCONTR+DUX_SERVIC
		If DUX->(MsSeek(xFilial("DUX")+cNumContr+cServic))
			cTabfre := DUX->DUX_TABFRE
			cTipTab := DUX->DUX_TIPTAB
		Endif
	Endif
	If !Empty(cTabfre) .And. !Empty(cTipTab)
		cAliasQry := GetNextAlias()
		cQuery := "SELECT COUNT(*) QTDCOMP FROM "
		cQuery += RetSqlName("DVE")+" DVE, "
		cQuery += RetSqlName("DT3")+" DT3  "
		cQuery += " WHERE DVE.DVE_FILIAL = '"+xFilial('DVE')+"'"
		cQuery += "   AND DVE.DVE_TABFRE = '"+cTabfre+"'"
		cQuery += "   AND DVE.DVE_TIPTAB = '"+cTipTab+"'"
		cQuery += "   AND DVE.D_E_L_E_T_ = ' '"
		cQuery += "   AND DT3.DT3_FILIAL = '"+xFilial('DT3')+"'"
		cQuery += "   AND DT3.DT3_CODPAS = DVE_CODPAS"
		cQuery += "   AND DT3.DT3_TIPFAI = '16'"
		cQuery += "   AND DT3.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		If (cAliasQry)->(!Eof()) .And. (cAliasQry)->QTDCOMP > 0
			lRetquery := .T.
			If isInCallStack("tmsa340mnt")// para validar o estorno da viagem de coleta
				lRet := .F.
			Endif
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf
	If lRetquery .And. lRet
		// SE achou o componente do tipo herda valor, busco a viagem da solicitação de coleta e verifico se esta encerrada.
		If !Empty(cNumSol)
			cAliasViag := GetNextAlias()
			cQuery := " SELECT Max(DUD.R_E_C_N_O_) DUDRECNO"
			cQuery += "  FROM " + RetSqlName('DUD') + " DUD "
			cQuery += "  WHERE DUD.DUD_FILIAL	 = '" + xFilial("DUD")  + "'" + CRLF
			cQuery += "    AND DUD.DUD_FILDOC	 = '" + cFilCfs + "'" + CRLF
			cQuery += "    AND DUD.DUD_DOC   	 = '" + cNumSol + "'" + CRLF
			cQuery += "    AND DUD.DUD_SERIE   	 = 'COL'" + CRLF
			cQuery += "    AND DUD.D_E_L_E_T_ 	 = '' "
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasViag, .F., .T.)
			If (cAliasViag)->(!Eof())
				DUD->( DbGoto( (cAliasViag)->DUDRECNO ) )
				cFilVia := DUD->DUD_FILORI
				cViagem := DUD->DUD_VIAGEM
			EndIf
			(cAliasViag)->(dbCloseArea())
			If !Empty(cViagem)
				DTQ->(DbSetOrder(2))//DTQ_FILIAL+DTQ_FILORI+DTQ_VIAGEM
				If DTQ->(MsSeek(xFilial("DTQ")+cFilVia+cViagem))
					If DTQ->DTQ_STATUS != StrZero(3, Len(DTQ->DTQ_STATUS))
						//-- Ponto de entrada para desligar a validação da viagem de coleta em transito
						If lTMViaCol
							lRetPE := ExecBlock("TMVIACOL",.F.,.F.,{cFilVia,cViagem,cFilCfs,cNumSol})
							If ValType(lRetPE) != "L"
								lRetPE := .F.
							EndIf
						EndIf
						If !lRetPE
							lRet := .F.
							Help("",1,"TMSXFUND02")
							//Viagem de coleta não encerrada para a solicitação de coleta informada.
							//Favor encerrar a viagem de coleta referente a solicitação de coleta informada na nota fiscal do cliente.
						EndIf
					Endif
				Endif
			Endif
		EndIf
	Endif
Endif

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsVlVgSrv
@autor		: Eduardo Alberti
@descricao	: Valida Se Viagem Tem Solicitações De Coleta Faturadas Com Utilização De Serviço e/ou Cod. Negociação
@since		: May./2016
@using		: Tmsa310
@review	:
@param		: 	cFilOri 	: Filial Origem
				cViagem	: Número Da Viagem
				cNotas		: Se Passada Por Parâmetro Retorna As NFs Calculadas
/*/
//-------------------------------------------------------------------------------------------------
Function TmsVlVgSrv( cFilOri , cViagem , cNotas )

	Local aArea 	:= GetArea()
	Local aArDUD	:= DUD->(GetArea())
	Local aArDT5	:= DT5->(GetArea())
	Local aArDTC	:= DTC->(GetArea())
	Local lRet  	:= .F.
	
	Default cFilOri := ""
	Default cViagem := ""
	Default cNotas  := ""

	//-- Posiciona No Movimento Da Viagem
	DbSelectArea("DUD")
	DbSetOrder(2) //-- DUD_FILIAL+DUD_FILORI+DUD_VIAGEM+DUD_SEQUEN+DUD_FILDOC+DUD_DOC+DUD_SERIE
	MsSeek( FWxFilial("DUD") + cFilOri + cViagem , .F. )

	While !DUD->(Eof()) .And. (DUD->(DUD_FILIAL + DUD_FILORI + DUD_VIAGEM) == (FWxFilial("DUD") + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM))

		//-- Verifica Se Trata-Se De Notas De Coleta
		If DUD->DUD_SERIE == "COL"

			//-- Na Solicitação De Coleta
			DbSelectArea("DT5")
			DT5->(DbSetOrder( 4 )) //-- DT5_FILIAL+DT5_FILDOC+DT5_DOC+DT5_SERIE
			If MsSeek(FWxFilial('DT5') + DUD->DUD_FILDOC + DUD->DUD_DOC + DUD->DUD_SERIE , .F. )

				//-- Verifica Se Controla Serviço Ou Cód. Negociação
				If !Empty(DT5->DT5_SERVIC) .Or. !Empty(DT5->DT5_CODNEG)

					//-- Posiciona Nos Documentos Do Cliente
					DbSelectArea("DTC")
					DbSetOrder(8) //-- DTC_FILIAL+DTC_FILORI+DTC_NUMSOL
					If MsSeek( FWxFilial("DTC") + cFilOri + DT5->DT5_NUMSOL , .F.)
						If !TmsRetViag(DTC->DTC_NUMSOL,DTC->DTC_NCONTR,DTC->DTC_SERVIC,DTC->DTC_CODNEG)
							//-- Verifica Se Documento Está Calculado
							If !Empty( DTC->(DTC_FILDOC + DTC_DOC + DTC_SERIE))
								lRet   := .T.
								cNotas := Iif( !Empty(cNotas) ,",","") + DTC->DTC_DOC + "/" + DTC->DTC_SERIE //-- Carrega As NFs Que Serão Mostrada No Help
							EndIf
						Endif
					EndIf
				EndIf
			EndIf
		EndIf

		DUD->(DbSkip())
	EndDo

	RestArea(aArDTC)
	RestArea(aArDT5)
	RestArea(aArDUD)
	RestArea(aArea)

Return(lRet)

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  TmsPsqDY4
@autor		: Ramon Prado
@descricao	: Verifica se existe DY4 para o documento/nota fiscal em questao
@since		: Fev./2015
@review	:

Argumentos	:

/*/
//-------------------------------------------------------------------------------------------------
Function TmsPsqDY4(cFilDoc, cDoc, cSerie, cNumNfc, cSerNfc,cCodPro)
Local aArea	:= getArea()
Local lRet		:= .F.
Local lDY4		:= AliasIndic("DY4")

Default cNumNfc := ""
Default cSerNfc := ""
Default cCodPro := ""

If lDY4
	DbSelectArea("DY4")
	DbSetOrder(1) //Filial + Fil.Docto. + No.Docto. + Serie Docto. + Doc.Cliente + Serie Dc.Cli + Produto
	If MsSeek(xFilial("DY4")+cFilDoc+cDoc+cSerie+cNumNfc+cSerNfc+cCodPro)
		lRet := .T.
	Endif
EndIf

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  TmsPesqSix
@autor		: Ramon Prado
@descricao	: Verifica se existe o indice desejado no dicionario SIX
@since		: Jun./2015
@review	:

Argumentos: cIndice, cOrdem   Exemplo: cIndice "DY4", cOrdem "1"
/*/
//-------------------------------------------------------------------------------------------------
Function TmsPesqSix(cIndice,cOrdem)
Local lRet      := .T.
Local aAreaSix  := SIX->(GetArea())

SIX->(dbSetOrder(1))
If !( SIX->(dbSeek(cIndice+cOrdem)))
	lRet := .F.
EndIf

RestArea(aAreaSix)
Return lRet
//-------------------------------------------------------------------------------------------------
/* {Protheus.doc} TmsVldNLib
@autor		: Katia
@descricao	: Valida Numero Liberacao da Seguradora
@since		: 23/03/2015
@using		: RRE - Regra de Restricao de Embarque
*/
//-------------------------------------------------------------------------------------------------
Function TmsVldNLib(cAliasDJA,cChaveDJA,cNumLib,cFilOri,cViagem)
Local lRet      := .T.
Local cQuery    := ""
Local cAliasQDJA:= ""

If Empty(cNumLib)
	lRet:= .F.
Else
	cAliasQDJA:= GetNextAlias()
	cQuery := ""
	cQuery += "SELECT COUNT(*) NREG "
	cQuery += " FROM " + RetSqlName("DJA")+ " DJA "
	cQuery += " WHERE DJA.DJA_FILIAL = '" + xFilial('DJA') + "' "
	cQuery += " AND DJA.DJA_ALIAS = '" + cAliasDJA + "' "
	cQuery += " AND DJA.DJA_LIBSEG = '" + cNumLib  + "' "
	cQuery += " AND (DJA.DJA_CHAVE <> '" + cChaveDJA  + "' "
	cQuery += " OR (DJA.DJA_CHAVE = '" + cChaveDJA  + "' "
	cQuery += " AND DJA.DJA_VIAGEM <> '" + cViagem  + "') ) "
	cQuery += " AND DJA.D_E_L_E_T_=' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQDJA, .F., .T.)
	If (cAliasQDJA)->NREG > 0
		lRet:= .F.
	EndIf

	(cAliasQDJA)->(dbCloseArea())
EndIf
Return lRet


//-------------------------------------------------------------------------------------------------
/* {Protheus.doc} TmsTipos
@autor		: Katia
@descricao	: Monta Array com os Tipos de Frota e Tipo de Motorista
@since		: 14/12/2015
@using		: RRE - Regra de Restricao de Embarque
*/
//-------------------------------------------------------------------------------------------------
Function TmsTipos(cItemDTR,cFroVei,cFilOri,cViagem,aTipos)

Local cQuery    := ""
Local cAliasDA4 := ""
Default cItemDTR:= ""
Default cFroVei := ""
Default cFilOri := ""
Default cViagem := ""

If !Empty(cFroVei)
	cAliasDA4 := GetNextAlias()
	cQuery := " SELECT DUP_ITEDTR, DA4_TIPMOT "
	cQuery += " FROM " + RetSqlName("DUP") + " DUP "
	cQuery += " INNER JOIN " + RetSqlName("DA4") + " DA4 ON "
	cQuery += "        DA4.DA4_FILIAL = '" + xFilial("DA4") + "' AND "
	cQuery += "        DA4.DA4_COD = DUP.DUP_CODMOT  AND "
	cQuery += "        DA4.D_E_L_E_T_ = '' "
	cQuery += " WHERE  DUP.DUP_FILIAL = '" + xFilial("DUP") + "' AND "
	cQuery += "       DUP_FILORI     = '" + cFilOri + "' AND "
	cQuery += "       DUP_VIAGEM     = '" + cViagem + "' AND "
	cQuery += "       DUP_ITEDTR     = '" + cItemDTR + "' AND "
	cQuery += "       DUP.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDA4,.F.,.T.)
	While (cAliasDA4)->(!Eof())
		If !Empty((cAliasDA4)->DA4_TIPMOT)
			nPos:= aScan(aTipos,cFroVei+(cAliasDA4)->DA4_TIPMOT)
			If nPos == 0
				aAdd(aTipos,cFroVei+(cAliasDA4)->DA4_TIPMOT)
			EndIf
		EndIf

		(cAliasDA4)->(DbSkip())
	EndDo
	(cAliasDA4)->(DbCloseArea())
EndIf

Return Nil

/*/-----------------------------------------------------------
{Protheus.doc} TmsAltVeic
Altera o veiculo da nota fiscal

Uso: TMSAF76

@sample
//TmsAltVeic

@author Ramon Prado.
@since 22/06/2016
@version 1.0
-----------------------------------------------------------/*/
Function TmsAltVeic(cContrt,cCodNeg,cFilOri,cLotNFc,cNumNFc,cSerNFc,cCliRem,cLojRem,cFilVia,cViagem,cSerTms,cTipTra,cServic)
Local aArea     := GetArea()
Local aCompVia  := {}
Local cAltVei   := ""
Local cQuery    := ""
Local cAliasDVU := ""
Local cSeekDVU  := ""
Local cTipVei   := ""
Local nPosCpo   := 0
Local nPosVei   := 0
Local nPosRb1   := 0
Local nPosRb2   := 0
Local nPosRb3   := 0
Local nCntFor1  := 0
Local lAltVei   := .F.

Default cContrt := ""
Default cCodNeg := ""
Default cFilOri := ""
Default cLotNFc := ""
Default cNumNFc := ""
Default cSerNFc := ""
Default cCliRem := ""
Default cLojRem := ""
Default cFilVia := ""
Default cViagem := ""
Default cSerTms := ""
Default cTipTra := ""
Default cServic := ""

cAltVei := TmsSobServ('ALTVEI',.T.,.T.,cContrt,cCodNeg,cServic,"0",,.F.)

If IsInCallStack("TMSAF76")
	If cAltVei == "1"
		lAltVei := .T.
	ElseIf cAltVei == "3"
		cAliasDVU := GetNextAlias()
		cQuery := "SELECT COUNT(DVU_NUMNFC) QTDREG "
		cQuery += "  FROM " + RetSqlName("DVU") + " DVU "
		cQuery += " WHERE DVU_FILIAL = '" + xFilial("DVU") + "' "
		cQuery += "   AND DVU_FILORI = '" + cFilOri + "' "
		cQuery += "   AND DVU_LOTNFC = '" + cLotNFc + "' "
		cQuery += "   AND DVU_NUMNFC = '" + cNumNFc + "' "
		cQuery += "   AND DVU_SERNFC = '" + cSerNFc + "' "
		cQuery += "   AND DVU_CLIREM = '" + cCliRem + "' "
		cQuery += "   AND DVU_LOJREM = '" + cLojRem + "' "
		cQuery += "   AND DVU.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDVU,.T.,.T.)
		If (cAliasDVU)->(Eof()) .Or. (cAliasDVU)->QTDREG == 0
			lAltVei := .T.
		EndIf
		(cAliasDVU)->(DbCloseArea())
		RestArea(aArea)
	EndIf
EndIf

If lAltVei
	//-- Exclui registros anteriores
	DVU->(DbSetOrder(2))
	If DVU->(DbSeek(cSeekDVU := xFilial("DVU") + cFilOri + cLotNFc + cNumNFc + cSerNFc + cCliRem + cLojRem))
		While DVU->(!Eof()) .And. DVU->(DVU_FILIAL + DVU_FILORI + DVU_LOTNFC + DVU_NUMNFC + DVU_SERNFC + DVU_CLIREM + DVU_LOJREM) == cSeekDVU
			RecLock("DVU",.F.)
			DVU->(DbDelete())
			DVU->(MsUnLock())
			DVU->(DbSkip())
		EndDo
	EndIf

	//-- Busca veículos da viagem
	aCompVia := TmsA240Mnt(,,04,cFilVia,cViagem,aCompVia,"",cSerTms,cTipTra,,,,.F.)
	nPosCpo  := Ascan(aCompVia[1],{|x| x[2] == "DTR_CODCPO"})
	nPosVei  := Ascan(aCompVia[1],{|x| x[2] == "DTR_CODVEI"})
	nPosRb1  := Ascan(aCompVia[1],{|x| x[2] == "DTR_CODRB1"})
	nPosRb2  := Ascan(aCompVia[1],{|x| x[2] == "DTR_CODRB2"})
	nPosRb3  := Ascan(aCompVia[1],{|x| x[2] == "DTR_CODRB3"})

	For nCntFor1 := 1 To Len(aCompVia[2])
		//-- Busca composição ou veículo principal da viagem
		cTipVei := ""
		If nPosCpo > 0 .And. !Empty(aCompVia[2][nCntFor1,nPosCpo])
			cTipVei := aCompVia[2][nCntFor1,nPosCpo]
		ElseIf (nPosRb1 > 0 .And. Empty(aCompVia[2][nCntFor1,nPosRb1])) .And. ;
			   (nPosRb2 > 0 .And. Empty(aCompVia[2][nCntFor1,nPosRb2])) .And. ;
			   (nPosRb3 > 0 .And. Empty(aCompVia[2][nCntFor1,nPosRb3]))
			If nPosVei > 0 .And. !Empty(aCompVia[2][nCntFor1,nPosVei])
				cTipVei := Posicione("DA3",1,xFilial("DA3") + aCompVia[2][nCntFor1,nPosVei],"DA3_TIPVEI")
			EndIf
		EndIf

		//-- Atualiza com a composição ou com o veículo principal da viagem
		If !Empty(cTipVei)
			RecLock("DVU",.T.)
			DVU->DVU_FILIAL:= xFilial("DVU")
			DVU->DVU_FILORI:= cFilOri
			DVU->DVU_LOTNFC:= cLotNFc
			DVU->DVU_NUMNFC:= cNumNFc
			DVU->DVU_SERNFC:= cSerNFc
			DVU->DVU_CLIREM:= cCliRem
			DVU->DVU_LOJREM:= cLojRem
			DVU->DVU_ITEM  := StrZero(nCntFor1,Len(DVU->DVU_ITEM))
			DVU->DVU_TIPVEI:= cTipVei
			DVU->DVU_QTDVEI:= 1
			MsUnLock()
		EndIf
	Next nCntFor1
EndIf

Return

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  TmsSqEnd
@autor		: Daniel Carlos Leme
@descricao	: Retorna dados de endereço considerando a sequencia de entrega
@since		: Jun./2016
@review	:

Argumentos	:

/*/
//-------------------------------------------------------------------------------------------------
Function TmsSqEnd(cCliente,cLoja,cSeqEnd,cCpo)
Local cRet := ""

If !Empty(cSeqEnd)
	If DUL->(ColumnPos("DUL_"+Substr(cCpo,At("_",cCpo)+1)) ) > 0
		DUL->(dbSetOrder(2)) //-- DUL_FILIAL+DUL_CODCLI+DUL_LOJCLI+DUL_SEQEND
		If DUL->( MsSeek(FwxFilial("DUL") + cCliente + cLoja +  cSeqEnd ) )
			cRet := DUL->&("DUL_"+Substr(cCpo,At("_",cCpo)+1))
		EndIf
	EndIf
Else
	If SA1->(ColumnPos("A1_"+Substr(cCpo,At("_",cCpo)+1)) ) > 0
		SA1->(dbSetOrder(1)) //-- A1_FILIAL+A1_COD+A1_LOJA
		If SA1->(MsSeek(FwxFilial('SA1')+cCliente+cLoja))
			cRet := SA1->&("A1_"+Substr(cCpo,At("_",cCpo)+1))
		EndIf
	EndIf
EndIf

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TmsVerCTe ºAutor Felipe Barbieri     º Data ³  20/01/17     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função utilizada Impressão do DACTE                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TmsVerCTe()
Local lRTMSR27   := ExistBlock("RTMSR27",,.T.)
Local lRTMSR31   := ExistBlock("RTMSR31",,.T.)
Local lRTMSR35   := ExistBlock("RTMSR35",,.T.)
Local cVersaoCTe := ""
Local cError     := ""
Local lUsaColab  := UsaColaboracao("2")

If !lUsaColab
	cIdEnt      := getCfgEntidade(@cError)
	If !Empty(cIdEnt)
		cVersaoCTe := getCfgVersao(@cError, cIdEnt, "57" )
		cVersaoTSS := getVersaoTSS(@cError)
		If cVersaoCTe = "3.00" .And. lRTMSR35
			ExecBlock("RTMSR35",.F.,.F.)
		ElseIf cVersaoCTe = "3.00" .And. lRTMSR31
			ExecBlock("RTMSR31",.F.,.F.)
		ElseIf cVersaoCTe <= "2.00" .And. lRTMSR27
		   ExecBlock("RTMSR27",.F.,.F.)
		EndIf
	EndIf
Else
	cVersaoCte		:= ColGetPar("MV_VERCTE","")
	If cVersaoCTe = "3.00" .And. lRTMSR35
		ExecBlock("RTMSR35",.F.,.F.)
	ElseIf cVersaoCTe = "3.00" .And. lRTMSR31
		ExecBlock("RTMSR31",.F.,.F.)
	ElseIf cVersaoCTe <= "2.00" .And. lRTMSR27
	   ExecBlock("RTMSR27",.F.,.F.)
	EndIf
EndIf

Return Nil
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsModInco()
@autor		: Eduardo Alberti
@descricao	: Retorna Retorna o Modo De Tratamento Da Incomp. Produtos
@since		: Aug./2016
@using		: TMSA029 - Incomp. Produtos //-- Perfil Do Cliente - '1' = Bloqueia Lote NFs, '2' = Separa Documentos
@review	:

Argumentos	:
/*/
//-------------------------------------------------------------------------------------------------
Function TmsModInco( cTipo, cCliente, cLoja )

	Local aArea      := GetArea()
	Local aArDUO     := DUO->(GetArea())
	Local cMod       := ""
	Local cMVCliGen := GetMV("MV_CLIGEN",,'')
	Local cCliGen   :=  Left(Alltrim(cMVCliGen),Len(DTC->DTC_CLIDEV))
	Local cLojGen   := Right(Alltrim(cMVCliGen),Len(DTC->DTC_LOJDEV))

	Default cTipo    := "INC"
	Default cCliente := ""
	Default cLoja    := ""

	//-- Perfil Do Cliente - '1' = Bloqueia Lote NFs, '2' = Separa Documentos
	DbSelectArea("DUO")
	DbSetOrder(1) //-- DUO_FILIAL+DUO_CODCLI+DUO_LOJCLI
	If ! DUO->(MsSeek(FWxFilial("DUO") + cCliente + cLoja, .F.))
		DUO->(MsSeek(FWxFilial("DUO") + cCliGen + cLojGen, .F.))
	EndIf

	If cTipo == "INC"
		If DUO->(ColumnPos("DUO_INCOMP")) > 0
			cMod := DUO->DUO_INCOMP	//-- Se campo Existir Define Pelo Conteudo Do Campo
		Else
			cMod := '2'				//-- Se Não Existir o Campo, Separa Documentos (Padrão)
		EndIf
	ElseIf cTipo == "RRE"
		If DUO->(ColumnPos("DUO_RRE")) > 0
			cMod := DUO->DUO_RRE	//-- Se campo Existir Define Pelo Conteudo Do Campo
		Else
			cMod := ''
		EndIf
	EndIf

	RestArea(aArDUO)
	RestArea(aArea)

Return( cMod )

//-------------------------------------------------------------------------------------------------
/* {Protheus.doc} TmsUniNeg
@autor		: Valdemar
@descricao	: Verifica se utiliza unidade de negocio no contrato do cliente
@since		: 18/09/2016
@using		: Contrato do cliente
*/
//-------------------------------------------------------------------------------------------------
Function TmsUniNeg(cCampo)
Local lRet   := .T.

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsAtuDJI()
@autor		: Eduardo Alberti
@descricao	: Geração/Atualização De Histórico Do Componente Do Frete
@param		: cFilVge  -> Caractere - Filial Origem Da Viagem Informada
@param		: cViagem  -> Caractere - Numero Da Viagem Informada
@param		: cTipCal  -> Caractere - 1=Previsto; 2=Realizado
@param		: cStatus  -> Caractere - 1=Calculado     -  Cria DJI Conforme DT8;
                                         2=Cancelado     -  Cancela DJI;
                                         3=Calc. + Canc. -  Cria DJI Conforme DT8 e Cancela DJI Anterior
                                         4=Retorna Para o DT8 e DT6 o Último Movimento 'Previsto' Válido.
                                         5=Recria DT8 Conforme Último Movimento 'Cancelado' Do DJI e Revaloriza DT6 ( Utilizado No Estorno Do Apontamento Ocorrencias Co "Retorna Documento")
@param		: aParTab  -> Array     - Vetor Contendo Campos Que Vão Servir De Chave Para Busca Do Registro No DT8 Ou DJI
@return	: lRotAut  -> Booleado - Se .t. Efetuou Geração Do Histórico; Se .f. Não Encontrou a Chave Informada
@since		: Sep./2016
@using		: Genérico
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Function TmsAtuDJI( cFilVge, cViagem, cTipCal, cStatus, aParTab, lRotAut )

	Local aAreas    := {DT6->(GetArea()),DT8->(GetArea()),DTQ->(GetArea()),GetArea()}
	Local lRet      := .f.
	Local nTotReg   := 0
	Local cAliasTmp := GetNextAlias()
	Local bQuery    := {|| Iif(Select(cAliasTmp) > 0, (cAliasTmp)->(dbCloseArea()), Nil) , dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasTmp,.F.,.T.), dbSelectArea(cAliasTmp), (cAliasTmp)->(dbEval({|| nTotReg++ })), (cAliasTmp)->(dbGoTop())  }
	Local cQuery    := ""
	Local cFilQry   := ""
	Local nCnt      := 0
	Local nCamDJI   := 0
	Local nCamTmp   := 0
	Local bCampo    := {|x| FieldName(x) }
	Local cSeqGer   := ""
	Local nCodRet   := 0
	Local aInfDJI   := {}
	Local aDjiDt6   := {}
	Local aStruDJI  := {}
	Local aNoAtu    := {}
	Local cUsuario  := RetCodUsr()
    Local DBS_TYPE  := 2
    Local cType     := 2
    Local cAliasAtu := ""

	Default cFilVge := ""
	Default cViagem := ""
	Default cTipCal := '1' //-- 1=Previsto; 2=Realizado
	Default cStatus := '1' //-- 1=Calculado; 2=Cancelado
	Default aParTab := {}
	Default lRotAut := .f.

	//-- Carrega Vetor De-Para De Campos
	aAdd( aDjiDt6 , {'DJI_VALFRE' , 'DT6_VALFRE' , 'S' } )	//-- Valor Frete
	aAdd( aDjiDt6 , {'DJI_TIPFRE' , 'DT6_TIPFRE' , 'S' } )	//-- Tipo Frete 1=Cif 2=Fob
	aAdd( aDjiDt6 , {'DJI_NCONTR' , 'DT6_NCONTR' , 'S' } )	//-- Número Contrato
	aAdd( aDjiDt6 , {'DJI_LOTNFC' , 'DT6_LOTNFC' , 'S' } )	//-- Numero Lote TMS
	aAdd( aDjiDt6 , {'DJI_CLIREM' , 'DT6_CLIREM' , 'S' } )	//-- Cliente Remetente
	aAdd( aDjiDt6 , {'DJI_LOJREM' , 'DT6_LOJREM' , 'S' } )	//-- Loja Remetente
	aAdd( aDjiDt6 , {'DJI_CLICAL' , 'DT6_CLICAL' , 'S' } )	//-- Cliente Calculo
	aAdd( aDjiDt6 , {'DJI_LOJCAL' , 'DT6_LOJCAL' , 'S' } )	//-- Loj Calculo
	aAdd( aDjiDt6 , {'DJI_DEVFRE' , 'DT6_DEVFRE' , 'S' } )	//-- Devedor Frete 1=Remetente;2=Destinatario;3=Consignatario;4=Despachante
	aAdd( aDjiDt6 , {'DJI_QTDUNI' , 'DT6_QTDUNI' , 'S' } )	//-- Quantidade Unitizadores
	aAdd( aDjiDt6 , {'DJI_BASSEG' , 'DT6_BASSEG' , 'S' } )	//-- TDA
	aAdd( aDjiDt6 , {'DJI_METRO3' , 'DT6_METRO3' , 'S' } )	//-- M3
	aAdd( aDjiDt6 , {'DJI_SERVIC' , 'DT6_SERVIC' , 'S' } )	//-- Serviço
	aAdd( aDjiDt6 , {'DJI_DT6STA' , 'DT6_STATUS' , 'S' } )	//-- Status DT6
	aAdd( aDjiDt6 , {'DJI_CODNEG' , 'DT6_CODNEG' , 'S' } )	//-- Código da Negociação
	aAdd( aDjiDt6 , {'DJI_CDRDES' , 'DT6_CDRCAL' , 'N' } )	//-- Regiao de Calculo
	aAdd( aDjiDt6 , {'DJI_VALTOT' , 'DT6_VALTOT' , 'N' } )	//-- Valor Total Calculado
	aAdd( aDjiDt6 , {'DJI_TABFRE' , 'DT6_TABFRE' , 'N' } )	//-- Cód. Tab. Frete
	aAdd( aDjiDt6 , {'DJI_TIPTAB' , 'DT6_TIPTAB' , 'N' } )	//-- Tipo Tabela
	aAdd( aDjiDt6 , {'DJI_SEQTAB' , 'DT6_SEQTAB' , 'N' } )	//-- Seq. Tabela


	//-- Validação Do Dicionário Utilizado
	If !AliasInDic("DJI")
		If !lRotAut
			MsgNextRel()	//-- É Necessário a Atualização Do Sistema Para a Expedição Mais Recente
		EndIf
		Return()
	EndIf

	//-- Inicializa Controle De Sequence
	Begin Sequence

		//-- Processa Somente Com Numero Da Viagem Informado
		If Empty( cViagem )
			Break
		EndIf

		//-- Identifica Viagem
		DbSelectArea("DTQ")
		DbSetOrder(2) //-- DTQ_FILIAL+DTQ_FILORI+DTQ_VIAGEM+DTQ_ROTA
		If !MsSeek( xFilial("DTQ") + PadR( cFilVge , TamSX3("DTQ_FILORI")[1]) + PadR( cViagem , TamSX3("DTQ_VIAGEM")[1]) ,.f.)
			Break
		EndIf

		//-- Formata As Expressões SQL Conforme Vetor De Parametros Informado
		If Len(aParTab) > 0 .And. Empty(cFilQry)

			//-- Tratamento Do Vetor De Campos
            If cStatus == "2"
                cAliasAtu := "DJI"
            Else
                cAliasAtu := "DT8"
            EndIf

            For nCnt := 1 To Len(aParTab)

				If ValType( aParTab[nCnt] ) == "A" .And. Len( aParTab[nCnt] ) >= 2

					If ValType( aParTab[nCnt,01] ) == "C"

						If (cAliasAtu)->(ColumnPos(aParTab[nCnt,01])) > 0

                            cType := (cAliasAtu)->(DBFieldInfo( DBS_TYPE, FieldPos(aParTab[nCnt,01]) ))

                            cFilQry += " AND " + aParTab[nCnt,01] + " = "
							If cType == "N"
								cFilQry += Alltrim(Str(aParTab[nCnt,02]))
							ElseIf cType == "D"
								cFilQry += "'" + DtoS(aParTab[nCnt,02]) + "'"
                            Else
                                cFilQry += "'" + aParTab[nCnt,02] + "'"
							EndIf
						EndIf
					EndIf
				EndIf
			Next nCnt
		EndIf

		//---------------------------------------------------------------------------------------------
		//-- Tratamento Para Inclusão Dados No DJI                                                    -
		//---------------------------------------------------------------------------------------------
		If cStatus $ '1|3' //-- 1 = Calculado; 3 = Calculado + Cancela DJI Anterior

			//-- Executa Pesquisa No DT8 Conforme Parametros
			If !Empty(cFilQry)

				//-- Cancela Movimento Anterior Do DJI Antes De Gerar o Novo
				If cStatus == '3'

					//---------------------------------------------------------------------------------------------
					//-- Chama Esta Mesma Função De Forma Recursiva Para Cancelar O Movimento Anterior Caso Exista-
					//---------------------------------------------------------------------------------------------
					If !Empty(aInfDJI)
						TmsAtuDJI( cFilVge, cViagem, Nil, '2', Nil, .f. )
					EndIf
				EndIf

				cQuery :=	" SELECT      DT8.* " //-- Tem Que Ser Select * Para Selecionar Os Campos Customizados Também
				cQuery +=	" FROM        " + RetSQLName("DT8") + " DT8 "
				cQuery +=	" WHERE       DT8.DT8_FILIAL  =  '" + FWxFilial("DT8") + "' "
				cQuery +=	"             " + cFilQry + " " //-- Filtra Por Documento
				cQuery +=	" AND         DT8.D_E_L_E_T_  = ' ' "
				cQuery +=	" ORDER BY    DT8.R_E_C_N_O_ "

				//-- Executa Parse
				cQuery := ChangeQuery(cQuery)

				//-- Executa Query
				Eval(bQuery)

				// Formata Campos (TcSetField)
				aEval(DT8->(dbStruct()),{|e| If(e[2] != "C" .And. Alltrim(e[1]) $ Upper(cQuery), TCSetField( cAliasTmp,e[1], e[2], e[3], e[4]), Nil)})

				DbSelectArea("DJI")

				//-- Determina Quantidade De Campos Da Tabela
				nCamDJI := DJI->( FCount() )
				nCamTmp := (cAliasTmp)->( FCount() )
				aCamTmp := (cAliasTmp)->( DbStruct() )

				DbSelectArea(cAliasTmp)
				(cAliasTmp)->(DbGoTop())

				//-- Inicializa Controle Transacional
				Begin Transaction

					While (cAliasTmp)->( !Eof() )

						//-- Cria Variáveis De Memória
						RegToMemory('DJI',.T.)

						//-- Atribui Valor De Campos Por Macro Substituição
						For nCnt := 1 To Len(aCamTmp)

							cCampo := "DJI_" + Substr(aCamTmp[ nCnt, 01 ], 05, 06)

							If DJI->(ColumnPos(cCampo)) > 0

								If Alltrim(cCampo) == "DJI_FILIAL"
									M->DJI_FILIAL := FWxFilial("DJI")
								Else
									M->&( cCampo ) := (cAliasTmp)->&( aCamTmp[ nCnt, 01 ] )
								EndIf

							EndIf

						Next nCnt

						//-- Grava Campos Complementares Específicos da Tabela
						M->DJI_DATGER  := MsDate()
						M->DJI_HORGER  := Time()
						M->DJI_FILVGE  := cFilVge
						M->DJI_VIAGEM  := cViagem
						M->DJI_SEQGER  := Iif( Empty(cSeqGer), cSeqGer := TmsSeqDJI(), cSeqGer )
						M->DJI_TIPCAL  := cTipCal
						M->DJI_STATUS  := cStatus
						M->DJI_CODUSR  := Iif( lRotAut, "000000", cUsuario )

						//-- Verifica Se Está No Componente 'TF' (Total Do Frete).
						If M->DJI_CODPAS == 'TF'

							//-- Posiciona No Documento Calculado
							DbSelectArea("DT6")
							DbSetOrder(1) //-- DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
							If MsSeek(FWxFilial("DT6") + M->DJI_FILDOC + M->DJI_DOC + M->DJI_SERIE , .F. )

								//-- Copia Valores Do DT6 Para DJI
								For nCnt := 1 To Len(aDjiDt6)
									If aDjiDt6[nCnt,03] == 'S'
										M->&( aDjiDt6[nCnt,01] ) := DT6->&( aDjiDt6[nCnt,02] )
									EndIf
								Next nCnt
							EndIf
						EndIf

						//-- Grava Tabela Conforme Variáveis
						RecLock('DJI',.T.)
						For nCnt := 1 To nCamDJI
							FieldPut( nCnt, M->&( Eval( bCampo,nCnt ) ) )
						Next
						DJI->(MsUnLock())

						(cAliasTmp)->(DbSkip())
					EndDo

				//-- Encerra Controle Transacional
				End Transaction
			EndIf

		//---------------------------------------------------------------------------------------------
		//-- Tratamento Para Cancelamento Do Cálculo ( cStatus = '2' - Cancelado ).                   -
		//---------------------------------------------------------------------------------------------
		ElseIf cStatus == '2'

			cQuery :=	" UPDATE  " + RetSQLName("DJI") + " "
			cQuery +=	" SET     DJI_STATUS  =  '2' " //-- Cancelado
			cQuery +=	" WHERE   R_E_C_N_O_  IN ( SELECT      R_E_C_N_O_ "
			cQuery +=	                         " FROM        " + RetSQLName("DJI") + " "
            cQuery +=	                         " WHERE       DJI_FILIAL  =  '" + FWxFilial("DJI") + "' "
			cQuery +=	                         "             " + cFilQry + " " //-- Filtra Por Documento
			cQuery +=	                         " AND         DJI_FILVGE  =  '" + cFilVge + "' "
			cQuery +=	                         " AND         DJI_VIAGEM  =  '" + cViagem + "' "
			cQuery +=	                         " AND         D_E_L_E_T_  =  ' ' "
			cQuery +=	                         " AND         DJI_SEQGER  IN ( SELECT     MAX(DJI_SEQGER) "
			cQuery +=	                                                      " FROM       " + RetSQLName("DJI") + " "
			cQuery +=	                                                      " WHERE      DJI_FILIAL  =  '" + FWxFilial("DJI") + "' "
			cQuery +=	                                                      "            " + cFilQry + " " //-- Filtra Por Documento
			cQuery +=	                                                      " AND        DJI_FILVGE  =  '" + cFilVge + "' "
			cQuery +=	                                                      " AND        DJI_VIAGEM  =  '" + cViagem + "' "
			cQuery +=	                                                      " AND        D_E_L_E_T_  =  ' ' ) ) "

			//-- Executa Script
			nCodRet:= TcSqlExec(cQuery)

			//-- Inclui Log De Erro
			If nCodRet < 0
				If !(lRotAut)
					lRet := .f.
					Help( ,, ProcName(),, TcSqlError() , 1, 0)
				EndIf
			EndIf

		//---------------------------------------------------------------------------------------------
		//-- 4 = Retorna Para o DT8 e DT6 o Último Movimento 'Previsto' Válido.                       -
		//---------------------------------------------------------------------------------------------
		ElseIf cStatus == '4'

			//---------------------------------------------------------------------------------------------
			//-- Passo 1 - Cancela o Movimento De Encerramento da Viagem No DJI.                          -
			//---------------------------------------------------------------------------------------------
			//-- Chama Esta Mesma Função De Forma Recursiva Para Cancelar O Movimento Anterior Caso Exista
			TmsAtuDJI( cFilVge, cViagem, Nil, '2', Nil, .f. )

			//---------------------------------------------------------------------------------------------
			//-- Passo 2 - Retorna Os valores Do Fechamento Da Viagema Para As Tabelas DT8 e DT6          -
			//---------------------------------------------------------------------------------------------

			cQuery :=	" SELECT      DJI.R_E_C_N_O_ DJIREC "
			cQuery +=	" FROM        " + RetSQLName("DJI") + " DJI "
			cQuery +=	" WHERE       DJI.DJI_FILIAL  =  '" + FWxFilial("DJI") + "' "
			cQuery +=	" AND         DJI_FILVGE      =  '" + cFilVge + "' "
			cQuery +=	" AND         DJI_VIAGEM      =  '" + cViagem + "' "
			cQuery +=	" AND         DJI_TIPCAL      =  '1' "
			cQuery +=	" AND         DJI_STATUS      =  '1' "
			cQuery +=	" AND         DJI.D_E_L_E_T_  =  ' ' "
			cQuery +=	" ORDER BY    DJI.R_E_C_N_O_ "

			//-- Executa Parse
			cQuery := ChangeQuery(cQuery)

			//-- Executa Query
			Eval(bQuery)

			//-- Formata Campo DDU.R_E_C_N_O_
			TcSetField(cAliasTmp,"DJIREC","N",16,0)

			//-- Posiciona na Tabela Origem (DJI)
			DbSelectArea("DJI")

			//-- Determina Estrutura da tabela
			aStruDJI := DJI->( DbStruct() )

			//-- Campos Que Não Serão Atualizados
			aNoAtu   := { "DT8_FILIAL","DT8_FILDOC","DT8_DOC","DT8_SERIE","DT8_CODPRO","DT8_CODPAS" }

			//-- Inicializa Controle Transacional
			Begin Transaction

				DbSelectArea(cAliasTmp)
				(cAliasTmp)->(DbGoTop())

				While (cAliasTmp)->( !Eof() )

					If (cAliasTmp)->DJIREC <= 0
						(cAliasTmp)->(DbSkip())
						Loop
					EndIf

					//-- Posiciona na Tabela Origem (DJI)
					DbSelectArea("DJI")
					DJI->(DbGoTo( (cAliasTmp)->DJIREC ))

					DbSelectArea("DT8")
					DbSetOrder(2) //-- DT8_FILIAL+DT8_FILDOC+DT8_DOC+DT8_SERIE+DT8_CODPRO+DT8_CODPAS
					If MsSeek(xFilial("DT8") + DJI->DJI_FILDOC + DJI->DJI_DOC + DJI->DJI_SERIE + DJI->DJI_CODPRO + DJI->DJI_CODPAS , .F.)

						RecLock("DT8", .F. )

						//-- Atualiza Campos da DT8 Conforme DJI
						For nCnt := 1 To Len(aStruDJI)

							cCampo := "DT8_" + Substr(aStruDJI[ nCnt, 01 ], 05, 06)

							//-- Exclui Campos Chave Da Atualização
							If Ascan( aNoAtu , Alltrim(cCampo) ) == 0

								If DT8->(ColumnPos(cCampo)) > 0
									DT8->&( cCampo ) :=  DJI->&( aStruDJI[ nCnt, 01 ] )
								EndIf
							EndIf
						Next nCnt

						DT8->(MsUnlock())

						//-- Se o Campo DJI_CODPAS For 'TF', Executa Gravação Dos Dados Da Tabela DT6
						If DJI->DJI_CODPAS == 'TF'

							DbSelectArea("DT6")
							DbSetOrder(1) //-- DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
							If MsSeek( FWxFilial("DT6") + DJI->DJI_FILDOC + DJI->DJI_DOC + DJI->DJI_SERIE, .f. )

								RecLock("DT6",.f.)

								//-- Atualiza Campos da DT6 Conforme DJI
								For nCnt := 1 To Len(aDjiDt6)
									DT6->&( aDjiDt6[nCnt,2] ) :=  DJI->&( aDjiDt6[nCnt,1] )
								Next nCnt

								DT6->(MsUnlock())

							EndIf
						EndIf
					EndIf

					(cAliasTmp)->(DbSkip())
				EndDo

			//-- Encerra Controle Transacional
			End Transaction

		//---------------------------------------------------------------------------------------------
		//-- 5 = Recria DT8 Conforme Último Movimento Do DJI e Revaloriza DT6 ( Utilizado No Estorno Do Apontamento Ocorrencias Co "Retorna Documento")
		//---------------------------------------------------------------------------------------------
		ElseIf cStatus == '5'

			cQuery :=	" SELECT      DJI.R_E_C_N_O_ DJIREC "
			cQuery +=	" FROM        " + RetSQLName("DJI") + " DJI "
			cQuery +=	" WHERE       DJI.DJI_FILIAL  =  '" + FWxFilial("DJI") + "' "
			cQuery +=	" AND         DJI.DJI_FILVGE  =  '" + cFilVge + "' "
			cQuery +=	" AND         DJI.DJI_VIAGEM  =  '" + cViagem + "' "
			cQuery +=	"             " + StrTran( cFilQry,"DJI_","DJI.DJI_") + " " //-- Filtra Por Documento
			cQuery +=	" AND         DJI.DJI_TIPCAL  =  '1' "
			cQuery +=	" AND         DJI_STATUS      =  '2' "
			cQuery +=	" AND         DJI.D_E_L_E_T_  =  ' ' "
			cQuery +=	" AND         DJI.DJI_SEQGER  IN ( SELECT		MAX(DJIX.DJI_SEQGER) "
			cQuery +=	"                                  FROM 		" + RetSQLName("DJI") + " DJIX "
			cQuery +=	"                                  WHERE 		DJIX.DJI_FILIAL  =  '" + FWxFilial("DJI") + "' "
			cQuery +=	"                                  			" + StrTran( cFilQry,"DJI_","DJIX.DJI_") + " " //-- Filtra Por Documento
			cQuery +=	"                                  AND			DJIX.D_E_L_E_T_  = ' ' )"
			cQuery +=	" ORDER BY    DJI.R_E_C_N_O_ "

			//-- Executa Parse
			cQuery := ChangeQuery(cQuery)

			//-- Executa Query
			Eval(bQuery)

			//-- Formata Campo DDU.R_E_C_N_O_
			TcSetField(cAliasTmp,"DJIREC","N",16,0)

			//-- Posiciona na Tabela Origem (DJI)
			DbSelectArea("DJI")

			//-- Determina Estrutura da tabela
			aStruDJI := DJI->( DbStruct() )

			//-- Inicializa Controle Transacional
			Begin Transaction

				DbSelectArea(cAliasTmp)
				(cAliasTmp)->(DbGoTop())

				While (cAliasTmp)->( !Eof() )

					If (cAliasTmp)->DJIREC <= 0
						(cAliasTmp)->(DbSkip())
						Loop
					EndIf

					//-- Posiciona na Tabela Origem (DJI)
					DbSelectArea("DJI")
					DJI->(DbGoTo( (cAliasTmp)->DJIREC ))

					//---------------------------------------------------------------------------------------------
					//-- Passo 1 - Altera o Status Do DJI De Cancelado Para Previsto
					//---------------------------------------------------------------------------------------------
					RecLock("DJI",.F.)
					Replace DJI->DJI_STATUS With '1' //-- Previsto
					DJI->(MsUnlock())

					//---------------------------------------------------------------------------------------------
					//-- Passo 2 - Recria DT8 Conforme DJI
					//---------------------------------------------------------------------------------------------
					DbSelectArea("DT8")
					DbSetOrder(2) //-- DT8_FILIAL+DT8_FILDOC+DT8_DOC+DT8_SERIE+DT8_CODPRO+DT8_CODPAS
					If !MsSeek(xFilial("DT8") + DJI->DJI_FILDOC + DJI->DJI_DOC + DJI->DJI_SERIE + DJI->DJI_CODPRO + DJI->DJI_CODPAS , .F.)

						RecLock("DT8", .T. )

						//-- Atualiza Campos da DT8 Conforme DJI
						For nCnt := 1 To Len(aStruDJI)

							cCampo := "DT8_" + Substr(aStruDJI[ nCnt, 01 ], 05, 06)

							//-- Tratamento Do Campo Filial
							If Upper(Alltrim(cCampo)) == "DT8_FILIAL"
								Replace DT8->DT8_FILIAL With FWxFilial("DT8")
							Else

								If DT8->(ColumnPos(cCampo)) > 0
									DT8->&( cCampo ) :=  DJI->&( aStruDJI[ nCnt, 01 ] )
								EndIf
							EndIf
						Next nCnt

						DT8->(MsUnlock())

						//---------------------------------------------------------------------------------------------
						//-- Passo 3 - Refaz Valorização Dos Dados Da Tabela DT6 Conforme Gravação DJI
						//---------------------------------------------------------------------------------------------
						If DJI->DJI_CODPAS == 'TF'

							DbSelectArea("DT6")
							DbSetOrder(1) //-- DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
							If MsSeek( FWxFilial("DT6") + DJI->DJI_FILDOC + DJI->DJI_DOC + DJI->DJI_SERIE, .f. )

								RecLock("DT6",.f.)

								//-- Atualiza Campos da DT6 Conforme DJI
								For nCnt := 1 To Len(aDjiDt6)
									DT6->&( aDjiDt6[nCnt,2] ) :=  DJI->&( aDjiDt6[nCnt,1] )
								Next nCnt

								DT6->(MsUnlock())

							EndIf
						EndIf
					EndIf

					(cAliasTmp)->(DbSkip())
				EndDo

			//-- Encerra Controle Transacional
			End Transaction

		EndIf

	//-- Finaliza Controle De Sequence
	End Sequence

	//-- Fecha Arquivo Temporário
	If Select(cAliasTmp) > 0
		(cAliasTmp)->(DbCloseArea())
	EndIf

	//-- Reposiciona Registros
	AEval(aAreas,{|x,y| RestArea(x) })

Return( lRet )

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsSeqDJI()
@autor		: Eduardo Alberti
@descricao	: Geração Da Sequencia De Gravação Do Campo DJI_SEQGER
@param		: Nenhum    -> A Chave Do DJI Que Será Gravada Deve Estar Em Memória
@return	: Caractere -> Próxima Sequencia Disponível
@since		: Sep./2016
@using		: Genérico
@review	:

Argumentos	:
/*/
//-------------------------------------------------------------------------------------------------
Function TmsSeqDJI()

	Local aAreas    := {GetArea()}
	Local cRet      := ""
	Local nTotReg   := 0
	Local cAliasTmp := GetNextAlias()
	Local bQuery    := {|| Iif(Select(cAliasTmp) > 0, (cAliasTmp)->(dbCloseArea()), Nil) , dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasTmp,.F.,.T.), dbSelectArea(cAliasTmp), (cAliasTmp)->(dbEval({|| nTotReg++ })), (cAliasTmp)->(dbGoTop())  }
	Local cQuery    := ""
	Local nTamSeq   := TamSX3("DJI_SEQGER")[1]

	cQuery :=	" SELECT      MAX(DJI.DJI_SEQGER) DJI_SEQGER "
	cQuery +=	" FROM        " + RetSqlName("DJI") + " DJI "
	cQuery +=	" WHERE       DJI.DJI_FILIAL = '" + FWxFilial("DJI") + "' "
	cQuery +=	" AND         DJI.DJI_FILDOC = '" + M->DJI_FILDOC    + "' "
	cQuery +=	" AND         DJI.DJI_DOC    = '" + M->DJI_DOC       + "' "
	cQuery +=	" AND         DJI.DJI_SERIE  = '" + M->DJI_SERIE     + "' "
	cQuery +=	" AND         DJI.DJI_FILVGE = '" + M->DJI_FILVGE    + "' "
	cQuery +=	" AND         DJI.DJI_VIAGEM = '" + M->DJI_VIAGEM    + "' "
	cQuery +=	" AND         DJI.DJI_CODPRO = '" + M->DJI_CODPRO    + "' "
	//cQuery +=	" AND         DJI.DJI_CODPAS = '" + M->DJI_CODPAS    + "' "
	cQuery +=	" AND         DJI.D_E_L_E_T_ = ' ' "

	//-- Executa Parse
	cQuery := ChangeQuery(cQuery)

	//-- Executa Query
	Eval(bQuery)

	//-- Determina valor De Retorno Conforme Resultado Da Query
	If Empty((cAliasTmp)->DJI_SEQGER)
		cRet := StrZero( 1 , nTamSeq )
	Else
		cRet := Soma1( (cAliasTmp)->DJI_SEQGER, nTamSeq )
	EndIf

	//-- Fecha Arquivo Temporário
	If Select(cAliasTmp) > 0
		(cAliasTmp)->(DbCloseArea())
	EndIf

	//-- Reposiciona Registros
	AEval(aAreas,{|x,y| RestArea(x) })

Return( cRet )

//-------------------------------------------------------------------------------------------------
/* {Protheus.doc} TMSCriaTab
@autor		: Valdemar
@descricao	: Criar tabela temporária via JOB quando dentro de transação
@since		: 23/01/2017
@using		: Divergencias Das Classes De Risco/Grupo Embalagens
*/
//-------------------------------------------------------------------------------------------------
Function TMSCriaTab(cEmp,cFil,lRpc,aDados)

	//Local cRet       := GetNextAlias()

	Default lRPC   := .F.
	Default aDados := {}

	If lRPC
		RpcSetType(3)
		RpcSetEnv(cEmp,cFil,,,"TMS",,,/*lShowFinal*/,/*lAbend*/,.F./*lOpenSX*/,/*lConnect*/)
	Endif

	/*
	oTempTable := FWTemporaryTable():New()
	oTempTable:SetFields(aDados[1])
	oTempTable:AddIndex("01",{"B1_COD"})
	oTempTable:Create()

	cRet := oTempTable:GetAlias()
	*/

	CriaTmpDb("", aDados[2] , aDados[1] )

Return aDados[2]

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tms3GfeInt()
@autor		: Katia
@descricao	: Integração Viagem TMS x GFE
@param		: Filial de Origem, Viagem, Rotina Automatica, Estorno
@return	: Logico - lRet
@since		: Dez./2016
@using		: Genérico
@review	:

Argumentos	:
/*/
//-------------------------------------------------------------------------------------------------
Function Tms3GfeInt(cFilOri, cViagem, lRotAut, lEstorno,cFilDoc,cDoc,cSerie)
Local lRet     := .T.
Local aArea    := GetArea()
Local aAreaDTQ := DTQ->(GetArea())
Local lProcessa:= .F.
Local lVgeRdp  := .F.
Local lTmsRdpU  := SuperGetMV( 'MV_TMSRDPU',.F., 'N' ) <> 'N'  //F-Fechamento, S=Saida, C=Chegada, N=Não Utiliza o Romaneio unico por Lote de Redespacho
Local lAltDocto := .F.

Default cFilOri := ""
Default cViagem := ""
Default lRotAut := .F.
Default lEstorno:= .F.
Default cFilDoc := ""
Default cDoc    := ""
Default cSerie  := ""

SaveInter()
DTQ->(DbSetOrder(2))   // DTQ_FILIAL+DTQ_FILORI+DTQ_VIAGEM+DTQ_ROTA
If DTQ->(DbSeek(xFilial("DTQ") + cFilOri + cViagem))
	lVgeRdp  := DTQ->DTQ_TIPVIA == StrZero(5,Len(DTQ->DTQ_TIPVIA)) .And. lTmsRdpU //Viagem Redespacho e MV_TMSRDPU ativo
	lProcessa:= DTQ->DTQ_PAGGFE == StrZero(1,Len(DTQ->DTQ_PAGGFE))  //Sim
EndIf

If !lProcessa
	//Verifica se os Documentos da Viagem tem Redespacho informado
	lProcessa:= TmsRedDJN(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM)
EndIf

If lProcessa
	If !lEstorno  //Inclusao
		aAreaDTQ := DTQ->(GetArea())
		If FindFunction('GFEX300') 	.And. IsInCallStack("TMSA310Grv")   //Temporario somente para o Fechamento da Viagem
			lRet:= TMSFUNLVGE(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,3,@lAltDocto)

			//-- Tem documentos que ja existiam no GFE, entao chama para alteração incluindo os trechos
			If lRet .And. lAltDocto
				lRet:= TMSFUNGVGE(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,3,,.T.)  //.T. Executou GFEX300 e tem alteração de Docto
			EndIf

		Else
			lRet:= TMSFUNGVGE(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,3,lRotAut)
		EndIf
		RestArea(aAreaDTQ)


	Else  //--- tratar Estorno
		aAreaDTQ := DTQ->(GetArea())
		lRet:= Tms3GfeEst(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,cFilDoc,cDoc,cSerie,lVgeRdp )
		RestArea(aAreaDTQ)

	EndIf
EndIf
RestInter()
RestArea(aArea)
Return( lRet )

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tms3GfeEst()
@autor		: Katia
@descricao	: Estorno da Integração Viagem TMS x GFE
@param		: Filial de Origem, Viagem, Rotina Automatica, Estorno
@return	: Logico - lRet
@since		: Dez./2016
@using		: Genérico
@review	:

Argumentos	:
/*/
//-------------------------------------------------------------------------------------------------
Function Tms3GfeEst(cFilOri,cViagem,cFilDoc,cDoc,cSerie,lVgeRdp)

Local lRet     := .T.
Local aArea    := GetArea()
Local cCDTPDC  := ""
Local cEmisDc  := ""
Local cAliasDOC:= ""
Local cTPDCTMS := SuperGetMV("MV_TPDCTMS",,"")
Local lNumProp := Iif(FindFunction("GFEEMITMP"),GFEEMITMP(),.F.)      //Parametro Numeracao
Local cNumRom  := ""
Local oModelGWN:= Nil
Local cQuery1  := ""
Local lTMS3GFE := Iif(FindFunction('TmsIntGFE'),TmsIntGFE('02'),.F.)
Local cAliasQry:= ""
Local lTmsRdpU  := SuperGetMV( 'MV_TMSRDPU',.F., 'N' ) <> 'N'  //F-Fechamento, S=Saida, C=Chegada, N=Não Utiliza o Romaneio unico por Lote de Redespacho
Local lTMSA340  := IsInCallStack("TMSA340Grv") .Or. IsInCallStack("TMSA340Mnt")
Local cColGFE   := SuperGetMV( "MV_COLGFE" ,.F., "0" )  //0-Padrão, 1-Encerramento; 2-Nao Integra Coleta
Local lContinua := .T.
Local lTabDM8   := AliasIndic("DM8")

Default cFilOri := ""
Default cViagem := ""
Default cFilDoc := ""
Default cDoc    := ""
Default cSerie  := ""
Default lVgeRdp := .F.

//Integração Protheus com SIGAGFE
If lTMS3GFE .Or. (lTmsRdpU .And. !Empty(cViagem))

	cAliasQry := GetNextAlias()
	cQuery := " SELECT DT6_FILDOC, DT6_DOC, DT6_SERIE, DT6_FILDCO, DT6_DOCDCO, DT6_SERDCO, DUD.DUD_CHVEXT, DUD.R_E_C_N_O_ DUDRECNO, "
	cQuery += " DUD.DUD_NUMRED, DUD.DUD_FILORI, DUD.DUD_STATUS  "
	cQuery += " FROM " + RetSqlName('DUD') + " DUD "

	cQuery += " JOIN " + RetSqlName('DT6') + " DT6 "
	cQuery += " ON DT6_FILIAL ='" + xFilial('DT6') + "' "
	cQuery += "   AND	DT6_FILDOC = DUD_FILDOC "
	cQuery += "   AND	DT6_DOC = DUD_DOC "
	cQuery += "   AND	DT6_SERIE = DUD_SERIE "
	cQuery += "   AND DT6.D_E_L_E_T_ = ' ' "

	cQuery += " WHERE DUD_FILIAL ='" + xFilial('DUD') + "' "
	cQuery += "   AND	DUD_FILORI ='" + cFilOri + "' "
	cQuery += "   AND	DUD_VIAGEM ='" + cViagem + "' "
	If !Empty(cFilDoc) .And. !Empty(cDoc) .And. !Empty(cSerie)
		cQuery += "   AND	DUD_FILDOC = '" + cFilDoc + "' "
		cQuery += "   AND	DUD_DOC  = '" + cDoc + "' "
		cQuery += "   AND	DUD_SERIE = '" + cSerie + "' "
	EndIf
	If !lTMSA340 .And. cColGFE <> "1"  
		cQuery += "   AND DUD_STATUS <> '" + StrZero( 9, Len( DUD->DUD_STATUS ) ) + "'"   //Cancelado
	EndIf	
	cQuery += "   AND DUD_CHVEXT <> ''"
	cQuery += "   AND DUD.D_E_L_E_T_ = ' ' "
	cQuery += "   ORDER BY DUD.DUD_FILORI, DUD.DUD_VIAGEM, DUD.DUD_CHVEXT "

	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	If (cAliasQry)->(!Eof())
		While (cAliasQry)->(!Eof())	
			If lTMSA340 
				//MV_COLGFE == 1, As Solicitações de coletas serão integradas no Encerramento da Viagem
				lContinua:= (cAliasQry)->DT6_SERIE == 'COL' .And. cColGFE == "1" 
				If lContinua 
					If (cAliasQry)->DUD_STATUS == StrZero( 9, Len( DUD->DUD_STATUS ) ) 
						If !ExistFunc('TMSUltOcor') .Or. TMSUltOcor(cFilOri,cViagem,(cAliasQry)->DT6_FILDOC,(cAliasQry)->DT6_DOC,(cAliasQry)->DT6_SERIE,'04') == 0				
							lContinua:= .F.
						EndIf	
					EndIf	
				EndIf
			Else
				lContinua:= .T.
				If (cAliasQry)->DT6_SERIE == 'COL' .And. (cColGFE $ "1|2")
					lContinua:= .F.  
				EndIf
			EndIf

			If lContinua
				DUD->(MsGoto( (cAliasQry)->DUDRECNO ))

				cNumRom:= TmsRomGWN(DUD->DUD_CHVEXT,'2')

				cAliasDOC:= GetNextAlias()

				If (cAliasQry)->DT6_SERIE == 'COL'    //--- Coleta
					DT5->(DbSetOrder( 4 ))
					If DT5->(MsSeek(xFilial('DT5')+(cAliasQry)->DT6_FILDOC+(cAliasQry)->DT6_DOC+(cAliasQry)->DT6_SERIE))

						If DT5->(ColumnPos('DT5_CLIREM')) > 0
							cCliRem:= DT5->DT5_CLIREM
							cLojRem:= DT5->DT5_LOJREM
						EndIf

						If Empty(cCliRem)
							DUE->(DbSetOrder(1))
							If DUE->(dbSeek(xFilial('DUE')+DT5->DT5_CODSOL))
								cCliRem:= DUE->DUE_CODCLI
								cLojRem:= DUE->DUE_LOJCLI
							EndIf
						EndIf

						If Empty(cCliRem)
							cCliRem:= DT5->DT5_FILORI
						EndIf

						If lNumProp
							If FindFunction( "GFEM011COD")
								cEmisDc:= GFEM011COD(cCliRem,cLojRem,1,,)
							EndIf
						Else
							cEmisDc:= Posicione("SA1",1,xFilial("SA1")+cCliRem+cLojRem,"A1_CGC")
						EndIf

						cCDTPDC:= 'COL' //- Para coleta será fixo.

						lRet:= TmsExcGFE(cFilOri,cViagem,cCDTPDC,cEmisDc,'COL',DT5->DT5_NUMSOL,(cAliasQry)->DT6_FILDOC,(cAliasQry)->DT6_DOC,(cAliasQry)->DT6_SERIE)
						If lRet
							RecLock('DUD', .F.)
							DUD->DUD_CHVEXT := ""
							MsUnLock()

							If lTabDM8 .And. FindFunction("TMSFUNGDM8") 
								TMSFUNGDM8(DUD->DUD_FILDOC,DUD->DUD_DOC,DUD->DUD_SERIE,DUD->DUD_FILORI,DUD->DUD_VIAGEM,Space(TamSx3("DM8_CHVEXT")[1]))
							EndIf
						Else
							Exit
						EndIf

					EndIf
				Else
					cQuery1 := " SELECT DTC_FILIAL, DTC_FILDOC, DTC_DOC, DTC_SERIE, DTC_NUMNFC, DTC_SERNFC, DTC_CLIREM, DTC_LOJREM "
					cQuery1 += "       FROM " + RetSqlName("DTC") + " DTC "
					cQuery1 += " WHERE DTC.DTC_FILIAL = '" + xFilial('DTC') + "' "
					cQuery1 += "  AND DTC.DTC_FILDOC   = '" + (cAliasQry)->DT6_FILDOC + "' "
					cQuery1 += "  AND DTC.DTC_DOC      = '" + (cAliasQry)->DT6_DOC    + "' "
					cQuery1 += "  AND DTC.DTC_SERIE    = '" + (cAliasQry)->DT6_SERIE  + "' "
					cQuery1 += "  AND DTC.D_E_L_E_T_   = ' ' "
					cQuery1 += " UNION "
					cQuery1 += " SELECT DY4_FILIAL AS DTC_FILIAL, DY4_FILDOC AS DTC_FILDOC, DY4_DOC AS DTC_DOC, DY4_SERIE AS DTC_SERIE, DY4_NUMNFC AS DTC_NUMNFC, "
					cQuery1 += " DY4_SERNFC AS DTC_SERNFC, DY4_CLIREM AS DTC_CLIREM, DY4_LOJREM AS DTC_LOJREM "
					cQuery1 += "       FROM " + RetSqlName("DY4") + " DY4 "
					cQuery1 += " WHERE DY4.DY4_FILIAL = '" + xFilial('DY4') + "' "
					cQuery1 += "  AND DY4.DY4_FILDOC   = '" + (cAliasQry)->DT6_FILDOC + "' "
					cQuery1 += "  AND DY4.DY4_DOC      = '" + (cAliasQry)->DT6_DOC + "' "
					cQuery1 += "  AND DY4.DY4_SERIE    = '" + (cAliasQry)->DT6_SERIE + "' "
					cQuery1 += "  AND DY4.D_E_L_E_T_   = ' ' "

					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery1),cAliasDOC)
					While (cAliasDOC)->(!Eof())

						cCDTPDC := Padr(cTPDCTMS,Len(GW1->GW1_CDTPDC))

						If lNumProp
							If FindFunction( "GFEM011COD")
								cEmisDc:= GFEM011COD((cAliasDOC)->DTC_CLIREM,(cAliasDOC)->DTC_LOJREM,1,,)
							EndIf
						Else
							cEmisDc:= Posicione("SA1",1,xFilial("SA1")+(cAliasDOC)->DTC_CLIREM+(cAliasDOC)->DTC_LOJREM,"A1_CGC")
						EndIf

						//---- exclui o GFE
						lRet:= TmsExcGFE(cFilOri,cViagem,cCDTPDC,cEmisDc,(cAliasDOC)->DTC_SERNFC,(cAliasDOC)->DTC_NUMNFC,(cAliasDOC)->DTC_FILDOC,(cAliasDOC)->DTC_DOC,(cAliasDOC)->DTC_SERIE,DUD->DUD_FILORI,DUD->DUD_NUMRED )

						If lRet
							RecLock('DUD', .F.)
							DUD->DUD_CHVEXT := ""
							MsUnLock()

							//---- Viagem de Redespacho com parametro MV_TMSRDPU atualiza a chave externa
							If !Empty(DUD->DUD_NUMRED)
								DFV->(DbSetOrder(2)) //DFV_FILIAL+DFV_FILDOC+DFV_DOC+DFV_SERIE+DFV_STATUS
								If DFV->(dBSeek(xFilial('DFV')+ (cAliasDOC)->DTC_FILDOC + (cAliasDOC)->DTC_DOC +(cAliasDOC)->DTC_SERIE ))
									Reclock("DFV",.F.)
									DFV->DFV_CHVEXT := ""
									DFV->(MsUnlock())
								EndIf
							EndIf

							If lTabDM8 .And. FindFunction("TMSFUNGDM8")
								TMSFUNGDM8(DUD->DUD_FILDOC,DUD->DUD_DOC,DUD->DUD_SERIE,DUD->DUD_FILORI,DUD->DUD_VIAGEM,Space(TamSx3("DM8_CHVEXT")[1]))
								//-- DJN somente Entrega
								TMSFUNGDJN(DUD->DUD_FILDOC,DUD->DUD_DOC,DUD->DUD_SERIE,DUD->DUD_FILORI,DUD->DUD_VIAGEM,Space(TamSx3("DM8_CHVEXT")[1]))
							EndIf

						Else
							Exit
						EndIf

						(cAliasDOC)->(DbSkip())
					EndDo
					(cAliasDOC)->(DbCloseArea())
				EndIf

				If !lRet
					Exit
				EndIf
			EndIf

			(cAliasQry)->(dbSkip())
		EndDo
	EndIf

	(cAliasQry)->( dbCloseArea() )


EndIf

If oModelGWN <> Nil
	oModelGWN:Destroy()
EndIf

RestArea(aArea)
Return( lRet )

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsRedDJN()
@autor		: Katia
@descricao	: Verifica se existe Redespacho Adicional para a viagem - DJN
@param		: Filial de Origem, Viagem, cFilDoc, cDoc, cSerie
@return	: Logico - lRet
@since		: Jan./2017
@using		: Genérico
@review	:

Argumentos	:
/*/
//-------------------------------------------------------------------------------------------------
Function TmsRedDJN(cFilOri,cViagem,cFilDoc,cDoc,cSerie,cCodFor,cLojFor)
Local lRet:= .F.
Local cAliasNew:= ""
Local cQuery   := ""
Local aArea    := GetArea()

Default cFilOri:= ""
Default cViagem:= ""
Default cFilDoc:= ""
Default cDoc   := ""
Default cSerie := ""
Default cCodFor:= ""
Default cLojFor:= ""

	cAliasNew := GetNextAlias()
	cQuery := " SELECT COUNT(*) NREGDJN  "
	cQuery += "   FROM " + RetSqlName("DJN") + " DJN "
	cQuery += "  WHERE DJN_FILIAL  = '"+ xFilial("DJN")+"' "
	cQuery += "    AND DJN_FILORI  = '"+cFilOri+"' "
	cQuery += "    AND DJN_VIAGEM  = '"+cViagem+"' "
	If !Empty(cFilDoc) .And. !Empty(cDoc) .And. !Empty(cSerie)
		cQuery += "    AND DJN_FILDOC  = '"+cFilDoc+"' "
		cQuery += "    AND DJN_DOC  = '"+cDoc+"' "
		cQuery += "    AND DJN_SERIE  = '"+cSerie+"' "
	EndIf
	If !Empty(cCodFor) .And. !Empty(cLojFor)
		cQuery += "    AND DJN_CODFOR  = '"+cCodFor+"' "
		cQuery += "    AND DJN_LOJFOR  = '"+cLojFor+"' "
	EndIf
	cQuery += "    AND DJN.D_E_L_E_T_ = ' ' "
	cQuery    := ChangeQuery(cQuery)
	cAliasNew := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.T.,.T.)
	If (cAliasNew)->(!Eof()) .And. (cAliasNew)->NREGDJN > 0
		lRet:= .T.
	EndIf
	(cAliasNew)->( dbCloseArea() )

RestArea(aArea)
Return lRet


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsGFEDUD()
@autor		: Katia
@descricao	: Verifica o numero do Romaneio do Documento da viagem
@param		: Filial de Origem, Viagem, cFilDoc, cDoc, cSerie
@return	: cNumRom
@since		: Jan./2017
@using		: Genérico
@review	:

Argumentos	:
/*/
//-------------------------------------------------------------------------------------------------
Function TmsGFEDUD(cFilOri,cViagem,cFilDoc,cDoc,cSerie,lChekRom,cChvExt,cCdTpOp)
Local cRomGWN  := ""
Local cAliasNew:= ""
Local cQuery   := ""
Local aArea    := GetArea()
Local lRet     := .T.
Local aErrGFE  := {}
Local lContinua:= .F.
Local cChaveAnt:= ""

Default cFilOri := ""
Default cViagem := ""
Default cFilDoc := ""
Default cDoc    := ""
Default cSerie  := ""
Default lChekRom:= .F.   //Procura o Romaneio disponivel na viagem para inclusao de novos documentos
Default cChvExt := ""
Default cCdTpOp := ""

	cAliasNew := GetNextAlias()
	cQuery := " SELECT DUD.DUD_CHVEXT, DUD.DUD_CDTPOP, DJN.DJN_CDTPOP "
	cQuery += "   FROM " + RetSqlName("DUD") + " DUD "
	cQuery += "   JOIN " + RetSqlName("DJN") + " DJN "
	cQuery += "  ON DJN_FILIAL  = '"+ xFilial("DJN")+"' "
	cQuery += "    AND DJN_FILORI  = '"+cFilOri+"' "
	cQuery += "    AND DJN_VIAGEM  = '"+cViagem+"' "
	If !Empty(cCdTpOp)
		cQuery += "    AND DJN_CDTPOP  = '"+cCdTpOp+"' "
	EndIf
	cQuery += "    AND DJN.D_E_L_E_T_ = ' ' "
	cQuery += "  WHERE DUD_FILIAL  = '"+ xFilial("DUD")+"' "
	cQuery += "    AND DUD_FILORI  = '"+cFilOri+"' "
	cQuery += "    AND DUD_VIAGEM  = '"+cViagem+"' "
	If !Empty(cFilDoc) .And. !Empty(cDoc) .And. !Empty(cSerie)
		cQuery += "    AND DUD_FILDOC  = '"+cFilDoc+"' "
		cQuery += "    AND DUD_DOC  = '"+cDoc+"' "
		cQuery += "    AND DUD_SERIE  = '"+cSerie+"' "
	EndIf
	cQuery += "    AND DUD.DUD_CHVEXT <> ' ' "
	cQuery += "    AND DUD.D_E_L_E_T_ = ' ' "
	cQuery += "    GROUP BY DUD.DUD_CHVEXT, DUD.DUD_CDTPOP, DJN.DJN_CDTPOP "
	cQuery += "    ORDER BY DUD.DUD_CHVEXT DESC "
	cQuery    := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.T.,.T.)
	While !(cAliasNew)->(EoF())
		If (cAliasNew)->DUD_CHVEXT <> cChaveAnt
			lContinua:= .T.
		EndIf
		cChaveAnt:= (cAliasNew)->DUD_CHVEXT

		If lContinua .And. !Empty(cCdTpOp)
			lContinua:= (cAliasNew)->DUD_CDTPOP == cCdTpOp .Or. (cAliasNew)->DJN_CDTPOP == cCdTpOp
		EndIf

		If lContinua
			lRet   := .F.
			cChvExt:= ""

			If lChekRom
				cRomGWN:= TmsRomGWN((cAliasNew)->DUD_CHVEXT,'1')   //Filial + Romaneio
				lRet:= TmsChkGWN(cFilDoc,cDoc,cSerie, cRomGWN,.T.,@aErrGFE)
				If lRet
					cChvExt:= (cAliasNew)->DUD_CHVEXT
					Exit
				EndIf
			Else
				cChvExt:= (cAliasNew)->DUD_CHVEXT
				lRet   := .T.
			EndIf
		EndIf

		(cAliasNew)->( dbSkip() )
	EndDo
	(cAliasNew)->( dbCloseArea() )

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsChkGWN()
@autor		: Katia
@descricao	: Verifica se poderá incluir documento de carga no Romaneio
@param		: cFilDoc, cDoc, cSerie,cNumRom,lAuto,aErrGFE
@return	: Logico - lRet
@since		: Jan./2017
@using		: Genérico
@review	:

Argumentos	:
/*/
//-------------------------------------------------------------------------------------------------
Function TmsChkGWN(cFilDoc,cDoc,cSerie,cNumRom,lAuto,aErrGFE)
Local lRet		:= .T.
Local aArea   := GetArea()

Default cFilDoc:= ""
Default cDoc   := ""
Default cSerie := ""
Default cNumRom:= ""     //Filial + Nro Romaneio
Default lAuto  := .F.

GWN->( dbSetOrder(1) )
If GWN->( dbSeek( cNumRom ) )

	If !lRet .And. lAuto
		If Len(aErrGFE) == 0
			Aadd(aErrGFE,{STR0045})  //"Inconsistência com o Frete Embarcador (SIGAGFE): "
		EndIf
		Aadd(aErrGFE,{STR0048 + cFilDoc + " " + cDoc + " " + cSerie  + " : " + Iif(GWN->GWN_SIT $ "3",STR0046,STR0047) + " : " + cNumRom })   //"Não foi possivel reabrir o Romaneio."
	EndIf
EndIf

RestArea(aArea)
Return lRet


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsExcGFE()
@autor		: Katia
@descricao	: Exclui documento de carga e Romaneio de Carga do GFE
@param		:
@return	: Logico - lRet
@since		: Jan./2017
@using		: Genérico
@review	:

Argumentos	:
/*/
//-------------------------------------------------------------------------------------------------
Function TmsExcGFE(cFilOri,cViagem,cCDTPDC,cEmisDc,cSerDC,cNumDC,cFilDoc,cDoc,cSerie,cFilRed,cNumRed )

Local lRet			:= .T.
Local aArea		:= GetArea()
Local oModelGW1	:= FWLoadModel("GFEA044")
Local oModelGWU	:= oModelGW1:GetModel('GFEA044_GWU')
Local nOpcao		:= 0
Local cChvAtu		:= ""
Local nContTr		:= 0
Local lViagem		:= .F.
Local lExcTrecho  := .F.   //Indica somente a exclusao do Trecho
Local aCalcRom    := {}
Local aErrGFE     := {}
Local lTmsRdpU    := SuperGetMV( 'MV_TMSRDPU',.F., 'N' ) <> 'N'  //F-Fechamento, S=Saida, C=Chegada, N=Não Utiliza o Romaneio unico por Lote de Redespacho
Local lCalcAut    := .T.
Local cSeekGWE    := ""
Local lPagar	  := .F. 

Default cFilOri	:= ""
Default cViagem	:= ""
Default cCDTPDC	:= ""
Default cEmisDC	:= ""
Default cSerDC	:= ""
Default cNumDC	:= ""
Default cFilRed	:= ""
Default cNumRed	:= ""

If !Empty(cViagem)
	cFilGW1:= cFilOri
ElseIf !Empty(cNumRed) .And. !Empty(cFilRed)
	cFilGW1:= cFilRed
Else
	cFilGW1:= xFilial('GW1')
EndIf

If !Empty(cViagem)
	DTQ->(DbSetOrder(2))//DTQ_FILIAL+DTQ_FILORI+DTQ_VIAGEM
	If DTQ->(MsSeek(xFilial("DTQ")+cFilOri+cViagem))
		lViagem:= DTQ->DTQ_TIPVIA <> StrZero(5,Len(DTQ->DTQ_TIPVIA)) //Redespacho
	EndIf
EndIf

GW1->( dbSetOrder(1) )
If GW1->( dbSeek(cFilGW1+PadR(cCDTPDC,Len(GW1->GW1_CDTPDC))+Padr(cEmisDc,Len(GW1->GW1_EMISDC))+PadR(cSerDC,Len(GW1->GW1_SERDC))+PadR(cNumDC,Len(GW1->GW1_NRDC)) ))                  
	lRet    := .T.
	cNumRom := GW1->GW1_NRROM
	cSeekGW1:= GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC+cFilDoc+cDoc+cSerie
    cSeekGWE:= GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC

	//--- Verifica se é exclusao de um Trecho ou exclusão do Romaneio
	//--- se é somente exclusao do trecho, nao sera necessario reabrir o romaneio , pois será alterado o trecho como pagar igual a 'Nao' e
	//--- deverá ser executado o calculo

	If !Empty(cViagem)
		cChvAtu:= 'VGMTMS' + ";" + PadR(cFilOri,Len(DTQ->DTQ_FILORI)) + ';' + cViagem
		Pergunte("TMB144",.F.)
		If GetRpoRelease() >= "12.1.023"
			If Type("mv_par08") == "N" .And. mv_par08 == 2  //Executa o Calculo do Romaneio Automatico 1-Sim, 2-Não
				lCalcAut:= .F.
			EndIf
		Else
			If Type("mv_par09") == "N" .And. mv_par09 == 2  //Executa o Calculo do Romaneio Automatico 1-Sim, 2-Não
				lCalcAut:= .F.
			EndIf
		EndIf
	Else
		cChvAtu:= 'RDPTMS' + ";" + PadR(cFilRed,Len(DFV->DFV_FILORI)) + ';' + cNumRed
		Pergunte("TMSAR05",.F.)
		If Type("mv_par01") == "N" .And. mv_par01 == 2  //Executa o Calculo do Romaneio Automatico 1-Sim, 2-Não
			lCalcAut:= .F.
		EndIf
	EndIf

	GWE->(dbSetOrder(1))
	If GWE->( dbSeek(xFilial("GWE") + cSeekGWE ) )
		nOpcao:= 5 	//--- Exclusao
		While !GWE->(Eof()) .And. (GWE->(GWE_FILIAL+GWE_CDTPDC+GWE_EMISDC+GWE_SERDC+GWE_NRDC)) == xFilial("GWE")+cSeekGWE
			If !Empty(GWE->GWE_CHVEXT)
				If GWE->GWE_CHVEXT <> cChvAtu
					lExcTrecho:= .T.
					nOpcao    := 4   //--- Alteração
					Exit
				EndIf	
			Else
				//--- Se Vazio, registro antigo gerado antes da inclusao deste campo
				cChvAtu:= ""
			EndIf
			GWE->(DbSkip())
		EndDo
	Else
		lRet:= .F.
	EndIf

	If lRet
		GWN->( dbSetOrder(1) )
		If GWN->( dbSeek(xFilial("GWN") + GW1->GW1_NRROM) ) .And. GWN->GWN_SIT $ "3|4"  //Liberado e ou Encerrado
			lRet:= .T.
			If (!lTmsRdpU .And. Empty(cViagem)) .Or. nOpcao == 5  //Redespacho gerando mais de um romaneio, continua processo antigo
				If GWN->GWN_SIT $ "3" .And. !lExcTrecho
					lRet   := GFEA050REA( FWGetRunSchedule() )   //Reabre o Romaneio
				ElseIf GWN->GWN_SIT $ "4"
					Help( ,, 'HELP',, STR0047, 1, 0,) //"O Romaneio já está encerrado."
					lRet   := .F.
				EndIf
			EndIf
		EndIf
	EndIf

   	If lRet

		//Se integração da 'nova' viagem e ou com o Lote de Redespacho Unico
		If !Empty(cChvAtu)
			If lRet
				oModelGW1:SetOperation( nOpcao )
				oModelGW1:Activate()

				If nOpcao == 4 //Alteracao, ao inves de excluir, deve alterar o campo pagar para 'nao' (processo do SIGAGFE)
					//--- Guarda o Romaneio para chamada do calculo do frete
					If lCalcAut
						If aScan(aCalcRom, xFilial("GWN")+cNumRom ) == 0
							aAdd(aCalcRom, xFilial("GWN")+cNumRom)
						EndIf
					EndIf

					If GWU->(ColumnPos('GWU_CHVEXT')) > 0

						For nContTr := 1 to oModelGWU:Length()
							oModelGWU:GoLine( nContTr )
							If oModelGWU:GetValue("GWU_CHVEXT") == PadR(cChvAtu,Len(GWU->GWU_CHVEXT))  .Or. Empty(oModelGWU:GetValue("GWU_CHVEXT"))    //Considerar conteudo vazio pois o requisito MV_TMSRDPU foi implementado apos a viagem e neste caso a Chave estava vazia
								If oModelGWU:GetValue("GWU_PAGAR") == "1"  //Pagar
									oModelGWU:SetValue( 'GWU_PAGAR' , "2" )   //Nao
								EndIf
							EndIf
						Next nContTr

					EndIf
				EndIf
			EndIf
		Else   //---- Processo antigo antes da integração viagem normal e redespacho unico
			GWU->( dbSetOrder(1) )
			GWU->( dbSeek(xFilial("GWU") + PadR(cCDTPDC,Len(GWU->GWU_CDTPDC))+ Padr(cEmisDc,Len(GWU->GWU_EMISDC)) + PADR(cSerDC,LEN(GWU->GWU_SERDC))+ PADR(cNumDC,LEN(GWU->GWU_NRDC))+ 'z', .T. ) )
			GWU->(dbSkip( -1 ))
			If GWU->(GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC) == xFilial("GWU") + PadR(cCDTPDC,Len(GWU->GWU_CDTPDC))+ Padr(cEmisDc,Len(GWU->GWU_EMISDC))  + PADR(cSerDC,LEN(GWU->GWU_SERDC))+ PADR(cNumDC,LEN(GWU->GWU_NRDC))
				nI    := Val(AllTrim(GWU->GWU_SEQ))
				lPagar:= GWU->GWU_PAGAR == '1'
			EndIf
			nOpcao:= 5   //Exclusao

			If nI > 2
				nOpcao:= 4 //Alteracao... Exclui somente o trecho.
			ElseIf nI == 2
			 	If !lPagar //Ultimo Trecho Nao Pagar
					nOpcao:= 5
				Else
					nOpcao:= 4
				EndIf
			EndIf


			oModelGW1:SetOperation( nOpcao )
			oModelGW1:Activate()

			If nOpcao == 4     //Volta para CIF, quando restar apenas 1 trecho
				oModelGW1:SetValue( 'GFEA044_GW1', 'GW1_TPFRET', "1" )   //CIF
			EndIf

			If nI > 2      //Quando ha mais de um trecho, devera excluir somente o ultimo trecho.
				oModelGWU:GoLine(nI)

				If !oModelGWU:IsDeleted()
					oModelGWU:DeleteLine()
				EndIf

				If !lPagar
				 //Deleta a anterior tambem
					nI:= nI - 1
					oModelGWU:GoLine(nI-1)
					If !oModelGWU:IsDeleted()
						oModelGWU:DeleteLine()
					EndIf
				 EndIf
			EndIf
		EndIf

		If lRet

			If lRet .And. nOpcao == 5
				If AliasIndic("GWE")
					GWE->(dbSetOrder(1))
					If GWE->(DbSeek(xFilial("GWE")+cSeekGW1 ))
						RecLock( 'GWE', .F. )
						DbDelete()
						MsUnLock()
					EndIf
				EndIf
			EndIf

			If oModelGW1:VldData()
				oModelGW1:CommitData()
			Else
				Help('',1,'TMSXFUND06',,oModelGW1:GetErrorMessage()[6],4,1)	 //"Inconsistência com o Frete Embarcador (SIGAGFE): "
				lRet := .F.
			EndIf
		
		EndIf

		oModelGW1:Deactivate()
	EndIf

	//-- Verifica se existe algum documento de carga no Romaneio. Se nao existir, o Romaneio sera excluido.
	If lRet
		GW1->( dbSetOrder(9) )
		If !GW1->( dbSeek( cFilGW1 + cNumRom ))
			GWN->( dbSetOrder(1) )
			If GWN->( dbSeek(xFilial("GWN") + cNumRom) )
				oModelGWN:= FWLoadModel("GFEA050")
				oModelGWN:SetOperation( 5 )
				oModelGWN:Activate()

				If oModelGWN:VldData()
					oModelGWN:CommitData()
				Else
					Help('',1,'TMSXFUND06',,oModelGWN:GetErrorMessage()[6] + ' - ' + GWN->GWN_FILIAL + '/' + GWN->GWN_NRROM,4,1)	 //"Inconsistência com o Frete Embarcador (SIGAGFE): "
					lRet := .F.
				EndIf
				oModelGWN:Deactivate()
				oModelGWN:Destroy()

	           //---- Limpa a chave externa da viagem
				If lRet .And. !Empty(cViagem)
					DTQ->( dbSetOrder(2) )
					If DTQ->( dbSeek( xFilial("DTQ")+cFilOri+cViagem ) ) .And. DTQ->DTQ_CHVEXT == PadR( GWN->GWN_FILIAL + ';' + GWN->GWN_NRROM , TamSX3("DTQ_CHVEXT")[1])
						RecLock('DTQ', .F.)
						DTQ->DTQ_CHVEXT := ""
						MsUnLock()
					EndIf
				EndIf

			EndIf
		Else
			//---- Chamada do Calculo do Romaneio que houve alteração com a inclusao do novo trecho
			If Len(aCalcRom) > 0 .And. FindFunction('TMSCALROM')
				MsgRun( STR0057 , STR0058 , {|| CursorWait(), lRet:= TMSCALROM(aCalcRom, @aErrGFE), CursorArrow()}) //Aguarde... Recalculando do Romaneio
				If Len(aErrGFE) > 0
					TmsMsgErr(aErrGFE)
					aSize(aErrGFE,0)
					aErrGFE:= {}
					lRet:= .T.   //Temporario apos definicao do calculo do GFE
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

aSize(aCalcRom, 0)
RestArea(aArea)
Return lRet


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsIntGFE()
@autor		: Katia
@descricao	: Verifica se a Integração TMS x GFE está ativa
@param		: cRotina (R-Redespacho ou V-Viagem)
@return	: Logico - lRet
@since		: Jan./2017
@using		: Genérico
@review	:

Argumentos	:
/*/
//-------------------------------------------------------------------------------------------------

Function TmsIntGFE(cRotina)

Local lIntGFE  := SuperGetMv("MV_INTGFE",.F.,.F.)
Local cIntGFE2 := SuperGetMv("MV_INTGFE2",.F.,"2")
Local lTMSGFE  := SuperGetMv("MV_TMSGFE",,.F.)
Local cTMS3GFE := SuperGetMV("MV_TMS3GFE",,"N")  //F-Fechamento Vge, S=Saida Vge, C=Chegada Vge,N=Nao Integra
Local lRet		 := .F.
Local aArea    := GetArea()

Default cRotina:= ''

If cRotina == '01' //Redespacho
	If lTMSGFE .And. lIntGFE  .And. cIntGFE2 $ "1"
		lRet:= .T.
	EndIf
ElseIf cRotina == '02' //Viagem
	If lIntGFE .And. cIntGFE2 $ "1" .And. !Empty(cTMS3GFE) .And. cTMS3GFE <> 'N'
		lRet:= .T.
	EndIf
Else
	If lTMSGFE .Or. cTMS3GFE <> 'N'
		lRet:= .T.
	EndIf
EndIf

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsDocGFE()
@autor		: Katia
@descricao	: Verifica se o Documento ja foi integrado ao SIGAGFE
@param		: cFilOri,cFilDoc,cDoc,cSerie
@return	: Caracter - cChvExt (Filial;Nro Romaneio)
@since		: Jan./2017
@using		: Genérico
@review	:

Argumentos	:
/*/
//-------------------------------------------------------------------------------------------------

Function TmsDocGFE(cFilOri,cFilDoc,cDoc,cSerie)
Local cRet     := ""
Local aArea    := GetArea()
Local aAreaDT6 := DT6->(GetArea())

Default cFilOri:= ""
Default cFilDoc:= ""
Default cDoc   := ""
Default cSerie := ""

//-- cFilOri: Verificar se ja existe o Documento na Filial de origem do DUD.
DbSelectArea("DT6")
DbSetOrder(1) //-- DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SER
If dBSeek(xFilial("DT6") + cFilDoc + cDoc + cSerie)

	GWE->( dbSetOrder(2) )
	If GWE->( dbSeek( IIf(Empty(cFilOri),xFilial('GWE'),cFilOri) + cFilDoc + cDoc + cSerie ) )
		GW1->( dbSetOrder(1) )
		If GW1->( dbSeek( IIf(Empty(cFilOri),xFilial('GW1'),cFilOri) + GWE->GWE_CDTPDC + GWE->GWE_EMISDC + GWE->GWE_SERDC + GWE->GWE_NRDC ))
			cRet:= GW1->GW1_FILIAL + ';' + GW1->GW1_NRROM
		EndIf
	Else
		If !Empty(DT6->DT6_DOCDCO)
			DbSetOrder(1)
			If Dbseek(xFilial("DT6")+DT6->DT6_FILDCO+DT6->DT6_DOCDCO+DT6->DT6_SERDCO)
				If GWE->( dbSeek( IIf(Empty(cFilOri),xFilial('GWE'),cFilOri) + DT6->DT6_FILDOC + DT6->DT6_DOC + DT6->DT6_SERIE ) )
					GW1->( dbSetOrder(1) )
					If GW1->( dbSeek( IIf(Empty(cFilOri),xFilial('GW1'),cFilOri) + GWE->GWE_CDTPDC + GWE->GWE_EMISDC + GWE->GWE_SERDC + GWE->GWE_NRDC ))
						cRet:= GW1->GW1_FILIAL + ';' + GW1->GW1_NRROM
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

EndIf
RestArea(aArea)
RestArea(aAreaDT6)
Return cRet

//---------------------------------------------------
/*/{Protheus.doc} TMSViewGFE
Visualiza Documento de Carga GFE
@author	Katia
@version	1.0
@since		19/01/2017
@sample    Esta função tem por objetivo visualizar o
			Docto de Carga do GFE
/*/
//----------------------------------------------------
Function TMSViewGFE(cTab, nReg, nOpcx,cNumNfc,cSerNfc,cCliRem,cLojRem,cProduto,cFilOri,cLotNfc)
Local aAreaDTC	:= DTC->(GetArea())
Local aAreaDT5	:= DT5->(GetArea())
Local cTPDCTMS	:= SuperGetMV("MV_TPDCTMS",,"")
Local cCdTpDc		:= Padr(cTPDCTMS,Len(GW1->GW1_CDTPDC))
Local cEmisDc		:= ""
Local lNumProp   := Iif(FindFunction("GFEEMITMP"),GFEEMITMP(),.F.)      //Parametro Numeracao
Local lDT5Remet	:= DT5->(ColumnPos("DT5_CLIREM")) > 0
Local lRet			:= .T.

//--- Definicao dos campos devido a chamado pela função TMSDocXNf
Default cTab		:= ""
Default nReg		:= 0

Default cNumNfc	:= ""
Default cSerNfc	:= ""
Default cCliRem	:= ""
Default cLojRem	:= ""
Default cProduto	:= ""
Default cFilOri	:= ""
Default cLotNfc	:= ""

If (!Empty(cNumNfc) .Or. !Empty(DTC->(Recno())) ).And. Empty(DT5->(Recno()))
	cTab:= 'DTC'
EndIf

If cTab == 'DT5'
	cSerNfc:= 'COL'
	cCDTPDC:= 'COL'
	cNumNfc:= DT5->DT5_NUMSOL

	If lDT5Remet
		cCliRem:= DT5->DT5_CLIREM
		cLojRem:= DT5->DT5_LOJREM
	EndIf

	If Empty(cCliRem)
		DUE->(DbSetOrder(1))
		If DUE->(dbSeek(xFilial('DUE')+DT5->DT5_CODSOL))
			cCliRem:= DUE->DUE_CODCLI
			cLojRem:= DUE->DUE_LOJCLI
		EndIf
	EndIf

	If Empty(cCliRem)
		cCliRem:= DT5->DT5_FILORI
	EndIf

	If lNumProp
		If FindFunction( "GFEM011COD")
			cEmisDc:= GFEM011COD(cCliRem,cLojRem,1,,)
		EndIf	
	Else
		cEmisDc:= Posicione("SA1",1,xFilial("SA1")+cCliRem+cLojRem,"A1_CGC")
	EndIf

Else
	If !Empty(cNumNfc) .And. !Empty(cSerNfc)
		DTC->(DbSetOrder(2))
		If !DTC->( DbSeek(  xFilial('DTC')+ cNumNFC + cSerNFC + cCliRem + cLojRem + cProduto + cFilOri + cLotNfc))
			lRet:= .F.
		EndIf
	EndIf

	If lRet
		cSerNfc:= DTC->DTC_SERNFC
		cNumNfc:= DTC->DTC_NUMNFC

		If lNumProp
			If FindFunction( "GFEM011COD")
				cEmisDc:= GFEM011COD(DTC->DTC_CLIREM,DTC->DTC_LOJREM,1,,)
			EndIf
		Else
			cEmisDc:= Posicione("SA1",1,xFilial("SA1")+DTC->DTC_CLIREM+DTC->DTC_LOJREM,"A1_CGC")
		EndIf
	EndIf
EndIf

If lRet
	dbSelectArea("GW1")
	GW1->( dbSetOrder(1) )
	If GW1->( dbSeek( xFilial("GW1")+PadR(cCDTPDC,Len(GW1->GW1_CDTPDC))+cEmisDc+PadR(cSerNfc,Len(GW1->GW1_SERDC))+PadR(cNumNfc,Len(GW1->GW1_NRDC)) ))
		SaveInter()
		FwExecView(,'GFEC040',,,{||.T.})   //Visualizar
		RestInter()
	Else
		Help(" ",1,"TMSXFUNA45") //"Documento de Carga não localizado!
	EndIf
EndIf

RestArea(aAreaDTC)
RestArea(aAreaDT5)
Return

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsReTitle
@autor		: Eduardo Alberti
@descricao	: Retorna Descrição Do Campo Conforme Dicionário Mais Seu Nome Entre Parênteses
@since		: Jan./2017
@using		: Genérico TMS
@review	:
@param		: cCampo 	:= Nome Do Campo Conforme Dicionário SX3

Argumentos	:
/*/
//-------------------------------------------------------------------------------------------------
Function TmsReTitle( cCampo )

	Local cRet := ''

	If !Empty(cCampo)
		cRet := Space(1) + AllTrim(RetTitle( cCampo ))  + Space(1) +  '(' + Alltrim(cCampo) + ')'
	EndIf

Return( cRet )

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsDuaGfe()
@autor		: Eduardo Alberti
@descricao	: Verifica Integração TMS X GFE De Acordo Com Tabela Informada
@since		: Jan./2017
@using		: Genérico TMS
@review	:
@param		: cTabela   := Tabela Para Testar Integração
              cCampo 	:= Nome Do Campo Conforme Dicionário SX3

/*/
//-------------------------------------------------------------------------------------------------
Function TmsDuaGfe( cTabela, cChave )

	Local aArea      := { GetArea()	}
	Local nX         := 0
	Local lRet       := .f.
	Local cQuery     := ""
	Local nTotReg    := 0
	Local cAliasT    := GetNextAlias()
	Local bQuery     := {|| Iif(Select(cAliasT) > 0, (cAliasT)->(dbCloseArea()), Nil) , dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T.), dbSelectArea(cAliasT), (cAliasT)->(dbEval({|| nTotReg++ })), (cAliasT)->(dbGoTop())  }

	Default cTabela  := "DUA"
	Default cChave   := ""

	If cTabela == "DUA"

		cQuery += " SELECT      GWD.R_E_C_N_O_ "
		cQuery += " FROM        " + RetSqlName("GWD") + " GWD "
		cQuery += " WHERE       GWD.GWD_FILIAL  =  '" + FWxFilial("GWD") + "' "
		cQuery += " AND         GWD.GWD_CHVEXT  =  '" + PadR(cChave,TamSX3("GWD_CHVEXT")[1]) + "' "
		cQuery += " AND         GWD.D_E_L_E_T_  =  '  ' "

		cQuery := ChangeQuery(cQuery)

		//-- Executa Query
		Eval(bQuery)

		If nTotReg > 0
			lRet := .t.
		EndIf
	EndIf

	//-- Fecha Arquivos Temporários
	If Select(cAliasT) > 0
		(cAliasT)->(DbCloseArea())
	EndIf

	//-- Reposiciona Arquivos
	For nX := 1 To Len(aArea)
		RestArea(aArea[nX])
	Next nX

Return( lRet )


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMsAtuGXP()
@autor		: Katia
@descricao	: Atualiza no Documento de Carga (SIGAGFE) o Documento de Origem - GXP
@since		: Fev./2017
@using		: TMSA050
@review	:
@param		: aColsDTC	:= aCols da rotina TMSA050
              nOpcRot	:= Opcao da rotina
              lExcGXP 	:= lExclui todos os registros da GXP
/*/
//-------------------------------------------------------------------------------------------------

Function TMsAtuGXP(aHeadDTC,aColsDTC,aColsAntDC,nOpcRot,lExcGXP)

Local oModel		:= Nil
Local oMdGridGXP	:= Nil
Local nPosNUMNFC := Ascan(aHeadDTC, { |x| AllTrim(x[2]) == 'DTC_NUMNFC' })
Local nPosSERNFC := Ascan(aHeadDTC, { |x| AllTrim(x[2]) == 'DTC_SERNFC' })
Local nPosNFEID  := Ascan(aHeadDTC, { |x| AllTrim(x[2]) == 'DTC_NFEID' })
Local aArea      := GetArea()
Local cCliRem    := M->DTC_CLIREM
Local cLojRem    := M->DTC_LOJREM
Local cFilCfs    := M->DTC_FILCFS
Local cNumSol    := M->DTC_NUMSOL
Local cFilOri    := M->DTC_FILORI
Local lAtuGXP    := .F.
Local nCnt       := 0
Local lNumProp   := Iif(FindFunction("GFEEMITMP"),GFEEMITMP(),.F.)      //Parametro Numeracao

Default aHeadDTC  := {}
Default aColsDTC  := {}
Default aColsAntDC:= {}
Default nOpcRot   := 0
Default lExcGXP   := .F.

SaveInter()

//--- Posiciona no GFE
lRet:= TMSCarGW1(cFilCfs,cNumSol)
If lRet
	If lNumProp
		If FindFunction( "GFEM011COD")
			cEmisDc:= GFEM011COD(cCliRem,cLojRem,1,,)
		EndIf	
	Else
		cEmisDc:= Posicione("SA1",1,xFilial("SA1")+cCliRem+cLojRem,"A1_CGC")
	EndIf

	oModel:= FWLoadModel( 'GFEA044' )
	oModel:SetOperation( 4 )
	oModel:Activate()
	oMdGridGXP := oModel:GetModel( "GFEA044_GXP" )
EndIf

If lRet

	//--- Primeiro exclui os registros do aColsAnt
	If nOpcRot == 4 .Or. lExcGXP
		If !Empty(aColsAntDC)
			For nCnt:= 1 To Len(aColsAntDC)
				If oMdGridGXP:SeekLine( { {"GXP_FILORI", cFilOri }, {"GXP_EMIORI", cEmisDc }, {"GXP_SERORI", aColsAntDC[nCnt,nPosSERNFC] },;
					                      {"GXP_DOCORI", aColsAntDC[nCnt,nPosNUMNFC]  } } )  .And. !oMdGridGXP:IsDeleted()
					oMdGridGXP:DeleteLine()
					lAtuGXP:= .T.
				EndIf
			Next nCnt
		EndIf

		For nCnt:= 1 To Len(aColsDTC)
			If oMdGridGXP:SeekLine( { {"GXP_FILORI", cFilOri }, {"GXP_EMIORI", cEmisDc }, {"GXP_SERORI", aColsDTC[nCnt,nPosSERNFC] },;
				                      {"GXP_DOCORI", aColsDTC[nCnt,nPosNUMNFC]  } } )  .And. !oMdGridGXP:IsDeleted()
				oMdGridGXP:DeleteLine()
				lAtuGXP:= .T.
			EndIf
		Next nCnt
	EndIf

	//-- Atualiza os dados no GFE com base no aCols
	If !Empty(aColsDTC)
		For nCnt:= 1 To Len(aColsDTC)
			//-- Alteracao, deletando a linha OU Estorno do documento
			If ( !lExcGXP .And. !aColsDTC[nCnt,Len(aColsDTC[nCnt])] )  .Or. (lExcGXP .And. GdFieldGet("DTC_ESTORN",nCnt)<> '1' ) //Deletado
				lRet:= TMSFUNGGXP(oMdGridGXP,aColsDTC[nCnt,nPosNFEID ],cFilOri,cEmisDc,aColsDTC[nCnt,nPosSERNFC],aColsDTC[nCnt,nPosNUMNFC]  )
				If lRet
					lAtuGXP:= .T.
				EndIf
			EndIf
		Next nCnt
	EndIf

EndIf

If lAtuGXP
	lRet := oModel:VldData()
	If !lRet
		Help("", 1, "TMSXFUND06",," " + oModel:GetErrorMessage()[6]+" "+oModel:GetErrorMessage()[4] ,4,1)  //Inconsistência com o Frete Embarcador (SIGAGFE)
		lRet:= .F.
	Else
		lRet := oModel:CommitData()
	EndIf
EndIf

If oModel <> Nil
	oModel:DeActivate()
	oModel:Destroy()
EndIf

RestInter()
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSCarGW1()
@autor		: Katia
@descricao	: Carrega o Documento de Carga da Solicitação de Coleta vinculada a Nota do Cliente
            : Fev./2017
@using		: TMSA050
@review	:
@param		: cFilCfs  := Filial da Solicitação de Coleta (DTC_FILCFS)
              cNumSol 	:= Solicitação de Coleta
/*/
//-------------------------------------------------------------------------------------------------
Function TMSCarGW1(cFilCfs,cNumSol)
Local cSeek    := ""
Local cFilDT5  := xFilial('DT5')
Local lRet     := .F.
Local aArea    := GetArea()

Default cFilCfs:= ""
Default cNumSol:= ""

If !Empty(cNumSol)
	DT5->(dbSetOrder(1))
	If !Empty(cFilCfs)
		cFilDT5 := IIf(Empty(cFilDT5), cFilDT5, cFilCfs)
		cSeek   := cFilDT5+cFilCfs+cNumSol
	Else
		cSeek := cFilDT5+cFilOri+cNumSol
	EndIf

	If DT5->(MsSeek(cSeek))
		DbSelectArea('GWE')
		GWE->( dbSetOrder(2) )
		If GWE->( dbSeek( xFilial('GWE') + DT5->DT5_FILORI + DT5->DT5_NUMSOL + 'COL' ) )
			DbSelectArea('GW1')
			GW1->( dbSetOrder(1) )
			If GW1->( dbSeek( xFilial('GW1') + GWE->GWE_CDTPDC + GWE->GWE_EMISDC + GWE->GWE_SERDC + GWE->GWE_NRDC ))
				lRet:= .T.
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsRedAdic()
@autor		: Katia
@descricao	: Verifica se existe Redespacho Adicional para o Documento
@param		: Filial de Origem, Viagem, cFilDoc, cDoc, cSerie, cCodFor, cLojFor
@return	: Logico - lRet
@since		: Jan./2017
@using		: TMSA360 - Apontamento de Ocorrencia
@review	:

Argumentos	:
/*/
//-------------------------------------------------------------------------------------------------
Function TmsRedAdic(cFilOri,cViagem,cFilDoc,cDoc,cSerie,cCodFor,cLojFor)
Local lRet:= .F.
Local cAliasNew:= ""
Local cQuery   := ""
Local lExistDJN:= .F.
Local aArea    := GetArea()

Default cFilOri:= ""
Default cViagem:= ""
Default cFilDoc:= ""
Default cDoc   := ""
Default cSerie := ""
Default cCodFor:= ""
Default cLojFor:= ""

	cAliasNew := GetNextAlias()
	cQuery := " SELECT DJN_CODFOR, DJN_LOJFOR  "
	cQuery += "   FROM " + RetSqlName("DJN") + " DJN "
	cQuery += "  WHERE DJN_FILIAL  = '"+ xFilial("DJN")+"' "
	cQuery += "    AND DJN_FILORI  = '"+cFilOri+"' "
	cQuery += "    AND DJN_VIAGEM  = '"+cViagem+"' "
	cQuery += "    AND DJN_FILDOC  = '"+cFilDoc+"' "
	cQuery += "    AND DJN_DOC     = '"+cDoc+"' "
	cQuery += "    AND DJN_SERIE   = '"+cSerie+"' "
	cQuery += "    AND DJN.D_E_L_E_T_ = ' ' "
	cQuery    := ChangeQuery(cQuery)
	cAliasNew := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.T.,.T.)
	While (cAliasNew)->(!Eof())
		lExistDJN:= .T.
		If (cAliasNew)->DJN_CODFOR == cCodFor .And. (cAliasNew)->DJN_CODFOR  == cLojFor
			lRet:= .T.
			Exit
		EndIf
		(cAliasNew)->(DbSkip())
	EndDo
	(cAliasNew)->( dbCloseArea() )

	//--- Se nao encontrou o registro na DJN retorna para inclusao da ocorrencia
	If !lExistDJN
		lRet:= .T.
	EndIf

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsFor2Vet()
@autor		: Eduardo Alberti
@descricao	: Gera Vetor Com Fornecedores Disponíveis Para Apontamento De Ocorrências
@since		: Mar./2017
@using		: Genérico TMS
@review     :
@param		:

/*/
//-------------------------------------------------------------------------------------------------
Function TmsFor2Vet()

	Local aArea     := GetArea()
	Local aRet      := {}
	Local nA        := 0
	Local cChave    := ""
	Local nIndRed   := 1
	Local lCmpDFV   := DFV->(ColumnPos("DFV_FILORI")) > 0 .And. DFV->(ColumnPos("DFV_TIPVEI")) > 0
	Local lRetInd   := FindFunction("TMSRetInd")
	Local cSeekRed  := ""
	Local lDTRCodFav:= DTR->(ColumnPos("DTR_CODFAV")) > 0
	Local cCodFor   := ""
	Local cLojFor   := ""
	Local lFavDTR   := .F.

	If Type("M->DTQ_VIAGEM") == "U" .And. Type("M->DUA_VIAGEM") != "U"
		M->DTQ_FILORI := M->DUA_FILORI
		M->DTQ_VIAGEM := M->DUA_VIAGEM
	EndIf

	If !Empty(M->DTQ_VIAGEM)

		//----------------------------------------------------------------------------------------------------------------
		//-- Passo 01 -> Inclui Cód. Fornecedor Do DJM (Fornecedores Adicionais Da Viagem)
		//----------------------------------------------------------------------------------------------------------------
		DbSelectArea("DJM")
		DbSetOrder(1) //-- DJM_FILIAL+DJM_FILORI+DJM_VIAGEM+DJM_CODFOR+DJM_LOJFOR
		MsSeek( FWxFilial("DJM") + M->DTQ_FILORI + M->DTQ_VIAGEM , .F. )

		While DJM->(!Eof()) .And. DJM->(DJM_FILIAL+DJM_FILORI+DJM_VIAGEM) == (FWxFilial("DJM") + M->DTQ_FILORI + M->DTQ_VIAGEM)

			//-- Inclui Fornecedor Informado No DJM
			If aScan( aRet, { |x| x[1] ==  DJM->(DJM_CODFOR + "-" + DJM_LOJFOR) }) == 0

				If TmsValSA2( DJM->DJM_CODFOR, DJM->DJM_LOJFOR )

					aAdd( aRet , { DJM->(DJM_CODFOR + "-" + DJM_LOJFOR), SA2->A2_NOME})

					//-- Inclui Fornecedor Informado No SA2
					If !Empty(SA2->A2_CODFAV) .And. aScan( aRet, { |x| x[1] ==  SA2->(A2_CODFAV + "-" + A2_LOJFAV) }) == 0

						If TmsValSA2( SA2->A2_CODFAV, SA2->A2_LOJFAV )
							aAdd( aRet , { SA2->(A2_CODFAV + "-" + A2_LOJFAV), SA2->A2_NOME } )
						EndIf
					EndIf
				EndIf
			EndIf

			DJM->(DbSkip())
		EndDo

		//----------------------------------------------------------------------------------------------------------------
		//-- Passo 02 -> Inclui Cód. Fornecedor Do DTR (Veículos Da Viagem)
		//----------------------------------------------------------------------------------------------------------------
		aVeiDTR := {}
		aAdd( aVeiDTR, 'DTR_CODVEI' )
		aAdd( aVeiDTR, 'DTR_CODRB1' )
		aAdd( aVeiDTR, 'DTR_CODRB2' )

		//-- Terceiro Reboque
		If DTR->(FieldPos('DTR_CODRB3')) > 0
			aAdd( aVeiDTR, 'DTR_CODRB3')
		EndIf

		DbSelectArea("DTR")
		DbSetOrder(1) //-- DTR_FILIAL+DTR_FILORI+DTR_VIAGEM+DTR_ITEM
		MsSeek( FWxFilial("DTR") + M->DTQ_FILORI + M->DTQ_VIAGEM , .F. )

		While DTR->(!Eof()) .And. DTR->(DTR_FILIAL+DTR_FILORI+DTR_VIAGEM) == (FWxFilial("DTR") + M->DTQ_FILORI + M->DTQ_VIAGEM)
			lFavDTR:= .F.
			If lDTRCodFav .And. !Empty(DTR->DTR_CODFAV) //Favorecido da Viagem
				lFavDTR:= .T.
				cCodFor:= DTR->DTR_CODFAV
				cLojFor:= DTR->DTR_LOJFAV
			Else
				cCodFor:= DTR->DTR_CODFOR
				cLojFor:= DTR->DTR_LOJFOR
			EndIf

			If !Empty(cCodFor) .And. aScan( aRet, { |x| x[1] ==  cCodFor + "-" + cLojFor  }) == 0

				If TmsValSA2( cCodFor, cLojFor )

					aAdd( aRet , { cCodFor + "-" + cLojFor, SA2->A2_NOME })

					If !lFavDTR
						//-- Inclui Fornecedor Informado No SA2
						If !Empty(SA2->A2_CODFAV) .And. aScan( aRet, { |x| x[1] ==  SA2->(A2_CODFAV + "-" + A2_LOJFAV) }) == 0
							If TmsValSA2( SA2->A2_CODFAV, SA2->A2_LOJFAV )
								aAdd( aRet , { SA2->(A2_CODFAV + "-" + A2_LOJFAV), SA2->A2_NOME } )
							EndIf
						EndIf
					EndIf	

				EndIf
			EndIf	

			//-- Verifica Veículos Do DTR
			For nA := 1 To Len(aVeiDTR)

				//-- Posiciona No Cad. Veículos
				DbSelectArea("DA3")
				DbSetOrder(1) //-- DA3_FILIAL+DA3_COD
				If MsSeek( FWxFilial("DA3") + &('DTR->' + aVeiDTR[nA]) , .f. ) .And. !Empty(&('DTR->' + aVeiDTR[nA]))

					//-- Proprietário Veículo
					If !Empty(DA3->DA3_CODFOR) .And. aScan( aRet, { |x| x[1] ==  DA3->(DA3_CODFOR + "-" + DA3_LOJFOR) }) == 0
						If TmsValSA2( DA3->DA3_CODFOR, DA3->DA3_LOJFOR )

							aAdd( aRet , { DA3->(DA3_CODFOR + "-" + DA3_LOJFOR), SA2->A2_NOME })

							//-- Inclui Fornecedor Informado No SA2
							If !Empty(SA2->A2_CODFAV) .And. aScan( aRet, { |x| x[1] ==  SA2->(A2_CODFAV + "-" + A2_LOJFAV) }) == 0
								If TmsValSA2( SA2->A2_CODFAV, SA2->A2_LOJFAV )
									aAdd( aRet , { SA2->(A2_CODFAV + "-" + A2_LOJFAV), SA2->A2_NOME } )
								EndIf
							EndIf
						EndIf
					EndIf

					//-- Favorecido Do Veículo
					If !Empty(DA3->DA3_CODFAV) .And. aScan( aRet, { |x| x[1] ==  DA3->(DA3_CODFAV + "-" + DA3_LOJFAV) }) == 0
						If TmsValSA2( DA3->DA3_CODFAV, DA3->DA3_LOJFAV )
							aAdd( aRet , { DA3->(DA3_CODFAV + "-" + DA3_LOJFAV), SA2->A2_NOME })
						EndIf
					EndIf

				EndIf
			Next nA

			DTR->(DbSkip())
		EndDo

		//----------------------------------------------------------------------------------------------------------------
		//-- Passo 04 -> Inclui Cód. Fornecedor Do DJN (Redespacho Adicional da Viagem)
		//----------------------------------------------------------------------------------------------------------------
		If Type('aCols') == 'A' .And. AliasInDic('DJN')

			DbSelectArea("DT2")
			DbSetOrder(1) //-- DT2_FILIAL+DT2_CODOCO
			MsSeek(xFilial('DT2') + GdFieldGet('DUA_CODOCO',n),.F.)

			//-- Verifica Se Integra GFE
			If !Empty(DT2_CDTIPO) //-- Tipo Da Ocorrencia GFE

				cChave := FWxFilial("DJN") + M->DUA_FILORI + M->DUA_VIAGEM + GdFieldGet("DUA_FILDOC",n) + GdFieldGet("DUA_DOC",n) + GdFieldGet("DUA_SERIE",n)

				DbSelectArea("DJN")
				DbSetOrder(1) //-- DJN_FILIAL+DJN_FILORI+DJN_VIAGEM+DJN_FILDOC+DJN_DOC+DJN_SERIE+DJN_SEQRDP
				MsSeek( cChave  , .f. )

				While DJN->(!Eof()) .And. ( cChave == DJN->(DJN_FILIAL + DJN_FILORI + DJN_VIAGEM + DJN_FILDOC + DJN_DOC + DJN_SERIE))

					If !Empty(DJN->DJN_CODFOR) .And. aScan( aRet, { |x| x[1] ==  DJN->(DJN_CODFOR + "-" + DJN_LOJFOR) }) == 0

						If TmsValSA2( DJN->DJN_CODFOR, DJN->DJN_LOJFOR )

							aAdd( aRet , { DJN->(DJN_CODFOR + "-" + DJN_LOJFOR), SA2->A2_NOME })

							//-- Inclui Fornecedor Informado No SA2
							If !Empty(SA2->A2_CODFAV) .And. aScan( aRet, { |x| x[1] ==  SA2->(A2_CODFAV + "-" + A2_LOJFAV) }) == 0
								If TmsValSA2( SA2->A2_CODFAV, SA2->A2_LOJFAV )
									aAdd( aRet , { SA2->(A2_CODFAV + "-" + A2_LOJFAV), SA2->A2_NOME } )
								EndIf
							EndIf
						EndIf
					EndIf

					DJN->(DbSkip())
				EndDo
			EndIf
		EndIf
	Else
		//----------------------------------------------------------------------------------------------------------------
		//-- Passo 03 -> Inclui Cód. Fornecedor Do DFT (Redespachante X Documentos)
		//----------------------------------------------------------------------------------------------------------------
		//-- Movimento de Viagem
		DbSelectArea("DUD")
		DbSetOrder(1) //-- DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE+DUD_FILORI+DUD_VIAGEM
		If Type('aCols') == 'A' .And. MsSeek( FWxFilial("DUD") + GdFieldGet("DUA_FILDOC",n) + GdFieldGet("DUA_DOC",n) + GdFieldGet("DUA_SERIE",n)  , .f. )

			//-- Verifica Redespacho
			If !Empty(DUD->DUD_NUMRED)

				//-- Redespachante X Documentos
				DbSelectArea("DFT")

				If lRetInd
					cSeekRed:= TMSRetInd('DFT',DUD->DUD_NUMRED,Iif(lCmpDFV, DUD->DUD_FILORI, ''),@nIndRed)
				Else
					cSeekRed:= DUD->DUD_NUMRED
				EndIf

				DFT->(DbSetOrder(nIndRed))
				If DFT->(DbSeek( FWxFilial("DFT") + cSeekRed ))

					If !Empty(DFT->DFT_CODFOR) .And. aScan( aRet, { |x| x[1] ==  DFT->(DFT_CODFOR + "-" + DFT_LOJFOR) }) == 0

						If TmsValSA2( DFT->DFT_CODFOR, DFT->DFT_LOJFOR )

							aAdd( aRet , { DFT->(DFT_CODFOR + "-" + DFT_LOJFOR), SA2->A2_NOME })

							//-- Inclui Fornecedor Informado No SA2
							If !Empty(SA2->A2_CODFAV) .And. aScan( aRet, { |x| x[1] ==  SA2->(A2_CODFAV + "-" + A2_LOJFAV) }) == 0
								If TmsValSA2( SA2->A2_CODFAV, SA2->A2_LOJFAV )
									aAdd( aRet , { SA2->(A2_CODFAV + "-" + A2_LOJFAV), SA2->A2_NOME } )
								EndIf
							EndIf
						EndIf
					EndIf

					//----------------------------------------------------------------------------------------------------------------
					//-- Passo 03 -> Inclui Cód. Fornecedor Do DJO (Redespacho Adicional)
					//----------------------------------------------------------------------------------------------------------------
					If Type('aCols') == 'A' .And. AliasInDic('DJO')

						DbSelectArea("DT2")
						DbSetOrder(1) //-- DT2_FILIAL+DT2_CODOCO
						MsSeek(xFilial('DT2') + GdFieldGet('DUA_CODOCO',n),.F.)

						//-- Verifica Se Integra GFE
						If !Empty(DT2_CDTIPO) //-- Tipo Da Ocorrencia GFE

							cChave := FWxFilial("DJO") + DFT->DFT_FILORI + DFT->DFT_NUMRED + GdFieldGet("DUA_FILDOC",n) + GdFieldGet("DUA_DOC",n) + GdFieldGet("DUA_SERIE",n)
							DbSelectArea("DJO")
							DbSetOrder(1) //-- DJO_FILIAL+DJO_FILORI+DJO_NUMRED+DJO_FILDOC+DJO_DOC+DJO_SERIE+DJO_SEQRDP
							MsSeek( cChave  , .f. )

							While DJO->(!Eof()) .And. ( cChave == DJO->(DJO_FILIAL + DJO_FILORI + DJO_NUMRED + DJO_FILDOC + DJO_DOC + DJO_SERIE))

								If !Empty(DJO->DJO_CODFOR) .And. aScan( aRet, { |x| x[1] ==  DJO->(DJO_CODFOR + "-" + DJO_LOJFOR) }) == 0

									If TmsValSA2( DJO->DJO_CODFOR, DJO->DJO_LOJFOR )

										aAdd( aRet , { DJO->(DJO_CODFOR + "-" + DJO_LOJFOR), SA2->A2_NOME })

										//-- Inclui Fornecedor Informado No SA2
										If !Empty(SA2->A2_CODFAV) .And. aScan( aRet, { |x| x[1] ==  SA2->(A2_CODFAV + "-" + A2_LOJFAV) }) == 0
											If TmsValSA2( SA2->A2_CODFAV, SA2->A2_LOJFAV )
												aAdd( aRet , { SA2->(A2_CODFAV + "-" + A2_LOJFAV), SA2->A2_NOME } )
											EndIf
										EndIf
									EndIf
								EndIf

								DJO->(DbSkip())
							EndDo
						EndIf
					EndIf

				EndIf
			EndIf
		EndIf
	EndIf

	If Empty(aRet)
		aAdd(aRet,{Space(Len(SA2->(A2_CODFAV + "-" + A2_LOJFAV))), Space(Len(SA2->A2_NOME))})
	EndIf
	RestArea(aArea)

Return(aRet)

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsValSA2()
@autor		: Eduardo Alberti
@descricao	: Valida Código Do Fornecedor No SA2
@since		: Mar./2017
@using		: Genérico TMS
@review	:
@param		: cCodigo   := Código Do Fornecedor
              cLoja  	:= Loja Do Fornecedor
              lPos      := Retorna SA2 Posicionado (Booleano)
              lBlq      := Valida Fornecedores Bloqueados No Cadastro (Booleano)
/*/
//-------------------------------------------------------------------------------------------------
Function TmsValSA2( cCodigo, cLoja, lPos, lBlq )

	Local lRet   := .f.
	Local aArea  := GetArea()
	Local aArSA2 := SA2->(GetArea())

	Default cCodigo := ""
	Default cLoja   := ""
	Default lPos    := .t. //-- Default Retorna Posicionado
	Default lBlq    := .t. //-- Default Avaliar Bloqueio Cadastral

	//-- Formata Variáveis Para Correto Posicionamento
	cCodigo := PadR(cCodigo , TamSX3("A2_COD" )[1] )
	cLoja   := PadR(cLoja   , TamSX3("A2_LOJA")[1] )

	//-- Posiciona No Cadastro Do Fornecedor
	DbSelectArea("SA2")
	DbSetOrder(1)
	If MsSeek( FWxFilial("SA2") + cCodigo + cLoja , .f. )

		//-- Verifica Se Avalia Bloqueio
		If lBlq
			If SA2->A2_MSBLQL  == '2' //-- Não Bloqueado
				lRet := .t.
			EndIf
		Else
			lRet := .t. //-- Liberado Sem Avaliação De Fornecedor Bloqueado No Cadastro
		EndIf
	EndIf

	//-- Restaura Posiciomamento Original SA2
	If !(lPos)
		RestArea(aArSA2)
	EndIf

	//-- Restaura Area Original
	If !("SA2" $ aArea[1])
		RestArea(aArea)
	EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ TmsLibVeic ³ Autor ³ Valdemar Roberto  ³ Data ³ 03.05.2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Função para liberar os veiculos e motoristas da viagem     ³±±
±±           ³ quando alguma não conformidade ocorrer na abertura da      ³±±
±±           ³ viagem                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsLibVeic(cExp01,cExp02)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Filial de Origem da Viagem                        ³±±
±±³          ³ cExp02 - Numero da Viagem                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TmsLibVeic(cFilOri,cViagem,lExbHlp)
Local lRet      := .T.
Local aAreas    := {DTQ->(GetArea()),DTR->(GetArea()),DUP->(GetArea()),DUQ->(GetArea()),DVB->(GetArea()),SDG->(GetArea()),DVW->(GetArea()),GetArea()}
Local cQuery    := ""
Local cAliasDUD := ""
Local cAliasDTA := ""
Local cSeek     := ""
Local nQtdDoc   := 0

Default cFilOri := ""
Default cViagem := ""
Default lExbHlp := .T.

//-- Busca Movimento de Documentos da viagem
cAliasDUD := GetNextAlias()
cQuery := "SELECT COUNT(DUD_DOC) QTDEDUD "
cQuery += "  FROM " + RetSqlName("DUD") + " DUD "
cQuery += " WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
cQuery += "   AND DUD_FILORI = '" + cFilOri + "' "
cQuery += "   AND DUD_VIAGEM = '" + cViagem + "' "
cQuery += "   AND DUD.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDUD,.T.,.T.)

If (cAliasDUD)->(!Eof())
	nQtdDoc += (cAliasDUD)->QTDEDUD
EndIf
(cAliasDUD)->(DbCloseArea())
RestArea(aAreas[Len(aAreas)])

//-- Busca Carregamentos da Viagem
cAliasDTA := GetNextAlias()
cQuery := "SELECT COUNT(DTA_DOC) QTDEDTA "
cQuery += "  FROM " + RetSqlName("DTA") + " DTA "
cQuery += " WHERE DTA_FILIAL = '" + xFilial("DTA") + "' "
cQuery += "   AND DTA_FILORI = '" + cFilOri + "' "
cQuery += "   AND DTA_VIAGEM = '" + cViagem + "' "
cQuery += "   AND DTA.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDTA,.T.,.T.)

If (cAliasDTA)->(!Eof())
	nQtdDoc += (cAliasDTA)->QTDEDTA
EndIf
(cAliasDTA)->(DbCloseArea())
RestArea(aAreas[Len(aAreas)])

//-- Verifica Documentos Vinculados à Viagem
If nQtdDoc > 0
	If lExbHlp
		MsgAlert("Existem documentos vinculados à viagem. A liberação do veículo não poderá ser efetuada.","Atenção")
	EndIf
	lRet := .F.
EndIf

If lRet
	//-- Estorna Veiculos da Viagem
	DTR->(DbSetOrder(1))
	If DTR->(DbSeek(cSeek := xFilial("DTR") + cFilOri + cViagem))
		While DTR->(!Eof()) .And. DTR->(DTR_FILIAL + DTR_FILORI + DTR_VIAGEM) == cSeek
			DTR->(RecLock("DTR",.F.))
			DTR->(DbDelete())
			DTR->(MsUnlock())
			DTR->(DbSkip())
		EndDo
	EndIf

	//-- Estorna Motoristas da Viagem
	DUP->(DbSetOrder(1))
	If DUP->(DbSeek(cSeek := xFilial("DUP") + cFilOri + cViagem))
		While DUP->(!Eof()) .And. DUP->(DUP_FILIAL + DUP_FILORI + DUP_VIAGEM) == cSeek
			DUP->(RecLock("DUP",.F.))
			DUP->(DbDelete())
			DUP->(MsUnlock())
			DUP->(DbSkip())
		EndDo
	EndIf

	//-- Estorna Ajudantes da Viagem
	DUQ->(DbSetOrder(1))
	If DUQ->(DbSeek(cSeek := xFilial("DUQ") + cFilOri + cViagem))
		While DUQ->(!Eof()) .And. DUQ->(DUQ_FILIAL + DUQ_FILORI + DUQ_VIAGEM) == cSeek
			RecLock("DUQ",.F.)
			DUQ->(DbDelete())
			DUQ->(MsUnlock())
			DUQ->(DbSkip())
		EndDo
	EndIf

	//-- Estorna Lacres da Viagem
	DVB->(DbSetOrder(1))
	If DVB->(DbSeek(cSeek := xFilial("DVB") + cFilOri + cViagem))
		While DVB->(!Eof()) .And. DVB->(DVB_FILIAL + DVB_FILORI + DVB_VIAGEM) == cSeek
			RecLock("DVB",.F.)
			DVB->(DbDelete())
			DVB->(MsUnlock())
			DVB->(DbSkip())
		EndDo
	EndIf

	//-- Estorna Adiantamento da Viagem SDG
	SDG->(DbSetOrder(5))
	If SDG->(DbSeek(cSeek := xFilial("SDG") + cFilOri + cViagem))
		While SDG->(!Eof()) .And. SDG->(DG_FILIAL + DG_FILORI + DG_VIAGEM) == cSeek
			TMSA070Bx("2",SDG->DG_NUMSEQ,cFilOri,cViagem,,,,,,,)
			SDG->(DbSkip())
		EndDo
	EndIf

	//-- Estorna Valor Informado da Viagem
	DVW->(DbSetOrder(1))
	If DVW->(DbSeek(cSeek := xFilial("DVW") + cFilOri + cViagem))
		While DVW->(!Eof()) .And. DVW->(DVW_FILIAL + DVW_FILORI + DVW_VIAGEM) == cSeek
			RecLock("DVW",.F.)
			DVW->(DbDelete())
			DVW->(MsUnlock())
			DVW->(DbSkip())
		EndDo
	EndIf

	//-- Estorna Viagem
	DTQ->(DbSetOrder(2))
	If DTQ->(DbSeek(xFilial("DTQ") + cFilOri + cViagem))
		DTQ->(RecLock("DTQ",.F.))
		DTQ->(DbDelete())
		DTQ->(MsUnlock())
	EndIf

EndIf

AEval(aAreas,{|x,y| RestArea(x) })

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsTabPrev()
             Geração Das Tabelas (Temporárias) De Prévia De Cálculo
@author      Eduardo Alberti
@since       Jan./2017
@version     MP11.5
@sample      Exemplo de uso do bloco
@see         FWTeste2,FWTeste3,FWTeste4 //-- Indica as funções que devem ser observadas pelo desenvolvedor antes do uso. “Veja também”.
@obs         Pré-requisito -> TOTVS|DBAccess 4.2 Server com build igual ou superior à 20141119 (Mar 12 2015).
@param       Parâmetros de entrada, listados na ordem de passagem. Exemplo: cFederalId Informe.
@return      ExpL  indica se a rotina foi executada corretamente.
/*/
//-------------------------------------------------------------------------------------------------
Function TmsTabPrev( cOpc, aTabPrv, lAuto, aTabTmp )

	Local aArea     := { GetArea(), SIX->(GetArea()) }
	Local nI        := 0
	Local aStru     := {}
	Local cTab      := ""
	Local nCount    := 0
	Local aIndex    := {}

	Default aTabTmp := {"DTC","DT6"}
	Default cOpc    := "C" //-- Criar
	Default aTabPrv := {}
	Default lAuto   := .f.

	//-- Cria Tabelas Temporárias
	If cOpc == "C"

		If Len(aTabPrv) == 0

			For nI := 1 To Len(aTabTmp)

				DbSelectArea( aTabTmp[nI] )

				aStru   := ( aTabTmp[nI] )->(DbStruct())
				cTab    := GetNextAlias()
				oObj    := FWTemporaryTable():New( cTab )

				oObj:SetFields( aStru )

				//-- oTabBrw:GetRealName() //-- Retorna o Nome No BD
				//-- oTabBrw:GetAlias()    //-- Retorna o Alias

				//-- Cria Indices Conforme Necessidade
				DbSelectArea("SIX")
				DbSetOrder(1) //-- Indice + Ordem
				If MsSeek( aTabTmp[nI] )

					nCount := 0
					While !(SIX->(Eof())) .And. SIX->INDICE == aTabTmp[nI]

						nCount ++

						DbSelectArea( aTabTmp[nI] )
						DbSetOrder( nCount )

						aIndex := StrToKarr( SqlOrder( (SIX->INDICE)->(IndexKey()) ) , ',' )

						oObj:AddIndex( StrZero(nCount,2) , aIndex )

						SIX->(DbSkip())
					EndDo
				EndIf

				oObj:Create()

				If ValType(oObj) == 'O'
					aAdd( aTabPrv, { oObj, oObj:GetAlias(), oObj:GetRealName() })
				Else

				EndIf
			Next nI
		Else

		EndIf

	//-- Exclui Tabelas Temporárias
	ElseIf cOpc == "E" .And. Len(aTabPrv) > 0
		For nI := 1 To Len(aTabPrv)
			aTabPrv[nI,01]:Delete()
		Next aTabPrv
	EndIf

	//-- Reposiciona Arquivos
	For nI := 1 To Len(aArea)
		RestArea(aArea[nI])
	Next nI

Return(aTabPrv)
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsChkRom()
@autor		: Katia
@descricao	: Verifica se o Documento se enquadra em algum Romaneio em aberto na viagem
@since		: Maio/2017
@using		: Genérico TMS
@review	:
@param		: cFilOri  := Filial de Origem
              cViagem	:= Viagem
              cRecnoDUD:= Recno DUD
              cUFOri    :=
              cCdMunO   :=
              cCEPOri   :=
              cCdClFr   :=
/*/
//-------------------------------------------------------------------------------------------------
Function TmsChkRom(cFilOri,cViagem,cRecnoDUD)
Local cAliasDUD  := ""
Local cQuery     := ""
Local cRet       := ""
Local aArea      := GetArea()
Local aAreaDUD   := DUD->(GetArea())
Local cCHVEXT    := ""
Local aChvExt    := {}
Local cFilRom    := ""
Local cNumRom    := ""
Local cQuery1    := ""
Local cUFOri     := ""
Local cCdMunO    := ""
Local cCepOri    := ""
Local cUFDes     := ""
Local cCdMunD    := ""
Local cCepDes    := ""
Local cCdClFr    := ""

Default cFilOri  := ""
Default cViagem  := ""
Default cRecnoDUD:= ""

If !Empty(cRecnoDUD)
	DbSelectArea("DUD")
	DUD->(DbGoTo(cRecnoDUD))

	//----------- Posiciona no Documento Principal para pegar as caracteristicas da integração GFE ----------
	cUFOri  := DUD->DUD_UFORI
	cCdMunO := DUD->DUD_CDMUNO
	cCepOri := DUD->DUD_CEPORI
	cUFDes  := DUD->DUD_UFDES
	cCdMunD := DUD->DUD_CDMUND
	cCepDes := DUD->DUD_CEPDES
	cCdClFr := DUD->DUD_CDCLFR

	If Empty(DUD->DUD_UFORI) .And. Empty(DUD->DUD_CDMUNO)
		cAliasDJN := GetNextAlias()
		cQuery1 := " SELECT * FROM " + RetSqlName("DJN") + " DJN "
		cQuery1 += "  WHERE DJN_FILIAL  = '"+ xFilial("DJN")+"' "
		cQuery1 += "    AND DJN_FILORI  = '" + DUD->DUD_FILORI + "' "
		cQuery1 += "    AND DJN_VIAGEM  = '" + DUD->DUD_VIAGEM + "' "
		cQuery1 += "    AND DJN_FILDOC  = '" + DUD->DUD_FILDOC + "' "
		cQuery1 += "    AND DJN_DOC = '" + DUD->DUD_DOC + "' "
		cQuery1 += "    AND DJN_SERIE = '" + DUD->DUD_SERIE + "' "
		cQuery1 += "    AND DJN.D_E_L_E_T_ = ' ' "
		cQuery1 += "   ORDER BY DJN_FILORI, DJN_VIAGEM, DJN_FILDOC, DJN_DOC, DJN_SERIE, DJN_SEQRDP "
		cQuery1    := ChangeQuery(cQuery1)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery1),cAliasDJN,.T.,.T.)
		If (cAliasDJN)->(!Eof())
			cUFOri  := (cAliasDJN)->DJN_UFORI
			cCdMunO := (cAliasDJN)->DJN_CDMUNO
			cCepOri := (cAliasDJN)->DJN_CEPORI
			cUFDes  := (cAliasDJN)->DJN_UFDES
			cCdMunD := (cAliasDJN)->DJN_CDMUND
			cCepDes := (cAliasDJN)->DJN_CEPDES
			cCdClFr := (cAliasDJN)->DJN_CDCLFR
		EndIf
	EndIf

	//------------- Verifica os Documentos que foram integrados ao GFE ---------------------------------
	cAliasDUD := GetNextAlias()
	cQuery := " SELECT DUD_CHVEXT, "
	cQuery += " CASE WHEN DUD_UFORI = ' ' AND DUD_CDMUNO = ' ' THEN DJN_UFORI  ELSE DUD_UFORI END AS DUD_UFORI, "
	cQuery += " CASE WHEN DUD_UFORI = ' ' AND DUD_CDMUNO = ' ' THEN DJN_CDMUNO ELSE DUD_UFORI END AS DUD_CDMUNO, "
	cQuery += " CASE WHEN DUD_UFORI = ' ' AND DUD_CDMUNO = ' ' THEN DJN_CEPORI ELSE DUD_UFORI END AS DUD_CEPORI, "
	cQuery += " CASE WHEN DUD_UFORI = ' ' AND DUD_CDMUNO = ' ' THEN DJN_UFDES  ELSE DUD_UFORI END AS DUD_UFDES, "
	cQuery += " CASE WHEN DUD_UFORI = ' ' AND DUD_CDMUNO = ' ' THEN DJN_CDMUND ELSE DUD_UFORI END AS DUD_CDMUND, "
	cQuery += " CASE WHEN DUD_UFORI = ' ' AND DUD_CDMUNO = ' ' THEN DJN_CEPDES ELSE DUD_UFORI END AS DUD_CEPDES, "
	cQuery += " CASE WHEN DUD_UFORI = ' ' AND DUD_CDMUNO = ' ' THEN DJN_CDCLFR ELSE DUD_UFORI END AS DUD_CDCLFR, "
	cQuery += " CASE WHEN DUD_UFORI = ' ' AND DUD_CDMUNO = ' ' THEN DJN_TPFRRD ELSE DUD_UFORI END AS DUD_TPFRRD, "
	cQuery += " CASE WHEN DUD_UFORI = ' ' AND DUD_CDMUNO = ' ' THEN DJN_TIPVEI ELSE DUD_UFORI END AS DUD_TIPVEI "
	cQuery += " FROM " + RetSqlName('DUD') + " DUD "
	cQuery += " JOIN " + RetSqlName('DJN') + " DJN "
	cQuery += " ON DJN_FILIAL = '" + xFilial('DJN') + "' "
	cQuery += "   AND	DJN_FILORI = '" + cFilOri + "' "
	cQuery += "   AND	DJN_VIAGEM = '" + cViagem + "' "
	cQuery += "   AND	DJN_FILDOC <> '" + DUD->DUD_FILDOC + "' "
	cQuery += "   AND	DJN_DOC <> '" + DUD->DUD_DOC + "' "
	cQuery += "   AND	DJN_SERIE <> '" + DUD->DUD_SERIE + "' "
	cQuery += "   AND DJN.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE DUD_FILIAL = '" + xFilial('DUD') + "' "
	cQuery += "   AND	DUD_FILORI = '" + cFilOri + "' "
	cQuery += "   AND	DUD_VIAGEM = '" + cViagem + "' "
	cQuery += "   AND DUD_STATUS <> '" + StrZero( 9, Len( DUD->DUD_STATUS ) ) + "'"   //Cancelado
	cQuery += "   AND	DUD_FILDOC <> '" + DUD->DUD_FILDOC + "' "
	cQuery += "   AND	DUD_DOC <> '" + DUD->DUD_DOC + "' "
	cQuery += "   AND	DUD_SERIE <> '" + DUD->DUD_SERIE + "' "
	cQuery += "   AND	DUD_CHVEXT <> ' '  "
	cQuery += "   AND DUD.D_E_L_E_T_ = ' ' "
	cQuery += "   GROUP BY DUD_CHVEXT, DUD_UFORI, DUD_CDMUNO, DUD_CEPORI, DUD_UFDES, DUD_CDMUND, DUD_CEPDES, DUD_CDCLFR, DUD_TPFRRD, DUD_TIPVEI "
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDUD, .F., .T.)
	If (cAliasDUD)->(!Eof())
		While (cAliasDUD)->(!Eof())
			 //---- Verifica se existe um Romaneio com as mesmas caracteristicas do documento da viagem
			 If (cAliasDUD)->DUD_UFORI == cUFOri .And. (cAliasDUD)->DUD_CDMUNO == cCdMunO .And. (cAliasDUD)->DUD_CEPORI == cCepOri ;
			     .And. (cAliasDUD)->DUD_CDCLFR == cCdClFr
			     	cCHVEXT:= 	(cAliasDUD)->DUD_CHVEXT
			     	Exit
			 EndIf
			(cAliasDUD)->(DbSkip())
		EndDo
	EndIf
	(cAliasDUD)->(DbCloseArea())
EndIf

If !Empty(cChvExt)
	aChvExt:= Str2Arr(Upper(cCHVEXT), ";")   //quebra em array por delimitador ";"
	cFilRom:= Iif(Len(aChvExt[1])>0,aChvExt[1],'')
	cNumRom:= Iif(Len(aChvExt[2])>0,aChvExt[2],'')
	cRet:= cFilRom + cNumRom   //Filial Romaneio + Nro Romaneio

	//--- Verifica se poderá utilizar o Romaneio
	GWN->( dbSetOrder(1) )
	If GWN->( dbSeek(cRet) )
		lRet:= .F.
		If GWN->GWN_SIT $ "3|4"  //Liberado e ou Encerrado
			/*
			If GWN->GWN_SIT $ "3"
				lRet:= GFEA050REA(.T.)   //Reabre o Romaneio
				If ValType(lRet) <> 'L'
					lRet:= .F.
				EndIf
			*/
			//If GWN->GWN_SIT $ "4"
			//	lRet:= .F.
			//EndIf
		EndIf

		//--- Se nao conseguiu reabrir o Romaneio, retorna Vazio para ser gerado um novo romaneio
		If !lRet
			cRet:= ""
		EndIf
	EndIf

EndIf

RestArea(aArea)
RestArea(aAreaDUD)

Return cRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsRomGWN()
@autor		: Katia
@descricao	: Retorna o Numero do Romaneio
@since		: Maio/2017
@using		: Genérico TMS
@review	:
@param		: cChvExt  := DUD->DUD_CHVEXT
              cTipRet  := Retorno da composição do Romaneio onde  1=Filial + Romaneio ou 2= Romaneio
/*/
//-------------------------------------------------------------------------------------------------

Function TmsRomGWN(cChvExt,cTipRet)   //Filial + Romaneio
Local cFilRom:= ""
Local cNumRom:= ""
Local aChvExt:= {}

Default cChvExt:= ""
Default cTipRet:= '1'   //1=Filial + Romaneio, 2= Romaneio

aChvExt:= Str2Arr(Upper(cChvExt), ";")   //quebra em array por delimitador ";"

If cTipRet == '1'
	cFilRom:= Iif(Len(aChvExt[1])>0,aChvExt[1],'')
	cNumRom:= Padr(cFilRom,Len(GWN->GWN_FILIAL)) + Iif(Len(aChvExt[2])>0,aChvExt[2],'')
Else
	cNumRom:= Iif(Len(aChvExt[2])>0,aChvExt[2],'')
EndIf

Return cNumRom


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsVgeGFE()
@autor		: Katia
@descricao	: Verifica quantidade de documentos que estao no Romaneio
@param		: Filial de Origem, Viagem, cCjvDUD
@return	: lRet
@since		: Jan./2017
@using		: Genérico
@review	:

Argumentos	:
/*/
//-------------------------------------------------------------------------------------------------
Function TmsVgeGFE(cFilOri,cViagem,cChvDUD)
Local cAliasNew:= ""
Local cQuery   := ""
Local aArea    := GetArea()
Local nRet     := 0

Default cFilOri := ""
Default cViagem := ""
Default cChvDUD := ""

	cAliasNew := GetNextAlias()
	cQuery := " SELECT COUNT(*) NREG "
	cQuery += "   FROM " + RetSqlName("DUD") + " DUD "
	cQuery += "  WHERE DUD_FILIAL  = '"+ xFilial("DUD")+"' "
	cQuery += "    AND DUD_FILORI  = '"+cFilOri+"' "
	cQuery += "    AND DUD_VIAGEM  = '"+cViagem+"' "
	cQuery += "    AND DUD.DUD_CHVEXT = ' " + cChvDUD + "' "
	cQuery += "    AND DUD.D_E_L_E_T_ = ' ' "
	cQuery    := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.T.,.T.)
	If !(cAliasNew)->(EoF())
		nRet:= (cAliasNew)->NREG
	EndIf
	(cAliasNew)->( dbCloseArea() )

RestArea(aArea)
Return nRet

/*/{Protheus.doc} TMSRentab
//TODO Descrição auto-gerada.
@author caio.y
@since 20/07/2017
@version undefined
@param nOpc, numeric, Operação
@param cFilOri, characters, Filial de Origem
@param cViagem, characters, Viagem
@type function
/*/
Function TMSRentab( nOpc , cFilOri , cViagem , lTela )
Local aArea		:= GetArea()
Local aRet		:= {}
Local nRet		:= 0
Local lRet		:= .F.
Local nContVei	:= 1

Default nOpc		:= 3
Default cFilOri		:= DTQ->DTQ_FILORI
Default cViagem		:= DTQ->DTQ_VIAGEM
Default lTela		:= .T.

If nOpc == 4
	nOpc	:= 3
EndIf

DL3->(dbSetOrder(2)) //-- FILIAL+FILORI+VIAGEM
If DL3->(DBSeek(xFilial("DL3") + cFilOri + cViagem ))
	If lTela .And. ( nOpc == 3 .Or. nOpc == 2 )
		FwExecView(,"TMSAO45",MODEL_OPERATION_VIEW ,,{||.T.})
		AAdd(aRet , { .T. , cFilOri , cViagem , DL3->DL3_NUMSIM , DL3->DL3_TABFRE, DL3->DL3_TIPTAB, DL3->DL3_TABCAR , DL3->DL3_VLRRCT, DL3->DL3_VLRTMS , DL3->DL3_VLRGFE , DL3->DL3_VLRTOT , DL3->DL3_PERCUS , DL3->DL3_RENTAB } )
	ElseIf !lTela .And. ( nOpc == 3 .Or. nOpc == 2 )
		AAdd(aRet , { .T. , cFilOri , cViagem , DL3->DL3_NUMSIM , DL3->DL3_TABFRE, DL3->DL3_TIPTAB, DL3->DL3_TABCAR , DL3->DL3_VLRRCT, DL3->DL3_VLRTMS , DL3->DL3_VLRGFE , DL3->DL3_VLRTOT , DL3->DL3_PERCUS , DL3->DL3_RENTAB } )
	ElseIf nOpc ==  5

		DTQ->(dbSetOrder(2))
		If DTQ->(MsSeek(xFilial("DTQ") + cFilOri + cViagem )) .And. DTQ->DTQ_STATUS == "1" //-- Em aberto
			lRet	:= .T.
		Else
			lRet	:= .F.
		EndIf

		If lRet
			AAdd(aRet , { .T. , cFilOri , cViagem , DL3->DL3_NUMSIM , DL3->DL3_TABFRE, DL3->DL3_TIPTAB, DL3->DL3_TABCAR , DL3->DL3_VLRRCT, DL3->DL3_VLRTMS , DL3->DL3_VLRGFE , DL3->DL3_VLRTOT , DL3->DL3_PERCUS , DL3->DL3_RENTAB } )

			If lTela
				nRet := FwExecView(,"TMSAO45",MODEL_OPERATION_DELETE,,{||.T.})
			Else
				lRet	:= AO45ExcRent(DL3->DL3_NUMSIM)

				If lRet
					nRet	:= 0
				Else
					nRet	:= 1
				EndIf
			EndIf

			If nRet == 1
				aRet	:= {}
				AAdd(aRet , { .F. , cFilOri , cViagem , , , , ,, ,  ,  ,  , } )
			EndIf
		Else
			If lTela
				Help('',1,'TMSAO4505',,) //-- Viagem com status diferente de 1=Em Aberto, não podem ter sua rentabilidade excluída. A rentabilidade só poderá ser excluída ao realizar o Estorno do Fechamento da Viagem.
			EndIf
			aRet	:= {}
			AAdd(aRet , { .F. , cFilOri , cViagem , , , , ,, ,  ,  ,  , } )
		EndIf

	EndIf
Else
	If nOpc == 3 .And. lTela
		DTQ->(dbSetOrder(2))
		If DTQ->(DBSeek(xFilial("DTQ") + cFilOri + cViagem )) .And. DTQ->DTQ_STATUS == "1" //-- Em aberto
			lRet	:= .T.

			//-- Tratamento para verificar se a viagem é comboio
			DTR->(dbSetOrder(1))
			If DTR->( dBSeek( xFilial("DTR") + cFilOri + cViagem ))
				nContVei	:= 0
				While DTR->( !Eof() ) .And. DTR->(DTR_FILIAL + DTR_FILORI + DTR_VIAGEM) ==  xFilial("DTR") + cFilOri + cViagem
				 	nContVei++
					DTR->(dbSkip())
				EndDo
				If nContVei > 1
					lRet	:= .T.
					Help('',1,'TMSAO4507',,) //-- Rentabilidade Prévia não está prevista para viagens em comboio.
				EndIf
			EndIf
		Else
			lRet	:= .F.
			If lTela
				Help('',1,'TMSAO4506',,) //-- Só é permitido simular a rentabilidade de viagens com status 1=Em Aberto e durante o Fechamento da Viagem.
			EndIf
		EndIf

		If lRet .And. nContVei <= 1
			aRet	:= MontaRentab(cFilOri , cViagem )
		EndIf

	ElseIf nOpc == 5 .And. lTela
		Help('', 1, 'REGNOIS' )
	EndIf
EndIf

If Len(aRet) == 0
	AAdd(aRet , { .F. , cFilOri , cViagem , , , ,  , ,  , , , , } )
EndIf

RestArea(aArea)
Return aRet

/*/{Protheus.doc} MontaRentab
//Monta a rentabilidade prévia
@author caio.y
@since 20/07/2017
@version undefined
@param cFilOri, characters, Filial de Origem
@param cViagem, characters, Viagem
@type function
/*/
Static Function MontaRentab(cFilOri , cViagem )
Local bWhileVei		:= {||}
Local aRet			:= {}
Local aAreaDTR		:= DTR->(GetArea())
Local aAreaDTQ		:= DTQ->(GetArea())
Local aArea			:= GetArea()
Local aTabPag		:= {}
Local aFornec		:= {}
Local aMsgErr		:= {}
Local aErros		:= {}
Local aFrete		:= {}
Local aSimula		:= {}
Local aPagarTMS		:= {}
Local aPagarGFE		:= {}
Local aDiaHist		:= {}
Local cAliasVei		:= ""
Local cSeekVei		:= ""
Local cMsgErr		:= ""
Local cLogGFE		:= ""
Local nGrupVei		:= 1
Local nCnt			:= 1
Local nAux			:= 0
Local nAuxErr		:= 0
Local nContErr		:= 1
Local lRet			:= .T.

Default cFilOri		:= DTQ->DTQ_FILORI
Default cViagem		:= DTQ->DTQ_VIAGEM

lRet	:= VldRentab( cFilOri, cViagem )

If lRet

	aPagarGFE	:= TmsPrvGfe(cFilOri,cViagem,@cLogGFE)

	If Posicione("DTQ",2,xFilial("DTQ") + cFilOri + cViagem , "DTQ_PAGGFE") <> "1"
		DTR->(dbSetOrder(1))
		cSeekVei  := xFilial('DTR')+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM
		bWhileVei := {|| DTR->(! Eof()) .And. DTR->DTR_FILIAL+DTR->DTR_FILORI+DTR->DTR_VIAGEM == cSeekVei }
		cAliasVei := 'DTR'

		If (cAliasVei)->(MsSeek(cSeekVei))
			While Eval(bWhileVei)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Preenche Array com todos os Fornecedores dos veículos da viagem³
				//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
				//³Parametros da aFornec:                                         ³
				//³01- Codigo do Fornecedor                                       ³
				//³02- Loja do fornecedor                                         ³
				//³03- Codigo do Veiculo ou do Reboque                            ³
				//³04- Tipo da frota  1=Própria; 2=Terceiro; 3=Agregado           ³
				//³05- Tipo do Veiculo                                            ³
				//|06- Grupo de Veiculo  0=Veiculo  1=1o Reb.  2=2oReb. 3=3oReb.  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aFornec	:= StaticCall(TMSA250,TMA250Forn,1,,"DTR")

				For nCnt := 1 To Len(aFornec)
					aSimula 	:= {}
					cCodForn	:= aFornec[nCnt,1]
					cLojForn	:= aFornec[nCnt,2]
					cCodVei		:= aFornec[nCnt,3]
					nGrupVei   	:= aFornec[nCnt,6]
					cMsgErr		:= ""
					aErros		:= {}

					aRet	:= A250FrePag( DTQ->DTQ_FILORI , DTQ->DTQ_VIAGEM , cCodVei,  @aErros , .T. , @aFrete , nGrupVei, cCodForn, cLojForn, @aDiaHist ,  @aTabPag, "1", .T. ,,.T.,@aSimula )

					If Len(aErros) > 0
						For nContErr := 1 To Len(aErros)
							For nAuxErr	:= 1 To Len(aErros[nContErr])
								cMsgErr		+= aErros[nContErr,nAuxErr]
							Next nAuxErr
							aAdd(aMsgErr , aErros[nContErr] )
						Next nContErr
					EndIf

					If Len(aSimula) > 0
						For nAux := 1 To len(aSimula)
							Aadd(aPagarTMS,aSimula[nAux][Len(aSimula[nAux])])
							Aadd(aPagarTMS[Len(aPagarTMS)],cMsgErr )
						Next nAux
					ElseIf Len(aRet) > 0
						Aadd(aPagarTMS,aRet[Len(aRet)])
						Aadd(aPagarTMS[Len(aPagarTMS)],cMsgErr )
					EndIf

				Next nCnt

				(cAliasVei)->(dbSkip())
			EndDo

			If Len(aMsgErr) > 0
				TmsMsgErr(aMsgErr)
			EndIf

		EndIf
	EndIf

	If !Empty(cLogGFE)
		Pergunte("TMSAO45", .F. )
		cMsgErr	+= "------------------------------------------------------------------------------------------" + chr(10) + chr(13)
		If mv_par04 == 1 //-- Grava log inteiro
			cMsgErr	+= GFEX1MEMO(cLogGFE)
		Elseif mv_par04 == 2 //-- Grava endereço do log
			cMsgErr	+= cLogGFE
		EndIf
		cMsgErr	+= "------------------------------------------------------------------------------------------" + chr(10) + chr(13)

	EndIf
	//-- Grava tabela temporária
	Processa( {|| aRet	:= AO45GrvTmp(cFilOri , cViagem , aPagarTMS , aPagarGFE , cMsgErr ) } )
Else
	aRet	:= {}
	AAdd(aRet , { lRet , cFilOri , cViagem ,  , , ,  , ,  ,  , , ,  } )
EndIf

RestArea(aAreaDTR)
RestArea(aAreaDTQ)
RestArea(aArea)

Return aRet


/*/{Protheus.doc} VldRentab
Valida se a rentabilidade pode ser gerada
@author caio.y
@since 10/05/2017
@version undefined
@param cFilOri, characters, Filial de Origem
@param cViagem, characters, Viagem
@type function
/*/
Static Function VldRentab(cFilOri,cViagem)
Local lRet		:= .T.
Local aArea		:= GetArea()

Default cFilOri		:= ""
Default cViagem		:= ""

DTY->(dbSetOrder(2)) //-- FILIAL+FILORI+VIAGEM
If DTY->( MsSeek( xFilial("DTY") + cFilOri + cViagem ))
	lRet	:= .F.
	Help('',1,'TMSAO4504',,) //-- O contrato de carreteiro já foi gerado para essa viagem. Não será possível visualizar a Rentabilidade Prévia.
EndIf

RestArea(aArea)
Return lRet

/*/{Protheus.doc} TmsPrvGfe
             Calcula Valores Do Frete Pagar Com Integração Com Frete Embarcador (GFE)
@author      Caio Murakami
@since       Jul./2017
@version     MP12.1.17
@sample      TmsPrvGfe( cFilOri , cViagem )
@see         TMSA144
@param       cFilOri -> Filial Origem Da Viagem
             cViagem -> Número Da Viagem
@return      Array Contendo Os Dados Do Cálculo
/*/
Function TmsPrvGfe( cFilOri , cViagem , cLogErro )
Local aArea     	:= { DUD->(GetArea()), DJN->(GetArea()), DTQ->(GetArea()) ,  GetArea() }
Local aPagarGFE  	:= {}
Local aAreaDTC		:= {}
Local nX         	:= 0
Local nCont		 	:= 0
Local nAltura		:= 0
Local nVolume		:= 0
Local nPesoR		:= 0
Local nVlrFrt		:= 0
Local nPrevEnt		:= 0
Local nNumCalc		:= 0
Local nClassFret	:= 0
Local nTipOper		:= 0
Local nQtdKm		:= 0
Local nItemDTC		:= 0
Local nTrecho		:= 0
Local nContGW1		:= 1
Local nContGW8		:= 1
Local nItemDUM		:= 1
Local lReentDev  	:= .F.
Local cTPDCTMS   	:= SuperGetMV("MV_TPDCTMS",,"")
Local lNumProp   	:= SuperGetMv("MV_EMITMP",.F.,"0") == "1" .And. SuperGetMv("MV_INTGFE2",.F.,"2") == "1"
Local lIntGFE    	:= SuperGetMV("MV_INTGFE",.F.,.F.)
Local lPagGfe		:= .F.
Local cEmisDc    	:= ""
Local cDestDc		:= ""
Local cCliRem   	:= ""
Local cLojRem    	:= ""
Local cIcm       	:= ""
Local cCliDes		:= ""
Local cLojDes		:= ""
Local cA1_CGC		:= ""
Local cA1_CdMuDes	:= ""
Local cA1_EstDes	:= ""
Local cNota			:= ""
Local cQuery	 	:= ""
Local cAliasQry		:= ""
Local cQueryDTC		:= ""
Local cAliasDTC		:= ""
Local cDsItem		:= ""
Local cTrecho		:= ""
Local cCGCTran		:= ""
Local cCGC			:= ""
Local cTabela		:= ""
Local cNumNegoc		:= ""
Local cRota			:= ""
Local cFaixa		:= ""
Local cTipoVei		:= ""
Local cTransp		:= ""
Local cCodFor		:= ""
Local cLojFor		:= ""
Local cCodMot		:= ""
Local cCdrOri		:= ""
Local cCdrDes		:= ""
Local cFilDoc		:= ""
Local cDoc			:= ""
Local cSerie		:= ""
Local cSeek			:= ""
Local cA1_CEPDes  	:= ""
Local cTipVei		:= ""
Local cCdUfDes		:= ""
Local cCdMunD		:= ""
Local cCdUfOri		:= ""
Local cCdMunOri		:= ""
Local cCEPOri		:= ""
Local cCEPDes		:= ""
Local cCDCLFR		:= ""
Local cSerTMS		:= ""
Local cCgcTransp	:= ""
Local cCDTPOP		:= ""
Local dDatValid		:= CToD("")
Local lCalcula		:= .F.

Local oModelSim  	:= FWLoadModel("GFEX010")
Local oModelNeg  	:= oModelSim:GetModel("GFEX010_01")
Local oModelAgr  	:= oModelSim:GetModel("DETAIL_01")  // oModel do grid "Agrupadores"
Local oModelDC  	:= oModelSim:GetModel("DETAIL_02")  // oModel do grid "Doc Carga"
Local oModelIt   	:= oModelSim:GetModel("DETAIL_03")  // oModel do grid "Item Carga"
Local oModelTr   	:= oModelSim:GetModel("DETAIL_04")  // oModel do grid "Trechos"
Local oModelInt  	:= oModelSim:GetModel("SIMULA")     // oModel do field que dispara a simulação
Local oModelCal1 	:= oModelSim:GetModel("DETAIL_05")  // oModel do calculo do frete
Local oModelCal2 	:= oModelSim:GetModel("DETAIL_06")  // oModel das informações complemetares do calculo

Default cFilOri  	:= ""
Default cViagem  	:= ""
Default cLogErro	:= ""

Pergunte("TMSAO45",.F.)

DTQ->(dbSetOrder(2))
DTR->(dbSetOrder(3))
If lIntGFE .And. DTQ->(MsSeek(xFilial("DTQ") + cFilOri + cViagem )) .And. DTR->(dbSeek(xFilial('DTR')+cFilOri+cViagem))

	cTransp := ""
	cCodFor := DTR->DTR_CODFOR
	cLojFor	:= DTR->DTR_LOJFOR
	lPagGfe	:= IIf(DTQ->DTQ_PAGGFE == "1" , .T. , .F. )
	cSerTMS	:= DTQ->DTQ_SERTMS

	If Empty(cTransp)
		SA2->( dbSetOrder(1) )
		If SA2->( dbSeek( xFilial("SA2")+cCodFor+cLojFor ))
			If !lNumProp
				cCgcTransp := IIF(SA2->A2_TIPO <> 'X',SA2->A2_CGC,AllTrim(SA2->A2_COD)+AllTrim(SA2->A2_LOJA) )
			Else
				If FindFunction( "GFEM011COD")
					cCgcTransp := GFEM011COD(SA2->A2_COD,SA2->A2_LOJA,2,,)
				EndIf	
			EndIf
		EndIf
	Else
		If lNumProp
			cCgcTransp := Posicione("GU3",13,xFilial("GU3")+cTransp,"GU3_CDEMIT")
		Else
			cCgcTransp := Posicione("SA4",1,xFilial("SA4")+cTransp,"A4_CGC")
		EndIf
	EndIf

	DUP->(dbSetOrder(2)) //DUP_FILIAL+DUP_FILORI+DUP_VIAGEM+DUP_CODMOT
	If DUP->(MsSeek(xFilial('DUP') + cFilOri + cViagem ))
		cCodMot:= DUP->DUP_CODMOT
	EndIf

	//-- Retorna a distancia por cliente / regiao.
	cCdrOri := Posicione("DA8",1,xFilial("DA8") + DTQ->DTQ_ROTA , "DA8_CDRORI")	//-- Regiao de Origem
	cCdrDes := TMSRetRegD(DTQ->DTQ_SERTMS,DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM) 		//--Região de Destino

	If DTQ->DTQ_SERTMS <> StrZero(2, Len(DTQ->DTQ_SERTMS))
		nQtdKm := TMSDistRot(,.F.,cCdrOri,cCdrDes)
	Else
		nQtdKm := TMSDistRot(DTQ->DTQ_ROTA,.F.)
	EndIf

	oModelSim:SetOperation(3)
	oModelSim:Activate()

	If mv_par05 == 1 //-- Sim
		oModelNeg:LoadValue('CONSNEG' ,"1" ) //-- 1=Considera Tab.Frete em Negociacao
	Else
		oModelNeg:LoadValue('CONSNEG' ,"2" ) //-- 2=Considera apenas Tab.Frete Aprovadas
	EndIf

	//-- Agrupadores - Não obrigatorio
	oModelAgr:LoadValue('GWN_DOC'   	, DTQ->DTQ_VIAGEM) //-- Viagem
	oModelAgr:LoadValue('GWN_NRROM' 	, DTQ->DTQ_VIAGEM)
	oModelAgr:LoadValue('GWN_CDTPVC' 	, DTQ->DTQ_TIPVEI )
	oModelAgr:LoadValue('GWN_CDCLFR'	, DTQ->DTQ_CDCLFR) 	//-- '1' Classificação de frete
	oModelAgr:LoadValue('GWN_CDTPOP'	, DTQ->DTQ_CDTPOP) 	//-- '1' Tipo Da Operação
	oModelAgr:LoadValue('GWN_DISTAN'	, nQtdKm ) 			//-- Distancia
	oModelAgr:LoadValue('GWN_CDTRP' 	, cCgcTransp )

	cAliasQry	:= GetNextAlias()
	cQuery := " SELECT DUD.* "
	cQuery += " FROM " + RetSqlName('DUD') + " DUD "
	cQuery += " INNER JOIN " + RetSqlName('DTQ') + " DTQ "
	cQuery += " ON DTQ_FILIAL = '" + xFilial('DTQ') + "' "
	cQuery += "   AND	DTQ_FILORI = '" + cFilOri + "' "
	cQuery += "   AND	DTQ_VIAGEM = '" + cViagem + "' "
	cQuery += "   AND DTQ.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE DUD_FILIAL = '" + xFilial('DUD') + "' "
	cQuery += "   AND	DUD_FILORI = '" + cFilOri + "' "
	cQuery += "   AND	DUD_VIAGEM = '" + cViagem + "' "
	cQuery += "   AND DUD_STATUS <> '" + StrZero( 9, Len( DUD->DUD_STATUS ) ) + "'"   //Cancelado
	cQuery += "   AND DUD.D_E_L_E_T_ = ' ' "
	cQuery += "   AND ( (EXISTS(SELECT 1 FROM " + RetSqlName('DJN') + " DJN "
	cQuery += " 					WHERE DJN.DJN_FILIAL = '" + xFilial('DJN') + "' "
	cQuery += "   				AND	DJN.DJN_FILORI = '" + cFilOri + "' "
	cQuery += "   				AND	DJN.DJN_VIAGEM = '" + cViagem + "' "
	cQuery += "   				AND	DJN.DJN_FILDOC = DUD.DUD_FILDOC "
	cQuery += "   				AND	DJN.DJN_DOC = DUD.DUD_DOC "
	cQuery += "   				AND	DJN.DJN_SERIE = DUD.DUD_SERIE "
	cQuery += "   				AND DJN.D_E_L_E_T_ = ' ' )) "
	cQuery += "   				OR DTQ.DTQ_PAGGFE = '1' )    "
	cQuery += "   ORDER BY DUD.DUD_FILORI, DUD.DUD_VIAGEM, DUD.DUD_CDTPOP "

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	nContGW8	:= 1
	SB5->(dbSetOrder(1))
	While (cAliasQry)->( !Eof() )
		lCalcula	:= .T.
		cFilDoc		:= (cAliasQry)->DUD_FILDOC
		cDoc		:= (cAliasQry)->DUD_DOC
		cSerie		:= (cAliasQry)->DUD_SERIE
		cTipVei		:= (cAliasQry)->DUD_TIPVEI
		cCdUfDes	:= (cAliasQry)->DUD_UFDES
		cCdMunD		:= (cAliasQry)->DUD_CDMUND
		cCdUfOri	:= (cAliasQry)->DUD_UFORI
		cCdMunOri	:= (cAliasQry)->DUD_CDMUNO
		cCEPOri		:= (cAliasQry)->DUD_CEPORI
		cCEPDes		:= (cAliasQry)->DUD_CEPDES
		cCDCLFR		:= (cAliasQry)->DUD_CDCLFR
		cCDTPOP		:= (cAliasQry)->DUD_CDTPOP
		cNota		:= ""

		DT6->(dbSetOrder(1))
		If DT6->(dbSeek(xFilial('DT6')+cFilDoc+cDoc+cSerie )) .And. DT6->DT6_SERTMS <> StrZero(1,Len(DT6->DT6_SERTMS))

			cAliasDTC:= GetNextAlias()
			cQueryDTC := "	SELECT * FROM ( "
			cQueryDTC += "	SELECT DTC_FILIAL, DTC_FILORI, DTC_FILDOC, DTC_DOC, DTC_SERIE, DTC_NUMNFC, DTC_SERNFC, DTC_EMINFC, DTC_CLIREM, DTC_LOJREM, DTC_CLIDES, DTC_LOJDES, DTC_NFEID, DTC_VALICM,DTC_CODPRO,DTC_LOTNFC, DTC_SQEDES "
			cQueryDTC += "       FROM " + RetSqlName("DTC") + " DTC "
			cQueryDTC += " WHERE DTC.DTC_FILIAL = '" + xFilial('DTC') + "' "
			cQueryDTC += "  AND DTC.DTC_FILDOC   = '" + cFilDoc + "' "
			cQueryDTC += "  AND DTC.DTC_DOC      = '" + cDoc + "' "
			cQueryDTC += "  AND DTC.DTC_SERIE    = '" + cSerie + "' "
			cQueryDTC += "  AND DTC.D_E_L_E_T_   = ' ' "
			cQueryDTC += " UNION "
			cQueryDTC += " SELECT DY4_FILIAL AS DTC_FILIAL, DY4_FILORI AS DTC_FILORI, DY4_FILDOC AS DTC_FILDOC, DY4_DOC AS DTC_DOC, DY4_SERIE AS DTC_SERIE, DY4_NUMNFC AS DTC_NUMNFC, DY4_SERNFC AS DTC_SERNFC, '' AS DTC_EMINFC, "
			cQueryDTC += " DY4_CLIREM AS DTC_CLIREM, DY4_LOJREM AS DTC_LOJREM, '' AS DTC_CLIDES, '' AS DTC_LOJDES, '' AS DTC_NFEID, 0 AS DTC_VALICM,DY4_CODPRO AS DTC_CODPRO,DY4_LOTNFC AS DTC_LOTNFC, '' AS DTC_SQEDES "
			cQueryDTC += "       FROM " + RetSqlName("DY4") + " DY4 "
			cQueryDTC += " WHERE DY4.DY4_FILIAL = '" + xFilial('DY4') + "' "
			cQueryDTC += "  AND DY4.DY4_FILDOC   = '" + cFilDoc + "' "
			cQueryDTC += "  AND DY4.DY4_DOC      = '" + cDoc + "' "
			cQueryDTC += "  AND DY4.DY4_SERIE    = '" + cSerie + "' "
			cQueryDTC += "  AND DY4.D_E_L_E_T_   = ' ' "
			cQueryDTC += "	)AliasTmp ORDER BY DTC_FILDOC, DTC_DOC, DTC_SERIE, DTC_NUMNFC, DTC_SERNFC "
			cQueryDTC := ChangeQuery(cQueryDTC)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryDTC),cAliasDTC)

			While (cAliasDTC)->(!Eof())
				lReentDev	:= .F.
				nTrecho		:= 0

				If cNota <> (cAliasDTC)->DTC_NUMNFC+(cAliasDTC)->DTC_SERNFC

					If TmsPsqDY4(cFilDoc,cDoc,cSerie)
						DbSelectArea("DTC")
						DbSetOrder(2) //Filial + Doc.Cliente + Serie Dc.Cli + Remetente + Loja Remet. + Cod. Produto
						If DTC->(MsSeek(xFilial("DTC")+(cAliasDTC)->DTC_NUMNFC+(cAliasDTC)->DTC_SERNFC+(cAliasDTC)->DTC_CLIREM+(cAliasDTC)->DTC_LOJREM+(cAliasDTC)->DTC_CODPRO+(cAliasDTC)->DTC_FILORI+(cAliasDTC)->DTC_LOTNFC))
							lReentDev := .T.
						Endif
					EndIf

					cIcm 	:= Iif((cAliasDTC)->DTC_VALICM == 0 , "2" , "1")

					//-- Dados do cliente destinatário da nota
					SA1->( dbSetOrder(1) )
					If Iif(!lReentDev , SA1->( dbSeek(xFilial("SA1")+(cAliasDTC)->DTC_CLIDES+(cAliasDTC)->DTC_LOJDES ) ) , SA1->( dbSeek(xFilial("SA1")+DTC->DTC_CLIDES+DTC->DTC_LOJDES ) ) )
						If SA1->A1_TIPO == "X"
							cA1_CGC := AllTrim(SA1->A1_COD)+AllTrim(SA1->A1_LOJA)
							cA1_CGC := PadR( cA1_CGC, TamSx3("GW1_CDDEST")[1] )
						Else
							cA1_CGC := SA1->A1_CGC
						EndIf
						cA1_CdMuDes := SA1->A1_COD_MUN
						cA1_EstDes  := SA1->A1_EST
						cA1_CdMuDes := SA1->A1_COD_MUN
						cA1_CEPDes  := SA1->A1_CEP
					EndIf

					If lNumProp
						If FindFunction( "GFEM011COD")
							cEmisDc	:= GFEM011COD((cAliasDTC)->DTC_CLIREM,(cAliasDTC)->DTC_LOJREM,1,,)
							If !lReentDev
								cDestDc	:= GFEM011COD((cAliasDTC)->DTC_CLIDES,(cAliasDTC)->DTC_LOJDES,1,,)
							Else
								cDestDc	:= GFEM011COD(DTC->DTC_CLIDES,DTC->DTC_LOJDES,1,,)
							EndIf
						EndIf	
					Else
						cEmisDc	:= Posicione("SA1",1,xFilial("SA1") + (cAliasDTC)->DTC_CLIREM + (cAliasDTC)->DTC_LOJREM,"A1_CGC")
						cDestDc	:= cA1_CGC
					EndIf

					//-- Documento de Carga
					If nContGW1 > 1
						oModelDC:AddLine(.T.)
					EndIf

					oModelDC:LoadValue("GW1_NRROM" , cViagem )
					oModelDC:LoadValue('GW1_EMISDC', cEmisDc)                          	//-- Codigo Do Emitente - Chave
					oModelDC:LoadValue('GW1_NRDC'  ,(cAliasDTC)->DTC_NUMNFC  )     		//-- Numero Da Nota     - Chave
					oModelDC:LoadValue('GW1_SERDC', (cAliasDTC)->DTC_SERNFC )
					oModelDC:LoadValue('GW1_CDTPDC', Padr(cTPDCTMS,Len(GW1->GW1_CDTPDC))) 	//-- Tipo Do Documento  - Chave
					oModelDC:LoadValue('GW1_CDREM' , cEmisDc )		//-- Remetente
					oModelDC:LoadValue('GW1_CDDEST', cDestDc )  	//-- Destinatario
					oModelDC:LoadValue("GW1_ENTNRC", "")			//-- Cidade Destino
					oModelDC:LoadValue("GW1_ENTCEP" , cA1_CEPDes)		//-- CEP Destino
					oModelDC:LoadValue('GW1_TPFRET', "1" )			//-- 1-Cif;2=Cif Redesp;3=FOB;4=FOB redesp;5=Consig;6=Consignado Redesp
					oModelDC:LoadValue('GW1_ICMSDC', cIcm)			//-- '2' = Mercadoria com ICMS? ( 1=Sim;2=Nao )
					oModelDC:LoadValue('GW1_USO'   , "1" )
					oModelDC:LoadValue('GW1_QTUNI' , 1 )

					//--------------------------------------------------------------------------------------------
					//---- Itens do Documentos DTC
					//--------------------------------------------------------------------------------------------
					nItemDTC:= 0
					aAreaDTC:= DTC->(GetArea())
					DTC->( dbSetOrder(2) )
					If !lReentDev
						cSeek := xFilial("DTC")+(cAliasDTC)->DTC_NUMNFC+(cAliasDTC)->DTC_SERNFC+(cAliasDTC)->DTC_CLIREM+(cAliasDTC)->DTC_LOJREM
						DTC->( dbSeek(cSeek))
					Else
						cSeek := xFilial("DTC")+DTC->DTC_NUMNFC+DTC->DTC_SERNFC+DTC->DTC_CLIREM+DTC->DTC_LOJREM
					EndIf

					nContGW8	:= 1

					While !DTC->( Eof() ) .And. DTC->DTC_FILIAL+DTC->DTC_NUMNFC+DTC->DTC_SERNFC+DTC->DTC_CLIREM+DTC->DTC_LOJREM == cSeek
						If (cAliasDTC)->DTC_FILORI <> DTC->DTC_FILORI
							DTC->( dbSkip() )
							Loop
						EndIf

						If nContGW8 > 1 .Or. nContGW1 > 1
							oModelIt:AddLine()
						EndIf

						//-- Itens do Documento de Carga
						If SB5->(MsSeek( xFilial("SB5")+ DTC->DTC_CODPRO) )
							nAltura := SB5->B5_ALTURA
							nVolume := (nAltura * SB5->B5_LARG * SB5->B5_COMPR) * ( DTC->DTC_QTDVOL)
						Else
							nAltura	:= 0
							nVolume	:= 0
						EndIf

						cDsItem := SubStr(Posicione("SB1",1,xFilial("SB1")+DTC->DTC_CODPRO,"B1_DESC"),1,50)
						nPesoR  := DTC->DTC_PESO

						//-- Itens do Documento de Carga
						oModelIt:LoadValue('GW8_CDTPDC', Padr(cTPDCTMS,Len(GW1->GW1_CDTPDC)) )
						oModelIt:LoadValue('GW8_EMISDC', cEmisDc )
						oModelIt:LoadValue('GW8_SERDC' , (cAliasDTC)->DTC_SERNFC )
						oModelIt:LoadValue('GW8_NRDC'  , (cAliasDTC)->DTC_NUMNFC )
						oModelIt:LoadValue('GW8_ITEM'  , DTC->DTC_CODPRO )
						oModelIt:LoadValue('GW8_CDCLFR', DTQ->DTQ_CDCLFR )
						oModelIt:LoadValue('GW8_DSITEM', cDsItem )
						oModelIt:LoadValue('GW8_QTDE'  , DTC->DTC_QTDVOL )
						oModelIt:LoadValue('GW8_VALOR' , DTC->DTC_VALOR )
						oModelIt:LoadValue('GW8_VOLUME', nVolume )
						oModelIt:LoadValue('GW8_PESOR' , nPesoR )
						oModelIt:LoadValue('GW8_PESOC' , DTC->DTC_PESOM3 )
						oModelIt:LoadValue('GW8_QTDALT', DTC->DTC_PESO * DTC->DTC_QTDVOL )
						oModelIt:LoadValue('GW8_TRIBP' ,"1" )

						nContGW8++
						DTC->( dbSkip() )
					EndDo
					RestArea(aAreaDTC)

					cNota	:= (cAliasDTC)->DTC_NUMNFC + (cAliasDTC)->DTC_SERNFC
					cTransp	:= ""

					CalcTrecho(oModelTr, cEmisDc, (cAliasDTC)->DTC_NUMNFC, (cAliasDTC)->DTC_SERNFC, cTransp, @nTrecho,cA1_EstDes,cA1_CdMuDes,cTipVei,cA1_CEPDes,cCodFor,cLojFor , lPagGfe , cCdUfOri, cCdMunOri, cCepOri , cCdUfDes, cCdMunD , cSerTMS ,;
					 			cFilOri , cViagem , cFilDoc , cDoc , cSerie , nContGW1 , cCEPDes , cCDCLFR , cCDTPOP )

					If nTrecho > 1
						oModelDC:LoadValue( 'GW1_TPFRET', "2" )		  //CIF COM REDESPACHO
					EndIf
					(cAliasDTC)->(dbSkip())
				EndIf
			EndDo

		Else

			//---- Coleta
			DT5->(DbSetOrder( 4 ))
			If DT5->(MsSeek(xFilial('DT5')+ cFilDoc + cDoc + cSerie))

				cCliRem:= DT5->DT5_CLIREM
				cLojRem:= DT5->DT5_LOJREM

				If Empty(cCliRem)
					DUE->(DbSetOrder(1))
					If DUE->(dbSeek(xFilial('DUE')+DT5->DT5_CODSOL))
						cCliRem:= DUE->DUE_CODCLI
						cLojRem:= DUE->DUE_LOJCLI
					EndIf
				EndIf

				If Empty(cCliRem)
					If FindFunction( "GFEM011COD")
						cEmisDc := GFEM011COD(,,,.T.,DT5->DT5_FILORI)
					EndIf
				Else
					If lNumProp
						If FindFunction( "GFEM011COD")
							cEmisDc:= GFEM011COD(cCliRem,cLojRem,1,,)
						EndIf
					Else
						cEmisDc:= Posicione("SA1",1,xFilial("SA1")+cCliRem+cLojRem,"A1_CGC")
					EndIf
				EndIf

				cCliDes:= DT5->DT5_CLIDES
				cLojDes:= DT5->DT5_LOJDES

				If Empty(cCliDes)
					If FindFunction( "GFEM011COD")
						cDestDc := GFEM011COD(,,,.T.,DT5->DT5_FILORI)
					EndIf	

					If !Empty(DT6->DT6_CDRCAL)
						DUY->(DbSetOrder(1))
						If DUY->(MsSeek(xFilial("DUY")+DT6->DT6_CDRCAL))
							cA1_EstDes := DUY->DUY_EST
							cA1_CdMuDes:= DUY->DUY_CODMUN
						EndIf
					Else
						aAreaSM0 := SM0->(GetArea())
						cA1_CdMuDes:= NoAcentoCte(Posicione("SM0",1,cEmpAnt+DT5->DT5_FILORI,"M0_ESTENT"))
						cA1_EstDes := Substr(NoAcentoCte(Posicione("SM0",1,cEmpAnt+DT5->DT5_FILORI,"M0_CODMUN")),3)
						cA1_CEPDes := NoAcentoCte(Posicione("SM0",1,cEmpAnt+DT5->DT5_FILORI,"M0_CEPENT"))
						RestArea(aAreaSM0)
					EndIf
				Else

			      	If SA1->( dbSeek(xFilial("SA1")+cCliDes+cLojDes ) )
						If SA1->A1_TIPO == "X"
							cA1_CGC := AllTrim(SA1->A1_COD)+AllTrim(SA1->A1_LOJA)
							cA1_CGC := PadR( cA1_CGC, TamSx3("GW1_CDDEST")[1] )
						Else
							cA1_CGC := SA1->A1_CGC
						EndIf
						cA1_CdMuDes := SA1->A1_COD_MUN
						cA1_EstDes  := SA1->A1_EST
						cA1_CEPDes  := SA1->A1_CEP
					EndIf

					If lNumProp
						If FindFunction( "GFEM011COD")
							cDestDc	:= GFEM011COD(cCliDes,cLojDes,1,,)
						EndIf	
					Else
						cDestDc	:= cA1_CGC
					EndIf
				EndIf

				lRet	:= .T.
				nOpc	:= 3
				cCDTPDC	:= 'COL' //- Para coleta será fixo.

				//-- Documento de Carga
				If nContGW1 > 1
					oModelDC:AddLine(.T.)
				EndIf

				oModelDC:LoadValue("GW1_NRROM" , cViagem )
				oModelDC:LoadValue('GW1_EMISDC', cEmisDc)           //-- Codigo Do Emitente - Chave
				oModelDC:LoadValue('GW1_NRDC'  , DT5->DT5_NUMSOL  ) //-- Numero Da Nota     - Chave
				oModelDC:LoadValue('GW1_SERDC', 'COL' )
				oModelDC:LoadValue('GW1_CDTPDC', Padr(cTPDCTMS,Len(GW1->GW1_CDTPDC))) 	//-- Tipo Do Documento  - Chave
				oModelDC:LoadValue('GW1_CDREM' , cEmisDc )		//-- Remetente
				oModelDC:LoadValue('GW1_CDDEST', cDestDc )  	//-- Destinatario
				oModelDC:LoadValue("GW1_ENTNRC", "")			//-- Cidade Destino
				oModelDC:LoadValue("GW1_ENTCEP" , cA1_CEPDes)	//-- CEP Destino
				oModelDC:LoadValue('GW1_TPFRET', "1" )			//-- 1-Cif;2=Cif Redesp;3=FOB;4=FOB redesp;5=Consig;6=Consignado Redesp
				oModelDC:LoadValue('GW1_ICMSDC', "2")			//-- '2' = Mercadoria com ICMS? ( 1=Sim;2=Nao )
				oModelDC:LoadValue('GW1_USO'   , "1" )
				oModelDC:LoadValue('GW1_QTUNI' , 1 )

				//--------------------------------------------------------------------------------------------
				//---- Itens do Documentos DUM
				//--------------------------------------------------------------------------------------------
				nItemDUM	:= 0
				nContGW8	:= 1
				DUM->(dbSetOrder(1))
				If DUM->( MsSeek(xFilial("DUM") + DT5->DT5_FILORI + DT5->DT5_NUMSOL ,.F.) )
					While DUM->( !Eof() ) .And.  DUM->(DUM_FILIAL+DUM_FILORI+DUM_NUMSOL) == (xFilial("DUM") + DT5->DT5_FILORI + DT5->DT5_NUMSOL)
						If nContGW8 > 1 .Or. nContGW1 > 1
							oModelIt:AddLine()
						EndIf
						//-- Itens do Documento de Carga
						If SB5->(MsSeek( xFilial("SB5")+ DUM->DUM_CODPRO) )
							nAltura := SB5->B5_ALTURA
							nVolume := (nAltura * SB5->B5_LARG * SB5->B5_COMPR) * ( DUM->DUM_QTDVOL)
						Else
							nAltura	:= 0
							nVolume	:= 0
						EndIf

						cDsItem := SubStr(Posicione("SB1",1,xFilial("SB1")+DUM->DUM_CODPRO,"B1_DESC"),1,50)
						nPesoR  := DUM->DUM_PESO

						oModelIt:LoadValue('GW8_CDTPDC', Padr(cTPDCTMS,Len(GW1->GW1_CDTPDC)) )
						oModelIt:LoadValue('GW8_EMISDC', cEmisDc )
						oModelIt:LoadValue('GW8_SERDC' , 'COL'  )
						oModelIt:LoadValue('GW8_NRDC'  , DT5->DT5_NUMSOL)
						oModelIt:LoadValue('GW8_ITEM'  , DUM->DUM_CODPRO )
						oModelIt:LoadValue('GW8_CDCLFR', DTQ->DTQ_CDCLFR )
						oModelIt:LoadValue('GW8_DSITEM', cDsItem )
						oModelIt:LoadValue('GW8_QTDE'  , DUM->DUM_QTDVOL )
						oModelIt:LoadValue('GW8_VALOR' , DUM->DUM_VALMER )
						oModelIt:LoadValue('GW8_VOLUME', nVolume )
						oModelIt:LoadValue('GW8_PESOR' , nPesoR )
						oModelIt:LoadValue('GW8_PESOC' , DUM->DUM_PESOM3 )
						oModelIt:LoadValue('GW8_QTDALT', DUM->DUM_PESO * DUM->DUM_QTDVOL )
						oModelIt:LoadValue('GW8_TRIBP' ,"1" )

						nContGW8++
						DUM->( dbSkip() )
					EndDo

					CalcTrecho(oModelTr, cEmisDc, DT5->DT5_NUMSOL , 'COL', cTransp, @nTrecho,cA1_EstDes,cA1_CdMuDes,cTipVei,cA1_CEPDes,cCodFor,cLojFor , lPagGfe , cCdUfOri, cCdMunOri, cCepOri , cCdUfDes, cCdMunD , cSerTMS ,;
					 			cFilOri , cViagem , cFilDoc , cDoc , cSerie , nContGW1 , cCEPDes , cCDCLFR , cCDTPOP  )

					If nTrecho > 1
						oModelDC:LoadValue( 'GW1_TPFRET', "2" )		  //CIF COM REDESPACHO
					EndIf

				EndIf

			EndIf
		EndIf

		nContGW1++
		(cAliasQry)->(dbSkip())
	EndDo

	If lCalcula
		//-- Dispara a simulação
		oModelInt:SetValue("INTEGRA" ,"A")

		cLogErro	:= GFEX010Log()

		If oModelCal1:GetQtdLine() > 1 .Or. !Empty( oModelCal1:GetValue('C1_NRCALC'  ,1) )

			For nCont := 1 to oModelCal1:GetQtdLine()

				oModelCal1:GoLine( nCont )

				nVlrFrt	 		:= oModelCal1:GetValue('C1_VALFRT'  ,nCont )
				nPrevEnt  		:= oModelCal1:GetValue('C1_DTPREN'  ,nCont ) - ddatabase

				nNumCalc		:= oModelCal2:GetValue	("C2_NRCALC" 	,1 )  //"N?ero C?culo"
				nClassFret		:= oModelCal2:GetValue	("C2_CDCLFR" 	,1 )  //"Class Frete"
				nTipOper		:= oModelCal2:GetValue	("C2_CDTPOP" 	,1 )  //"Tipo Operacao"
				cTrecho			:= oModelCal2:GetValue	("C2_SEQ" 		,1 )  //"Trecho"
				cCGCTran		:= oModelCal2:GetValue	("C2_CDEMIT"	,1 )  //"Emit Tabela"
				cTabela			:= oModelCal2:GetValue	("C2_NRTAB" 	,1 )  //"Nr tabela "
				cNumNegoc		:= oModelCal2:GetValue	("C2_NRNEG" 	,1 )  //"Nr Negoc"
				cRota			:= oModelCal2:GetValue	("C2_NRROTA" 	,1 )  //"Rota"
				dDatValid		:= oModelCal2:GetValue	("C2_DTVAL" 	,1 )  //"Data Validade"
				cFaixa			:= oModelCal2:GetValue	("C2_CDFXTV" 	,1 )  //"Faixa"
				cTipoVei		:= oModelCal2:GetValue	("C2_CDTPVC" 	,1 )  //"Tipo Ve?ulo"

				SA4->(dbSetOrder(3))
		     	If SA4->(dbSeek(xFilial("SA4")+RTrim(cCGCTran)))
					aAdd (aPagarGFE , {,SA4->A4_COD,SA4->A4_NOME,nVlrFrt,nPrevEnt,nNumCalc,nClassFret,nTipOper,cTrecho,cTabela,cNumNegoc,cRota,dDatValid,cFaixa,cTipoVei,.T.})
			 	Else

					GU3->( dbSetOrder(1) )
					If GU3->( MsSeek(xFilial("GU3") + cCGCTran) )
						cCGC := GU3->GU3_IDFED
					EndIf

			 		If SA4->(dbSeek(xFilial("SA4")+rtRIM(cCGC)))
			 			AADD (aPagarGFE , {,SA4->A4_COD,SA4->A4_NOME,nVlrFrt,nPrevEnt,nNumCalc,nClassFret,nTipOper,cTrecho,cTabela,cNumNegoc,cRota,dDatValid,cFaixa,cTipoVei,.T.})
			 		Else
			 			AADD (aPagarGFE , {,cCGCTran, "" ,nVlrFrt,nPrevEnt,nNumCalc,nClassFret,nTipOper,cTrecho,cTabela,cNumNegoc,cRota,dDatValid,cFaixa,cTipoVei,.F.})
			 		EndIf
	         	EndIf
			Next nCont

		EndIf
	EndIf
EndIf

//-- Reposiciona Arquivos
For nX := 1 To Len(aArea)
	RestArea(aArea[nX])
Next nX

Return( aPagarGFE )

/*/{Protheus.doc} CalcTrecho
//TODO Função realiza o cálculo do trecho de acordo com a nota fiscal
@author caio.y
@since 28/07/2017
@version undefined
@param oModelTr, object, descricao
@param cEmisDc, characters, descricao
@param cNumNFC, characters, descricao
@param cSerNFC, characters, descricao
@param cTransp, characters, descricao
@param nTrecho, numeric, descricao
@param cA1_EstDes, characters, descricao
@param cA1_CdMuDes, characters, descricao
@param cTipVei, characters, descricao
@param cA1_CEPDes, characters, descricao
@param cCodFor, characters, descricao
@param cLojFor, characters, descricao
@param lPagGfe, logical, descricao
@param cCdUfOri, characters, descricao
@param cCdMunOri, characters, descricao
@param cCepOri, characters, descricao
@param cCdUfDes, characters, descricao
@param cCdMunD, characters, descricao
@param cSerTMS, characters, descricao
@param cFilOri, characters, descricao
@param cViagem, characters, descricao
@param cFilDoc, characters, descricao
@param cDoc, characters, descricao
@param cSerie, characters, descricao
@param nContGW1, numeric, descricao
@param cCEPDes, characters, descricao
@param cCDCLFR, characters, descricao
@param cCdTpOp, characters, descricao
@type function
/*/
Static Function CalcTrecho(oModelTr, cEmisDc, cNumNFC, cSerNFC, cTransp, nTrecho, cA1_EstDes, cA1_CdMuDes, cTipVei, cA1_CEPDes, cCodFor, cLojFor , lPagGfe , cCdUfOri, cCdMunOri, cCepOri , cCdUfDes, cCdMunD , cSerTMS , cFilOri , cViagem , cFilDoc , cDoc , cSerie , nContGW1 ,  cCEPDes , cCDCLFR , cCdTpOp  )
Local aArea			:= GetArea()
Local cSeq      	:= CriaVar('GWU_SEQ')
Local cCgcTransp	:= ""
Local lNumProp   	:= SuperGetMv("MV_EMITMP") == "1" .And. SuperGetMv("MV_INTGFE2",.F.,"2") == "1"
Local cTPDCTMS  	:= SuperGetMV("MV_TPDCTMS",,"")
Local cCdTpDc   	:= Padr(cTPDCTMS,Len(GW1->GW1_CDTPDC))

Default cCEPDes		:= ""
Default cCDCLFR		:= ""
Default cCdTpOp		:= ""

If Empty(cTransp)
	SA2->( dbSetOrder(1) )
	If SA2->( dbSeek( xFilial("SA2")+cCodFor+cLojFor ))
		If !lNumProp
			cCgcTransp := IIF(SA2->A2_TIPO <> 'X',SA2->A2_CGC,AllTrim(SA2->A2_COD)+AllTrim(SA2->A2_LOJA) )
		Else
			If FindFunction( "GFEM011COD")
				cCgcTransp := GFEM011COD(SA2->A2_COD,SA2->A2_LOJA,2,,)
			EndIf	
		EndIf
	EndIf
Else
	If lNumProp
		cCgcTransp := Posicione("GU3",13,xFilial("GU3")+cTransp,"GU3_CDEMIT")
	Else
		cCgcTransp := Posicione("SA4",1,xFilial("SA4")+cTransp,"A4_CGC")
	EndIf
EndIf

//--- Redespachos da Viagem
If (cSerTMS $ '1|3')
	CalcRedesp(oModelTr,nTrecho,@cSeq,lNumProp,cA1_CEPDes,cCdTpDc , cFilOri , cViagem , cFilDoc , cDoc , cSerie , cEmisDc , cNumNFC,  cSerNFC , nContGW1 , lPagGfe , cCgcTransp , cTipVei, cCdUfDes , cCdMunD , cCEPDes , cCDCLFR , cCdTpOp , cCdUfOri, cCdMunOri, cCepOri   )
EndIf

nTrecho:= Val(AllTrim(cSeq))
RestArea(aArea)
Return

/*/{Protheus.doc} CalcRedesp
//Efetua o cálculo da tabela de redespacho DJN
@author caio.y
@since 28/07/2017
@version undefined
@param oModelTr, object, descricao
@param nTrecho, numeric, descricao
@param cSeq, characters, descricao
@param lNumProp, logical, descricao
@param cA1_CEPDes, characters, descricao
@param cCdTpDc, characters, descricao
@param cFilOri, characters, descricao
@param cViagem, characters, descricao
@param cFilDoc, characters, descricao
@param cDoc, characters, descricao
@param cSerie, characters, descricao
@param cEmisDc, characters, descricao
@param cNumNFC, characters, descricao
@param cSerNFC, characters, descricao
@param nContGW1, numeric, descricao
@type function
/*/
Static Function CalcRedesp( oModelTr, nTrecho, cSeq, lNumProp, cA1_CEPDes, cCdTpDc , cFilOri , cViagem , cFilDoc , cDoc , cSerie , cEmisDc , cNumNFC,  cSerNFC , nContGW1 , lPagGfe , cCgcTransp , cTipVei , cUfDes , cCdMunDes , cCEPDes , cCDCLFR , cCdTpOp , cCdUfOri, cCdMunOri, cCepOri  )
Local aArea			:= GetArea()
Local cAliasDJN 	:= GetNextAlias()
Local cQuery    	:= ""
Local nContGWU		:= 1

Default oModelTr 	:= Nil
Default nTrecho     := 0
Default lNumProp    := .F.
Default cSeq        := CriaVar('GWU_SEQ')
Default cA1_CEPDes	:= ""
Default cCdTpDc		:= ""
Default cFilOri		:= ""
Default cViagem		:= ""
Default cFilDoc		:= ""
Default cDoc		:= ""
Default cSerie		:= ""
Default lPagGfe		:= .F.
Default cCgcTransp	:= ""
Default cTipVei		:= ""
Default cUfDes		:= ""
Default cCdMunDes	:= ""
Default cCEPDes 	:= ""
Default cCDCLFR 	:= ""
Default cCdTpOp  	:= ""
Default cCdUfOri	:= ""
Default	cCdMunOri	:= ""
Default cCepOri		:= ""

If lPagGfe
	//--- Inclusao do Trecho adicional do Redespacho da Viagem (DJN)
	cSeq	:= Soma1(cSeq)
	nTrecho	:= Val(AllTrim(cSeq))

	If nContGW1 > 1  .Or. nContGWU > 1
		oModelTr:AddLine()
	EndIf

	oModelTr:LoadValue('GWU_CDTPDC'	, cCdTpDc 	)
	oModelTr:LoadValue('GWU_EMISDC' , cEmisDc 	)
	oModelTr:LoadValue('GWU_SEQ'   	, "01" 		)
	oModelTr:LoadValue('GWU_SERDC' 	, cSerNFC 	)
	oModelTr:LoadValue('GWU_NRDC'  	, cNumNFC 	)
	oModelTr:LoadValue('GWU_CDTRP' 	, cCgcTransp  )
	oModelTr:LoadValue('GWU_NRCIDD'	, TMS120CDUF( cUfDes , "1") + cCdMunDes  )
	oModelTr:LoadValue('GWU_UFD'   	, cUfDes )
	oModelTr:LoadValue('GWU_CDTPVC' , cTipVei )
	oModelTr:LoadValue('GWU_NRCIDO' , TMS120CDUF( cCdUfOri  , "1") + cCdMunOri )
	oModelTr:LoadValue('GWU_CEPO' 	, cCEPOri )
	oModelTr:LoadValue('GWU_CEPD' 	, cCEPDes )
	oModelTr:LoadValue('GWU_CDCLFR' , cCDCLFR )
	oModelTr:LoadValue('GWU_CDTPOP' , cCdTpOp )

	nContGWU++
EndIf

cQuery := " SELECT * FROM " + RetSqlName("DJN") + " DJN "
cQuery += "  WHERE DJN_FILIAL  	= '"+ xFilial("DJN")+"' "
cQuery += "    AND DJN_FILORI  	= '" + cFilOri + "' "
cQuery += "    AND DJN_VIAGEM  	= '" + cViagem + "' "
cQuery += "    AND DJN_FILDOC  	= '" + cFilDoc + "' "
cQuery += "    AND DJN_DOC 		= '" + cDoc + "' "
cQuery += "    AND DJN_SERIE	= '" + cSerie + "' "
cQuery += "    AND DJN.D_E_L_E_T_ = ' ' "
cQuery += "   ORDER BY DJN_FILORI, DJN_VIAGEM, DJN_FILDOC, DJN_DOC, DJN_SERIE, DJN_SEQRDP "
cQuery    := ChangeQuery(cQuery)

DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDJN,.T.,.T.)

SA2->( dbSetOrder(1) )
While (cAliasDJN)->(!Eof())

	If SA2->( dbSeek( xFilial("SA2")+(cAliasDJN)->DJN_CODFOR+(cAliasDJN)->DJN_LOJFOR) )

		//--- Inclusao do Trecho adicional do Redespacho da Viagem (DJN)
		cSeq	:= Soma1(cSeq)
		nTrecho	:= Val(AllTrim(cSeq))
		cCepDes	:= Iif( Empty( (cAliasDJN)->DJN_CEPDES) , cA1_CEPDes ,  (cAliasDJN)->DJN_CEPDES )

		If Empty(SA2->A2_TRANSP)
			If !lNumProp
				cCgcTransp := IIF(SA2->A2_TIPO <> 'X',SA2->A2_CGC,AllTrim(SA2->A2_COD)+AllTrim(SA2->A2_LOJA) )
			Else
				If FindFunction( "GFEM011COD")
					cCgcTransp := GFEM011COD(SA2->A2_COD,SA2->A2_LOJA,2,,)
				EndIf
			EndIf
		Else
			If lNumProp
				cCgcTransp := Posicione("GU3",13,xFilial("GU3")+SA2->A2_TRANSP,"GU3_CDEMIT")
			Else
				cCgcTransp := Posicione("SA4",1,xFilial("SA4")+SA2->A2_TRANSP,"A4_CGC")
			EndIf
		EndIf

		If nContGW1 > 1  .Or. nContGWU > 1
			oModelTr:AddLine()
		EndIf

		oModelTr:LoadValue('GWU_CDTPDC'	, cCdTpDc 	)
		oModelTr:LoadValue('GWU_EMISDC' , cEmisDc 	)
		oModelTr:LoadValue('GWU_SEQ'   	, cSeq 		)
		oModelTr:LoadValue('GWU_SERDC' 	, cSerNFC 	)
		oModelTr:LoadValue('GWU_NRDC'  	, cNumNFC 	)
		oModelTr:LoadValue('GWU_CDTRP' 	, cCgcTransp  )
		oModelTr:LoadValue('GWU_NRCIDD'	, TMS120CDUF((cAliasDJN)->DJN_UFDES, "1") + (cAliasDJN)->DJN_CDMUND )
		oModelTr:LoadValue('GWU_UFD'   	, (cAliasDJN)->DJN_UFDES )
		oModelTr:LoadValue('GWU_CDTPVC' , (cAliasDJN)->DJN_TIPVEI )
		oModelTr:LoadValue('GWU_NRCIDO' , TMS120CDUF( (cAliasDJN)->DJN_UFORI , "1") + (cAliasDJN)->DJN_CDMUNO )
		oModelTr:LoadValue('GWU_CEPO' 	, (cAliasDJN)->DJN_CEPORI )
		oModelTr:LoadValue('GWU_CEPD' 	, (cAliasDJN)->DJN_CEPDES )
		oModelTr:LoadValue('GWU_CDCLFR' , (cAliasDJN)->DJN_CDCLFR )
		oModelTr:LoadValue('GWU_CDTPOP' , (cAliasDJN)->DJN_CDTPOP )

		nContGWU++
	EndIf

	(cAliasDJN)->(DbSkip())
EndDo
(cAliasDJN)->( dbCloseArea() )

RestArea(aArea)
Return



/*/{Protheus.doc} TMSSqlToTemp
//Inclusão de tabela temporária
@author caio.y
@since 09/08/2017
@version undefined
@param cQueryAux, characters, Query contendo o Select
@param aEstruExp, array, Estrutura dos campos
@param cRealName, characters, Nome real da tabela temporária
@param lExibErr, logical, Indica se exibirá mensagem de erro
@type function
/*/
Function TMSSqlToTemp(cQueryAux, aEstruExp, cRealName , lExibErr  )
Local lRet		:= .T.
Local cQuery	:= ""
Local nI		:= 1

Default cQueryAux	:= ""
Default aEstruExp	:= {}
Default cRealName	:= ""
Default lExibErr	:= .F.

cQuery := "INSERT INTO " + cRealName + " ( "
For nI := 1 To Len( aEstruExp )
	If nI > 1
		cQuery += ", "
	EndIf
	cQuery += aEstruExp[ nI, 1 ]
Next

cQuery += " ) " + cQueryAux

If TCSqlExec( cQuery ) <> 0
	lRet	:= .F.
	If lExibErr
		Help('',1,'TMSXFUND08',,TCSQLError() ) //-- Erro ao incluir tabela temporária
	EndIf
EndIf

Return lRet

//---------------------------------------------------
/*/{Protheus.doc} TMSCODUNQ
Função que verifica o controle do codigo unico
@author	Katia
@version	1.0
@since		12/07/2017
@sample    Esta função tem por objetivo verificar a
o controle do codigo unico do DATASUL
/*/
//----------------------------------------------------
Function TMSCODUNQ()
Local lRet	:= Iif(FindFunction("FwAdapterInfo"),Iif(Len( FwAdapterInfo("MATA020B","CUSTOMERVENDORRESERVEID") ) , .T. , .F. ),.F.)

Return lRet

//---------------------------------------------------
/*/{Protheus.doc} TMSCALROM
Função que chama o calculo do Romaneio no GFE
@author	Katia
@version	1.0
@since		12/07/2017
@sample    Esta função tem por objetivo executar o calculo
do frete do GFE quando há alteração no Romaneio com
a inclusao de um novo trecho
/*/
//----------------------------------------------------

Function TMSCALROM(aCalcRom,aErrGFE)

Local nCount     := 0
Local cMsgErro   := ""
Local aRetCalc   := {}
Local lRomOK     := .F.
Local nCountOk   := 0
Local nY			:= 0
Local aErr       := {}
Local aArea 	   := GetArea()
Local lCalcGFE   := .F.

Default aCalcRom  := {}
Default aErrGFE   := {}

For nCount:= 1 To Len(aCalcRom)
	//Somente chama o recalculo se o Romaneio já estiver sido calculado
	DbSelectArea("GWN")
	GWN->(dbSetOrder(1))
	If GWN->(dbSeek(aCalcRom[nCount]))
		lCalcGFE := .T.
		cMsgErro := ""
		aRetCalc := {}
		lRomOk := GFE050CALC(,.F.,@cMsgErro,aRetCalc)

		If lRomOk
			nCountOk++
		Else
			If Len(aRetCalc) > 0 //Falha dentro do cálculo do frete.

				aErr:=GFECalcErr(aRetCalc[3][1][2])
		 		For nY:= 1 to Len(aRetCalc[3][1][4])
					aErr[1] := StrTran(aErr[1],"[" + cValToChar(nY) + "]",aRetCalc[3][1][4][nY])
				Next

				aAdd(aErrGFE, {'Romaneio: ' + GWN->GWN_FILIAL + ' / ' +  GWN->GWN_NRROM + ' : ' +  aErr[1] + ' - ' +  aRetCalc[2]})

			Else
				aAdd(aErrGFE, {'Romaneio: ' + GWN->GWN_FILIAL + ' / ' + GWN->GWN_NRROM + ' : ' + cMsgErro }) // Falha de pré-validação
			EndIf
		EndIf
	EndIf
Next nCount

If lCalcGFE
	If nCountOk == 0
		aAdd(aErrGFE, {"Nenhum Romaneio calculado com sucesso."})
	EndIf
Else
	lRomOK:= .T.
EndIf

//--- Limpa Variavel
aSize(aErr,0)

RestArea(aArea)
Return lRomOK

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSCHVDUD
Função que verifica se o Documento foi integrado ao GFE

@class
@author	Katia
@version	1.0
@since		01/06/2017
@return
@Param		oDlgOco: Objeto da janela
@sample

/*/
//-------------------------------------------------------------------
Function TMSChvDUD(cFilDoc,cDoc,cSerie)

Local lRet        := .F.
Local aAreaAnt    := GetArea()
Local cAliasQryD  := GetNextAlias()
Local cQueryDUD   := ""

Default cFilDoc  := ""
Default cDoc     := ""
Default cSerie   := ""

cQueryDUD := " SELECT (MAX(R_E_C_N_O_)) R_E_C_N_O_"
cQueryDUD += " FROM " + RetSqlName("DUD")  + " DUD "
cQueryDUD += " WHERE DUD_FILIAL = '" + xFilial("DUD") + "'"
cQueryDUD += "   AND DUD_FILDOC = '" + cFilDoc + "'"
cQueryDUD += "   AND DUD_DOC    = '" + cDoc + "'"
cQueryDUD += "   AND DUD_SERIE  = '" + cSerie + "'"
cQueryDUD += "   AND DUD_CHVEXT <> '' "
cQueryDUD += "   AND DUD.D_E_L_E_T_ = '' "
cQueryDUD := ChangeQuery(cQueryDUD)
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryDUD), cAliasQryD, .F., .T. )
If (cAliasQryD)->(!Eof()) .And. (cAliasQryD)->R_E_C_N_O_ > 0
	lRet:= .T.
EndIf
(cAliasQryD)->( DbCloseArea() )

RestArea(aAreaAnt)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TmsVerAVB ºAutor Marlon Heiber       º Data ³  23/11/17     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função para exibir no browser o texto de status de         º±±
±±º          ³ averbação conforme DL5_STATUS.                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TmsVerAVB()
Local cSitAbv := ""

If FWAliasInDic("DL5",.F.)
	Posicione("DL5",1,XFILIAL("DL5")+DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE,"DL5->DL5_STATUS")
	cSitAbv := ""
	Do Case
		Case DL5->DL5_STATUS == "0"
			cSitAbv := "0 - Aguardando Averbação"
		Case DL5->DL5_STATUS == "1"
			cSitAbv := "1 - Falha Comunicação c/ WebService"
		Case DL5->DL5_STATUS == "2"
			cSitAbv := "2 - Averbado"
		Case DL5->DL5_STATUS == "3"
			cSitAbv := "3 - Recusado"
		Case DL5->DL5_STATUS == "4"
			cSitAbv := "4 - Aguardando Cancelamento Averbação"
		Case DL5->DL5_STATUS == "5"
			cSitAbv := "5 - Falha Comunic. Cancelamento Averb."
		Case DL5->DL5_STATUS == "6"
			cSitAbv := "6 - Averbação Cancelada"
		Case DL5->DL5_STATUS == "7"
			cSitAbv := "7 - Cancelamento da Averbação Recusado"
		Case DL5->DL5_STATUS == "8"
			cSitAbv := "8 - Doc. Cancelado Antes da Averbação"
	EndCase
EndIf
Return cSitAbv

/*----------------------------------------------------------------------------
TMSLogMsg

@author  Wander Horongoso
@since   19/02/2018
@version 1.0

Objetivo: padronizar a geração de mensagens no console (antigo Conout).

Entrada:
cLevel: indica o tipo de mensagem. Valores aceitos: "INFO", "WARN", "ERROR", "FATAL", "DEBUG";
cMsg: conteúdo da mensagem.

----------------------------------------------------------------------------*/
Function TMSLogMsg(cLevel, cMsg)
Default cLevel := "INFO"
Default cMsg := ""

	cLevel := PadR(Upper(cLevel), 7)
    FWLogMsg(cLevel, "LAST", "SIGATMS", ProcName(2), , "01", cMsg, , ,{}, 2)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSVlBxCan ºAutor Felipe Barbiere      º Data ³  27/09/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função para Validar Cancelamento de Baixa a receber        º±±
±±º          ³ Chamada pela função fa070can (FINA070.PRX)                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSVlBxCan()
Local lRet := .F.

CheckHLP('PTMSXFUND09', {'Esse título foi gerado pelo SIGATMS',' e a Fatura se encontra cancelada.',' Não poderá sofrer exclusão.'},{''},{''},.T.)

If Upper(Alltrim(SE1->E1_ORIGEM)) $ "TMSA850/TMSA491" .And. SE1->E1_SITFAT == '3'
	HELP(" ",1,"TMSXFUND09") //Esse título foi gerado pelo SIGATMS e a Fatura se encontra cancelada. Não poderá sofrer exclusão.
	lRet := .T.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSAltSE1 ºAutor Felipe Barbiere      º Data ³  28/09/18    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função para Validar Cancelamento de Baixa a receber        º±±
±±º          ³ Chamada pela função FA040Alter (FINA040.PRX)               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSAltSE1()
Local lRet    := .F.
Local lDif 	  := .F.
Local aCampos := {"E1_VALOR", "E1_IRRF", "E1_ISS", "E1_MOEDA", "E1_INSS", "E1_CSLL", ;
				  "E1_COFINS", "E1_PIS", "E1_TXMOEDA", "E1_CODRET" }				  
Local cOrigem := Upper(Alltrim(SE1->E1_ORIGEM))

CheckHLP('PTMSXFUND10', {'Esse título foi gerado pelo SIGATMS.',' Não poderá sofrer alteração.',''},{''},{''},.T.)
If cOrigem == "TMSA850" .Or. cOrigem == "TMSA491" 
	aEval(aCampos, { |cCampo| lDif := lDif .Or. (&("SE1->" + cCampo) != &("M->" + cCampo) )} )
	If lDif
		HELP(" ",1,"TMSXFUND10") //Esse título foi gerado pelo SIGATMS. Não poderá sofrer alteração.
		lRet := .T.
	EndIf
EndIf

Return lRet

/*----------------------------------------------------------------------------
TMSIDRESP

@author  Katia
@since   02/10/2018
@version 1.0

Objetivo: Identificação do Responsavel Tecnico pelo sistema utilizado na emissão
do documento fiscal eletronico (CT-e e MDF-e)
----------------------------------------------------------------------------*/
Function TMSIdResp()
Local cIdResp:= ""

cIdResp += "<infRespTec>" 
cIdResp += 		"<CNPJ>53113791000122</CNPJ>"     					//CNPJ da pessoa juridica desenvolvedora do sistema
cIdResp += 		"<xContato>Hugo Luiz Do Nascimento Silva</xContato>" //Nome da pessoa a ser contatada na empresa desenvolvedora do sistema
cIdResp += 		"<email>hugo.nascimento@totvs.com.br</email>"    	//E-mail para Contato
cIdResp += 		"<fone>01120997067</fone>"							//DDD+Numero
cIdResp += "</infRespTec>"

Return cIdResp



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSVldCar  ºAutor Felipe Barbiere      º Data ³  09/10/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função para Validar carregamento com manifesto na viagem   º±±
±±º          ³ quando MV_MDFEAUT está ativo                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSVldCar(cCampo, nOpcao)
Local lMDFeAut := GetMV("MV_MDFEAUT",,.F.) .And. ExistFunc("TmsMDFeAut")
Local lRet     := .T.

Default cCampo := ""
Default nOpcao := 0

CheckHLP('PTMSXFUND10', {'Não é permitido carregamento com manif.',' quando MV_MDFEAUT (MDF-e Automático) ',' estiver habilitado.'},{''},{''},.T.)

If lMDFeAut .And. cCampo $ "TMSA141A02/TMA141002/TMA14401" .And. (nOpcao == 3 .Or. nOpcao == 4)
	HELP(" ",1,"TMSXFUND10") //Não é permitido carregamento com manif. quando MV_MDFEAUT (MDF-e Automático) estiver habilitado.
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSVldMotP
//Verifica se motorista esta sendo utilizado em uma outra viagem ou planejamento para o mesmo periodo informado.
@author  ruan.salvador
@since   22/10/2018
@param cPlan,   characters, Código do Planejamento
@param cViagem, characters, Código da Viagem
@param cCodMot, characters, Código do Motorista
@param aPlanej, array, [1]Data ini [2]Hora ini [3]Data fim [4]Hora fim
/*/
//-------------------------------------------------------------------
Function TMSVldMotP(cPlan, cViagem, cCodMot, aPlanej, cViagInt)
	Local cAliasQry  := GetNextAlias()
	Local cQuery     := ''
	Local cNumVge    := ''
	Local cNumPln    := '' 
	Local cPeriodIni := DtoS( aPlanej[1]) + aPlanej[2]
	Local cPeriodFim := DtoS( aPlanej[3]) + aPlanej[4] 
	Local cOcorCan   := SuperGetMv('MV_OCORCAN',,'') //-- Ocorrencia de Cancelamento p/ Viagem de Coleta Planejada em aberto
	Local lMVTMSAloc := SuperGetMv("MV_TMSALOC",.F.,.T.)
	Local lMVITMSDMD := SuperGetMv("MV_ITMSDMD",.F.,.F.)
	Local lTmsExp    := TmsExp() .And. Substr(FunName(),1,7) == "TMSA144"
	Local lRet       := .T.
	Local lAchou     := .F.
	
	Default cViagem  := ''
	Default cViagInt:= M->DTR_NUMVGE   //Tratamento devido a Viagem Modelo 3 (DM4)

	If lMVTMSAloc .AND. !Empty(cCodMot)
		
		cQuery := " SELECT DUP.DUP_FILORI, DUP.DUP_VIAGEM, DTR_DATINI, DTR_HORINI, DTR_DATFIM, DTR_HORFIM "	
		cQuery += "   FROM " + RetSQLTab('DUP') 
		cQuery += "        INNER JOIN " + RetSQLTab('DTR') 
		cQuery += "	          ON DTR.DTR_FILIAL = '" + xFilial('DTR') + "'"
		cQuery += "		     AND DTR.DTR_FILORI = DUP.DUP_FILORI "
		cQuery += "		     AND DTR.DTR_VIAGEM = DUP.DUP_VIAGEM "
		If !Empty(cViagem)
			cQuery += "	     AND DTR.DTR_NUMVGE <> '" + cViagem + "'"
			cQuery += "	     AND DTR.DTR_VIAGEM <> '" + cViagem + "'"
		EndIf
		cQuery += "		     AND DTR.D_E_L_E_T_ = ' ' "
		cQuery += "		   INNER JOIN " + RetSQLTab('DTQ')
		cQuery += "	          ON DTQ.DTQ_FILIAL = '" + xFilial('DTQ') + "'"
		cQuery += "		     AND DTQ.DTQ_FILORI = DUP.DUP_FILORI "
		cQuery += "		     AND DTQ.DTQ_VIAGEM = DUP.DUP_VIAGEM "
		cQuery += "		     AND DTQ.DTQ_STATUS NOT IN ('3', '9')  " //Encerrada //Cancelada
		If lTmsExp .And. !Empty( cOcorCan ) 
			cQuery += "      AND DTQ.DTQ_TIPVIA <> '3' "
			cQuery += "      AND DTQ.DTQ_SERTMS <> '1' "
		EndIf
		cQuery += "		     AND DTQ.D_E_L_E_T_ = ' ' "
		cQuery += "  WHERE DUP.DUP_FILIAL = '" + xFilial('DUP') + "'" 
		cQuery += "    AND DUP.DUP_CODMOT = '" + cCodMot + "' "
		If !Empty(cViagem)
			cQuery += "AND DUP.DUP_VIAGEM <> '" + cViagem + "'"
		EndIf
		cQuery += "    AND DUP.D_E_L_E_T_ = ' ' "
		// Valida se existe viagem conflitante com data e hora
		cQuery += "    AND (('" + DtoS( aPlanej[1] ) + "' BETWEEN DTR.DTR_DATINI AND DTR.DTR_DATFIM ) "        
		cQuery += "     OR	('" + Dtos( aPlanej[3] ) + "' BETWEEN DTR.DTR_DATINI AND DTR.DTR_DATFIM ) "
		cQuery += "		OR ((DTR.DTR_DATINI BETWEEN '" + DtoS( aPlanej[1] ) + "' AND '" + Dtos( aPlanej[3] ) + "') "
		cQuery += "	    OR  (DTR.DTR_DATFIM BETWEEN '" + DtoS( aPlanej[1] ) + "' AND '" + Dtos( aPlanej[3] ) + "')))"
		// Mantido validação da função original aMotPlanej
		cQuery += "     AND NOT EXISTS (SELECT DF7_FILORI,DF7_VIAGEM "
		cQuery += "                       FROM " + RetSQLTab('DF7')
		cQuery += "                      WHERE DF7.DF7_FILIAL = '" + xFilial('DF7') + "'"
		cQuery += "                        AND ((DF7.DF7_FILORI = DUP.DUP_FILORI AND DF7.DF7_VIAGEM = DUP.DUP_VIAGEM)  "
		cQuery += "                         OR  (DF7.DF7_FILDTR = DUP.DUP_FILORI AND DF7.DF7_VGEDTR = DUP.DUP_VIAGEM)) "
		cQuery += "                        AND DF7.D_E_L_E_T_  = ' ') "
	
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)

		While !(cAliasQry)->(EoF()) .And. lRet
			
			If (cAliasQry)->DUP_VIAGEM != cViagInt
				If cPeriodIni >= (cAliasQry)->(DTR_DATINI + DTR_HORINI) .And. cPeriodIni <= (cAliasQry)->(DTR_DATFIM + DTR_HORFIM)
					lAchou := .T.	
				ElseIf 	cPeriodFim >= (cAliasQry)->(DTR_DATINI + DTR_HORINI) .And. cPeriodFim <= (cAliasQry)->(DTR_DATFIM + DTR_HORFIM)
					lAchou := .T.					
				ElseIf (cAliasQry)->(DTR_DATINI + DTR_HORINI) >= cPeriodIni .And. (cAliasQry)->(DTR_DATINI + DTR_HORINI) <= cPeriodFim
					lAchou := .T.					
				ElseIf (cAliasQry)->(DTR_DATFIM + DTR_HORFIM) >= cPeriodIni .And. (cAliasQry)->(DTR_DATFIM + DTR_HORFIM) <= cPeriodFim
					lAchou := .T.	
				EndIf
			
				cNumVge := (cAliasQry)->(DUP_FILORI + '/' + DUP_VIAGEM)
			EndIf
			
			If lAchou 
				If !Empty(cViagem)
					If (Empty((cAliasQry)->(DTR_DATINI)) .Or. Empty((cAliasQry)->(DTR_HORINI)) .Or. Empty((cAliasQry)->(DTR_DATFIM)) .Or. Empty((cAliasQry)->(DTR_HORFIM)))
						Help(" ",1,"HELP",, STR0060 + cCodMot + STR0061 + cNumVge + ".", 3, 00) //"O motorista: cCodMot está sendo utilizado na viagem: cNumVge
						lRet := .F.
					Else
						Help(" ",1,"HELP",, STR0060 + cCodMot + STR0061 + cNumVge + ;
											STR0064 + DToC(sTod((cAliasQry)->(DTR_DATINI))) + " " + SubStr((cAliasQry)->(DTR_HORINI), 1, 2 ) + ":" + SubStr((cAliasQry)->(DTR_HORINI), 3, 2 ) + ;
											STR0065 + DToC(sTod((cAliasQry)->(DTR_DATFIM))) + " " + SubStr((cAliasQry)->(DTR_HORFIM), 1, 2 ) + ":" + SubStr((cAliasQry)->(DTR_HORFIM), 3, 2 ) ;
											, 3, 00)
						lRet := .F.
					EndIf
					Exit
				Else
					If (Empty((cAliasQry)->(DTR_DATINI)) .Or. Empty((cAliasQry)->(DTR_HORINI)) .Or. Empty((cAliasQry)->(DTR_DATFIM)) .Or. Empty((cAliasQry)->(DTR_HORFIM)))
						If !MsgYesNo( STR0060 + cCodMot + STR0061 + cNumVge + STR0063, "HELP" )
							Help(" ",1,"HELP",, STR0072, 3, 00) // Operação cancelada pelo usuário.
							lRet := .F.
						EndIf
					Else
						If !MsgYesNo(STR0060 + cCodMot + STR0061 + cNumVge + ;
											STR0064 + DToC(sTod((cAliasQry)->(DTR_DATINI))) + " " + SubStr((cAliasQry)->(DTR_HORINI), 1, 2 ) + ":" + SubStr((cAliasQry)->(DTR_HORINI), 3, 2 ) + ;
											STR0065 + DToC(sTod((cAliasQry)->(DTR_DATFIM))) + " " + SubStr((cAliasQry)->(DTR_HORFIM), 1, 2 ) + ":" + SubStr((cAliasQry)->(DTR_HORFIM), 3, 2 ) + ;
											STR0063, "HELP")
							Help(" ",1,"HELP",, STR0072, 3, 00) // Operação cancelada pelo usuário.
							lRet := .F.
						EndIf
					EndIf
					Exit
				EndIf
			EndIf
			(cAliasQry)->(DbSkip())
		EndDo
		
		(cAliasQry)->(DbCloseArea())
		lAchou	:= .F.   
		
		If AliasInDic('DL9') .AND. lRet .And. lMVITMSDMD .And. ProcName(3) != "TMSA240MNT"
			cAliasQry  := GetNextAlias()
			cQuery := " SELECT DL9.DL9_COD, DL9.DL9_DATINI, DL9.DL9_HORINI, DL9.DL9_DATFIM, DL9.DL9_HORFIM "
			cQuery += " FROM " + RetSQLTab('DL9')
			cQuery += " WHERE DL9.DL9_FILIAL = '" + xFilial('DL9') + "'" 
			If !Empty(cPlan)
				cQuery += "   AND DL9.DL9_COD <> '" + cPlan + "' " 
			EndIf
			cQuery += "   AND DL9.DL9_CODMOT = '" + cCodMot + "' "
			cQuery += "   AND DL9.DL9_STATUS NOT IN ('4', '5', '9')  " //Encerrado //Recusado //Cancelado
			cQuery += "   AND (('" + DtoS( aPlanej[1] ) + "' BETWEEN DL9.DL9_DATINI AND DL9.DL9_DATFIM )  "        
			cQuery += "    OR  ('" + Dtos( aPlanej[3] ) + "' BETWEEN DL9.DL9_DATINI AND DL9.DL9_DATFIM )  "
			cQuery += "    OR  ((DL9.DL9_DATINI BETWEEN '" + DtoS( aPlanej[1] ) + "' AND '" + Dtos( aPlanej[3] ) + "') "
			cQuery += "    OR   (DL9.DL9_DATFIM BETWEEN '" + DtoS( aPlanej[1] ) + "' AND '" + Dtos( aPlanej[3] ) + "'))) "
			cQuery += "   AND DL9.DL9_COD NOT IN ( SELECT DF8.DF8_PLNDMD "
			cQuery += "   	FROM " + RetSQLTab('DF8')
			cQuery += "   	WHERE DF8.DF8_FILIAL = '" + xFilial('DF8') + "'" 
			If IsInCallStack('TMSA146')
				cQuery += "        AND DF8.DF8_NUMPRG = '" + DF8->DF8_NUMPRG + "'"
			ElseIf !Empty(cViagem)
				cQuery += "        AND DF8.DF8_VIAGEM = '" + cViagem + "'"
			EndIf
			cQuery += "            AND DF8.DF8_STATUS <> '9' AND DF8.D_E_L_E_T_ = ' ') "
			cQuery += "   AND DL9.D_E_L_E_T_ = ' ' "
			
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)
	
			While !(cAliasQry)->(EoF()) .And. lRet    
			
				If (cPeriodIni >= (cAliasQry)->(DL9_DATINI + DL9_HORINI) .AND. cPeriodIni <= (cAliasQry)->(DL9_DATFIM + DL9_HORFIM))
					lAchou := .T.				
				ElseIf 	( cPeriodFim >= (cAliasQry)->(DL9_DATINI + DL9_HORINI) .AND. cPeriodFim <= (cAliasQry)->(DL9_DATFIM + DL9_HORFIM))
					lAchou := .T.
				ElseIf ( (cAliasQry)->(DL9_DATINI + DL9_HORINI) >= cPeriodIni .AND. (cAliasQry)->(DL9_DATINI + DL9_HORINI) <= cPeriodFim)
					lAchou := .T.
				ElseIf ( (cAliasQry)->(DL9_DATFIM + DL9_HORFIM) >= cPeriodIni .AND. (cAliasQry)->(DL9_DATFIM + DL9_HORFIM) <= cPeriodFim)
					lAchou := .T.
				EndIf
			     
			    If lAchou 
					cNumPln := (cAliasQry)->(DL9_COD)
					If (Empty((cAliasQry)->(DL9_DATINI)) .Or. Empty((cAliasQry)->(DL9_HORINI)) .Or. Empty((cAliasQry)->(DL9_DATFIM)) .Or. Empty((cAliasQry)->(DL9_HORFIM)))
						If !MsgYesNo( STR0060 + cCodMot + STR0062 + cNumPln + STR0063, "HELP" )  //"O motorista: cCodMot está sendo utilizado no planejamento de demanda: cNumPln
							Help(" ",1,"HELP",, STR0072, 3, 00) // Operação cancelada pelo usuário.
							lRet := .F.
						EndIf
						Exit
					Else
						If !MsgYesNo( STR0060 + cCodMot + STR0062 + cNumPln +;
						              STR0064 + DToC(sTod((cAliasQry)->(DL9_DATINI))) + " " + SubStr((cAliasQry)->(DL9_HORINI), 1, 2 ) + ":" + SubStr((cAliasQry)->(DL9_HORINI), 3, 2 ) + ;
						              STR0065 + DToC(sTod((cAliasQry)->(DL9_DATFIM))) + " " + SubStr((cAliasQry)->(DL9_HORFIM), 1, 2 ) + ":" + SubStr((cAliasQry)->(DL9_HORFIM), 3, 2 ) + ;
	                                  STR0063, "HELP" ) 			           
							Help(" ",1,"HELP",, STR0072, 3, 00) // Operação cancelada pelo usuário.			           
							lRet := .F.
						EndIf
						Exit
					EndIf
				EndIf
				(cAliasQry)->(DbSkip())
			EndDo
			(cAliasQry)->(DbCloseArea())
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSVldVei
Valida se o veículo já está alocado para outro planejamento, programação ou viagem no mesmo período
@author  Gustavo Krug
@since   21/11/2018
@version 12.1.17
@param1 aVeic 	-> array	 -> Código do veículo e reboques.
@param2 cPlanej -> character -> Código do planejamento.
@param3 cProgram-> character -> Código da programação.
@param4 cViag 	-> character -> Código da viagem.
@param5 dDtIni 	-> date 	 -> Data inicial.
@param6 cHrIni 	-> character -> Hora inicial.
@param7 dDtFim 	-> date 	 -> Data final.
@param8 cHrFim 	-> character -> Hora final.
@param9 aVeic 	-> array 	 -> Código do veículo e reboques.
/*/
//-------------------------------------------------------------------
Function TMSVldVei( cPlanej, cProgram, cViag, dDtIni, cHrIni, dDtFim, cHrFim, aVeic, cViagInt )
	Local lRet		:= .T.
	Local lMVTMSAloc:= GetMv("MV_TMSALOC",.F.,.T.)
	Local lMVITMSDMD:= GetMv("MV_ITMSDMD",.F.,.T.)
	Local lAchou 	:= .F.	
	Local cQuery	:= ''
	Local cVeiErro	:= ''
 	Local cAliasQry	:= ''
	Local cNumVge	:= ''
	Local cNumPrg	:= ''
	Local cPlnPrg	:= '' //Planejamento encontrado em programação
	Local cPlnVge	:= '' //Planejamento encontrado em viagem
	Local cCodVei	:= AllTrim( aVeic[1] )
	Local cCodRB1	:= IIF(Len(aVeic) >= 2, AllTrim( aVeic[2] ), '' )  
	Local cCodRB2	:= IIF(Len(aVeic) >= 3, AllTrim( aVeic[3] ), '' )  
	Local cCodRB3	:= IIF(Len(aVeic) >= 4, AllTrim( aVeic[4] ), '' )  
	Local cReboques	:= ''
	Local cStatEnc	:= StrZero(3,Len(DTQ->DTQ_STATUS)) //-- Encerrado
	Local cStatCan	:= StrZero(9,Len(DTQ->DTQ_STATUS)) //-- Cancelado 
	Local cPeriodIni:= " "
	Local cPeriodFim:= " "
	Local nX 		:= 0
	Local aVeiQry	:= {}
	Local aVeiMsg	:= {}
	Local aNumDoc	:= {}
	Local lBlind	:= IsBlind()

	Default cPlanej := ''
	Default cProgram:= ''
	Default cViag	:= ''
	Default dDtIni	:= SToD('')
	Default cHrIni	:= ''
	Default dDtFim	:= SToD('')
	Default cHrFim	:= ''	
	Default aVeic	:= {'','','',''}
	Default cViagInt:= M->DTR_NUMVGE   //Tratamento devido a Viagem Modelo 3 (DM4)

	If lMVTMSAloc
	
		cPeriodIni := DtoS( dDtIni) + cHrIni
		cPeriodFim := DtoS( dDtFim) + cHrFim

		If !Empty(cCodRB1)
			cReboques += "'" + cCodRB1 + "'"
		EndIf
		If !Empty(cCodRB2)
			If !Empty(cReboques)
				cReboques += ",'" + cCodRB2 + "'"
			Else
				cReboques += "'" + cCodRB2  + "'" 
			EndIf
		EndIf
		If !Empty(cCodRB3)
			If !Empty(cReboques)
				cReboques += ",'" + cCodRB3 + "'"
			Else
				cReboques += "'" +  cCodRB3  + "'"
			EndIf
		EndIf

		//Valida Viagem - Verifica se a viagem referente ao complemento esta cancelada, encerrada ou o veiculo esta em uso.
		cAliasQry := GetNextAlias()
		cQuery := "SELECT DTR.DTR_CODVEI, DTR.DTR_CODRB1, DTR.DTR_CODRB2, DTR.DTR_CODRB3, DTR.DTR_DATINI,"
		cQuery += " 	  DTR.DTR_HORINI, DTR.DTR_DATFIM, DTR.DTR_HORFIM, DTQ_FILORI, DTQ_VIAGEM, DTQ_STATUS 
		cQuery += "FROM " + RetSQLTab('DTR')
		cQuery += "JOIN " + RetSQLTab('DTQ')
		cQuery += "  ON DTQ.DTQ_FILIAL = '" + xFilial('DTQ') + "' AND "
		cQuery += "     DTQ.DTQ_FILORI = DTR.DTR_FILORI AND "
		cQuery += "     DTQ.DTQ_VIAGEM = DTR.DTR_VIAGEM AND "
		cQuery += "     DTQ_STATUS NOT IN ('"+cStatEnc+"','"+cStatCan+"') AND "
		cQuery += "     DTQ.D_E_L_E_T_ = ' ' "

		cQuery += "WHERE  DTR.DTR_FILIAL = '" + xFilial('DTR') + "' "
		cQuery += "	AND ((DTR.DTR_CODVEI = '" + cCodVei + "' "
		If !Empty(cReboques)
			cQuery += "		OR DTR.DTR_CODRB1 IN (" + cReboques + ") "
			cQuery += "		OR DTR.DTR_CODRB2 IN (" + cReboques + ") "
			cQuery += "		OR DTR.DTR_CODRB3 IN (" + cReboques + ") "
		EndIf
		cQuery += " ) "
		cQuery += "	OR ( '" + cCodVei + "' = DTR.DTR_CODVEI "
		If !Empty(cCodRB1)
			cQuery += "		OR '" + cCodRB1 + "' IN (DTR.DTR_CODRB1, DTR.DTR_CODRB2, DTR.DTR_CODRB3) "
		EndIf
		If !Empty(cCodRB2)
			cQuery += "		OR '" + cCodRB2 + "' IN (DTR.DTR_CODRB1, DTR.DTR_CODRB2, DTR.DTR_CODRB3) "
		EndIf
		If !Empty(cCodRB3)
			cQuery += "		OR '" + cCodRB3 + "' IN (DTR.DTR_CODRB1, DTR.DTR_CODRB2, DTR.DTR_CODRB3) "
		EndIf
		cQuery += ")) "	

		If !Empty(cViag)
			cQuery += "		AND DTR.DTR_VIAGEM <> '" + cViag + "' "
			cQuery += "		AND DTR.DTR_NUMVGE <> '" + cViag + "' "
		EndIf
		// Valida se Data e Hora da programação são conflitantes com a tabela
		cQuery += "  	 	AND ( ('" + DtoS( dDtIni ) + "' BETWEEN DTR.DTR_DATINI AND DTR.DTR_DATFIM ) "
		cQuery += "      	OR    ('" + Dtos( dDtFim ) + "' BETWEEN DTR.DTR_DATINI AND DTR.DTR_DATFIM ) "
		// Valida se Data e Hora da tabela são conflitantes com a programação
		cQuery += "			OR ( (DTR.DTR_DATINI BETWEEN '" + DtoS( dDtIni ) + "' AND '" + Dtos( dDtFim ) + "') "
		cQuery += "			OR   (DTR.DTR_DATFIM BETWEEN '" + DtoS( dDtIni ) + "' AND '" + Dtos( dDtFim ) + "'))) "
		cQuery += "  		AND   DTR.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)

		While !(cAliasQry)->(EoF()) .And. lRet

			If (cAliasQry)->DTQ_VIAGEM != cViagInt
				If cPeriodIni >= (cAliasQry)->(DTR_DATINI + DTR_HORINI) .And. cPeriodIni <= (cAliasQry)->(DTR_DATFIM + DTR_HORFIM)
					lAchou := .T.	
				ElseIf 	cPeriodFim >= (cAliasQry)->(DTR_DATINI + DTR_HORINI) .And. cPeriodFim <= (cAliasQry)->(DTR_DATFIM + DTR_HORFIM)
					lAchou := .T.					
				ElseIf (cAliasQry)->(DTR_DATINI + DTR_HORINI) >= cPeriodIni .And. (cAliasQry)->(DTR_DATINI + DTR_HORINI) <= cPeriodFim
					lAchou := .T.					
				ElseIf (cAliasQry)->(DTR_DATFIM + DTR_HORFIM) >= cPeriodIni .And. (cAliasQry)->(DTR_DATFIM + DTR_HORFIM) <= cPeriodFim
					lAchou := .T.	
				EndIf
			EndIf
		
			If lAchou
				cNumVge := (cAliasQry)->DTQ_VIAGEM
				aAdd(aVeiQry, {(cAliasQry)->DTR_CODVEI, (cAliasQry)->DTR_CODRB1, (cAliasQry)->DTR_CODRB2, (cAliasQry)->DTR_CODRB3})
				If aScan(aNumDoc, (cAliasQry)->DTQ_VIAGEM) = 0
					aAdd(aNumDoc, (cAliasQry)->DTQ_VIAGEM)
				EndIf
			EndIf
			
			(cAliasQry)->(DbSkip())
		EndDo
	
		For nX := 1 To Len(aVeiQry)
			If aScan(aVeiQry[nX], cCodVei) > 0 .AND. aScan(aVeiMsg, cCodVei) = 0
				aAdd(aVeiMsg, cCodVei)
			EndIf	
			If aScan(aVeiQry[nX], cCodRB1) > 0 .AND. aScan(aVeiMsg, cCodRB1) = 0
				aAdd(aVeiMsg, cCodRB1) 
			EndIf
			If aScan(aVeiQry[nX], cCodRB2) > 0 .AND. aScan(aVeiMsg, cCodRB2) = 0
				aAdd(aVeiMsg, cCodRB2)
			EndIf
			If aScan(aVeiQry[nX], cCodRB3) > 0 .AND. aScan(aVeiMsg, cCodRB3) = 0
				aAdd(aVeiMsg, cCodRB3)
			EndIf
		Next nX
					
		cVeiErro := TStrItens(aVeiMsg)
		
		If Len(aNumDoc)  > 0	.And. !lBlind	
				If Empty(cViag) 
					If (Empty(dDtIni) .Or. Empty(cHrIni) .Or. Empty(dDtFim) .Or. Empty(cHrFim))
						If Len(aVeiMsg) > 1 
							If  Len(aNumDoc) == 1 
								If !MsgYesNo( STR0068 + cVeiErro + STR0071 + cNumVge + STR0063, "HELP" )  //"O veículo: cCodVei " estão sendo utilizados na viagem "                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
									Help(" ",1,"HELP",, STR0072, 3, 00) // Operação cancelada pelo usuário.
									lRet := .F.
								EndIf
							Else
								If !MsgYesNo( STR0068 + cVeiErro + STR0075 + STR0077 + TStrItens(aNumDoc) + STR0063, "HELP" )  //"O veículo: cCodVei estão sendo utilizados nas viagens
									Help(" ",1,"HELP",, STR0072, 3, 00) // Operação cancelada pelo usuário.
									lRet := .F.
								EndIf
							EndIf
						Else
							If  Len(aNumDoc) == 1
								If !MsgYesNo( STR0066 + cVeiErro + STR0061 + cNumVge + STR0063, "HELP" )  //"O veículo: cCodVei está sendo utilizado no planejamento de demanda: cPlnPrg
									Help(" ",1,"HELP",, STR0072, 3, 00) // Operação cancelada pelo usuário.
									lRet := .F.
								EndIf
							Else
								If !MsgYesNo( STR0066 + cVeiErro + STR0076 + STR0077 + TStrItens(aNumDoc) + STR0063, "HELP" )  //"O veículo: cCodVei " está sendo utilizado nas " "viagens"									
									Help(" ",1,"HELP",, STR0072, 3, 00) // Operação cancelada pelo usuário.
									lRet := .F.
								EndIf
							EndIf
						EndIf
					Else
						If Len(aVeiMsg) > 1
							If Len(aNumDoc) == 1
								If !MsgYesNo( STR0068 + cVeiErro + STR0071 + cNumVge +;
										STR0064 + DToC(dDtIni) + " " + SubStr(cHrIni, 1, 2 ) + ":" + SubStr(cHrIni, 3, 2 ) + ;
										STR0065 + DToC(dDtFim) + " " + SubStr(cHrFim, 1, 2 ) + ":" + SubStr(cHrFim, 3, 2 ) + ;
										STR0063, "HELP" ) 			           
									Help(" ",1,"HELP",, STR0072, 3, 00) // Operação cancelada pelo usuário.
									lRet := .F.
								EndIf
							Else
								If !MsgYesNo( STR0068 + cVeiErro + STR0075 + STR0077 + TStrItens(aNumDoc) +;
										STR0064 + DToC(dDtIni) + " " + SubStr(cHrIni, 1, 2 ) + ":" + SubStr(cHrIni, 3, 2 ) + ;
										STR0065 + DToC(dDtFim) + " " + SubStr(cHrFim, 1, 2 ) + ":" + SubStr(cHrFim, 3, 2 ) + ;
										STR0063, "HELP" ) 			           
									Help(" ",1,"HELP",, STR0072, 3, 00) // Operação cancelada pelo usuário.
									lRet := .F.
								EndIf
							EndIf
						Else
							If Len(aNumDoc) == 1
								If !MsgYesNo( STR0066 + cVeiErro + STR0061 + cNumVge +;
									STR0064 + DToC(dDtIni) + " " + SubStr(cHrIni, 1, 2 ) + ":" + SubStr(cHrIni, 3, 2 ) + ;
									STR0065 + DToC(dDtFim) + " " + SubStr(cHrFim, 1, 2 ) + ":" + SubStr(cHrFim, 3, 2 ) + ;
									STR0063, "HELP" )
									Help(" ",1,"HELP",, STR0072, 3, 00) // Operação cancelada pelo usuário.
									lRet := .F.
								EndIf
							Else
								If !MsgYesNo( STR0066 + cVeiErro + STR0076 + STR0077 + TStrItens(aNumDoc) +;
									STR0064 + DToC(dDtIni) + " " + SubStr(cHrIni, 1, 2 ) + ":" + SubStr(cHrIni, 3, 2 ) + ;
									STR0065 + DToC(dDtFim) + " " + SubStr(cHrFim, 1, 2 ) + ":" + SubStr(cHrFim, 3, 2 ) + ;
									STR0063, "HELP" )
									Help(" ",1,"HELP",, STR0072, 3, 00) // Operação cancelada pelo usuário.
									lRet := .F.
								EndIf
							EndIf
						EndIf	
					EndIf
				Else
					If Len(aVeiMsg) > 1
						If Len(aNumDoc) == 1
							Help("",1,"HELP", , STR0068 +  cVeiErro + STR0071 + cNumVge + ".", 1, 1) // "Os veículos " //" estão sendo utilizados na viagem: "
							lRet := .F.
						Else
							Help("",1,"HELP", , STR0068 +  cVeiErro + STR0075 + STR0077 + TStrItens(aNumDoc) + ".", 1, 1) // "Os veículos " //" estão sendo utilizados nas viagens: "
							lRet := .F.
						EndIf
					Else
						If Len(aNumDoc) == 1
							Help("",1,"HELP", , STR0066 +  cVeiErro + STR0061 + cNumVge + ".", 1, 1) //"O veículo " //" está sendo utilizado na viagem: "
							lRet := .F.
						Else
							Help("",1,"HELP", , STR0066 +  cVeiErro + STR0076 + STR0077 + TStrItens(aNumDoc) + ".", 1, 1) //"O veículo " //" está sendo utilizado nas viagens: "
							lRet := .F.						
						EndIf
					EndIf
				EndIf
			EndIf

		
		(cAliasQry)->(DbCloseArea())
		cVeiErro := ''
		aVeiMsg  := {}
		aVeiQry  := {}
		aNumDoc  := {}
		lAchou   := .F.
		
		// Busca se viagem encontrada possui planejamento de demanda, para que este não seja exibido em seguida
		If !Empty(cNumVge)
			cAliasQry := GetNextAlias()
			cQuery := "SELECT DF8.DF8_PLNDMD"
			cQuery += " FROM  " + RetSQLTab('DF8')
			cQuery += " WHERE DF8.DF8_VIAGEM = '" + cNumVge + "' "
			cQuery += " AND DF8.DF8_FILIAL = '" + xFilial('DF8') + "' "
			cQuery += " AND DF8.D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)

			If !(cAliasQry)->(Eof())
				cPlnVge := (cAliasQry)->DF8_PLNDMD
			EndIf
			(cAliasQry)->(DbCloseArea())
		EndIf
	
		// Valida Programação
		If lRet .And. ProcName(2) != "TMSA240MNT" .And.  !lBlind
			cAliasQry := GetNextAlias()
			cQuery := " SELECT DF8.DF8_NUMPRG, DF8.DF8_DATINI, DF8.DF8_HORINI, DF8.DF8_DATFIM, DF8.DF8_HORFIM, "
			cQuery += "        DDZ.DDZ_CODVEI, DDZ.DDZ_CODRB1, DDZ.DDZ_CODRB2, DDZ.DDZ_CODRB3, DF8.DF8_PLNDMD  "
			cQuery += " FROM " + RetSQLTab('DF8')
			cQuery += " JOIN " + RetSQLTab('DDZ')
			cQuery += "	ON  DDZ.DDZ_FILIAL = '" + xFilial('DDZ') + "' "
			cQuery += "	AND DDZ.DDZ_FILORI = DF8.DF8_FILORI "
			cQuery += "	AND DDZ.DDZ_NUMPRG = DF8.DF8_NUMPRG "
			cQuery += "	AND DDZ.DDZ_SEQPRG = DF8.DF8_SEQPRG "
			cQuery += "	AND DDZ.DDZ_VIAGEM = DF8.DF8_VIAGEM "
			cQuery += "	AND DDZ.D_E_L_E_T_ = ' ' "
			
			cQuery += " WHERE DF8.DF8_FILIAL = '" + xFilial('DF8') + "'" 
			If !Empty(cPlnVge)
				cQuery += "   AND DF8.DF8_PLNDMD <> '" + cPlnVge + "' "
			EndIf
			If !Empty(cPlanej)
				cQuery += "   AND DF8.DF8_PLNDMD <> '" + cPlanej + "' "
			EndIf
			If !Empty(cProgram)
				cQuery += "   AND DF8.DF8_NUMPRG <> '" + cProgram + "' "
			EndIf
			If !Empty(cViag)
				cQuery += "	  AND DF8.DF8_VIAGEM <> '" + cViag + "' "
				cQuery += "	  AND DF8.DF8_NUMVGE <> '" + cViag + "' "
			EndIf
			cQuery += "       AND DF8.DF8_STATUS NOT IN ('2', '9')  " // Encerrado // Cancelado
			cQuery += "       AND ((DDZ.DDZ_CODVEI = '" + cCodVei + "' "
			If !Empty(cReboques)
				cQuery += "	  OR DDZ.DDZ_CODRB1 IN (" + cReboques + ") "
				cQuery += "	  OR DDZ.DDZ_CODRB2 IN (" + cReboques + ") "
				cQuery += "	  OR DDZ.DDZ_CODRB3 IN (" + cReboques + ") "
			EndIf
			cQuery += " ) "
			
			cQuery += "	OR ( '" + cCodVei + "' = DDZ.DDZ_CODVEI "
			If !Empty(cCodRB1)
				cQuery += "		OR '" + cCodRB1 + "' IN (DDZ.DDZ_CODRB1, DDZ.DDZ_CODRB2, DDZ.DDZ_CODRB3) "
			EndIf
			If !Empty(cCodRB2)
				cQuery += "		OR '" + cCodRB2 + "' IN (DDZ.DDZ_CODRB1, DDZ.DDZ_CODRB2, DDZ.DDZ_CODRB3) "
			EndIf
			If !Empty(cCodRB3)
				cQuery += "		OR '" + cCodRB3 + "' IN (DDZ.DDZ_CODRB1, DDZ.DDZ_CODRB2, DDZ.DDZ_CODRB3) "	
			EndIf
			cQuery += "	)) "	
			// Valida se Data e Hora da programação são conflitantes com a tabela
			cQuery += " AND ( "
			cQuery += " 	   ( ('" + DtoS( dDtIni ) + "' BETWEEN DF8.DF8_DATINI AND DF8.DF8_DATFIM ) "
			cQuery += "      OR "
			cQuery += "          ('" + DtoS( dDtFim ) + "' BETWEEN DF8.DF8_DATINI AND DF8.DF8_DATFIM ) ) "
			// Valida se Data e Hora da tabela são conflitantes com a programação
			cQuery += " 	 OR "
			cQuery += "	        ((DF8.DF8_DATINI BETWEEN '" + DtoS( dDtIni ) + "' AND '" + Dtos( dDtFim ) + "' ) "
			cQuery += "      OR "
			cQuery += "	     	 (DF8.DF8_DATFIM BETWEEN '" + Dtos( dDtIni ) + "' AND '" + Dtos( dDtFim ) + "' ))) "
			cQuery += "	AND DF8.D_E_L_E_T_ = ' ' "
			
			cQuery := ChangeQuery(cQuery)
			
			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.T.,.T.) 

			While !(cAliasQry)->(EoF()) .And. lRet
			
				If (cPeriodIni >= (cAliasQry)->(DF8_DATINI + DF8_HORINI) .AND. cPeriodIni <= (cAliasQry)->(DF8_DATFIM + DF8_HORFIM))
					lAchou := .T.				
				ElseIf 	(cPeriodFim >= (cAliasQry)->(DF8_DATINI + DF8_HORINI) .AND. cPeriodFim <= (cAliasQry)->(DF8_DATFIM + DF8_HORFIM))
					lAchou := .T.
				ElseIf ((cAliasQry)->(DF8_DATINI + DF8_HORINI) >= cPeriodIni .AND. (cAliasQry)->(DF8_DATINI + DF8_HORINI) <= cPeriodFim)
					lAchou := .T.
				ElseIf ((cAliasQry)->(DF8_DATFIM + DF8_HORFIM) >= cPeriodIni .AND. (cAliasQry)->(DF8_DATFIM + DF8_HORFIM) <= cPeriodFim)
					lAchou := .T.
				EndIf
			
				If lAchou
					cNumPrg := (cAliasQry)->DF8_NUMPRG
					cPlnPrg := (cAliasQry)->DF8_PLNDMD
					aAdd(aVeiQry, {(cAliasQry)->DDZ_CODVEI, (cAliasQry)->DDZ_CODRB1, (cAliasQry)->DDZ_CODRB2, (cAliasQry)->DDZ_CODRB3})
					If aScan(aNumDoc, (cAliasQry)->DF8_PLNDMD) = 0
						aAdd(aNumDoc, (cAliasQry)->DF8_PLNDMD)
					EndIf
				EndIf
				(cAliasQry)->(DbSkip())
			EndDo   
			
			For nX := 1 To Len(aVeiQry)
				If aScan(aVeiQry[nX], cCodVei) > 0  .AND. aScan(aVeiMsg, cCodVei) = 0
					aAdd(aVeiMsg, cCodVei)
				EndIf
				If aScan(aVeiQry[nX], cCodRB1) > 0 .AND. aScan(aVeiMsg, cCodRB1) = 0
					aAdd(aVeiMsg, cCodRB1) 
				EndIf
				If aScan(aVeiQry[nX], cCodRB2) > 0 .AND. aScan(aVeiMsg, cCodRB2) = 0
					aAdd(aVeiMsg, cCodRB2)
				EndIf
				If aScan(aVeiQry[nX], cCodRB3) > 0 .AND. aScan(aVeiMsg, cCodRB3) = 0
					aAdd(aVeiMsg, cCodRB3)
				EndIf
			Next nX
			
			cVeiErro := TStrItens(aVeiMsg)
			
			If Len(aNumDoc)  > 0 .And. !lBlind
				If (Empty(dDtIni) .Or. Empty(cHrIni) .Or. Empty(dDtFim) .Or. Empty(cHrFim))
					If Len(aVeiMsg) > 1
						If  Len(aNumDoc) == 1
							If !MsgYesNo( STR0068 + cVeiErro + STR0069 + cNumPrg + STR0063, "HELP" )  // "Os veículos: cVeiErro estão sendo utilizados na programação: cNumPrg. Deseja Continuar? 
								Help(" ",1,"HELP",, STR0072, 3, 00) // Operação cancelada pelo usuário.
								lRet := .F.
							EndIf
						Else
							If !MsgYesNo( STR0068 + cVeiErro + STR0075 + STR0078 + TStrItens(aNumDoc) + STR0063, "HELP" )  // "Os veículos: cVeiErro estão sendo utilizados nas programação: cNumPrg. Deseja Continuar? 
								Help(" ",1,"HELP",, STR0072, 3, 00) // Operação cancelada pelo usuário.
								lRet := .F.
							EndIf						
						EndIf
					Else
						If  Len(aNumDoc) == 1
							If !MsgYesNo( STR0066 + cVeiErro + STR0067 + cNumPrg + STR0063, "HELP" )  // "O veículo: cVeiErro está sendo utilizado na programação: cNumPrg.  Deseja Continuar? 
								Help(" ",1,"HELP",, STR0072, 3, 00) // Operação cancelada pelo usuário.
								lRet := .F.
							EndIf
						Else
							If !MsgYesNo( STR0066 + cVeiErro + STR0076 + STR0078 + TStrItens(aNumDoc) + STR0063, "HELP" )  // "O veículo: cVeiErro está sendo utilizado na programação: cNumPrg.  Deseja Continuar? 
								Help(" ",1,"HELP",, STR0072, 3, 00) // Operação cancelada pelo usuário.
								lRet := .F.
							EndIf
						EndIf
					EndIf
				Else
					If Len(aVeiMsg) > 1
						If  Len(aNumDoc) == 1
							If !MsgYesNo( STR0068 + cVeiErro + STR0069 + cNumPrg +; 
								STR0064 + DToC(dDtIni) + " " + SubStr(cHrIni, 1, 2 ) + ":" + SubStr(cHrIni, 3, 2 ) + ;
								STR0065 + DToC(dDtFim) + " " + SubStr(cHrFim, 1, 2 ) + ":" + SubStr(cHrFim, 3, 2 ) + ;
								STR0063, "HELP" ) // "Os veículos: cVeiErro estão sendo utilizados na programação: cNumPrg no período DATINI HORINI a DATFIM HORFIM. Deseja Continuar? 		           
								Help(" ",1,"HELP",, STR0072, 3, 00) // Operação cancelada pelo usuário.
								lRet := .F.
							EndIf
						Else
							If !MsgYesNo( STR0068 + cVeiErro + STR0075 + STR0078 + TStrItens(aNumDoc) +;
								STR0064 + DToC(dDtIni) + " " + SubStr(cHrIni, 1, 2 ) + ":" + SubStr(cHrIni, 3, 2 ) + ;
								STR0065 + DToC(dDtFim) + " " + SubStr(cHrFim, 1, 2 ) + ":" + SubStr(cHrFim, 3, 2 ) + ;
								STR0063, "HELP" ) // "Os veículos: cVeiErro estão sendo utilizados na programação: cNumPrg no período DATINI HORINI a DATFIM HORFIM. Deseja Continuar? 		           
								Help(" ",1,"HELP",, STR0072, 3, 00) // Operação cancelada pelo usuário.
								lRet := .F.
							EndIf					
						EndIf
					Else
						If  Len(aNumDoc) == 1
							If !MsgYesNo( STR0066 + cVeiErro + STR0067 + cNumPrg +;
								STR0064 + DToC(dDtIni) + " " + SubStr(cHrIni, 1, 2 ) + ":" + SubStr(cHrIni, 3, 2 ) + ;
								STR0065 + DToC(dDtFim) + " " + SubStr(cHrFim, 1, 2 ) + ":" + SubStr(cHrFim, 3, 2 ) + ;
								STR0063, "HELP" ) // "O veículo: cVeiErro está sendo utilizado na programação: cNumPrg no período DATINI HORINI a DATFIM HORFIM.  Deseja Continuar? 
								Help(" ",1,"HELP",, STR0072, 3, 00) // Operação cancelada pelo usuário.
								lRet := .F.
							EndIf
						Else
							If !MsgYesNo( STR0066 + cVeiErro + STR0076 + STR0078 + TStrItens(aNumDoc) +;
								STR0064 + DToC(dDtIni) + " " + SubStr(cHrIni, 1, 2 ) + ":" + SubStr(cHrIni, 3, 2 ) + ;
								STR0065 + DToC(dDtFim) + " " + SubStr(cHrFim, 1, 2 ) + ":" + SubStr(cHrFim, 3, 2 ) + ;
								STR0063, "HELP" ) // "O veículo: cVeiErro está sendo utilizado nas programação: cNumPrg no período DATINI HORINI a DATFIM HORFIM.  Deseja Continuar? 
								Help(" ",1,"HELP",, STR0072, 3, 00) // Operação cancelada pelo usuário.
								lRet := .F.
							EndIf					
						EndIf
					EndIf
				EndIf
			EndIf		  
			
			(cAliasQry)->(DbCloseArea())
			cVeiErro:= ''
			aVeiMsg	:= {}
			aVeiQry	:= {}
			aNumDoc := {}
			lAchou	:= .F.           
		EndIf
		
		// Valida Planejamento 
		If  AliasInDic('DL9') .AND. lRet .And. lMVITMSDMD .And. ProcName(2) != "TMSA240MNT"
			cAliasQry := GetNextAlias()
			cQuery := " SELECT DL9.DL9_COD, DL9.DL9_DATINI, DL9.DL9_HORINI, DL9.DL9_DATFIM, DL9.DL9_HORFIM, "
			cQuery += "     DL9.DL9_CODVEI, DL9.DL9_CODRB1, DL9.DL9_CODRB2, DL9.DL9_CODRB3 "
			cQuery += " FROM " + RetSQLTab('DL9')
			cQuery += " WHERE DL9.DL9_FILIAL = '" + xFilial('DL9') + "'" 
			If !Empty(cPlanej)
				cQuery += "  AND DL9.DL9_COD <> '" + cPlanej + "' "
			EndIf
			If !Empty(cPlnVge)
				cQuery += "  AND DL9.DL9_COD <> '" + cPlnVge + "' "
			EndIf
			If !Empty(cPlnPrg)
				cQuery += "  AND DL9.DL9_COD <> '" + cPlnPrg + "' "
			EndIf
			cQuery += "      AND DL9.DL9_STATUS IN ('1', '2')  " // Encerrado // Recusado // Cancelado
			cQuery += "      AND ((DL9.DL9_CODVEI = '" + cCodVei + "' "
			If !Empty(cReboques)
				cQuery += "		OR DL9.DL9_CODRB1 IN (" + cReboques + ") "
				cQuery += "		OR DL9.DL9_CODRB2 IN (" + cReboques + ") "
				cQuery += "		OR DL9.DL9_CODRB3 IN (" + cReboques + ") "
			EndIf
			cQuery += " ) "

			cQuery += "	OR ( '" + cCodVei + "' = DL9.DL9_CODVEI "
			If !Empty(cCodRB1)
				cQuery += "		OR '" + cCodRB1 + "' IN (DL9.DL9_CODRB1, DL9.DL9_CODRB2, DL9.DL9_CODRB3) "
			EndIf
			If !Empty(cCodRB2)
				cQuery += "		OR '" + cCodRB2 + "' IN (DL9.DL9_CODRB1, DL9.DL9_CODRB2, DL9.DL9_CODRB3) "
			Endif
			If !Empty(cCodRB3)
				cQuery += "		OR '" + cCodRB3 + "' IN (DL9.DL9_CODRB1, DL9.DL9_CODRB2, DL9.DL9_CODRB3) "
			EndIf
			cQuery += "	)) "
			// Valida se Data e Hora da programação são conflitantes com a tabela
			cQuery += " AND (('" + DtoS( dDtIni ) + "' BETWEEN DL9.DL9_DATINI AND DL9.DL9_DATFIM ) "       
			cQuery += "  OR  ('" + DtoS( dDtFim ) + "' BETWEEN DL9.DL9_DATINI AND DL9.DL9_DATFIM ) "
			// Valida se Data e Hora da tabela são conflitantes com a programação
			cQuery += "	OR ((DL9.DL9_DATINI BETWEEN '" + DtoS( dDtIni ) + "' AND '" + Dtos( dDtIni ) + "') "
			cQuery += " OR ( DL9.DL9_DATFIM BETWEEN '" + Dtos( dDtFim ) + "' AND '" + Dtos( dDtFim ) + "'))) "
			cQuery += " AND DL9.D_E_L_E_T_ = ' ' "

			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)

			While !(cAliasQry)->(EoF()) .And. lRet
	    
				If (cPeriodIni >= (cAliasQry)->(DL9_DATINI + DL9_HORINI) .AND. cPeriodIni <= (cAliasQry)->(DL9_DATFIM + DL9_HORFIM))
					lAchou := .T.				
				ElseIf 	(cPeriodFim >= (cAliasQry)->(DL9_DATINI + DL9_HORINI) .AND. cPeriodFim <= (cAliasQry)->(DL9_DATFIM + DL9_HORFIM))
					lAchou := .T.
				ElseIf ((cAliasQry)->(DL9_DATINI + DL9_HORINI) >= cPeriodIni .AND. (cAliasQry)->(DL9_DATINI + DL9_HORINI) <= cPeriodFim)
					lAchou := .T.
				ElseIf ((cAliasQry)->(DL9_DATFIM + DL9_HORFIM) >= cPeriodIni .AND. (cAliasQry)->(DL9_DATFIM + DL9_HORFIM) <= cPeriodFim)
					lAchou := .T.
				EndIf

				If lAchou .AND. !((cAliasQry)->DL9_COD == cPlnPrg)						
					cPlnPrg := (cAliasQry)->(DL9_COD)
					aAdd(aVeiQry, {(cAliasQry)->DL9_CODVEI, (cAliasQry)->DL9_CODRB1, (cAliasQry)->DL9_CODRB2, (cAliasQry)->DL9_CODRB3})
					If aScan(aNumDoc, (cAliasQry)->DL9_COD) = 0
						aAdd(aNumDoc, (cAliasQry)->DL9_COD)
					EndIf
				EndIf	
				(cAliasQry)->(DbSkip())
			EndDo
			

			For nX := 1 To Len(aVeiQry)
				If aScan(aVeiQry[nX], cCodVei) > 0 .AND. aScan(aVeiMsg, cCodVei) = 0
					aAdd(aVeiMsg, cCodVei)
				EndIf
				If aScan(aVeiQry[nX], cCodRB1) > 0 .AND. aScan(aVeiMsg, cCodRB1) = 0
					aAdd(aVeiMsg, cCodRB1) 
				EndIf
				If aScan(aVeiQry[nX], cCodRB2) > 0 .AND. aScan(aVeiMsg, cCodRB2) = 0
					aAdd(aVeiMsg, cCodRB2)
				EndIf
				If aScan(aVeiQry[nX], cCodRB3) > 0 .AND. aScan(aVeiMsg, cCodRB3) = 0
					aAdd(aVeiMsg, cCodRB3)
				EndIf
			Next nX

			cVeiErro := TStrItens(aVeiMsg)
			
			If Len(aNumDoc)  > 0 .And. !lBlind
				If (Empty(dDtIni) .Or. Empty(cHrIni) .Or. Empty(dDtFim) .Or. Empty(cHrFim))
					If Len(aVeiMsg) > 1 
						If  Len(aNumDoc) == 1
							If !MsgYesNo( STR0068 + cVeiErro + STR0070 + cPlnPrg + STR0063, "HELP" ) //"Os veículos: cCodVei está sendo utilizado no planejamento de demanda: cPlnPrg
								Help(" ",1,"HELP",, STR0072, 3, 00) // Operação cancelada pelo usuário.
								lRet := .F.
							EndIf
						Else
							If !MsgYesNo( STR0068 + cVeiErro + STR0073 + STR0079 + TStrItens(aNumDoc) + STR0063, "HELP" )  //"O veículo: cCodVei estão sendo utilizados nos " "planejamentos " de demanda: cPlnPrg
								Help(" ",1,"HELP",, STR0072, 3, 00) // Operação cancelada pelo usuário.
								lRet := .F.
							EndIf
						EndIf
					Else
						If  Len(aNumDoc) == 1
							If !MsgYesNo( STR0066 + cVeiErro + STR0062 + cPlnPrg + STR0063, "HELP" )  //"O veículo: cCodVei está sendo utilizado no planejamento de demanda: cPlnPrg
								Help(" ",1,"HELP",, STR0072, 3, 00) // Operação cancelada pelo usuário.
								lRet := .F.
							EndIf
						Else
							If !MsgYesNo( STR0066 + cVeiErro + STR0074 + STR0079 + TStrItens(aNumDoc) + STR0063, "HELP" )  //"O veículo: cCodVei está sendo utilizado nos " "planejamentos " de demanda: cPlnPrg
								Help(" ",1,"HELP",, STR0072, 3, 00) // Operação cancelada pelo usuário.
								lRet := .F.
							EndIf
						EndIf
					EndIf
				Else
					If Len(aVeiMsg) > 1
						If  Len(aNumDoc) == 1
							If !MsgYesNo( STR0068 + cVeiErro + STR0070 + cPlnPrg +;
									STR0064 + DToC(dDtIni) + " " + SubStr(cHrIni, 1, 2 ) + ":" + SubStr(cHrIni, 3, 2 ) + ;
									STR0065 + DToC(dDtFim) + " " + SubStr(cHrFim, 1, 2 ) + ":" + SubStr(cHrFim, 3, 2 ) + ;
									STR0063, "HELP" ) //"Os veículos: cVeiErro estão sendo utilizados na programação: cNumPrg no período DATINI HORINI a DATFIM HORFIM. Deseja Continuar? 			           
								Help(" ",1,"HELP",, STR0072, 3, 00) // Operação cancelada pelo usuário.
								lRet := .F.
							EndIf
						Else
							If !MsgYesNo( STR0068 + cVeiErro + STR0073 + STR0079 + TStrItens(aNumDoc) +;
									STR0064 + DToC(dDtIni) + " " + SubStr(cHrIni, 1, 2 ) + ":" + SubStr(cHrIni, 3, 2 ) + ;
									STR0065 + DToC(dDtFim) + " " + SubStr(cHrFim, 1, 2 ) + ":" + SubStr(cHrFim, 3, 2 ) + ;
									STR0063, "HELP" ) //"Os veículos: cVeiErro estão sendo utilizados na programação: cNumPrg no período DATINI HORINI a DATFIM HORFIM. Deseja Continuar? 			           
								Help(" ",1,"HELP",, STR0072, 3, 00) // Operação cancelada pelo usuário.
								lRet := .F.
							EndIf
						EndIf
					Else
						If  Len(aNumDoc) == 1
							If !MsgYesNo( STR0066 + cVeiErro + STR0062 + cPlnPrg +;
								STR0064 + DToC(dDtIni) + " " + SubStr(cHrIni, 1, 2 ) + ":" + SubStr(cHrIni, 3, 2 ) + ;
								STR0065 + DToC(dDtFim) + " " + SubStr(cHrFim, 1, 2 ) + ":" + SubStr(cHrFim, 3, 2 ) + ;
								STR0063, "HELP" ) //"O veículo: cVeiErro está sendo utilizado na programação: cNumPrg no período DATINI HORINI a DATFIM HORFIM.  Deseja Continuar? 
								Help(" ",1,"HELP",, STR0072, 3, 00) // Operação cancelada pelo usuário.
								lRet := .F.
							EndIf
						Else
							If !MsgYesNo( STR0066 + cVeiErro + STR0074 + STR0079 + TStrItens(aNumDoc) +;
								STR0064 + DToC(dDtIni) + " " + SubStr(cHrIni, 1, 2 ) + ":" + SubStr(cHrIni, 3, 2 ) + ;
								STR0065 + DToC(dDtFim) + " " + SubStr(cHrFim, 1, 2 ) + ":" + SubStr(cHrFim, 3, 2 ) + ;
								STR0063, "HELP" ) //"O veículo: cVeiErro " está sendo utilizado nos " "planejamentos ": aNumDoc no período DATINI HORINI a DATFIM HORFIM.  Deseja Continuar? 
								Help(" ",1,"HELP",, STR0072, 3, 00) // Operação cancelada pelo usuário.
								lRet := .F.
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
			(cAliasQry)->(DbCloseArea())
		EndIf

	EndIf

Return( lRet )
//-------------------------------------------------------------------
/*/{Protheus.doc} TMVALDMOT
Validacao  
@author Alex Amaral
@since 12/02/2019
/*/
//-------------------------------------------------------------------
Function TMVALDMOT(cFilDF8,cNumPrg,cSeqPrg,cCodMot)
Local oMdl		   := FWModelActive()
Local oMdGridDLS := oMdl:GetModel('MdGridDLS')
Local lTabDLS    := TableInDic('DLS')
Local lRet 	   := .T.
Local cQuery     := "" 
Local cAliasQry  := GetNextAlias()
	
Default cFilDF8 := ''
Default cNumPrg := ''
Default cSeqPrg := ''
Default cCodMot := ''

		If oMdGridDLS:GetValue('DLS_ALTERA') == .F.
			Help("",1,STR0081, , , 4, 1,,,,{{STR0082}}) 	//--"Não é permitido alterar o codigo do motorista", Solução Para alterar Delete o atual e insira o novo motorista.		
			Return .F.
		EndIf
		
		//--Posicionar na tabela de Motoristas - DLS
		DA4->(DbSetOrder(1)) //DA4_FILIAL+DA4_COD						 								
		//--Verificar se o motorista está bloqueado
		If DA4->(DbSeek(xFilial("DA4") + cCodMot)) 
			If DA4->DA4_BLQMOT == StrZero(1,Len(DA4->DA4_BLQMOT))
				Help("",1,STR0080, , STR0060 + ":" + cCodMot + " - " + DA4->DA4_NOME , 4, 1) //--"O Motorista esta bloqueado"				
				Return .F.						
			EndIf
		EndIf			
		
		
		If lTabDLS
			cQuery := "SELECT DLS.DLS_FILORI, DLS.DLS_CODMOT,DLS.DLS_CONDUT,DF8.DF8_STATUS, DF8.DF8_VIAGEM FROM " + RetSqlName("DLS") + " DLS"
			cQuery += " INNER JOIN " + RetSqlName("DF8") + " DF8 ON"
			cQuery += " DF8.DF8_FILORI = DLS.DLS_FILORI "
			cQuery += " AND DF8.DF8_NUMPRG = DLS.DLS_NUMPRG "
			cQuery += " AND DF8.DF8_SEQPRG = DLS.DLS_ITEDF8 "	
			cQuery += " AND DF8.D_E_L_E_T_ = ' '"	
			cQuery += " WHERE DLS.DLS_FILIAL = '" + xFilial("DLS") + "' "
			cQuery += " AND DLS.DLS_CODMOT = '" + cCodMot + "' "			
			cQuery += " AND DLS.D_E_L_E_T_ = ' '"	
			cQuery    := ChangeQuery( cQuery )
			cAliasQry := GetNextAlias()
			dbUseArea( .T., 'TOPCONN', TCGENQRY(,, cQuery), cAliasQry, .T., .T. )
			(cAliasQry)->( dbGoTop() )				
	
			While ( cAliasQry )->( !Eof() )									 								
				If (cAliasQry)->DF8_STATUS	== '1' 
					Help("",1,STR0083, , STR0037 + ":" + cCodMot + " - " + DA4->DA4_NOME , 4, 1) //--"O Motorista esta Sendo usado por outra programação com Status em aberto"										
				EndIf
				(cAliasQry)->( dbSkip() )
			EndDo
			(cAliasQry)->( dbCloseArea() )

		EndIf		

Return lRet			

//-------------------------------------------------------------------
/*/{Protheus.doc} TmMontaDmd
Função que monta vetor com raiz das demandas, coletas e documentos
@author	Valdemar Roberto Mognon
@version	1.0
@since		13/03/2019
/*/
//-------------------------------------------------------------------

Function TmMontaDmd(cDocTms,cFilDoc,cDoc,cSerie,cObs,lEstorno,cTipOco,cViagem,lPndInd,lEmbVia)
Local aArea      := GetArea()
Local aAreaDL8   := DL8->(GetArea())
Local aVetDem    := {}
Local aVetDoc    := {}
Local cSqlDT5    := ""
Local cTmpDT5    := GetNextAlias()
Local cCodDmdAnt := ""
Local cCodColAnt := ""
Local nX         := 0
Local nTamDmd    := 0
Local nTamCol    := 0
local cViagemVal := ""

Default cDocTms  := ""
Default cFilDoc  := ""
Default cDoc     := ""
Default cSerie   := ""
Default cObs     := ""
Default lEstorno := .F.
Default cViagem  := ""
Default lPndInd  := .F.
Default lEmbVia  := .F.

If !Empty(cFilDoc) .And. !Empty(cDoc) .And. !Empty(cSerie) .And. FindFunction("TMSDMDXDOC")

    /*Tratamento abaixo realizado, pois ao carregar um conhecimento normal na viagem, estava alterando o status da demanda para Em Reprocesso*/
	if IsIncallStack("TmsA210Grv")
		cViagemVal := cViagem
	else
		cViagemVal := DUA->DUA_VIAGEM
	ENDIF
    //Em uma futura avaliação, estudar se lEmbVia pode ser deixado de passar como parâmetro pq só poderia variar dentro do TMSA210. 
	//Com a regra inclusa aqui, não há mais necessidade de validá-la lá. 	
	lEmbVia := Iif (cSerie == "COL", .T., TMA144CVg(cFilDoc,cDoc,cSerie,cViagemVal))
	
	aVetDem := TmsDmdXDoc(,,cFilDoc,cDoc,cSerie,Iif(cTipOco == "12" .And. lEstorno,.T.,.F.)) //retorna as demandas vinculadas ao documento

	For nX:= 1 to Len(aVetDem)	
		
		cSqlDT5 := "SELECT DT51.DT5_CODDMD CODDMD,DT51.DT5_SEQDMD SEQDMD,"
		cSqlDT5 += "       DT51.DT5_FILORI FILORI,DT51.DT5_NUMSOL NUMSOL,"
		cSqlDT5 += "       DT51.DT5_FILDOC FILDOC,DT51.DT5_DOC DOC,DT51.DT5_SERIE SERIE,'1' DOCTMS "
		cSqlDT5 += "  FROM " + RetSqlName("DT5") + " DT51 " 
		cSqlDT5 += " WHERE DT51.DT5_FILIAL = '" + xFilial("DT5") + "' " 
		cSqlDT5 += "   AND DT51.DT5_CODDMD = '" + aVetDem[nX,1] + "' "
		cSqlDT5 += "   AND DT51.DT5_SEQDMD = '" + aVetDem[nX,2] + "' "
		cSqlDT5 += "   AND DT51.DT5_STATUS <> '9' "
		cSqlDT5 += "   AND DT51.D_E_L_E_T_ = ' ' "

		cSqlDT5 += " UNION "

		cSqlDT5 += "SELECT DT52.DT5_CODDMD CODDMD,DT52.DT5_SEQDMD SEQDMD,"
		cSqlDT5 += "       DTC.DTC_FILCFS FILORI,DTC.DTC_NUMSOL NUMSOL,"
		cSqlDT5 += "       DT6.DT6_FILDOC FILDOC,DT6.DT6_DOC DOC,DT6.DT6_SERIE SERIE,DT6.DT6_DOCTMS DOCTMS "
		cSqlDT5 += "  FROM " + RetSqlName("DT6") + " DT6 " 
		cSqlDT5 += "  JOIN " + RetSqlName("DTC") + " DTC " 
		cSqlDT5 += "    ON DTC.DTC_FILIAL = '" + xFilial("DTC") + "' " 
		cSqlDT5 += "   AND DTC.DTC_FILDOC = DT6.DT6_FILDOC "
		cSqlDT5 += "   AND DTC.DTC_DOC    = DT6.DT6_DOC  "
		cSqlDT5 += "   AND DTC.DTC_SERIE  = DT6.DT6_SERIE "
		cSqlDT5 += "   AND DTC.D_E_L_E_T_ = ' '
		cSqlDT5 += "  JOIN " + RetSqlName("DT5") + " DT52 " 
		cSqlDT5 += "    ON DT52.DT5_FILIAL = '" + xFilial("DT5") + "' " 
		cSqlDT5 += "   AND DT52.DT5_FILORI = DTC.DTC_FILCFS "
		cSqlDT5 += "   AND DT52.DT5_NUMSOL = DTC.DTC_NUMSOL "
		cSqlDT5 += "   AND DT52.DT5_CODDMD = '" + aVetDem[nx,1] + "'"
		cSqlDT5 += "   AND DT52.DT5_SEQDMD = '" + aVetDem[nx,2] + "'"
		cSqlDT5 += "   AND DT52.DT5_STATUS <> '9' "
		cSqlDT5 += "   AND DT52.D_E_L_E_T_ = ' ' 
		cSqlDT5 += " WHERE DT6.DT6_FILIAL = '" + xFilial("DT6") + "' " 
		cSqlDT5 += "   AND DT6.D_E_L_E_T_ = ' ' "
		cSqlDT5 += " ORDER BY CODDMD,SEQDMD,FILORI,NUMSOL,DOCTMS,FILDOC,DOC,SERIE "
		
		cSqlDT5 := ChangeQuery(cSqlDT5)
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlDT5 ),cTmpDT5,.F.,.T.)
		
		While !(cTmpDT5)->(Eof())

			cCodDmdAnt := (cTmpDT5)->CODDMD + (cTmpDT5)->SEQDMD
			Aadd(aVetDoc,{(cTmpDT5)->CODDMD,(cTmpDT5)->SEQDMD,{}})
			nTamDmd := Len(aVetDoc)

			While !(cTmpDT5)->(Eof()) .And. (cTmpDT5)->CODDMD + (cTmpDT5)->SEQDMD == cCodDmdAnt

				cCodColAnt := cCodDmdAnt + (cTmpDT5)->FILORI + (cTmpDT5)->NUMSOL
				If (cTmpDT5)->DOCTMS == "1"
					Aadd(aVetDoc[nTamDmd,3],{(cTmpDT5)->FILORI,(cTmpDT5)->NUMSOL,{}})
					nTamCol := Len(aVetDoc[nTamDmd,3])
				EndIf

				While !(cTmpDT5)->(Eof()) .And. (cTmpDT5)->CODDMD + (cTmpDT5)->SEQDMD + (cTmpDT5)->FILORI + (cTmpDT5)->NUMSOL == cCodColAnt

					If (cTmpDT5)->DOCTMS != "1"
						Aadd(aVetDoc[nTamDmd,3,nTamCol,3],{(cTmpDT5)->FILDOC,(cTmpDT5)->DOC,(cTmpDT5)->SERIE})
					EndIf
					(cTmpDT5)->(DbSkip())

				EndDo

				cCodDmdAnt := (cTmpDT5)->CODDMD + (cTmpDT5)->SEQDMD
			EndDo

		EndDo

		(cTmpDT5)->(DbCloseArea())
		RestArea(aArea)

	Next nX

	TmDefStDmd(cDocTms,Aclone(aVetDoc),lEstorno,cObs,cTipOco,cViagem,lPndInd,lEmbVia)

EndIf

RestArea(aAreaDL8)
RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TmDefStDmd
Função que define o status do registro da demanda na Gestão de Demandas
@author	Valdemar Roberto Mognon
@version	1.0
@since		06/03/2019
/*/
//-------------------------------------------------------------------
Function TmDefStDmd(cDocTms,aVetDoc,lEstorno,cObs,cTipOco,cViagem,lPndInd,lEmbVia)
Local aArea     := GetArea()
Local aDemandas := {}
Local aDoctos   := {}
Local cQuery    := ""
Local cAliasQry := ""
Local cStatus   := ""
Local nCntFor1  := 0
Local nCntFor2  := 0
Local nCntFor3  := 0

Default cDocTms  := ""
Default aVetDoc  := {}
Default lEstorno := .F.
Default cViagem  := ""
Default cTipOco  := ""
Default lPndInd  := .F.
Default lEmbVia  := .F.

If !Empty(cDocTms) .And. !Empty(aVetDoc)
	If cDocTms == "1"	//-- Solicitações de coleta
		For nCntFor1 := 1 To Len(aVetDoc)
			Aadd(aDemandas,{aVetDoc[nCntFor1,1],aVetDoc[nCntFor1,2]})
			For nCntFor2 := 1 To Len(aVetDoc[nCntFor1,3])

				//-- Busca status dos documentos
				cAliasQry := GetNextAlias()
				cQuery := TmQryStDmd(aVetDoc[nCntFor1,3,nCntFor2,1],aVetDoc[nCntFor1,3,nCntFor2,2],"COL")
			
				cQuery := ChangeQuery(cQuery)
				DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
			
				While (cAliasQry)->(!Eof())
					Aadd(aDoctos,{aVetDoc[nCntFor1,3,nCntFor2,1],;
								  aVetDoc[nCntFor1,3,nCntFor2,2],;
								  "COL",;
								  (cAliasQry)->DT2_TIPOCO})

					(cAliasQry)->(DbSkip())	
				EndDo                                                  
				(cAliasQry)->(DbCloseArea())
				RestArea(aArea)
			Next nCntFor2
		Next nCntFor1
	Else	//-- Demais documentos
		For nCntFor1 := 1 To Len(aVetDoc)
			Aadd(aDemandas,{aVetDoc[nCntFor1,1],aVetDoc[nCntFor1,2]})
			For nCntFor2 := 1 To Len(aVetDoc[nCntFor1,3])
				For nCntFor3 := 1 To Len(aVetDoc[nCntFor1,3,nCntFor2,3])

					//-- Busca status dos documentos
					cAliasQry := GetNextAlias()
					cQuery := TmQryStDmd(aVetDoc[nCntFor1,3,nCntFor2,3,nCntFor3,1],aVetDoc[nCntFor1,3,nCntFor2,3,nCntFor3,2],aVetDoc[nCntFor1,3,nCntFor2,3,nCntFor3,3])
				
					cQuery := ChangeQuery(cQuery)
					DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
				
					While (cAliasQry)->(!Eof())
						Aadd(aDoctos,{aVetDoc[nCntFor1,3,nCntFor2,3,nCntFor3,1],;
									  aVetDoc[nCntFor1,3,nCntFor2,3,nCntFor3,2],;
									  aVetDoc[nCntFor1,3,nCntFor2,3,nCntFor3,3],;
									  (cAliasQry)->DT2_TIPOCO})

						(cAliasQry)->(DbSkip())	
					EndDo                                                  
					(cAliasQry)->(DbCloseArea())
					RestArea(aArea)
				Next nCntFor3
			Next nCntFor2
		Next nCntFor1
	EndIf

	//-- Retira a ocorrência atual
	If !Empty(aDoctos)
		Adel(aDoctos,Len(aDoctos))
		Asize(aDoctos,Len(aDoctos) - 1)
	EndIf
		
	//-- Define status da demanda
	
	//-- Quando efetuado o carregamento ou estorno do carregamento na viagem
	If !Empty(cViagem)
		cStatus := Iif(lEstorno,Iif(Ascan(aDoctos,{|x| x[4] == "04"}) > 0,"5",Iif(cDocTms == "1","2","4")), Iif(lEmbVia,"2","5"))	//-- Mudando status da demanda para 5-Reprocesso/4-Finalizada ou 2-Planejada/5-Reprocesso
	ElseIf lPndInd
		cStatus := Iif(lEstorno,"6","5")	//-- Mudando status da demanda para 6-Bloqueada ou 5-Reprocesso
	Else
		If cTipOco == "01"	//-- Encerra Processo
			//-- Quando existir documentos com ocorrência de retorna documento
			If Ascan(aDoctos,{|x| x[4] == "04"}) > 0 .Or. !lEmbVia
				cStatus := Iif(lEstorno,"5","4")	//-- Mudando status da demanda para 5-Reprocesso ou 4-Finalizada
			Else
				cStatus := Iif(lEstorno,"2","4")	//-- Mudando status da demanda para 2-Planejada ou 4-Finalizada
			EndIf
		EndIf
	
		If cTipOco == "02"	//-- Bloqueia Documento
			//-- Quando existir documentos com ocorrência de retorna documento
			If Ascan(aDoctos,{|x| x[4] == "04"}) > 0 .Or. !lEmbVia
				cStatus := Iif(lEstorno,"5","6")	//-- Mudando status da demanda para 5-Reprocesso ou 6-Bloqueada
			Else
				cStatus := Iif(lEstorno,"2","6")	//-- Mudando status da demanda para 2-Planejada ou 6-Bloqueada
			EndIf
		EndIf
		
		If cTipOco == "03"	//-- Libera Documento
			//-- Quando existir documentos com ocorrência de retorna documento
			If Ascan(aDoctos,{|x| x[4] == "04"}) > 0 .Or. !lEmbVia
				cStatus := Iif(lEstorno,"6","5")	//-- Mudando status da demanda para 6-Bloqueada ou 5-Reprocesso
			Else
				cStatus := Iif(lEstorno,"6","2")	//-- Mudando status da demanda para 6-Bloqueada ou 2-Planejada
			EndIf
		EndIf
	
		If cTipOco == "04"	//-- Retorna Documento
			//-- Quando não existir documentos com ocorrência de retorna documento
			If Empty(aDoctos) .Or. Ascan(aDoctos,{|x| x[4] == "04"}) == 0 .Or. !lEmbVia
				cStatus := Iif(lEstorno,"2","5")	//-- Mudando status da demanda para 2-Planejada ou 5-Reprocesso
			Else
				If Ascan(aDoctos,{|x| x[4] == "04"}) > 0
					cStatus:= "5"	//-- Mudando status da demanda para 5-Reprocesso
				EndIf
			EndIf
		EndIf
	
		If cTipOco == "06"	//-- Gera Pendência
			//-- Quando existir documentos com ocorrência de retorna documento
			If Ascan(aDoctos,{|x| x[4] == "04"}) > 0 .Or. !lEmbVia
				cStatus := Iif(lEstorno,"5","6")	//-- Mudando status da demanda para 5-Reprocesso ou 6-Bloqueada
			Else
				cStatus := Iif(lEstorno,"2","6")	//-- Mudando status da demanda para 2-Planejada ou 6-Bloqueada
			EndIf
		EndIf
		
		If cTipOco == "07"	//-- Estorna Pendência
			//-- Quando existir documentos com ocorrência de retorna documento
			If Ascan(aDoctos,{|x| x[4] == "04"}) > 0 .Or. !lEmbVia
				cStatus := Iif(lEstorno,"6","5")	//-- Mudando status da demanda para 6-Bloqueada ou 5-Reprocesso
			Else
				cStatus := Iif(lEstorno,"6","2")	//-- Mudando status da demanda para 6-Bloqueada ou 2-Planejada
			EndIf
		EndIf
		
		If cTipOco == "09"	//-- Gera Indenização
			//-- Quando existir documentos com ocorrência de retorna documento
			If Ascan(aDoctos,{|x| x[4] == "04"}) > 0 .Or. !lEmbVia
				cStatus := Iif(lEstorno,"5","6")	//-- Mudando status da demanda para 5-Reprocesso ou 6-Bloqueada
			Else
				cStatus := Iif(lEstorno,"2","6")	//-- Mudando status da demanda para 2-Planejada ou 6-Bloqueada
			EndIf
		EndIf
		
		If cTipOco == "10"	//-- Estorna Indenização
			//-- Quando existir documentos com ocorrência de retorna documento
			If Ascan(aDoctos,{|x| x[4] == "04"}) > 0 .Or. !lEmbVia
				cStatus := Iif(lEstorno,"6","5")	//-- Mudando status da demanda para 6-Bloqueada ou 5-Reprocesso
			Else
				cStatus := Iif(lEstorno,"6","2")	//-- Mudando status da demanda para 6-Bloqueada ou 2-Planejada
			EndIf
		EndIf

		If cTipOco == "11"	//-- Transferência de Mercadoria
			cStatus := Iif(lEstorno,Iif(Ascan(aDoctos,{|x| x[4] == "04"}) > 0,"5","2"),"5")	//-- Mudando status da demanda para 5-Reprocesso/2-Planejada ou 5-Reprocesso
		EndIf
		
		If cTipOco == "12"	//-- Cancelamento
			//-- Quando existir documentos com ocorrência de retorna documento
			If Ascan(aDoctos,{|x| x[4] == "04"}) > 0
				cStatus := Iif(lEstorno,"5","7")	//-- Mudando status da demanda para 5-Reprocesso ou 7-Cancelada
			Else
				cStatus := Iif(lEstorno,"2","7")	//-- Mudando status da demanda para 2-Planejada ou 7-Cancelada
			EndIf
		EndIf
		
		If cTipOco == "13"	//-- Chegada Eventual
			cStatus := Iif(lEstorno,Iif(Ascan(aDoctos,{|x| x[4] == "04"}) > 0,"5","2"),"5")	//-- Mudando status da demanda para 5-Reprocesso/2-Planejada ou 5-Reprocesso
		EndIf
	EndIf
		
	If FindFunction("TMATUDMDST")
		For nCntFor1 := 1 To Len(aDemandas)
			TmAtuDmdSt(aDemandas[nCntFor1,1],aDemandas[nCntFor1,2],cStatus,cObs)
		Next nCntFor1
	EndIf
EndIf

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TmQryStDmd
Função que busca o status dos documentos para integração com demandas
@author	Valdemar Roberto Mognon
@version	1.0
@since		07/03/2019
/*/
//-------------------------------------------------------------------
Function TmQryStDmd(cFilDoc,cDoc,cSerie)
Local cQuery := ""

Default cFilDoc := ""
Default cDoc    := ""
Default cSerie  := ""

cQuery := "SELECT DUA_FILDOC,DUA_DOC,DUA_SERIE,DT2_TIPOCO,DUA_NUMOCO "
cQuery += "  FROM " + RetSqlName("DUA") + " DUA "
cQuery += "  JOIN " + RetSqlName("DT2") + " DT2 "
cQuery += "    ON DT2_FILIAL = '" + xFilial("DT2") + "' "
cQuery += "   AND DT2_CODOCO = DUA_CODOCO "
cQuery += "   AND DT2.D_E_L_E_T_ = ' ' "
cQuery += " WHERE DUA_FILIAL = '" + xFilial("DUA") + "' "
cQuery += "   AND DUA_FILDOC = '" + cFilDoc + "' "
cQuery += "   AND DUA_DOC    = '" + cDoc + "' "
cQuery += "   AND DUA_SERIE  = '" + cSerie + "' "
cQuery += "   AND DUA.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY DUA_FILDOC,DUA_DOC,DUA_SERIE,DUA_NUMOCO "

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} TmVlColDJI
Função que valida se houve calculo e ou retorno do Valor da Valorização 
da Coleta conforme parametros
@author	Katia
@version	1.0
@since		06/11/2019
/*/
//-------------------------------------------------------------------
Function TmVlColDJI(cFilDoc,cDoc,cSerie,cFilOri,cViagem,cTipCal,cStatus)
Local aArea    := GetArea()
Local cAliasDJI:= ""
Local nRet     := 0
Local cQuery   := ""

Default cFilDoc := ""
Default cDoc    := ""
Default cSerie  := ""
Default cFilOri := ""
Default cViagem := ""
Default cTipCal := ""  //1- Previso;2-Realizado
Default cStatus := ""  //1- Calculado, 2-Cancelado

If TableInDic('DJI') .And. !Empty(cFilDoc) .And. !Empty(cDoc) .And. !Empty(cViagem)
	cAliasDJI  := GetNextAlias()
	cQuery :=	" SELECT  DJI.DJI_VALTOT  "
	cQuery +=	" FROM  " + RetSQLName("DJI") + " DJI "
	cQuery +=	" WHERE DJI.DJI_FILIAL  =  '" + FWxFilial("DJI") + "' "
	cQuery +=	" AND  DJI.DJI_FILDOC  =  '" + cFilDoc + "' "
	cQuery +=	" AND  DJI.DJI_DOC  =  '" + cDoc + "' "
	cQuery +=	" AND  DJI.DJI_SERIE  =  '" + cSerie + "' "
	cQuery +=	" AND  DJI.DJI_FILVGE  =  '" + cFilOri + "' "
	cQuery +=	" AND  DJI.DJI_VIAGEM  =  '" + cViagem + "' "
	If !Empty(cTipCal)
		cQuery +=	" AND  DJI.DJI_TIPCAL  =  '" + cTipCal + "' "
	EndIf
	If !Empty(cStatus)	
		cQuery +=	" AND  DJI_STATUS =  '" + cStatus + "' "
	EndIf	
	cQuery +=	" AND  DJI_CODPAS      =  'TF' " //Total Frete
	cQuery +=	" AND  DJI.D_E_L_E_T_  =  ' ' "  
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDJI)
	If (cAliasDJI)->(!Eof())  
		nRet:= (cAliasDJI)->DJI_VALTOT		
	EndIf
	(cAliasDJI)->(DbCloseArea())
EndIf

RestArea(aArea)
Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TmGuiaGRNE
Função que gera guia de GRNE
@author	Fabio Marchiori Sampaio
@version	1.0
@since		04/03/2020
/*/
//-------------------------------------------------------------------
Function TmGuiaGRNE(nValICMSST, nValICM, nVDifal, nValICMP, nVFCDif, nVlCRDTran)

Local cMVTmsGnre  := SuperGetMV("MV_TMSGNRE",,"")
Local nThreads    := SuperGetMv("MV_TMSTHRC", , 0) // Numero de threads para processamento simultaneos
Local lLancCont   := .F.
Local lTitICMS    := .F.
Local lGRecICMS   := .F.
Local lConfTit    := .F.
Local lGDifal     := .F.
Local lGFcpDif    := .F.
Local cUFOrigem   := ''
Local cNumero     := ''
Local cLcPadTit   := ''
Local nVlrIcm     := 0
Local nMes        := 0
Local nAno        := 0
Local dDtIni      := Ctod("//")
Local dDtFim      := Ctod("//")
Local dDtVenc     := Ctod("//")
Local aDSF2       := {}
Local aGNRE       := {}
Local aRecTit     := {}
Local aDatas      := {}
Local lJob		  := FWGetRunSchedule() .Or. (nThreads > 0)
Local cUFCRD20   := 'RJ/MG/SC/RS/PR/MT' //Geração de GNRE com redução do ICMS em 20% Conforme Convênio ICMS 106/96 somente para os Estado.

Default nVFCDif	    := 0
Default nValICMSST  := 0
Default nValICM     := 0 
Default nVDifal     := 0
Default nValICMP    := 0
Default nVlCRDTran  := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gravacao do ICMS Proprio    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If	nValICM > 0 
	//-- Tratamento para geracao da guia de recolhimento ICMS Proprio
	Pergunte("TMB200",.F.)
	lLancCont := Iif(ValType(MV_PAR04)<>"N",.F.,(MV_PAR04==1)) //-- Lanc.Contab.On-Line ?
	lTitICMS  := Iif(ValType(MV_PAR05)<>"N",.F.,(MV_PAR05==1)) //-- Gera Titulo ICMS Proprio ?
	lGRecICMS := Iif(ValType(MV_PAR06)<>"N",.F.,(MV_PAR06==1)) //-- Gera Guia ICMS Proprio ?
	cUFOrigem := MaFisRet(,"NF_UFORIGEM")
	If (GetMV("MV_ESTADO")<>cUFOrigem .And. (lTitICMS .Or. lGRecICMS)) .And. Empty(IESubTrib(SF2->F2_EST))
		cNumero   := SF2->F2_DOC
		If (nVlCRDTran > 0 .And. cUFOrigem $ cUFCRD20)
			nVlrIcm   := SF2->F2_VALICM - nVlCRDTran
		Else
			nVlrIcm   := SF2->F2_VALICM
		EndIf
		nMes      := Month(SF2->F2_EMISSAO)
		nAno      := Year(SF2->F2_EMISSAO)
		aDatas    := DetDatas(nMes,nAno,3,1)
		dDtIni    := aDatas[1]
		dDtFim    := aDatas[2]
		dDtVenc   := DataValida(aDatas[2]+1,.T.)
		aadd(aDSF2,{SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_TIPO,"2",SF2->F2_EST,SF2->F2_ESPECIE})
		GravaTit(lTitICMS,nVlrIcm,"ICMS","IC",cLcPadTit,dDtIni,dDtFim,dDtVenc,1,lGRecICMS,nMes,nAno,nVlrIcm,0,"MATA460A",;
				lLancCont,@cNumero,@aGNRE,,,,,,,,@aRecTit,@lConfTit,0,aDSF2,,,,,,,,,,,,,,,,,lJob)
	Else
		If !Empty(cMVTmsGnre)  
			If (cUFOrigem $ cMVTmsGnre .And. (lTitICMS .Or. lGRecICMS))
				cNumero   := SF2->F2_DOC
				If (nVlCRDTran > 0 .And. cUFOrigem $ cUFCRD20)
					nVlrIcm   := SF2->F2_VALICM - nVlCRDTran
				Else
					nVlrIcm   := SF2->F2_VALICM
				EndIf
				nMes      := Month(SF2->F2_EMISSAO)
				nAno      := Year(SF2->F2_EMISSAO)
				aDatas    := DetDatas(nMes,nAno,3,1)
				dDtIni    := aDatas[1]
				dDtFim    := aDatas[2]
				dDtVenc   := DataValida(aDatas[2]+1,.T.)
				aadd(aDSF2,{SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_TIPO,"2",SF2->F2_EST,SF2->F2_ESPECIE})
				GravaTit(lTitICMS,nVlrIcm,"ICMS","IC",cLcPadTit,dDtIni,dDtFim,dDtVenc,1,lGRecICMS,nMes,nAno,nVlrIcm,0,"MATA460A",;
						lLancCont,@cNumero,@aGNRE,,,,,,,,@aRecTit,@lConfTit,0,aDSF2,,,,,,,,,,,,,,,,,lJob)
			EndIf
		EndIf
	EndIf
	//Gnre EC87/2015
	//nVDifal esta variavel é preenchida pela função MaNFS2nfs, para casos que escrituraçao das notas teve alteração
	//apos processamento dos itens deve ser considerado conteudo Atualizado do livro (SF3).
	If nVDifal > 0
		If Empty(IESubTrib(SF2->F2_EST,.T.)) .And. SF2->F2_TIPOCLI=="F" .And. GetMV("MV_ESTADO")<>SF2->F2_EST
			lGDifal	    := Iif(ValType(MV_PAR08)<>"N",.F.,(mv_par08==1))
			lGFcpDif	:= Iif(ValType(MV_PAR09)<>"N",.F.,(mv_par09==1))
			If lGDifal
				nVlrdifal := nVDifal
				nDifFecp  := nVFCDif
				nMes      := Month(SF2->F2_EMISSAO)
				nAno      := Year(SF2->F2_EMISSAO)
				aDatas    := DetDatas(nMes,nAno,3,1)
				dDtIni	  := aDatas[1]
				dDtFim	  := aDatas[2]
				dDtVenc   := DataValida(aDatas[2]+1,.t.)
				lLancCont := Iif(ValType(MV_PAR04)<>"N",.F.,(mv_par04==1))
				aadd(aDSF2,{SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_TIPO,"2",SF2->F2_EST,SF2->F2_ESPECIE})
				If SF2->F2_EST $ GetNewPar("MV_SOMAGNR","")
					GravaTit((lGDifal .And. lGFcpDif),nVlrdifal+nDifFecp,"ICMS","IC",cLcPadTit,dDtIni,dDtFim,dDtVenc,1,lGDifal,nMes,nAno,0,nVlrdifal+nDifFecp,"MATA460A",;
							lLancCont,@cNumero,@aGNRE,,,SF2->F2_EST,,.T.,.T.,,@aRecTit,@lConfTit,0,aDSF2,,,,,,,,,,.T.,,,,.T.,,,lJob)
				Else
					GravaTit(lGDifal,nVlrdifal,"ICMS","IC",cLcPadTit,dDtIni,dDtFim,dDtVenc,1,lGDifal,nMes,nAno,0,nVlrdifal,"MATA460A",;
							lLancCont,@cNumero,@aGNRE,,,SF2->F2_EST,,,.T.,,@aRecTit,@lConfTit,0,aDSF2,,,,,,,,,,.T.,,,,.T.,,,lJob)
					If  nVFCDif	 > 0 .And. lGFcpDif
						GravaTit(lGFcpDif,nDifFecp,"ICMS","IC",cLcPadTit,dDtIni,dDtFim,dDtVenc,1,lGFcpDif,nMes,nAno,0,nDifFecp,"MATA460A",;
							lLancCont,@cNumero,@aGNRE,,,SF2->F2_EST,,.T.,.T.,,@aRecTit,@lConfTit,0,aDSF2,,,,,,,,,,.T.,,,,.T.,,,lJob)
					EndIf
				EndIf
			Endif
		EndIf
	EndIf

	If nValICMP > 0
		If Empty(IESubTrib(SF2->F2_EST,.T.)) .And. SF2->F2_TIPOCLI=="F" .And. GetMV("MV_ESTADO")<>cUFOrigem
			lGDifal	:= Iif(ValType(MV_PAR08)<>"N",.F.,(mv_par08==1))
			lGFcpDif	:= Iif(ValType(MV_PAR09)<>"N",.F.,(mv_par09==1))
			If lGDifal
				nVlrdifal	:= nValICMP
				nDifFecp	:= nVFCDif
				nMes		:= Month(SF2->F2_EMISSAO)
				nAno		:= Year(SF2->F2_EMISSAO)
				aDatas		:= DetDatas(nMes,nAno,3,1)
				dDtIni		:= aDatas[1]
				dDtFim		:= aDatas[2]
				dDtVenc		:= DataValida(aDatas[2]+1,.t.)
				lLancCont	:= Iif(ValType(MV_PAR04)<>"N",.F.,(mv_par04==1))

				AAdd( aDSF2, { SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_CLIENTE, SF2->F2_LOJA, SF2->F2_TIPO, "2", cUFOrigem, SF2->F2_ESPECIE } )

				If cUFOrigem $ GetNewPar("MV_SOMAGNR","")
					GravaTit(	( lGDifal .And. lGFcpDif ), nVlrdifal+nDifFecp, "ICMS", "IC", cLcPadTit, dDtIni, dDtFim, dDtVenc, 1, lGDifal, nMes, nAno, 0, nVlrdifal+nDifFecp, "MATA460A", ;
								lLancCont, @cNumero, @aGNRE, , , cUFOrigem, , , .T., , @aRecTit, @lConfTit, 0, aDSF2, , , , , , , , , , .T., , , ,.T., , , lJob )
				Else
					GravaTit(	lGDifal, nVlrdifal, "ICMS", "IC", cLcPadTit, dDtIni, dDtFim, dDtVenc, 1, lGDifal, nMes, nAno, nVlrdifal, 0, "MATA460A",;
								lLancCont, @cNumero, @aGNRE, , , cUFOrigem, , , , , @aRecTit, @lConfTit, 0, aDSF2, , , , , , , , , , , , , , , , , lJob )
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

// Gravacao do ICMS ST - Imposto Retido(ICR)
If nValICMSST > 0 .And. SF2->F2_TIPO <>"D"  //DLOGTMS02-10141
	Pergunte("TMB200",.F.)
	lLancCont := If(ValType(MV_PAR04)<>"N",.F.,(MV_PAR04==1)) //-- Lanc.Contab.On-Line ?
	lTitProd  := If(ValType(MV_PAR12)<>"N",.F.,(mv_par12==1)) //-- Gera Titulo Por Produto ? 
	lGRecProd := If(ValType(MV_PAR13)<>"N",.F.,(mv_par13==1)) //-- Gera Guia por Produto ?							
	
	// Gera Guia de Recolhimento ou Titulo ICMS no Contas a pagar quando nao for do mesmo Estado ³
	// e que o Estado Destino nao pos.suir IE no parametro da substituicao tributaria 
	If (GetMV("MV_ESTADO")<>SF2->F2_EST .And. Empty(IESubTrib(SF2->F2_EST)))
		If ( lGRecProd .Or. lTitProd )
			nMes      := Month(SF2->F2_EMISSAO)
			nAno      := Year(SF2->F2_EMISSAO)
			aDatas    := DetDatas( nMes, nAno, 3, 1 )
			dDtIni	  := aDatas[1]
			dDtFim	  := aDatas[2]
			dDtVenc	  := DataValida( aDatas[2]+1, .T. )

			//Armazenamento dos dados para ser utilizado na Guia de Recolhimento e no COntas a Pagar
			AAdd( aDSF2, { SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_CLIENTE, SF2->F2_LOJA, SF2->F2_TIPO, "2", SF2->F2_EST, SF2->F2_ESPECIE } )

			//Armazenamento dos dados para ser utilizado na Guia de Recolhimento por Produto
			GravaTit(	lTitProd, nValICMSST, "ICMS", "IC", cLcPadTit, dDtIni, dDtFim, dDtVenc, 1, lGRecProd, nMes, nAno, 0, nValICMSST, "MATA460A",;
						lLancCont, @cNumero, @aGNRE, , , , , , , , @aRecTit, @lConfTit, 0, aDSF2, , , , , , , , , , , , , , , , , lJob )
		EndIf
	EndIf
EndIf

Return

/*{Protheus.doc} TmsCmpMdl3
Complementa/Deleta os dados da viagem modelo 3 com base na viagem modelo 2
@type Function
@author Valdemar Roberto Mognon
@since 19/08/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Function TmsCmpMdl3(nOpcx)
Local lCont      := .T.
Local lTMS3GFE   := TmsIntGFE("02")
Local aAreas     := {DUP->(GetArea()),DJA->(GetArea()),DM3->(GetArea()),DTR->(GetArea()),DTA->(GetArea()),DUD->(GetArea()),GetArea()}
Local aDadosDM3  := {}
Local aDadosDM4  := {}
Local aDadosDM5  := {}
Local aDadosDM8  := {}
Local aDadosDTR  := {}
Local aDadosDUP  := {}
Local aCab 		 := {} 
Local aMaster	 := {} 
Local aGrid   	 := {} 
Local nOpcxMod3  := 0
Local cSeekDUD   := ""
Local cSeekDJA   := ""
Local cSequen    := StrZero(0,Len(DUD->DUD_SEQUEN))
Local cChave     := ""
Local nSeqDUD    := 0

Local lDM3ORIGEM := DM3->(ColumnPos("DM3_ORIGEM")) > 0

Default nOpcx := 0

//--- Busca a Ultima Sequencia do DUD da Viagem
nSeqDUD:= TmsSeqDUD(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM)
If nSeqDUD > 0
	cSequen:= StrZero(nSeqDUD,Len(DUD->DUD_SEQUEN))
EndIf

nOpcxMod3 := Iif(nOpcx == 3,4,nOpcx)
Aadd( aCab , {"DTQ_FILORI"  , DTQ->DTQ_FILORI 	, Nil })
Aadd( aCab , {"DTQ_VIAGEM"  , DTQ->DTQ_VIAGEM  	, Nil })

//-- Carrega Vetor dos Documentos da Viagem e do GFE
DUD->( DbSetOrder(2) )
DTA->( DbSetOrder(1) )
DM3->( DbSetOrder(1) )
DTQ->( DbSetOrder(1) )

If DUD->(DbSeek(cSeekDUD := xFilial("DUD") + DTQ->(DTQ_FILORI + DTQ_VIAGEM)))
	While DUD->(!Eof()) .And. DUD->(DUD_FILIAL + DUD_FILORI + DUD_VIAGEM) == cSeekDUD
		If nOpcxMod3 <> 5 .And. !DM3->(DbSeek(xFilial("DM3") + DUD->(DUD_FILDOC + DUD_DOC + DUD_SERIE + DUD_FILORI + DUD_VIAGEM)))
			If Empty(DUD->DUD_SEQUEN)
				cSequen := Soma1(cSequen,Len(DUD->DUD_SEQUEN))
			Else
				cSequen := DUD->DUD_SEQUEN
			EndIf
			Aadd(aDadosDM3,{})
			Aadd(aDadosDM3[Len(aDadosDM3)],{"DM3_SEQUEN",cSequen , Nil })
			Aadd(aDadosDM3[Len(aDadosDM3)],{"DM3_FILDOC",DUD->DUD_FILDOC , Nil })
			Aadd(aDadosDM3[Len(aDadosDM3)],{"DM3_DOC"   ,DUD->DUD_DOC , Nil })
			Aadd(aDadosDM3[Len(aDadosDM3)],{"DM3_SERIE" ,DUD->DUD_SERIE , Nil  })
			If lDM3ORIGEM
				If DTA->(DbSeek(xFilial("DTA") + DUD->(DUD_FILDOC + DUD_DOC + DUD_SERIE + DUD_FILORI + DUD_VIAGEM)))
					Aadd(aDadosDM3[Len(aDadosDM3)],{"DM3_ORIGEM",DTA->DTA_ORIGEM,Nil})
				Else
					Aadd(aDadosDM3[Len(aDadosDM3)],{"DM3_ORIGEM",CriaVar("DTA_ORIGEM"),Nil})
				EndIf
			EndIf
				
			If lTMS3GFE .And. !Empty(DUD->DUD_UFORI) .AND. nOpcxMod3 <> 4
			
				Aadd(aDadosDM8,{})
				Aadd(aDadosDM8[Len(aDadosDM8)],{"DM8_FILDOC",DUD->DUD_FILDOC, Nil })
				Aadd(aDadosDM8[Len(aDadosDM8)],{"DM8_DOC"   ,DUD->DUD_DOC	, Nil })
				Aadd(aDadosDM8[Len(aDadosDM8)],{"DM8_SERIE" ,DUD->DUD_SERIE, Nil })
				Aadd(aDadosDM8[Len(aDadosDM8)],{"DM8_UFORI" ,DUD->DUD_UFORI, Nil })
				Aadd(aDadosDM8[Len(aDadosDM8)],{"DM8_CDMUNO",DUD->DUD_CDMUNO, Nil })
				Aadd(aDadosDM8[Len(aDadosDM8)],{"DM8_CEPORI",DUD->DUD_CEPORI, Nil })
				Aadd(aDadosDM8[Len(aDadosDM8)],{"DM8_UFDES" ,DUD->DUD_UFDES, Nil })
				Aadd(aDadosDM8[Len(aDadosDM8)],{"DM8_CDMUND",DUD->DUD_CDMUND, Nil })
				Aadd(aDadosDM8[Len(aDadosDM8)],{"DM8_CEPDES",DUD->DUD_CEPDES, Nil })
				Aadd(aDadosDM8[Len(aDadosDM8)],{"DM8_TIPVEI",DUD->DUD_TIPVEI, Nil })
				Aadd(aDadosDM8[Len(aDadosDM8)],{"DM8_CDTPOP",DUD->DUD_CDTPOP, Nil })
				Aadd(aDadosDM8[Len(aDadosDM8)],{"DM8_CDCLFR",DUD->DUD_CDCLFR, Nil })
				Aadd(aDadosDM8[Len(aDadosDM8)],{"DM8_CHVEXT",DUD->DUD_CHVEXT , Nil })
				
			EndIf
		EndIf
		DUD->(DbSkip())
	EndDo
EndIf

//-- Carrega Vetor do Planejamento da Viagem e da Operadora de Frotas
DTR->(DbSetOrder(1))
If DTR->(DbSeek(xFilial("DTR") + DTQ->(DTQ_FILORI + DTQ_VIAGEM))) .And. nOpcxMod3 <> 5 
	If !Empty(DTR->DTR_DATINI)		
		Aadd(aDadosDM4,{"DM4_FILVGE",DTR->DTR_FILVGE , Nil })
		Aadd(aDadosDM4,{"DM4_NUMVGE",DTR->DTR_NUMVGE , Nil })
		Aadd(aDadosDM4,{"DM4_DATINI",DTR->DTR_DATINI , Nil })
		Aadd(aDadosDM4,{"DM4_HORINI",DTR->DTR_HORINI , Nil })
		Aadd(aDadosDM4,{"DM4_DATFIM",DTR->DTR_DATFIM , Nil })
		Aadd(aDadosDM4,{"DM4_HORFIM",DTR->DTR_HORFIM , Nil })
	EndIf

	If !Empty(DTR->DTR_CODOPE)
		Aadd(aDadosDM5,{"DM5_CODOPE",DTR->DTR_CODOPE , Nil })
		Aadd(aDadosDM5,{"DM5_TPSPDG",DTR->DTR_TPSPDG , Nil })
		Aadd(aDadosDM5,{"DM5_QTDSAQ",DTR->DTR_QTDSAQ , Nil })
		Aadd(aDadosDM5,{"DM5_QTDTRA",DTR->DTR_QTDTRA , Nil })
	Else
 		Aadd(aDadosDM5,{"DM5_PRCTRA",DTR->DTR_PRCTRA , Nil })
	EndIf
EndIf

//-- Atualiza DTR e DUP com base na DJA
DJA->(DbSetOrder(1))
DTR->(DbSetOrder(3))
DUP->(DbSetOrder(2))
If DJA->(DbSeek(cSeekDJA := xFilial("DJA") + DTQ->(DTQ_FILORI + DTQ_VIAGEM))) .And. nOpcxMod3 <> 5 
	While DJA->(!Eof()) .And. DJA->(DJA_FILIAL + DJA_FILORI + DJA_VIAGEM) == cSeekDJA
		If !Empty(DJA->DJA_LIBSEG)
			cChave := AllTrim(SubStr(DJA->DJA_CHAVE,Len(xFilial("DJA")) + 1))
			If DJA->DJA_ALIAS == "DA3"
				If DTR->(DbSeek(xFilial("DTR") + DTQ->(DTQ_FILORI + DTQ_VIAGEM) + cChave))
					Aadd(aDadosDTR,{})
					Aadd(aDadosDTR[Len(aDadosDTR)],{"DTR_CODVEI",DTR->DTR_CODVEI,Nil})
					Aadd(aDadosDTR[Len(aDadosDTR)],{"DTR_LIBRRE",DJA->DJA_LIBSEG,Nil})
					Aadd(aDadosDTR[Len(aDadosDTR)],{"DTR_INIRRE",DJA->DJA_DTIVSG,Nil})
					Aadd(aDadosDTR[Len(aDadosDTR)],{"DTR_FIMRRE",DJA->DJA_DTFVSG,Nil})
				EndIf
			ElseIf DJA->DJA_ALIAS == "DA4"
				If DUP->(DbSeek(xFilial("DUP") + DTQ->(DTQ_FILORI + DTQ_VIAGEM) + cChave))
					Aadd(aDadosDUP,{})
					Aadd(aDadosDUP[Len(aDadosDUP)],{"DUP_CODMOT",DUP->DUP_CODMOT,Nil})
					Aadd(aDadosDUP[Len(aDadosDUP)],{"DUP_LIBRRE",DJA->DJA_LIBSEG,Nil})
					Aadd(aDadosDUP[Len(aDadosDUP)],{"DUP_INIRRE",DJA->DJA_DTIVSG,Nil})
					Aadd(aDadosDUP[Len(aDadosDUP)],{"DUP_FIMRRE",DJA->DJA_DTFVSG,Nil})
				EndIf
			EndIf		
		EndIf
		DJA->(DbSkip())
	EndDo
EndIf

Aadd( aMaster     , {} )
Aadd( aMaster[Len(aMaster)] , aClone(aCab) )
Aadd( aMaster[Len(aMaster)] , "MdFieldDTQ" )
Aadd( aMaster[Len(aMaster)] , "DTQ" )

If Len(aDadosDM3) > 0 
	Aadd( aGrid  , {} )
	Aadd( aGrid[Len(aGrid)]  , aClone(aDadosDM3) )
	Aadd( aGrid[Len(aGrid)]  , "MdGridDM3")
	Aadd( aGrid[Len(aGrid)]  , "DM3" )
EndIf

If Len(aDadosDTR) > 0 
	Aadd( aGrid     , {} )
	Aadd( aGrid[Len(aGrid)] , aClone(aDadosDTR) )
	Aadd( aGrid[Len(aGrid)] , "MdGridDTR" )
	Aadd( aGrid[Len(aGrid)] , "DTR" )
	Aadd( aGrid[Len(aGrid)] , .T.)	//-- Indica que a linha do GRID será pesquisada para alteração
EndIf

If Len(aDadosDUP) > 0 
	Aadd( aGrid     , {} )
	Aadd( aGrid[Len(aGrid)] , aClone(aDadosDUP) )
	Aadd( aGrid[Len(aGrid)] , "MdGridDUP" )
	Aadd( aGrid[Len(aGrid)] , "DUP" )
	Aadd( aGrid[Len(aGrid)] , .T.)	//-- Indica que a linha do GRID será pesquisada para alteração
EndIf

If Len(aDadosDM8) > 0 
	Aadd( aGrid  , {} )
	Aadd( aGrid[Len(aGrid)]  , aClone(aDadosDM8) )
	Aadd( aGrid[Len(aGrid)]  , "MdGridDM8")
	Aadd( aGrid[Len(aGrid)]  , "DM8" )
EndIf

If Len(aDadosDM4) > 0 
	Aadd( aMaster     , {} )
	Aadd( aMaster[Len(aMaster)] , aClone(aDadosDM4) )
	Aadd( aMaster[Len(aMaster)] , "MdFieldDM4" )
	Aadd( aMaster[Len(aMaster)] , "DM4" )
EndIf

If Len(aDadosDM5) > 0 
	Aadd( aMaster     , {} )
	Aadd( aMaster[Len(aMaster)] , aClone(aDadosDM5) )
	Aadd( aMaster[Len(aMaster)] , "MdFieldDM5" )
	Aadd( aMaster[Len(aMaster)] , "DM5" )
EndIf

If Len(aMaster) > 0 
	lCont    := TMSExecAuto( "TMSAF60" ,  aMaster   , aGrid,  nOpcxMod3  , .T.  )
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lCont

/*{Protheus.doc} TmsSeqDUD
Retorna a ultima sequencia do DUD da Viagem]
@type Function
@author Katia
@since 16/09/2020
@version version
@param FilOri, Viagem
@return nSeq
*/
Function TmsSeqDUD(cFilOri,cViagem)
Local nSeqDud		:= 0
Local cAliasQry     := GetNextAlias()
Local cQuery        := ""

cQuery	:= " SELECT MAX(DUD_SEQUEN) DUD_SEQUEN FROM "
cQuery	+= RetSqlName("DUD")
cQuery	+= " WHERE DUD_FILIAL ='" + xFilial("DUD") + "'"
cQuery	+= "   AND DUD_FILORI ='" + cFilOri + "' "
cQuery	+= "   AND DUD_VIAGEM ='" + cViagem + "' "
cQuery 	+= "   AND D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
If (cAliasQry)->(!EOF())
	nSeqDud	:=	Val ( (cAliasQry)->DUD_SEQUEN )
EndIf
(cAliasQry)->(DbCloseArea())

Return nSeqDud

//-----------------------------------------------------------
/* {Protheus.doc} TMSHasMd3
Verifica se o Ambiente está atualizado com Viagem Modelo 3

@author		Rodrigo.Pirolo
@since		26/02/2021
@version	1.0
*/
//-----------------------------------------------------------

Function TMSHasMd3()

Local lRet	:= FindFunction("TMSAF60") .AND. AliasInDic("DM3")// .AND. AliasInDic("DMB")

Return lRet

/*{Protheus.doc} TmsF3Gen
Consulta Específica Genérica
@type Function
@author Valdemar Roberto Mognon
@since 04/03/2022
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Function TmsF3Gen(cAliasFil,cAliasSX,cFiltro)
Local aColunas := {}
Local aButtons := {}
Local nOpca    := 0
Local cCpoRet  := ""
Local oFWLayer
Local oPnlModal

Private oDlgPrinc := Nil

Default cAliasFil := ""
Default cAliasSX  := ""
Default cFiltro   := ""

If !Empty(cAliasFil) .And. cAliasSX $ "SX2:SX3:SIX"

	Var_IXB := ""
	If cAliasSX == "SX2"
		cCpoRet := 'SX2->X2_CHAVE'
	ElseIf cAliasSX == "SX3"
		cCpoRet := 'SX3->X3_CAMPO'
	Else
		cCpoRet := 'SIX->ORDEM'
	EndIf

	oDlgPrinc := FWDialogModal():New()
	oDlgPrinc:SetBackground(.F.)
	oDlgPrinc:SetTitle("Consulta Específica")
	oDlgPrinc:SetEscClose(.T.)
	oDlgPrinc:EnableAllClient()
	oDlgPrinc:CreateDialog()
	
	oPnlModal := oDlgPrinc:GetPanelMain()
		
		// Cria conteiner para os browses
		oFWLayer:= FWLayer():New()
		oFWLayer:Init(oPnlModal,.F.,.T.)
	
		// Define painel Master
		oFWLayer:AddLine("TELA",100,.F.)
	
		//-- Cria Browse
		oPanel  := oFWLayer:GetLinePanel("TELA")
		oBrowse := FWBrowse():New()
		oBrowse:SetOwner(oPanel)
		oBrowse:SetDescription("Consulta " + cAliasFil)
		oBrowse:SetProfileID(cAliasFil)
		oBrowse:SetAlias(cAliasSX)
		oBrowse:SetDataTable(.T.)
		If !Empty(cFiltro)
			oBrowse:SetFilterDefault(cFiltro)
		EndIf

		aColunas := BuscaCol(cAliasSX)

		oBrowse:SetColumns(aColunas)

		&(cAliasSX + "->(DbSetOrder(1))")
		
		oBrowse:Activate()
	
	Aadd(aButtons,{"","Ok"     ,{|| nOpca := 1,Var_IXB := &(cCpoRet),oDlgPrinc:DeActivate()},,,.T.,.F.})
	Aadd(aButtons,{"","Cancela",{|| nOpca := 0,oDlgPrinc:DeActivate()},,,.T.,.F.})
	oDlgPrinc:AddButtons(aButtons)
	
	oDlgPrinc:Activate()

EndIf

Return (nOpca == 1)

/*{Protheus.doc} BuscaCol
Consulta Específica Genérica
@type Static Function
@author Valdemar Roberto Mognon
@since 08/03/2022
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Static Function BuscaCol(cAlias)
Local aRet := {}
Local oColumn

Default cAlias := ""

If cAlias == "SX2"
	oColumn := FWBrwColumn():New()
	oColumn:SetTitle("Chave")
	oColumn:SetType("C")
	oColumn:SetSize(3)
	oColumn:SetDecimal(0)
	oColumn:SetPicture("@!")
	oColumn:SetData({|| SX2->X2_CHAVE})
	aAdd(aRet,oColumn)

	oColumn := FWBrwColumn():New()
	oColumn:SetTitle("Nome")
	oColumn:SetType("C")
	oColumn:SetSize(30)
	oColumn:SetDecimal(0)
	oColumn:SetPicture("@!")
	oColumn:SetData({|| SX2->X2_NOME})
	aAdd(aRet,oColumn)
ElseIf cAlias == "SX3"
	oColumn := FWBrwColumn():New()
	oColumn:SetTitle("Arquivo")
	oColumn:SetType("C")
	oColumn:SetSize(3)
	oColumn:SetDecimal(0)
	oColumn:SetPicture("@!")
	oColumn:SetData({|| SX3->X3_ARQUIVO})
	aAdd(aRet,oColumn)

	oColumn := FWBrwColumn():New()
	oColumn:SetTitle("Ordem")
	oColumn:SetType("C")
	oColumn:SetSize(2)
	oColumn:SetDecimal(0)
	oColumn:SetPicture("@!")
	oColumn:SetData({|| SX3->X3_ORDEM})
	aAdd(aRet,oColumn)

	oColumn := FWBrwColumn():New()
	oColumn:SetTitle("Campo")
	oColumn:SetType("C")
	oColumn:SetSize(10)
	oColumn:SetDecimal(0)
	oColumn:SetPicture("@!")
	oColumn:SetData({|| SX3->X3_CAMPO})
	aAdd(aRet,oColumn)

	oColumn := FWBrwColumn():New()
	oColumn:SetTitle("Descrição")
	oColumn:SetType("C")
	oColumn:SetSize(25)
	oColumn:SetDecimal(0)
	oColumn:SetPicture("@!")
	oColumn:SetData({|| SX3->X3_DESCRIC})
	aAdd(aRet,oColumn)
ElseIf cAlias == "SIX"
	oColumn := FWBrwColumn():New()
	oColumn:SetTitle("Índice")
	oColumn:SetType("C")
	oColumn:SetSize(3)
	oColumn:SetDecimal(0)
	oColumn:SetPicture("@!")
	oColumn:SetData({|| SIX->INDICE})
	aAdd(aRet,oColumn)

	oColumn := FWBrwColumn():New()
	oColumn:SetTitle("Ordem")
	oColumn:SetType("C")
	oColumn:SetSize(1)
	oColumn:SetDecimal(0)
	oColumn:SetPicture("@!")
	oColumn:SetData({|| SIX->ORDEM})
	aAdd(aRet,oColumn)

	oColumn := FWBrwColumn():New()
	oColumn:SetTitle("Descrição")
	oColumn:SetType("C")
	oColumn:SetSize(70)
	oColumn:SetDecimal(0)
	oColumn:SetPicture("@!")
	oColumn:SetData({|| SIX->DESCRICAO})
	aAdd(aRet,oColumn)
EndIf

Return aRet

/*{Protheus.doc} DinamicEnc
Enchoice Dinamica
@type Function
@author Carlos A. Gomes Jr.
@since 14/03/2007
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Function DinamicEnc(oObjTarg,aCpsHEn,aColSay,aObjs,cFunRefresh)
Local nLinha   := 22
Local nColun   := 0
Local nDifCol  := 0
Local nForGet  := 0
Local cBlKWhen := ""
Local cBlKGet  := ""
Local nErr     := 0
Local cRefresh := ""

DEFAULT aColSay     := {002,112,222,332}
DEFAULT cFunRefresh := ""

aObjs := Array(Len(aCpsHEn))
If !Empty(cFunRefresh)
	cRefresh := ".And." + cFunRefresh
EndIf

If ValType(oObjTarg) != "O"
	nErr := 1
ElseIf ValType(aCpsHEn) != "A" .Or. Empty(aCpsHEn) .Or. ValType(aCpsHEn[1]) != "A"
	nErr := 2
EndIf
	
If nErr != 0
	Help(,,"HELP",,STR0084 + "DinamicEnc(#" + StrZero(nErr,2) + ")",1,0,)	//-- "Problemas na função "
Else
	For nForGet := 1 To Len(aCpsHEn)
		aObjs[nForGet] := {aCpsHEn[nForGet,1],Nil}
		// Definicao de linhas e colunas
		If aCpsHEn[nForGet][2] == 1
			nLinha += 12
		EndIf
		If ValType(aCpsHEn[nForGet][9]) == "N" .And. aCpsHEn[nForGet][9] > 0
			nColun := aCpsHEn[nForGet][9]
		Else
			nColun := aColSay[aCpsHEn[nForGet][2]]
		EndIf
	
		// Mostrar título do campo em azul se obrigatório, caso contrário preto e na coordenada pré-definida no vetor aColSay	
		If ValType(aCpsHEn[nForGet][3]) == "C"
			TSay():New(nLinha,nColun,MontaBlock("{||'" + aCpsHEn[nForGet][3] + "'}"),oObjTarg ,,,,,,.T.,Iif(aCpsHEn[nForGet][6],CLR_HBLUE,CLR_BLACK),,,,,,,,)
			nDifCol := 45
		Else
			nDifCol := 0
		EndIf
		
		If ValType(aCpsHEn[nForGet][4]) == "A"
			
			// CodeBlock do campo com sua variavel de manipulacao
			cBlkGet := "{ | u | If( PCount() == 0, " + aCpsHEn[nForGet,1] + ", " + aCpsHEn[nForGet,1] + ":= u ) }"
			
			// Propriedade do campo Alterar ou Visualizar
			cBlKWhen := "{|| " + aCpsHEn[nForGet][7] + cRefresh + " }"
		
			//Verifica se Get ou Combo
			If Empty(aCpsHEn[nForGet][11])
				//Verifica se campo MEMO ou normal
				If aCpsHEn[nForGet][4][3] == "M"
					aObjs[nForGet][2] := TMultiGet():New(nLinha-1,nColun + nDifCol, &cBlKGet,oObjTarg, 250,30,,.F.,,,,.T.,,,,,,,,,,,.T.)
				Else
					aObjs[nForGet][2] := TGet():New(nLinha-1,nColun + nDifCol,&cBlKGet,oObjTarg,;
					CalcFieldSize(aCpsHEn[nForGet][4][3],aCpsHEn[nForGet][4][1],aCpsHEn[nForGet][4][2],aCpsHEn[nForGet][5]) + 10,8,;
					aCpsHEn[nForGet][5],Iif(!Empty(aCpsHEn[nForGet][10]),&("{|| "+aCpsHEn[nForGet][10]+" }"),),,,,.T.,,.T.,,.T.,;
					&(cBlkWhen),.F.,.F.,,.F.,.F.,aCpsHEn[nForGet][8],(aCpsHEn[nForGet][1]),,,,.T.)
				EndIf
			Else
				aObjs[nForGet][2] := TComboBox():New(nLinha-1,nColun + nDifCol,&cBlKGet, aCpsHEn[nForGet][11], 50,, oObjTarg,,, ;
				Iif(!Empty(aCpsHEn[nForGet][10]),&("{|| "+aCpsHEn[nForGet][10]+" }"),),,,.T.,,,,&(cBlkWhen),,,,,)
			EndIf
			
		EndIf
	Next
EndIf

Return

/*{Protheus.doc} BscLayout
Busca Layout
@type Function
@author Valdemar Roberto Mognon
@since 14/03/2022
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Function BscLayout(cCodFon,cCodReg)
Local aAreas   := {DN2->(GetArea()),DN3->(GetArea()),GetArea()}
Local aRet     := {}
Local aStruLay := {}
Local aStruCpo := {}
Local oStruct  := {}
Local nLinha   := 0
Local cSeekDN3 := ""
Local cAlias   := ""
Local lCpoExt  := .F.

Default cCodFon := ""
Default cCodReg := ""

DN2->(DbSetOrder(1))
If DN2->(MsSeek(xFilial("DN2") + cCodFon + cCodReg))
	oStruct  := FwFormStruct(1,DN2->DN2_ALIAS)
	aStruLay := oStruct:GetFields()

	DN3->(DbSetOrder(1))
	If DN3->(DbSeek(cSeekDN3 := xFilial("DN3") + cCodFon + cCodReg))
		While DN3->(!Eof()) .And. DN3->(DN3_FILIAL + DN3_CODFON + DN3_CODREG) == cSeekDN3
			lCpoExt := .F.
			If (nLinha := Ascan(aStruLay,{|x| x[3] == AllTrim(DN3->DN3_CAMPO)})) == 0
				cAlias   := Iif(Left(DN2->DN2_ALIAS,1) == "S",SubStr(DN2->DN2_ALIAS,2),DN2->DN2_ALIAS)
				nLinha   := Ascan(aStruLay,{|x| x[3] == cAlias + "_FILIAL"})
				aStruCpo := Aclone(aStruLay[nLinha])
				lCpoExt  := .T.
			EndIf
			aStruCpo := Aclone(aStruLay[nLinha])
			Aadd(aStruCpo,DN3->DN3_CONTEU)
			Aadd(aRet,aStruCpo)
			If lCpoExt
				aRet[Len(aRet),1] := DN3->DN3_CAMPO
			EndIf
			aRet[Len(aRet),3] := DN3->DN3_CAMPO
			aRet[Len(aRet),2] := DN3->DN3_DESCRI
			aRet[Len(aRet),4] := DN3->DN3_TIPO
			aRet[Len(aRet),5] := DN3->DN3_TAMANH
			aRet[Len(aRet),6] := DN3->DN3_DECIMA
			DN3->(DbSkip())
		EndDo
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return Aclone(aRet)

/*{Protheus.doc} QuebraReg
Quebra Registro
@type Function
@author Valdemar Roberto Mognon
@since 14/03/2022
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Function QuebraReg(cCodFon,cCodReg,cSeqReg,aLayout)
Local aAreas    := {DN5->(GetArea()),GetArea()}
Local aRet      := {}
Local cRegistro := ""
Local cCampo    := ""
Local nCntFor1  := 0

Default cCodFon := ""
Default cCodReg := ""
Default cSeqReg := ""
Default aLayout := {}

DN5->(DbSetOrder(1))
If DN5->(DbSeek( xFilial("DN5") + cCodFon + cCodReg + cSeqReg ))
	cRegistro := DN5->DN5_CONTEU
	For nCntFor1 := 1 To Len(aLayout)
		cCampo    := SubStr(cRegistro,1,aLayout[nCntFor1,5])
		cRegistro := SubStr(cRegistro,aLayout[nCntFor1,5] + 1)
		If aLayout[nCntFor1,4] == "N"
			Aadd(aRet,Val(cCampo) / (10^aLayout[nCntFor1,6]) )
		ElseIf aLayout[nCntFor1,4] == "D"
			Aadd(aRet,SToD(cCampo))
		Else
			Aadd(aRet,cCampo)
		EndIf
	Next nCntFor1
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return Aclone(aRet)

/*{Protheus.doc} ApontaOcor
Aponta Ocorrência
@type Function
@author Valdemar Roberto Mognon
@since 15/03/2022
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Function ApontaOcor(cFilOri,cViagem,cFilDoc,cDoc,cSerie,cSerTMS,cCodOco,dDatOco,cHorOco,cRecebe,nQtdVol,nPeso,aDados,cErro)
Local aAreas := {DT6->(GetArea()),GetArea()}
Local aCab   := {}
Local aItens := {}
Local nErro  := 0
Local aErro  := {}

Private lMsErroAuto := .F.
Private lAutoErrNoFile	:= .T.

Default cFilOri := ""
Default cViagem := ""
Default cFilDoc := ""
Default cDoc    := ""
Default cSerie  := ""
Default cSerTMS := ""
Default cCodOco := ""
Default dDatOco := CToD("")
Default cHorOco := ""
Default cRecebe := ""
Default nQtdVol := 0
Default nPeso   := 0
Default aDados  := {}
Default cErro   := ""

//-- Mapa do Vetor aDados
//-- Filial do documento + Número do documento + Série do documento
//-- Vetor aNotas (aCols das notas com pendência do TMSA360)
//--	Número da nota fiscal
//--	Série da nota fiscal
//--	Quantidade de volumes da nota fiscal
//--	Quantidade de volumes pendentes
//--	Descrição dos produtos (fixo << Enter >>  )
//--	Linha deletada (fixo .F.)
//-- Vetor aItens
//--	Número da nota fiscal
//--	Peso da nota fiscal
//-- Código da ocorrência
//-- Tipo da pendência (quando a ocorrência for do tipo 06)
//-- Linha do grid dos Ctes na qual a nota com pendência está inserida

//-- Cabeçalho da Ocorrência
If !Empty(cFilOri) .And. !Empty(cViagem)
	Aadd(aCab,{"DUA_FILORI",cFilOri,Nil})
	Aadd(aCab,{"DUA_VIAGEM",cViagem,Nil})
EndIf

//-- Itens da Ocorrência
If Empty(aDados) .And. ( nQtdVol == 0 .Or. nPeso == 0 )
	DT6->(DbSetOrder(1))
	DT6->(DbSeek(xFilial("DT6") + cFilDoc + cDoc + cSerie))
	If nQtdVol == 0
		nQtdVol := Iif( DT6->DT6_VOLORI > 0, DT6->DT6_VOLORI, 1 )
	EndIf
	If nPeso == 0
		nPeso := Iif( DT6->DT6_PESO > 0, DT6->DT6_PESO, 1 )
	EndIf
EndIf

Aadd(aItens,{{"DUA_SEQOCO",StrZero(1,Len(DUA->DUA_SEQOCO)),Nil},;
			 {"DUA_DATOCO",dDatOco                        ,Nil},;
			 {"DUA_HOROCO",cHorOco                        ,Nil},;
			 {"DUA_CODOCO",cCodOco                        ,Nil},;
			 {"DUA_RECEBE",cRecebe                        ,Nil},;
			 {"DUA_SERTMS",cSerTMS                        ,Nil},;
			 {"DUA_FILDOC",cFilDoc                        ,Nil},;
			 {"DUA_DOC"   ,cDoc                           ,Nil},;
			 {"DUA_SERIE" ,cSerie                         ,Nil},;
			 {"DUA_QTDOCO",nQtdVol                        ,Nil},;
			 {"DUA_PESOCO",nPeso                          ,Nil}})

MsExecAuto({|w,x,y,z|Tmsa360(w,x,y,z)},aCab,aItens,aDados,3)

If lMsErroAuto
	aErro := GetAutoGRLog()
	For nErro := 1 To Len(aErro)
		cErro += aErro[nErro] + CRLF
	Next
	If !IsBlind()
		TMSErrDtl(cErro)
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
FwFreeArray(aAreas)
FwFreeArray(aCab)
FwFreeArray(aItens)
FwFreeArray(aErro)

Return !lMsErroAuto

/*{Protheus.doc} ApontaComp
Aponta Comprovante de Entrega Normal
@type Function
@author Valdemar Roberto Mognon
@since 17/03/2022
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Function ApontaComp(cFilDoc,cDoc,cSerie,dDatEnt,cHorEnt,dDatCnt,cHorCnt)
Local aAreas    := {DTC->(GetArea()),DT6->(GetArea()),DU1->(GetArea()),GetArea()}
Local cLotCET   := ""
Local cSeekDTC  := ""
Local cQuery    := ""
Local cAliasDU1 := ""
Local aNFsComp  := {}

Default cFilDoc := ""
Default cDoc    := ""
Default cSerie  := ""
Default dDatEnt := dDataBase
Default cHorEnt := SubStr(Time(),1,2) + SubStr(Time(),4,2)
Default dDatCnt := dDataBase
Default cHorCnt := SubStr(Time(),1,2) + SubStr(Time(),4,2)

//-- Busca um lote de comprovante de entrega na data de hoje
//-- Se encontrar usa ele, e caso contrario cria um novo
cAliasDU1 := GetNextAlias()

cQuery += "SELECT MAX(DU1_LOTCET) ULTREG "

cQuery += "  FROM " + RetSqlName("DU1") + " DU1 "

cQuery += " WHERE DU1_FILIAL = '" + xFilial("DU1") + "' "
cQuery += "   AND DU1_DATLOT = '" + DToS(dDataBase) + "' "
cQuery += "   AND DU1.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasDU1,.F.,.T.)

If (cAliasDU1)->(EoF()) .Or. Empty((cAliasDU1)->ULTREG)
	cLotCET := GETSX8NUM("DU1","DU1_LOTCET")
Else
	cLotCET := (cAliasDU1)->ULTREG
EndIf

(cAliasDU1)->(DbCloseArea())

//-- Atualiza lote de comprovante de entrega e CTe
DT6->(DbSetOrder(1))
If DT6->(DbSeek(xFilial("DT6") + cFilDoc + cDoc + cSerie))
	DU1->(DbSetOrder(2))
	If !DU1->(DbSeek(xFilial("DU1") + cFilDoc + cDoc + cSerie))

		DTC->(DbSetOrder(3))
		If DTC->(DbSeek(cSeekDTC := xFilial("DTC") + cFilDoc + cDoc + cSerie))
			While DTC->(!Eof()) .And. DTC->(DTC_FILIAL + DTC_FILDOC + DTC_DOC + DTC_SERIE) == cSeekDTC
				//-- Gera comprovante de entrega
				RecLock("DU1",.T.)
				DU1->DU1_FILIAL := xFilial("DU1")
				DU1->DU1_LOTCET := cLotCET
				DU1->DU1_CODCLI := DT6->DT6_CLIDEV
				DU1->DU1_LOJCLI := DT6->DT6_LOJDEV
				DU1->DU1_DATLOT := dDataBase
				DU1->DU1_FILDOC := cFilDoc
				DU1->DU1_DOC    := cDoc
				DU1->DU1_SERIE  := cSerie
				DU1->DU1_NUMNFC := DTC->DTC_NUMNFC
				DU1->DU1_SERNFC := DTC->DTC_SERNFC
				DU1->DU1_FIMP   := StrZero(0,Len(DU1->DU1_FIMP))
				DU1->DU1_DATENT := dDatEnt
				DU1->DU1_HORENT := cHorEnt
				DU1->DU1_DATCNT := dDatCnt
				DU1->DU1_HORCNT := cHorCnt
				DU1->(MsUnlock())
				
				AAdd( aNFsComp, DT6->DT6_CHVCTE + DTC->DTC_NFEID )

				DTC->(DbSkip())
			EndDo
		EndIf
				
		//-- Atualiza CTe
		RecLock("DT6",.F.)
		DT6->DT6_LOTCET := cLotCEt
		DT6->(MsUnLock())

	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return aNFsComp

/*{Protheus.doc} ApontaCEle
Aponta Comprovante de Entrega Eletronico
@type Function
@author Valdemar Roberto Mognon
@since 17/03/2022
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Function ApontaCEle(cAlias,nOpcx,aDados,cChave,nIndice)
Local aAreas := {DM0->(GetArea()),DLY->(GetArea()),GetArea()}
Local nCmpos := 0
Local lSeek  := .F.

Default cAlias  := ""
Default nOpcx   := 0
Default aDados  := {}
Default cChave  := ""
Default nIndice := 0

If nOpcx == 3 .Or. nOpcx == 4	//-- Inclusão ou Alteração
	(cAlias)->(DbSetOrder(nIndice))
	lSeek := (cAlias)->(DbSeek(cChave))
	If ( nOpcx == 3 .And. !lSeek ) .Or. ( nOpcx == 4 .And. lSeek )
		RecLock(cAlias,Iif(nOpcx == 3,.T.,.F.))
		For nCmpos := 1 To Len(aDados)
			(cAlias)->(FieldPut(FieldPos(aDados[nCmpos][1]),aDados[nCmpos][2]))
		Next
		(cAlias)->(MsUnlock())
	EndIf
ElseIf nOpcx == 5	//-- Exclusão
	(cAlias)->(DbSetOrder(nIndice))
	If (cAlias)->(DbSeek(cChave))
		RecLock(cAlias,.F.)
		(cAlias)->(DbDelete())
		(cAlias)->(MsUnlock())
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return

/*{Protheus.doc} BscDocCEnt
Busca Documentos da Viagem
@type Function
@author Valdemar Roberto Mognon
@since 22/03/2022
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Function BscDocCEnt(cFilOri,cViagem,cCodFon)
Local aAreas    := {GetArea()}
Local aRet      := {}
Local cQuery    := ""
Local cAliasDUD := ""

Default cFilOri := ""
Default cViagem := ""
Default cCodFon := ""

If !Empty(cFIlOri) .And. !Empty(cViagem)
	cAliasDUD := GetNextAlias()
	cQuery := "SELECT DUD_FILDOC,DUD_DOC,DUD_SERIE "
	cQuery += "  FROM " + RetSqlName("DUD") + " DUD "
	cQuery += " WHERE DUD.DUD_FILIAL = '" + xFilial("DUD") + "' "
	cQuery += "   AND DUD.DUD_FILORI = '" + cFilOri + "' "
	cQuery += "   AND DUD.DUD_VIAGEM = '" + cViagem + "' "
	cQuery += "   AND DUD.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasDUD,.F.,.T.)
	
	While (cAliasDUD)->(!EoF())
		Aadd(aRet,{(cAliasDUD)->DUD_FILDOC,(cAliasDUD)->DUD_DOC,(cAliasDUD)->DUD_SERIE})
		(cAliasDUD)->(DbSkip())
	EndDo
EndIf

(cAliasDUD)->(DbCloseArea())

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return aRet

/*{Protheus.doc} MontaReg
Monta registro para envio ao coleta/entrega
@type Function
@author Valdemar Roberto Mognon
@since 18/04/2022
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Function MontaReg(aLayout,nSequen,lGrava,cSequen,lPrimeiro)
Local aIndice   := {}
Local aDadosReg := {}
Local aLayAdi   := {}
Local aRegistro := {}
Local cCampo    := ""
Local cLinha    := ""
Local cLinInd   := ""
Local cAlias    := ""
Local cIndice   := ""
Local nCntFor1  := 0
Local nSeqAdi   := 0
Local cCndDep   := ""

Default aLayout   := {}
Default nSequen   := 0
Default lGrava    := .T.
Default cSequen   := ""
Default lPrimeiro := .F.

If !Empty(aStruct) .And. nSequen > 0
	cAlias  := aStruct[nSequen,3]
	cIndice := aStruct[nSequen,4]
	
	aIndice := BscChave(cAlias,cIndice)

	//-- Registro
	For nCntFor1 := 1 To Len(aLayout)
		If !Empty(aLayout[nCntFor1,Len(aLayout[nCntFor1])])
			cCampo := &(aLayout[nCntFor1,Len(aLayout[nCntFor1])])
		Else
			cCampo := &(cAlias + "->" + aLayout[nCntFor1,3])
		EndIf
		If aLayout[nCntFor1,4] == "N"
			If aLayout[nCntFor1,6] == 0
				cCampo := StrZero(cCampo,aLayout[nCntFor1,5])
			Else
				cCampo := StrZero(cCampo * 10^aLayout[nCntFor1,6],aLayout[nCntFor1,5])
			EndIf
		ElseIf aLayout[nCntFor1,4] == "D"
			cCampo := PadR(DToS(cCampo),aLayout[nCntFor1,5])
		Else
			cCampo := PadR(cCampo,aLayout[nCntFor1,5])
		EndIf
		Aadd(aDadosReg,{aLayout[nCntFor1,3],cCampo})
		cLinha += cCampo
	Next nFntFor1

	//-- Chave
	For nCntFor1 := 1 To Len(aIndice)
		cLinInd += &(cAlias + "->" + aIndice[nCntFor1])
	Next nCntFor1

	If !Empty(cLinInd) .And. !Empty(cLinha)
		//-- Grava De/Para
		GrvDePara(aStruct[nSequen,1],aStruct[nSequen,2],cLinInd,lGrava)
		//-- Grava Histórico
		Aadd(aRegistro,{"DN5_CODOPE","1"})			//-- Inclusão
		Aadd(aRegistro,{"DN5_SITUAC","1"})			//-- Em Aberto
		Aadd(aRegistro,{"DN5_STATUS","2"})			//-- Não Integrado
		Aadd(aRegistro,{"DN5_PROCES",cProcesso})	//-- Processo
		Aadd(aRegistro,{"DN5_CONTEU",cLinha})		//-- Conteudo
		Aadd(aRegistro,{"DN5_CHAVE" ,cLinInd})		//-- Chave
		Aadd(aRegistro,{"DN5_DATGER",dDataBase})	//-- Chave
		Aadd(aRegistro,{"DN5_HORGER",SubStr(Time(),1,2) + SubStr(Time(),4,2)})	//-- Chave
		Aadd(aRegistro,{"DN5_FILORI",cFilAnt})		//-- Filial do Registro
		TMSGrvDN5(aStruct[nSequen,1],aStruct[nSequen,2],aRegistro,lGrava,cSequen,lPrimeiro)
	EndIf

	If !Empty(aStruct[nSequen,11]) .And. !Empty(aStruct[nSequen,12])
		If (nSeqAdi := Ascan(aStruct,{|x| x[1] + x[2] == aStruct[nSequen,11] + aStruct[nSequen,12]})) > 0	//-- Sequencia do registro adicional dentro da estrutura
			aLayAdi := BscLayout(aStruct[nSequen,11],aStruct[nSequen,12])
			cCndDep := Iif(Empty(aStruct[nSeqAdi,9]),".T.",AllTrim(aStruct[nSeqAdi,9]))
			If &(cCndDep)
				MontaReg(Aclone(aLayAdi),nSeqAdi)
			EndIf
		EndIf
	EndIf
EndIf

Return

/*{Protheus.doc} GrvDePara
Grava De/Para
@type Function
@author Valdemar Roberto Mognon
@since 18/04/2022
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Function GrvDePara(cCodFon,cCodReg,cChave,lGrava)
Local aAreas := {DN4->(GetArea()),GetArea()}

Default cCodFon := ""
Default cCodReg := ""
Default cChave  := ""
Default lGrava  := .T.

If lGrava
	DN4->(DbSetOrder(1))
	If !DN4->(DbSeek(xFilial("DN4") + cCodFon + cCodReg + PadR(cChave,Len(DN4->DN4_CHAVE))))
		RecLock("DN4",.T.)
		DN4->DN4_FILIAL := xFilial("DN4")
		DN4->DN4_CODFON := cCodFon
		DN4->DN4_CODREG := cCodReg
		DN4->DN4_CHAVE  := cChave
		DN4->DN4_DATGER := dDataBase
		DN4->DN4_HORGER := SubStr(Time(),1,2) + SubStr(Time(),4,2)
		DN4->DN4_STATUS := StrZero(2,Len(DN4->DN4_STATUS))	//-- Não Integrado
		DN4->(MsUnlock())
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return

/*{Protheus.doc} TMSGrvDN5
Grava Historico
@author Valdemar Roberto Mognon
@since 18/04/2022
*/
Function TMSGrvDN5(cCodFon,cCodReg,aRegistro,lGrava,cSequencia,lPrimeiro)
Local aAreas    := {DN5->(GetArea()),GetArea()}
Local cSeekDN5  := ""
Local cSequen   := ""
Local cLocaliza := ""
Local nCntFor1  := 0
Local nSeqIde   := 0

Default cCodFon    := ""
Default cCodReg    := ""
Default aRegistro  := {}
Default lGrava     := .T.
Default cSequencia := ""
Default lPrimeiro  := .F.

	If lGrava
		cSeekDN5 := xFilial("DN5") + cCodFon + cCodReg
		DN5->(DbSetOrder(1))
		DN5->(DbSeek(cSeekDN5 + Replicate("Z",Len(DN5->DN5_SEQUEN)),.T.))
		DN5->(DbSkip(-1))
	
		If DN5->(DN5_FILIAL + DN5_CODFON + DN5_CODREG ) != cSeekDN5
			cSequen := StrZero(1,Len(DN5->DN5_SEQUEN))
		Else
			cSequen := Soma1(DN5->DN5_SEQUEN)
		EndIf
	Else
		cSequen := cSequencia
	EndIf
	
	//-- Define o localizador do registro
	If (nSeqIde := Ascan(aLocaliza,{|x| x[3] == aStruct[Ascan(aStruct,{|x| x[1] + x[2] == cCodFon + cCodReg}),5]})) == 0
		Aadd(aLocaliza,{cCodReg,"#" + cCodReg + cSequen,aStruct[Ascan(aStruct,{|x| x[1] + x[2] == cCodFon + cCodReg}),5]})
		nSeqIde := Len(aLocaliza)
	Else
		For nCntFor1 := nSeqIde To Len(aLocaliza)
			aLocaliza[nCntFor1,2] := ""
		Next nCntFor1
		aLocaliza[nSeqIde,2] := "#" + cCodReg + cSequen
	EndIf
	For nCntFor1 := 1 To nSeqIde
		If !Empty(aLocaliza[nCntFor1,2])
		cLocaliza += aLocaliza[nCntFor1,2]
		EndIf
	Next nCntFor1

	If lGrava
		RecLock("DN5",.T.)
		DN5->DN5_FILIAL := xFilial("DN5")
		DN5->DN5_CODFON := cCodFon
		DN5->DN5_CODREG := cCodReg
		DN5->DN5_SEQUEN := cSequen
		DN5->DN5_LOCALI := cLocaliza
		
		For nCntFor1 := 1 To Len(aRegistro)
			DN5->(FieldPut(FieldPos(aRegistro[nCntFor1,1]),aRegistro[nCntFor1,2]))
		Next nCntFor1
		
		DN5->(MsUnlock())

		If lPrimeiro
			TMSGrvDNC(DN5->DN5_PROCES,DN5->DN5_CODFON,DN5->DN5_CODOPE,DN5->DN5_SITUAC,DN5->DN5_CODREG,DN5->DN5_LOCALI,DN5->DN5_STATUS)
		EndIf
	EndIf

	AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return

/*{Protheus.doc} BscChave
Busca Layout
@type Function
@author Valdemar Roberto Mognon
@since 18/04/2022
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Function BscChave(cAlias,cIndice)
Local aRet    := {}
Local cCampo  := ""
Local nPos    := 0

Default cAlias  := ""
Default cIndice := ""

cIndice := TMSAI82Ind(cAlias,cIndice,.F.)

While !Empty(cIndice)
	If (nPos := At("+",cIndice)) > 0
		cCampo  := SubStr(cIndice,1,nPos - 1)
		cIndice := SubStr(cIndice,nPos + 1)
		If (nPos := At("(",cCampo)) > 0
			cCampo := SubStr(cCampo,nPos + 1)
			cCampo := StrTran(cCampo,")","")
		EndIf
	Else
		cCampo  := cIndice
		cIndice := ""
	EndIf
	Aadd(aRet,AllTrim(cCampo))
EndDo

Return Aclone(aRet)

/*{Protheus.doc} BscIDMot
Busca ID Externo do Motorista
@type Function
@author Valdemar Roberto Mognon
@since 09/05/2022
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Function BscIDMot(cCodMot,cCodFon,lChkLst)
Local cRet   := ""
Local aAreas := {DN7->(GetArea()),DA4->(GetArea()),GetArea()}

Default cCodMot := ""
Default cCodFon := ""
Default lChkLst := .F.

If AliasInDic("DN7")
	DN7->(DbSetOrder(1))
	If DN7->(DbSeek(xFilial("DN7") + cCodMot + cCodFon))
		cRet := DN7->DN7_IDEXT
	Else
		If lChkLst
			DA4->(DbSetOrder(1))
			If DA4->(DbSeek(xFilial("DA4") + cCodMot))
				cRet := DA4->DA4_APPLOG
			EndIf
		EndIf
	EndIf
Else
	DA4->(DbSetOrder(1))
	If DA4->(DbSeek(xFilial("DA4") + cCodMot))
		cRet := DA4->DA4_APPLOG
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return cRet

/*{Protheus.doc} TMSMntJSon
Monta JSon dinamicamente
@type Function
@author Valdemar Roberto Mognon
@since 16/05/2022
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Function TMSMntJSon(cCodFon,cCodReg,cBase,cConteudo)
Local aAreas    := {DN3->(GetArea()),GetArea()}
Local cJSon     := ""
Local cSeekDN3  := ""
Local cCampo    := ""
Local nPosicao  := 1
Local nTamanho  := 0

Default cCodFon   := ""
Default cCodReg   := ""
Default cBase     := ""
Default cConteudo := ""

cJSon := cBase

DN3->(DbSetOrder(1))
If DN3->(DbSeek(cSeekDN3 := xFilial("DN3") + cCodFon + cCodReg))
	While DN3->(!Eof()) .And. DN3->(DN3_FILIAL + DN3_CODFON + DN3_CODREG) == cSeekDN3
		nTamanho := DN3->DN3_TAMANH
		cCampo   := SubStr(cConteudo,nPosicao,nTamanho)
		If DN3->DN3_TIPO == "N"
			cCampo := cValToChar( Val(cCampo) / (10^DN3->DN3_DECIMA) )
		Elseif DN3->DN3_TIPO == "D"
			cCampo := LocalToUTC( AllTrim(cCampo), "00:00:00" ) [1]
		EndIf
		cJSon    := StrTran(cJSon,"#" + AllTrim(DN3->DN3_CAMPO) + "#",AllTrim(cCampo))
		nPosicao += nTamanho
		DN3->(DbSkip())
	EndDo
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return cJSon

/*{Protheus.doc} TMSMntStru
Monta estrutura dos registros que serão enviados
@type Function
@author Valdemar Roberto Mognon
@since 23/05/2022
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Function TMSMntStru(cCodFon,lDecres)
Local aAreas   := {DN2->(GetArea()),GetArea()}
Local aRet     := {}
Local cSeekDN2 := ""

Default lDecres := .T.

//-- Mapa do vetor aRet
//-- 01 - Código da fonte
//-- 02 - Código do registro
//-- 03 - Alias do registro
//-- 04 - Indice do registro
//-- 05 - Prioridade de envio
//-- 06 - Registro do qual o alias do registro é dependente
//-- 07 - Comando de posicionamento no alias de dependência
//-- 08 - Condição de repetição (loop) dos registros
//-- 09 - Condição de uso do registro do alias de dependência
//-- 10 - Indica se o registro já foi processado
//-- 11 - Fonte do registro adicional
//-- 12 - Registro adicional

If !Empty(cCodFon)
	DN2->(DbSetOrder(2))
	If DN2->(DbSeek(cSeekDN2 := xFilial("DN2") + cCodFon))
		While DN2->(!Eof()) .And. DN2->(DN2_FILIAL + DN2_CODFON) == cSeekDN2
			If DN2->DN2_ATIVO == StrZero(1,Len(DN2->DN2_ATIVO))	//-- Sim
				Aadd(aRet,{DN2->DN2_CODFON,DN2->DN2_CODREG,DN2->DN2_ALIAS,DN2->DN2_INDICE,DN2->DN2_PRIORI,DN2->DN2_REGDEP,;
						   DN2->DN2_POSDEP,DN2->DN2_REPDEP,DN2->DN2_CNDDEP,"2",DN2->DN2_CODFON,DN2->DN2_REGADI,""})
			EndIf
			DN2->(DbSkip())
		EndDo
	EndIf
EndIf

If lDecres
	aSort(aRet,,,{|x,y| x[5] > y[5]})	//-- Ordena pela prioridade de forma decrescente
Else
	aSort(aRet,,,{|x,y| x[5] < y[5]})	//-- Ordena pela prioridade de forma crescente
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return Aclone(aRet)

/*{Protheus.doc} TMSLoopReg
Executa o loop de dependência entre registros
@type Function
@author Valdemar Roberto Mognon
@since 24/05/2022
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Function TMSLoopReg(aLayLoop,nSeqDep)
Local cAlias   := ""
Local cIndice  := ""
Local cRegAtu  := ""
Local cPosDep  := ""
Local cRepDep  := ""
Local cCndDep  := ""
Local nIndice  := 0
Local nCntFor1 := 0
Local aLayDep  := {}

Default aLayLoop := {}
Default nSeqDep  := 0

If !Empty(aStruct) .And. !Empty(nSeqDep)
	cRegAtu := aStruct[nSeqDep,2]
	cAlias  := aStruct[nSeqDep,3]
	cIndice := aStruct[nSeqDep,4]
	cPosDep := AllTrim(aStruct[nSeqDep,7])
	cRepDep := AllTrim(aStruct[nSeqDep,8])
	cCndDep := Iif(Empty(aStruct[nSeqDep,9]),".T.",AllTrim(aStruct[nSeqDep,9]))
	
	nIndice := Val(Iif(Asc(cIndice) < 65,cIndice,AllTrim(Str(Asc(cIndice) - 55))))

	//-- Seta índice
	(cAlias)->(DbSetOrder(nIndice))
	//-- Posiciona registro
	If (cAlias)->(DbSeek(&(cPosDep)))
		//-- Executa loop
		If !Empty(cRepDep)
			While (cAlias)->(!Eof()) .And. &(cRepDep)
				//-- Ajusta flag de execução do registro (quando mais de um registro no loop precisa voltar flag dos de baixo)
				For nCntFor1 := (nSeqDep + 1) To Len(aStruct)
					aStruct[nCntFor1,10] := "2"
				Next nCntFor1
				//-- Verifica condição
				If &(cCndDep)
					MontaReg(Aclone(aLayLoop),nSeqDep)
					TMSCtrLoop(Aclone(aLayLoop),nSeqDep)
				EndIf
	
				//-- Verifica a dependência no próximo registro
				While (nSequen := Ascan(aStruct,{|x| x[6] + x[10] == cRegAtu + "2"})) > 0	//-- Existe registro dependente do alias atual
					aLayDep := BscLayout(aStruct[nSequen,1],aStruct[nSequen,2])
					TMSLoopReg(Aclone(aLayDep),nSequen)
				EndDo
	
				(cAlias)->(DbSkip())
			EndDo
		Else
			If &(cCndDep)
				MontaReg(Aclone(aLayLoop),nSeqDep)
				TMSCtrLoop(Aclone(aLayLoop),nSeqDep)
			EndIf
		EndIf
	Else
		TMSCtrLoop(Aclone(aLayLoop),nSeqDep)
	EndIf
	aStruct[nSeqDep,10] := "1"
EndIf

Return

/*{Protheus.doc} TMSCtrLoop
Controla o loop de dependência entre registros
@type Function
@author Valdemar Roberto Mognon
@since 26/05/2022
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Function TMSCtrLoop(aLayCtrl,nSequen)
Local nSeqDep := 0
Local cRegAtu := ""
Local aLayDep := {}

Default aLauCtrl := {}
Default nSequen  := 0

If !Empty(aStruct) .And. !Empty(nSequen)
	cRegAtu := aStruct[nSequen,2]

	If (nSeqDep := Ascan(aStruct,{|x| + x[6] + x[10] == cRegAtu + "2"})) > 0	//-- Existe registro dependente do alias atual
		aLayDep := BscLayout(aStruct[nSeqDep,1],aStruct[nSeqDep,2])
		TMSLoopReg(Aclone(aLayDep),nSeqDep)
	EndIf
EndIf

Return

/*{Protheus.doc} TMSGetVar
Retorna conteudo variáveis estaticas
@type Function
@author Valdemar Roberto Mognon
@since 26/05/2022
@version 12.1.30
*/
Function TMSGetVar(cVar)	

Return &(cVar)

/*{Protheus.doc} TMSSetVar
Seta variáveis estaticas
@type Function
@author Valdemar Roberto Mognon
@since 26/05/2022
@version 12.1.30
*/
Function TMSSetVar(cVar,xCont)

&(cVar) := xCont

Return

/*{Protheus.doc} TMSDefEnd
Busca dados do cliente e endereço
@type Function
@author Valdemar Roberto Mognon
@since 27/05/2022
@version 12.1.30
*/
Function TMSDefEnd(cFilDoc,cDoc,cSerie,cTipo)
Local aDados  := {}
Local oColEnt

Default cFilDoc := ""
Default cDoc    := ""
Default cSerie  := ""
Default cTipo   := ""

If !Empty(cFilDoc) .And. !Empty(cDoc) .And. !Empty(cSerie)
    oColEnt := TMSBCACOLENT():New("DN1")

	If cTipo == "CARGA"
		aDados := OMSDocEnd(cDoc,cSerie)
	Else
		aDados := TMSDocEnd(cFilDoc,cDoc,cSerie)
	EndIf
	
	aDadosRem := TMSAI86VCL(aDados,Iif(cTipo == "CARGA",1,Iif(DUD->DUD_SERTMS == "1",1,2)))
	If (cTipo == "" .And. DUD->DUD_SERTMS != "1" .Or. !Empty(aDados[2,1])) .Or. cTipo == "CARGA"
		aDadosDes := TMSAI86VCL(aDados,Iif(cTipo == "CARGA",2,Iif(DUD->DUD_SERTMS == "1",2,1)))
	EndIf
EndIf

Return

/*{Protheus.doc} PesoCol
Totaliza os dados da coleta
@type Function
@author Valdemar Roberto Mognon
@since 01/06/2022
@version 12.1.30
*/
Function PesoCol(cFilOri,cNumSol)
Local aAreas    := {GetArea()}
Local cQuery    := ""
Local cAliasQry := ""

Default cFilOri := ""
Default cNumSol := ""

aDadosCol := {}

cAliasQry := GetNextAlias()
cQuery := "SELECT SUM(DUM_QTDVOL) DUM_QTDVOL,SUM(DUM_PESO) DUM_PESO,SUM(DUM_PESOM3) DUM_PESOM3,SUM(DUM_VALMER) DUM_VALMER "
cQuery += "  FROM " + RetSqlName("DUM") + " DUM "
cQuery += " WHERE DUM.DUM_FILIAL = '" + xFilial("DUM") + "' "
cQuery += "   AND DUM.DUM_FILORI = '" + cFilOri + "' "
cQuery += "   AND DUM.DUM_NUMSOL = '" + cNumSol + "' "
cQuery += "   AND DUM.D_E_L_E_T_= ' ' "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)

If !(cAliasQry)->(EoF())
	Aadd(aDadosCol,(cAliasQry)->DUM_QTDVOL)
	Aadd(aDadosCol,(cAliasQry)->DUM_PESO)
	Aadd(aDadosCol,(cAliasQry)->DUM_PESOM3)
	Aadd(aDadosCol,(cAliasQry)->DUM_VALMER)
EndIf

(cAliasQry)->(DbCloseArea())

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return

/*{Protheus.doc} GrvHeranca
Grava Herança do ID na Integração entre Sistemas
@type Function
@author Valdemar Roberto Mognon
@since 14/06/2022
@version 12.1.30
*/
Function GrvHeranca(cCodFon,cCodReg,cSequen)
Local aAreas   := {DN3->(GetArea()),DN5->(GetArea()),DNB->(GetArea()),GetArea()}
Local aAreaAnt := {}
Local cTexto   := ""
Local cLocali  := ""
Local cSeekDNB := ""
Local cSeekDN3 := ""
Local cChave   := ""
Local cIdExt   := ""
Local nPosLoc  := 0
Local nTamanho := 0
Local nPos     := 0

Default cCodFon := ""
Default cCodReg := ""
Default cSequen := ""

If !Empty(cCodFon) .And. !Empty(cCodReg) .And. !Empty(cSequen)
	//-- Lê registro que possui o ID Externo
	DN5->(DbSetOrder(1))
	DN3->(DbSetOrder(1))
	If DN5->(DbSeek(xFilial("DN5") + cCodFon + cCodReg + cSequen))
		cLocali := DN5->DN5_LOCALI
		cIdExt  := DN5->DN5_IDEXT
		//-- Busca todos os registros herdeiros
		DNB->(DbSetOrder(1))
		If DNB->(DbSeek(cSeekDNB := xFilial("DNB") + cCodFon + cCodReg))
			While DNB->(!Eof()) .And. DNB->(DNB_FILIAL + DNB_CODFON + DNB_CODREG) == cSeekDNB
				aAreaAnt := DN5->(GetArea())
				//-- Busca o localizador do registro herdeiro
				If (nPosLoc := At("#" + DNB->DNB_REGDES,cLocali)) > 0
					cChave := PadR(Left(cLocali,nPosLoc + 12),Len(DN5->DN5_LOCALI))
					//-- Guarda posição atual do loop e busca registro herdeiro
					DN5->(DbSetOrder(4))
					If DN5->(DbSeek(xFilial("DN5") + cCodFon + cChave))
						cTexto := DN5->DN5_CONTEU
						If DN3->(DbSeek(cSeekDN3 := xFilial("DN3") + cCodFon + DNB->DNB_REGDES))
							//-- Localiza a sequencia do ID externo dentro do conteudo do registro
							nTamanho := 0
							While DN3->(!Eof()) .And. DN3->(DN3_FILIAL + DN3_CODFON + DN3_CODREG) == cSeekDN3
								If DN3->DN3_CAMPO == DNB->DNB_CPODES
									If nTamanho > 0
										cTexto := Left(cTexto,nTamanho) + PadR(cIdExt,DN3->DN3_TAMANH) + SubStr(cTexto,nTamanho + DN3->DN3_TAMANH + 1)
									Else
										cTexto := PadR(cIdExt,DN3->DN3_TAMANH) + SubStr(cTexto,DN3->DN3_TAMANH + 1)
									EndIf
								Else
									nTamanho += DN3->DN3_TAMANH
								EndIf
								DN3->(DbSkip())
							EndDo
						EndIf
					EndIf
					RecLock("DN5",.F.)
					DN5->DN5_CONTEU := cTexto
					DN5->(MsUnlock())
					RestArea(aAreaAnt)
				EndIf
	
				cLocali := AllTrim(DN5->DN5_LOCALI)
				cChave := DN5->(DN5_FILIAL+DN5_CODFON+DN5_PROCES) + cLocali
				DN5->(DbSetOrder(5))
				DN5->( MsSeek( cChave ) )
				Do While !DN5->(Eof()) .And. DN5->(DN5_FILIAL+DN5_CODFON+DN5_PROCES) + Left(DN5->DN5_LOCALI,Len(cLocali)) == cChave 
					If (nPos := RAt('#'+ DNB->DNB_REGDES,AllTrim(DN5->DN5_LOCALI)) ) > 0 .And. RAt('#',AllTrim(DN5->DN5_LOCALI)) == nPos
						cTexto := DN5->DN5_CONTEU
						If DN3->(DbSeek(cSeekDN3 := xFilial("DN3") + cCodFon + DNB->DNB_REGDES))
							//-- Localiza a sequencia do ID externo dentro do conteudo do registro
							nTamanho := 0
							While DN3->(!Eof()) .And. DN3->(DN3_FILIAL + DN3_CODFON + DN3_CODREG) == cSeekDN3
								If DN3->DN3_CAMPO == DNB->DNB_CPODES
									If nTamanho > 0
										cTexto := Left(cTexto,nTamanho) + PadR(cIdExt,DN3->DN3_TAMANH) + SubStr(cTexto,nTamanho + DN3->DN3_TAMANH + 1)
									Else
										cTexto := PadR(cIdExt,DN3->DN3_TAMANH) + SubStr(cTexto,DN3->DN3_TAMANH + 1)
									EndIf
								Else
									nTamanho += DN3->DN3_TAMANH
								EndIf
								DN3->(DbSkip())
							EndDo
							RecLock("DN5",.F.)
							DN5->DN5_CONTEU := cTexto
							DN5->(MsUnlock())
						EndIf
					EndIf
					DN5->(DbSkip())
				EndDo
				RestArea(aAreaAnt)
				DNB->(DbSkip())
			EndDo
		EndIf
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return

/*{Protheus.doc} TMSGrvDNC
Grava cabeçalho do de/para e histórico
@author Valdemar Roberto Mognon
@since 20/06/2022
*/
Function TMSGrvDNC(cProces,cCodFon,cCodOpe,cSituac,cCodReg,cLocali,cStatus)
Local aAreas := {DNC->(GetArea()),GetArea()}

Default cProces := ""
Default cCodFon := ""
Default cCodOpe := ""
Default cSituac := ""
Default cCodReg := ""
Default cLocali := ""
Default cStatus := ""

DNC->(DbSetOrder(1))
If !DNC->(DbSeek(xFilial("DNC") + cCodFon + cProces))
	RecLock("DNC",.T.)
	DNC->DNC_FILIAL := xFilial("DNC")
	DNC->DNC_PROCES := cProces
	DNC->DNC_CODFON := cCodFon
	DNC->DNC_CODOPE := cCodOpe
	DNC->DNC_SITUAC := cSituac
	DNC->DNC_CODREG := cCodReg
	DNC->DNC_STATUS := cStatus
	DNC->DNC_DATULT := dDataBase
	DNC->DNC_HORULT := SubStr(Time(),1,2) + SubStr(Time(),4,2)
	DNC->(MsUnlock())
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return

/*{Protheus.doc} DocViaCol
Retorna documentos das viagens coligadas
@author Valdemar Roberto Mognon
@since 30/06/2022
*/
Function DocViaCol(cFilOri,cViagem)
Local aAreas    := {GetArea()}
Local aRet      := {}
Local aViaCol   := {}
Local aVgaPri   := {}
Local cQuery    := ""
Local cAliasDUD := ""
Local cViagens  := ""
Local nCntFor1  := 0

Default cFilOri := ""
Default cViagem := ""

aVgaPri := VgaPrincial(cFilOri,cViagem)
aViaCol := VgaColigada(aVgaPri[1,1],aVgaPri[1,2])

For nCntFor1 := 1 To Len(aViaCol)
    cViagens := cViagens + "'" + aViaCol[nCntFor1,2] + "',"
Next nCntFor1
cViagens := "(" + Left(cViagens,Len(cViagens) - 1) + ")"

cAliasDUD := GetNextAlias()
cQuery := "SELECT DUD.DUD_FILDOC, DUD.DUD_DOC, DUD.DUD_SERIE, DTQ.DTQ_FILORI, DTQ.DTQ_VIAGEM, DTQ.DTQ_STATUS "
cQuery += "  FROM " + RetSqlName("DUD") + " DUD "
cQuery += "INNER JOIN " + RetSqlName("DTQ") + " DTQ ON "
cQuery += "   DTQ.DTQ_FILIAL = '" + xFilial("DTQ") + "' AND"
cQuery += "   DTQ.DTQ_FILORI = DUD.DUD_FILORI AND "
cQuery += "   DTQ.DTQ_VIAGEM = DUD.DUD_VIAGEM AND "
cQuery += "   DTQ.D_E_L_E_T_= ' ' "
cQuery += " WHERE DUD.DUD_FILIAL = '" + xFilial("DUD") + "' "
cQuery += "   AND DUD.DUD_FILORI = '" + aVgaPri[1,1] + "' "
cQuery += "   AND DUD.DUD_VIAGEM IN " + cViagens + " "
cQuery += "   AND DUD.D_E_L_E_T_= ' ' "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasDUD,.F.,.T.)

While (cAliasDUD)->(!EoF())
    (cAliasDUD)->( Aadd( aRet, {DTQ_FILORI,DTQ_VIAGEM,DUD_FILDOC,DUD_DOC,DUD_SERIE,DTQ_STATUS,aVgaPri[1][1],aVgaPri[1][2]} ) )
    (cAliasDUD)->( DbSkip() )
EndDo

(cAliasDUD)->(DbCloseArea())

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return aRet

/*{Protheus.doc} PrxSeqTar
Obtem ultima sequencia de tarefas
@author Valdemar Roberto Mognon
@since 07/07/2022
*/
Function PrxSeqTar(cCodFon,cCodReg,cProces)
Local aArea     := GetArea()
Local nRet      := 0
Local cQuery    := ""
Local cAliasDN5 := ""

Default cCodFon := ""
Default cCodReg := ""
Default cProces := cProcesso

cAliasDN5 := GetNextAlias()
cQuery	:= "SELECT COUNT(DN5_PROCES) QUANTIDADE "
cQuery	+= "  FROM " + RetSQLName("DN5") + " DN5 "
cQuery	+= " WHERE DN5_FILIAL = '" + xFilial("DN5") + "' "
cQuery	+= "   AND DN5_CODFON = '" + cCodFon + "' "
cQuery	+= "   AND DN5_CODREG = '" + cCodReg + "' "
cQuery	+= "   AND DN5_PROCES = '" + cProces + "' "
cQuery	+= "   AND DN5.D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasDN5,.F.,.T.)

If (cAliasDN5)->(!Eof())
	nRet := (cAliasDN5)->QUANTIDADE + 1
EndIf

(cAliasDN5)->(DbCloseArea())

RestArea(aArea)

Return nRet

/*{Protheus.doc} ColEntAtiv
Verifica se a integração com coleta entrega está ativa
@author Valdemar Roberto Mognon
@since 05/07/2022
*/
Function ColEntAtiv(cFilOri,cViagem,cStatus)
Local aAreas  := {}
Local lRet    := .F.
Local oColEnt

Default cFilOri  := ""
Default cViagem  := ""
Default cStatus  := ""

If AliasInDic("DN1") .And. ExistFunc( "TMSAC30" )
	aAreas  := { DTQ->(GetArea()), DUP->(GetArea()), DN1->(GetArea()), GetArea() }
	oColEnt := TMSBCACOLENT():New("DN1")
	If oColEnt:DbGetToken() .And. !Empty(oColEnt:filext)
		DN1->(DbGoTo(oColEnt:config_recno))
		DUP->(DbSetOrder(1))
		If DUP->(DbSeek(xFilial("DUP") + cFilOri + cViagem)) .And. !Empty(BscIDMot(DUP->DUP_CODMOT,DN1->DN1_CODFON,))
			If Posicione("DTQ",2,xFilial("DTQ") + cFilOri + cViagem,"DTQ_STATUS") != cStatus
				Help(" ", , "TMSXFUND11", , STR0085, 2, 1) //--Não é permitido o vínculo em viagem coligada com status diferente de Em Aberto, quando a integração com a Gestão de Entregas estiver ativa.
				lRet := .T.
			EndIf
		EndIf
	EndIf
	
	AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
EndIf

Return lRet

/*{Protheus.doc} IncDocto
Verifica se o documento pode ser enviado ao coleta/entrega
@author Valdemar Roberto Mognon
@since 08/08/2022
*/
Function IncDocto()

lIncDocto := .T.

If !Empty(aTransito)
	lIncDocto := Ascan(aTransito,{|x| x[1] + x[2] + x[3] == DUD->(DUD_FILDOC + DUD_DOC + DUD_SERIE)}) > 0
EndIf

Return lIncDocto

/*{Protheus.doc} TMAltColEn
Inclui documentos (coletas) em viagem em transito
@author Carlos Alberto Gomes Junior
@since 16/08/22
*/
Function TMAltColEn( cFilOri, cViagem )
Local aAreas     := { DN1->(GetArea()), DTQ->(GetArea()), DUD->(GetArea()), GetArea() }
Local oColEnt    := TMSBCACOLENT():New("DN1")
Local cQuery     := ""
Local cAliasQry  := GetNextAlias()
Local aViaCol    := {}
Local aViagem    := {}
Local aDocInsert := {}
Local aDocDelete := {}
Local aVetDocs   := {}
Local nDoc       := 0
Local lColEntVia := .F.
Local cIdVia     := ""
Local lRet       := .T.
Local aDocVia    := {}
Local nPosDoc    := 0

    DTQ->(DbSetOrder(2))
    If DTQ->(MsSeek(xFilial("DTQ")+cFilOri+cViagem) ) .And. DTQ->DTQ_STATUS == '2' .And. oColEnt:DbGetToken()

		aViaCol := VgaPrincial( cFilOri, cViagem ) //Busca viagem principal se esta for uma coligada

        DUD->(dBsEToRDER(1))
        DN1->(DbGoTo(oColEnt:config_recno))
        cQuery := "SELECT DN5.DN5_CHAVE, DN5.DN5_CODFON, DN5.DN5_LOCALI, DN5.DN5_IDEXT, DN2.DN2_ALIAS " + CRLF
        cQuery += "FROM " + RetSQLName("DN5") + " DN5 " + CRLF
        cQuery += "INNER JOIN "+RetSQLName("DN2")+" DN2 ON  " + CRLF
        cQuery += "  DN2.DN2_FILIAL = '"+xFilial("DN2")+"' AND  " + CRLF
        cQuery += "  DN2.DN2_CODFON = DN5.DN5_CODFON AND  " + CRLF
        cQuery += "  DN2.DN2_CODREG = DN5.DN5_CODREG AND  " + CRLF
        cQuery += "  ( DN2.DN2_ALIAS  = 'DUD' OR DN2.DN2_ALIAS  = 'DTQ' ) AND  " + CRLF
        cQuery += "  DN2.D_E_L_E_T_ = ''  " + CRLF
        cQuery += "WHERE " + CRLF
        cQuery += "DN5.DN5_FILIAL = '" + xFilial("DN5") + "' AND " + CRLF
        cQuery += "DN5.DN5_FILORI = '" + cFilAnt + "' AND " + CRLF
        cQuery += "DN5.DN5_CODFON = '" + DN1->DN1_CODFON + "' AND " + CRLF
        cQuery += "DN5.DN5_PROCES = '" + aViaCol[1][1] + aViaCol[1][2] + "' AND " + CRLF
        cQuery += "DN5.DN5_STATUS IN ('1','2','3','4') AND " + CRLF
        cQuery += "DN5.D_E_L_E_T_ = '' " + CRLF

        cQuery := ChangeQuery(cQuery)
        DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
        Do While !(cAliasQry)->(Eof())
            lColEntVia := .T.
            If (cAliasQry)->DN2_ALIAS == 'DTQ'
                cIdVia := AllTrim((cAliasQry)->DN5_IDEXT)
            ElseIf (cAliasQry)->DN2_ALIAS == 'DUD'
                AAdd( aVetDocs, RTrim((cAliasQry)->DN5_CHAVE) )
                If !DUD->(MsSeek(xFilial("DUD")+AllTrim((cAliasQry)->DN5_CHAVE)))
                    AAdd( aDocDelete, AllTrim( (cAliasQry)->(DN5_CODFON+DN5_LOCALI) ) )
                EndIf
            EndIf
            (cAliasQry)->(DbSkip())
        EndDo
        (cAliasQry)->(DbCloseArea())

        //Se a viagem tem registros de integração com o coleta entrega
        If lColEntVia .And. ( Empty(cIdVia) .Or. ( lRet := ( aViagem := TMSAC30GDV(cIdVia,,.F.) )[1] ) )
            If !Empty(cIdVia) .And. ( aViagem[2] == "ENCERRADA" .Or. aViagem[2] == "AGUARDANDO_CONFIRMACAO_DESPACHO" )
                Help(" ", , "TMSXFUND12" + " - " + STR0086, , STR0087 + aViagem[2] + STR0088, 2, 1)
                lRet := .F.
            ElseIf Empty(cIdVia) .Or. aViagem[2] != "EXCLUIDA"
                DbSelectArea("DUD")
                DUD->(DbSetOrder(2))
                DUD->(MsSeek(xFilial("DUD")+DTQ->(DTQ_FILORI+DTQ_VIAGEM)))
                Do While !DUD->(Eof()) .And. DUD->(DUD_FILIAL+DUD_FILORI+DUD_VIAGEM) == xFilial("DUD")+DTQ->(DTQ_FILORI+DTQ_VIAGEM)
                    If AScan( aVetDocs, DUD->(DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE) + aViaCol[1][1] + aViaCol[1][2] ) == 0
                        DUD->(AAdd( aDocInsert, { DUD_FILDOC, DUD_DOC, DUD_SERIE } ) )
                    EndIf
                    DUD->(DbSkip())
                EndDo

                //Inclusão de documentos na viagem
                If Len(aDocInsert) > 0
                    TM310PrcFe(3,,,AClone(aDocInsert))
					If !Empty(cIdVia)
						TMSAI86AUX(DTQ->(DTQ_FILORI+DTQ_VIAGEM))
					EndIf
                EndIf

                If Len(aDocDelete) > 0
                    If !Empty(cIdVia)
                        aDocVia := TMSAC30GDV(cIdVia)
                    EndIf

                    //Retirada dos documentos da viagem
                    DN5->(DbSetOrder(4))
                    For nDoc := 1 To Len(aDocDelete)
                        DN5->(MsSeek(xFilial("DN5")+aDocDelete[nDoc]))
                        Do While !DN5->(Eof()) .And. xFilial("DN5")+aDocDelete[nDoc] == DN5->DN5_FILIAL + DN5->(Left(DN5_CODFON+DN5_LOCALI,Len(aDocDelete[nDoc])))
                            If !Empty(cIdVia)
								If (nPosDoc := AScan(aDocVia[2],{|x| x[1] == AllTrim(DN5->DN5_IDEXT) }) ) > 0
									If aViagem[2] == "AGUARDANDO_DESPACHO"
									    lRet := oColEnt:Post( "coletaentrega/core/api/v1/viagens/"+cIDVia+"/removerTarefaColeta", '{"coletaEntregaId": "'+AllTrim(DN5->DN5_IDEXT)+'"}' )[1]

									ElseIf aViagem[2] == "DESPACHO_CONFIRMADO"
										If aDocVia[02][nPosDoc][04] != "AGUARDANDO_INICIO" //.And. aDocVia[02][nPosDoc][04] != "DESLOCAMENTO_INICIADO" .And. aDocVia[02][nPosDoc][04] != "CHEGUEI_NO_LOCAL"
											Help(" ", , "TMSXFUND13" + " - " + STR0086, , STR0089 + aDocVia[02][nPosDoc][04], 2, 1)
											lRet := .F.
											Exit

										Else
										    lRet := oColEnt:Post( "coletaentrega/core/api/v1/viagens/"+cIDVia+"/removerColetaEmAndamento/"+AllTrim(DN5->DN5_IDEXT), "" )[1]

										EndIf
									EndIf
								EndIf
							EndIf

                            RecLock("DN5", .F.)
                            DN5->DN5_STATUS := Iif(Empty(DN5->DN5_IDEXT),"5","6")
                            DN5->DN5_MOTIVO := DN5->DN5_MOTIVO + DtoC(dDataBase) + "-" + Time() + CRLF + STR0090 + CRLF + CRLF
                            MsUnlock()
                            DN5->(DbSkip())

                        EndDo
                    Next

                EndIf
            EndIf
        EndIf

        AEval(aAreas,{|aArea| RestArea(aArea), FwFreeArray(aArea)})

    EndIf

    FWFreeObj(oColEnt)
    FwFreeArray(aAreas)
    FwFreeArray(aVetDocs)
    FwFreeArray(aDocInsert)
    FwFreeArray(aDocDelete)
    FwFreeArray(aViagem)
    FwFreeArray(aViaCol)
    FwFreeArray(aDocVia)

Return lRet

/*{Protheus.doc} TMCnd1150
Verifica se não é alteração de viagem e se é a viagem principal entre coligadas
para executar o registro 1150 do layout
@author Carlos Alberto Gomes Junior
@since 25/08/22
*/
Function TMCnd1150()
Local lRet     := !IsInCallStack("TMAltColEn")
Local aViagens := {}
	
	If lRet
 		aViagens := VgaPrincial(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM)
		lRet := DTQ->(aViagens[1][1] == DTQ_FILORI .And. aViagens[1][2] == DTQ_VIAGEM)
	EndIf
	FwFreeArray(aViagens)

Return lRet

/*{Protheus.doc} ProxCarga
Incrementa a sequencia da tarefa dentro da carga
@author Valdemar Roberto Mognon
@since 06/09/2022
*/
Function ProxCarga()

nSeqCarga ++

Return nSeqCarga

/*{Protheus.doc} ProxCarga
Busca o ID de viagens já enviadas
@author Carlos A. Gomes Jr.
@since 13/09/2022
*/
Function TMDN4IDVia(aStruct,nSequen)
Local cIDVia    := " "
Local aAreas    := { DN4->(GetArea()), GetArea() }
Local nStuc     := 0
Local cChaveVia := xFilial("DTQ")

DEFAULT aStruct := {}
DEFAULT nSequen := 0

	//-- Localiza primeiro registro da estrutura
	For nStuc := 1 To Len(aStruct)
		//-- Não é adicional de ninguém, ainda não foi processado e não dependente de ninguém
		If (Ascan(aStruct,{|x| x[11] + x[12] == aStruct[nStuc,1] + aStruct[nStuc,2]}) == 0) .And. ;
											aStruct[nStuc,10] == "2" .And. Empty(aStruct[nStuc,6])
			Exit
		EndIf
	Next
	If nStuc > 0 .And. nStuc <= Len(aStruct)
		If aStruct[nSequen][3] == "DUD"
			cChaveVia += DUD->(DUD_FILORI+DUD_VIAGEM)
		ElseIf aStruct[nSequen][3] == "DTQ"
			cChaveVia += DTQ->(DTQ_FILORI+DTQ_VIAGEM)
		EndIf
		DN4->(DbSetOrder(1))
		If DN4->(MsSeek(xFilial("DN4")+aStruct[nStuc,1]+aStruct[nStuc,2] + cChaveVia )) .And. !Empty(DN4->DN4_IDEXT)
			cIDVia := AllTrim(DN4->DN4_IDEXT)
		EndIf
	EndIf
	AEval(aAreas,{|aArea| RestArea(aArea), FwFreeArray(aArea) })
	FwFreeArray(aAreas)

Return cIDVia
