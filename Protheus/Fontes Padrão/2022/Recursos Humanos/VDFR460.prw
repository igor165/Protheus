#INCLUDE "VDFR460.ch"
#Include "Totvs.Ch"
#Include "Report.Ch"

Static dC_ADMISSA := Ctod("")		//-- Data de corte para o calculo
Static dPOS_C     	:= Ctod("")		//-- Data de inicio apÛs 15/12/1998

Static nA_TB := nA_TL := nA_ANOS := nA_MES := nA_DIAS := 0
Static nA2_TB := nA2_TL := nA2_ANOS := nA2_MES := nA2_DIAS := 0	//-- 2=Tempo Ferias e Licencas

Static nB_TB := nB_TL := nB_ANOS := nB_MES := nB_DIAS := 0
Static nBC_TB := nBC_TL := nBC_ANOS := nBC_MES := nBC_DIAS := 0
Static nBT_TB := nBT_TL := nBT_ANOS := nBT_MES := nBT_DIAS := 0

Static nC_TB := nC_TL := nC_ANOS := nC_MES := nC_DIAS := 0
Static nD_TB := nD_TL := nD_ANOS := nD_MES := nD_DIAS := 0

Static nE_TB := nE_TL := nE_ANOS := nE_MES := nE_DIAS := 0
Static nEFA_TB := nEFA_TL := nEFA_ANOS := nEFA_MES := nEFA_DIAS := 0

Static nF_TB := nF_TL := nF_ANOS := nF_MES := nF_DIAS := 0
Static nF40_TB := nF40_TL := nF40_ANOS := nF40_MES := nF40_DIAS := 0
Static nFFA_TB := nFFA_TL := nFFA_ANOS := nFFA_MES := nFFA_DIAS := 0

Static nG_TB := nG_TL := nG_ANOS := nG_MES := nG_DIAS := 0
Static nGFA_TB := nGFA_TL := nGFA_ANOS := nGFA_MES := nGFA_DIAS := 0

Static nH_TB := nH_TL := nH_ANOS := nH_MES := nH_DIAS := 0

Static nI_TB := nI_TL := nI_ANOS := nI_MES := nI_DIAS := 0
Static nIMS_TB := nIMS_TL := nIMS_ANOS := nIMS_MES := nIMS_DIAS := 0

Static nJ_TB := nJ_TL := nJ_ANOS := nJ_MES := nJ_DIAS := 0
Static nJMS_TB := nJMS_TL := nJMS_ANOS := nJMS_MES := nJMS_DIAS := 0

Static nK_TB := nK_TL := nK_ANOS := nK_MES := nK_DIAS := 0

Static nL_TB := nL_TL := nL_ANOS := nL_MES := nL_DIAS := 0
Static nM_TB := nM_TL := nM_ANOS := nM_MES := nM_DIAS := 0
Static nN_TB := nN_TL := nN_ANOS := nN_MES := nN_DIAS := 0
Static nO_TB := nO_TL := nO_ANOS := nO_MES := nO_DIAS := 0
Static nP_TB := nP_TL := nP_ANOS := nP_MES := nP_DIAS := 0
Static nQ_TB := nQ_TL := nQ_ANOS := nQ_MES := nQ_DIAS := 0
Static nR_TB := nR_TL := nR_ANOS := nR_MES := nR_DIAS := 0

Static nAPL_TL  := nAPL_ANOS := nAPL_MES := nAPL_DIAS := 0

Static aEmenda  := {}
Static cEmenda  := ""

Static cVdCert1 := SuperGetMv("MV_VDCERT1",,"")			//MINIST…RIO P⁄BLICO DO ESTADO DE MATO GROSSO
Static cVdCert2 := SuperGetMv("MV_VDCERT2",,"")			//PROCURADORIA - GERAL DE JUSTI«A
Static cVdCert3 := SuperGetMv("MV_VDCERT3",,"")			//DEPARTAMENTO DE GEST√O DE PESSOAS
Static cVdCert6 := SuperGetMv("MV_VDCERT6",,"-PGJ-")
Static cMV_VDFMTAP := SuperGetMv("MV_VDFMTAP",,"1")		// 1=Demonstra Bruto e Liquido diferenciado e 2=Liquido igual ao bruto

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ VDFR460  ≥ Autor ≥ Wagner Mobile Costa   ≥ Data ≥  30.07.14      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Calculo do tempo de aposentadoria                                ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ VDFR460(void)                                                    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥                                                                  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Generico                                                         ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥         ATUALIZACOES SOFRIDAS DESDE A CONSTRUÄAO INICIAL.                   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Programador ≥ Data     ≥ BOPS ≥  Motivo da Alteracao                         ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Marcos Perei≥14/11/2014≥      ≥Ajuste em L_TL para tratar liquido conforme o ≥±±
±±≥            ≥          ≥      ≥ MV_VDFMTAP                                   ≥±±
±±≥Silvia Tag  ≥18/07/2018≥      ≥Upgrade V12 - Retirada Ajusta SX1             ≥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function VDFR460()

Local aRegs			:= {}
Local cDir			:= SUBSTR(GetTempPath(),1,3)
Local aSay			:= {}
Local aButton		:= {}
Local nOpc			:= 0
Local aArea			:= GetArea()
Local aAreaSM0		:= SM0->(GetArea())
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F., {"",""} }) //[1]Acesso; [2]Ofusca; [3]Mensagem
Local aMsg			:= aOfusca[3]
Local aFldRel		:= {"RA_NOME", "RA_RACACOR"}
Local lBlqAcesso	:= aOfusca[2] .And. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRel ) )
Private cPerg		:= "VDFR460"
Private cTitulo		:= STR0001		// 'Calculo do tempo de aposentadoria'
Private lMembroM	:= .F.
Private lServidorM	:= .F.
Private lFeminino	:= .F.

If !lBlqAcesso
	If 	!File(cDir+'LibreOffice\program\swriter.exe')
		MsgInfo(STR0002)	// 'LibreOffice n„o esta gravado na pasta \LibreOffice\program\.'
		Return()
	Endif

		InitHTM()

		ZerVar()

		cSXB_SRACAT   := "SRA->RA_FILIAL == mv_par01"

		Aadd(aSay, STR0003)	// 'Esta opÁ„o tem como objetivo a montagem e apresentaÁ„o de documento no aplicativo'
		Aadd(aSay, STR0004)	// 'Libre Office.'

		Aadd(aButton, { 5, .T., { || Pergunte(cPerg, .T.) } } )
		Aadd(aButton, { 1, .T., { || nOpc := 1, FechaBatch() } })
		Aadd(aButton, { 2, .T., { || FechaBatch() } })

		FormBatch(cTitulo, aSay, aButton)

		If nOpc == 1
			MsAguarde({|| GerData() }, cTitulo,STR0005,.T.)	// 'Montando o documento. Aguarde ...'
		EndIf
		PtSetAcento(.F.)
Else
	Help(" ",1,aMsg[1],,aMsg[2],1,0)
Endif

DbSelectArea("SM0")
Set Filter To
RestArea(aAreaSM0)
RestArea(aArea)

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funáao    ≥ GerData     ≥ Autor ≥ Wagner Mobile Costa  ≥ Data ≥ 26.06.14 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descriáao ≥ Realiza a seleÁ„o dos dados do documento e envia para Libre  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ GerData                                                      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥                                                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ VDFR450 - Generico - Release 4                               ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function GerData()

Local cDir        := SUBSTR(GetTempPath(),1,3)
Local cDiretorio  := cDir+GetMV( "MV_VDFPAST" )
Local cArquivo    := "Aposentadoria"
Local nEsperaI    := 0, dData

DbSelectArea("SRA")
DbSetOrder(1)
If ! DbSeek(mv_par01 + mv_par02)
	MsgInfo(STR0008)	// 'AtenÁ„o. A matrÌcula informada n„o È valida !'
	Return
EndIf

If !ExistDir(cDiretorio)
	MsgInfo(STR0009 + cDiretorio)	// 'N„o foi possÌvel localizar o diretÛrio: '
	Return
EndIf

DbSelectArea("RII")
DbSetOrder(1)
DbSeek(mv_par01 + mv_par02)

// Variaveis utilizadas pelo relatÛrio
dC_ADMISSA := Ctod("15/12/1998")
dPOS_C      := dC_ADMISSA + 1

dData := dC_ADMISSA
If SRA->RA_ADMISSA > dC_ADMISSA
	dData := dDataBase
EndIf

//-- AverbaÁıes de licenÁa
BeginSql Alias "QRY"
	SELECT SUM(RII_TMPBRU) AS RII_TMPBRU, SUM(RII_TMPLIQ) AS RII_TMPLIQ
      FROM %table:RII%
     WHERE %notDel% AND RII_FILIAL = %Exp:mv_par01% AND RII_MAT = %Exp:mv_par02% AND RII_TIPAVE= %Exp:'2'%
EndSql
nA2_TB := nA2_TL := QRY->RII_TMPBRU
If cMV_VDFMTAP == "1"	// Bruto e Liquido Diferenciado
   nA2_TL := QRY->RII_TMPLIQ
EndIf

fDias2Anos(nA2_TL,@nA2_ANOS,@nA2_MES,@nA2_DIAS)

DbCloseArea()

//-- Tempo Trabalhado
M->RII_TMPBRU := 0
M->RII_TMPLIQ := 0
M->RA_TMPBRU  := 0
M->RA_TMPLIQ  := 0

MsProcTxt(STR0007 + " [" + Dtoc(SRA->RA_ADMISSA) + " - " + Dtoc(dData) + "] ...")		// 'Calculando o periodo ['
ProcessMessage()

VD460TEMPO(@M->RA_TMPBRU, @M->RA_TMPLIQ, SRA->RA_ADMISSA, dData)

M->RA_TMPANOT := 0
M->RA_TMPMEST := 0
M->RA_TMPDIAT := 0

Ferase(cDiretorio+"\" + cArquivo + ".HTM")
Ferase(cDiretorio+"\" + cArquivo + ".DOC")
Ferase(cDiretorio+"\vdfr460_logo.png")

nHandle := FCREATE(cDiretorio+"\" + cArquivo + ".HTM")

// 1=Membro   Masculino Antes 15/12/1998 						-> RA_SEXO = M e RA_CATFUNC = 0 ou 1
// 2=Servidor Masculino Antes 15/12/1998 						-> RA_SEXO = F e RA_CATFUNC = 2 ou 3
// 3=Membro/Servidor Feminino Antes 15/12/1998				-> RA_SEXO = F
// 4=Membro/Servidor Masculino/Feminino depois 15/12/1998	-> DEMAIS

If SRA->RA_ADMISSA > dC_ADMISSA
	WriteHTM(nHandle, "\inicializadores\vdfr460_apos.htm")
Else
	If SRA->RA_SEXO == "M" .And. SRA->RA_CATFUNC $ "0,1"
		lMembroM := .T.
		WriteHTM(nHandle, "\inicializadores\vdfr460_antes_masculino_membro.htm")
	ElseIf SRA->RA_SEXO == "M" .And. SRA->RA_CATFUNC $ "2,3"
		lServidorM := .T.
		WriteHTM(nHandle, "\inicializadores\vdfr460_antes_masculino_servidor.htm")
	Else
		lFeminino := .T.
		WriteHTM(nHandle, "\inicializadores\vdfr460_antes_feminino.htm")
	EndIf
EndIf

FClose(nHandle)

__copyfile("\inicializadores\vdfr460_logo.png", cDiretorio+"\vdfr460_logo.png")

If ! File(cDiretorio+'\'+cArquivo+".HTM")
	MsgInfo('AtenÁ„o. O arquivo [' + cFile + '] n„o foi encontrado !')
Else
	Winexec("\LibreOffice\program\swriter.exe --invisible --convert-to doc "+cDiretorio+'\'+cArquivo+".HTM --outdir "+cDiretorio)

	//Espera que o Arquivo de Resposta Seja Criado*/
	For nEsperaI := 1 To 50000
		If File(cDiretorio+'\'+cArquivo+'.DOC')
			exit
		ElseIf nEsperaI == 50000
			If !MsgYesNo(STR0006)		// 'A abertura est· demorando mais do que o esperado. Deseja continuar aguardando ?'
		        exit
		 	Endif
		EndIf
		nEsperaI += 1
	Next nEsperaI

	shellExecute( "Open", "\LibreOffice\program\soffice.exe", cDiretorio+'\'+cArquivo+".DOC" , cDiretorio, 1 )
EndIf

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funáao    ≥ WriteHTM    ≥ Autor ≥ Wagner Mobile Costa  ≥ Data ≥ 26.06.14 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descriáao ≥ Assistente para configuraÁ„o da estrutura do documento       ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ WriteHTM                                                      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥                                                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ VDFR450 - Generico - Release 4                               ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function WriteHTM(nHandle, cFile)

Local nLinha   := 0
Local nHdl     := 0
Local nInicial := 0
Local cBuffer  := "1"
Local cInicio  := "1"
Local cFim     := "1"
Local cAux     := "1"
Local aBuffer  := { "" }
Local nHdlFile := 0
Local nLinFil  := 0
Local nAux     := 0

If ! File(cFile)
	MsgInfo('AtenÁ„o. O arquivo [' + cFile + '] n„o foi encontrado !')
	Return .F.
EndIf

nHdl := FT_FUse(cFile)
FT_FGotop()
While (!FT_FEof())
	MsProcTxt('Gravando a linha [' + AllTrim(Str(++ nLinha)) + '] ...')
	ProcessMessage()

	aBuffer := { FT_FReadLN() + CRLF }

	If (nInicial := AT("[/FILE/", Upper(aBuffer[1]))) > 0
	 	cInicio := Left(aBuffer[1], nInicial - 1)
	 	cFim    := Subs(aBuffer[1], AT("\FILE\]", Upper(aBuffer[1])) + 7)

	 	cBuffer := Subs(aBuffer[1], nInicial + 7)
		cBuffer := Left(cBuffer, AT("\FILE\]", Upper(cBuffer)) - 1)

		aBuffer := { cInicio }

		//-- de Acordo com o nome do arquivo determina o tipo de averbaÁ„o a ser listado
		If Right(Upper(cBuffer), 9) = "RII_3.HTM" .Or. Right(Upper(cBuffer), 14) = "RII_APOS_3.HTM"
			cAux	:= "3"
			cBuffer:= StrTran(cBuffer, "_3", "")
		EndIf

		If ! File(cBuffer)
			MsgInfo('AtenÁ„o. O arquivo [' + cBuffer + '] n„o foi encontrado !')
		Else
			MsProcTxt('Incluindo o arquivo [' + cBuffer + '] ...')
			ProcessMessage()

			nHdlFile := FT_FUse(cBuffer)
			nLinFil := 0
			FT_FGotop()
			While (!FT_FEof())
				MsProcTxt('Lendo a linha [' + AllTrim(Str(++ nLinFil)) + '] ...')
				ProcessMessage()

				Aadd(aBuffer, FT_FReadLN() + CRLF)
				FT_FSkip()
			EndDo
			FClose(nHdlFile)
			FClose(nHdl)

			nHdl := FT_FUse(cFile)
			FT_FGotop()
			FT_FSkip(nLinha - 1)

			//-- RII - Averbacoes
			If Right(Upper(cBuffer), 7) = "RII.HTM" .Or. Right(Upper(cBuffer), 12) = "RII_APOS.HTM"
				BeginSql Alias "QRY"
					COLUMN RII_PERDE  AS DATE
					COLUMN RII_PERATE AS DATE

					SELECT RII_PERDE, RII_PERATE, RII_ORGEXP, RII_TMPBRU, RII_TMPLIQ
               		  FROM %table:RII%
                     WHERE %notDel% AND RII_FILIAL = %Exp:mv_par01% AND RII_MAT = %Exp:mv_par02% AND RII_TIPAVE= %Exp:cAux%
              	  ORDER BY RII_PERDE, RII_PERATE
				EndSql

				While ! Eof()
					// Tempo de comissionado antes da efetivacao
					If cAux	 == "3"
						nBC_TB += QRY->RII_TMPBRU
						If cMV_VDFMTAP == "1"	// Bruto e Liquido Diferenciado
						   nBC_TL += QRY->RII_TMPLIQ
    						Else
						   nBC_TL += QRY->RII_TMPBRU
    						EndIf
					Else
						M->RII_TMPBRU += QRY->RII_TMPBRU
						If cMV_VDFMTAP == "1"	// Bruto e Liquido Diferenciado
						   M->RII_TMPLIQ += QRY->RII_TMPLIQ
						Else
						   M->RII_TMPLIQ += QRY->RII_TMPBRU
    						EndIf
					EndIf

					M->RII_TMPANO := 0
					M->RII_TMPMES := 0
					M->RII_TMPDIA := 0
					fDias2Anos(QRY->RII_TMPLIQ,@M->RII_TMPANO,@M->RII_TMPMES,@M->RII_TMPDIA)

					WriteBUF(aBuffer, nHandle, cFile)

					DbSkip()
				EndDo
				DbClosearea()
			//-- PublicaÁıes das emendas
			ElseIf Right(Upper(cBuffer), 9) = "IDADE.HTM" .Or. Right(Upper(cBuffer), 14) = "IDADE_APOS.HTM"
				LoadEmenda()

				For nAux := 1 To Len(aEmenda)
					M->IDA_DTAPUB := aEmenda[nAux][2]
					M->IDA_TOTAL	:= aEmenda[nAux][2] - SRA->RA_NASC
					M->IDA_ANOS  	:= 0
					M->IDA_MESES 	:= 0
					M->IDA_DIAS	:= 0
					fDias2Anos(M->IDA_TOTAL,@M->IDA_ANOS,@M->IDA_MESES,@M->IDA_DIAS)

					WriteBUF(aBuffer, nHandle, cFile)
				Next

				M->IDA_DTAPUB := dDataBase
				M->IDA_TOTAL	:= dDataBase - SRA->RA_NASC
				M->IDA_ANOS 	:= 0
				M->IDA_MESES	:= 0
				M->IDA_DIAS	:= 0
				fDias2Anos(M->IDA_TOTAL,@M->IDA_ANOS,@M->IDA_MESES,@M->IDA_DIAS)

				WriteBUF(aBuffer, nHandle, cFile)
			EndIf
		EndIf

		Aadd(aBuffer, cFim)
	Else
		WriteBUF(aBuffer, nHandle, cFile)
	EndIf

	FT_FSkip()
EndDo
FClose(nHdl)

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ WriteBUF * Autor ≥ Wagner Mobile Costa   ≥ Data ≥  01.08.14  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥  Grava o resultado da substituiÁ„o no arquivo .HTM           ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ WriteBUF()                                                   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function WriteBUF(aBuffer, nHandle, cFile)

Local cData 	:= Alltrim(STR(DAY(dDataBase))+' de '+ MesExtenso( MONTH(dDataBase) )+' de '+ Alltrim(STR(YEAR(dDataBase)))+'.')
Local nBuffer	:= 0

For nBuffer := 1 To Len(aBuffer)
	cBuffer := STRTRAN ( aBuffer[nBuffer], "{*[data]*}", cData, ,)
	cBuffer := VD460Macro(cBuffer, nHandle, cFile)

	FWrite(nHandle, cbuffer)
Next

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ InitHTM * Autor ≥ Wagner Mobile Costa    ≥ Data ≥  30.07.14  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥  Gera os arquivos da pasta \inicializadores                  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ CabWrite()                                                   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function InitHTM

Local aFiles := {	{ "vdfr460_antes_feminino.htm", { || AntesFem() } },;
					{ "vdfr460_antes_masculino_membro.htm",  { || AntesMasM() } },;
					{ "vdfr460_antes_masculino_servidor.htm", { || AntesMasS() } },;
					{ "vdfr460_apos.htm", { || PerApos() } },;
					{ "vdfr460_idade.htm", { || HtmIdade() } },;
					{ "vdfr460_idade_apos.htm", { || IdadePos() } },;
					{ "vdfr460_ri5.htm", { || HtmRI5() } },;
					{ "vdfr460_rii.htm", { || HtmRII() } },;
					{ "vdfr460_rii_apos.htm", { || HtmRIIPos() } } }
Local nFiles := 1

For nFiles := 1 To Len(aFiles)
	If ! File("\inicializadores\" + aFiles[nFiles][1])
		SaveHtm(Eval(aFiles[nFiles][2]), aFiles[nFiles][1])
	EndIf
Next

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} SaveHTM
FunÁ„o para gravaÁ„o do HTML passado como parametro na pasta inicializadores
@sample 	SaveHTM
@param		cFile       Nome do arquivo a ser gerado
@param		aTxt        Matriz com o TXT  a ser gravado
@return	cRetorno  	Texto com as devidas alteraÁıes.
@author    Wagner Mobile Costa
@since		16/09/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------

Static Function SaveHTM(aTxt, cFile)

Local nTxt := 0

nHandle := FCREATE("\inicializadores\" + cFile)
For nTxt := 1 To Len(aTxt)
	FWrite(nHandle, aTxt[nTxt] + Chr(13) + Chr(10))
Next
FClose(nHandle)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} AntesFem
FunÁ„o para retorno da matriz do arquivo vdfr460_antes_feminino.htm
@sample 	SaveHTM
@return	aTxt        Matriz com o Txt a ser gravado
@author    Wagner Mobile Costa
@since		16/09/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------

Static Function AntesFem

Local aTxt := {}

Aadd(aTxt, '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">')
Aadd(aTxt, '<HTML>')
Aadd(aTxt, '<HEAD>')
Aadd(aTxt, '<META HTTP-EQUIV="CONTENT-TYPE" CONTENT="text/html; charset=windows-1252">')
Aadd(aTxt, '<TITLE></TITLE>')
Aadd(aTxt, '<META NAME="GENERATOR" CONTENT="LibreOffice 4.0.1.2 (Windows)">')
Aadd(aTxt, '<META NAME="CREATED" CONTENT="20050318;14262800">')
Aadd(aTxt, '<META NAME="CHANGED" CONTENT="20140916;10484573">')
Aadd(aTxt, '<META NAME="Info 0" CONTENT="">')
Aadd(aTxt, '<META NAME="Info 1" CONTENT="">')
Aadd(aTxt, '<META NAME="Info 2" CONTENT="">')
Aadd(aTxt, '<META NAME="Info 3" CONTENT="">')
Aadd(aTxt, '<META NAME="SDFOOTNOTE" CONTENT=";;;;P">')
Aadd(aTxt, '<META NAME="SDENDNOTE" CONTENT="ARABIC">')
Aadd(aTxt, '<STYLE TYPE="text/css">')
Aadd(aTxt, '<!--')
Aadd(aTxt, '@page { size: 29.7cm 21cm; margin-left: 2.5cm; margin-right: 2.5cm; margin-top: 1.1cm; margin-bottom: 1.1cm }')
Aadd(aTxt, 'P { margin-bottom: 0.21cm; color: #000000 }')
Aadd(aTxt, 'TD P { margin-bottom: 0.21cm; color: #000000 }')
Aadd(aTxt, 'A:link { color: #000080; so-language: zxx; text-decoration: underline }')
Aadd(aTxt, 'A:visited { color: #800000; so-language: zxx; text-decoration: underline }')
Aadd(aTxt, '-->')
Aadd(aTxt, '</STYLE>')
Aadd(aTxt, '</HEAD>')
Aadd(aTxt, '<BODY LANG="pt-PT" TEXT="#000000" LINK="#000080" VLINK="#800000" DIR="LTR" STYLE="border: 1px solid #000000; padding: 0.05cm">')
Aadd(aTxt, '<DIV TYPE=HEADER>')
Aadd(aTxt, '<P ALIGN=JUSTIFY STYLE="margin-bottom: 0cm"><IMG SRC="vdfr460_logo.png" NAME="figura1" ALIGN=RIGHT HSPACE=9 WIDTH=84 HEIGHT=74 BORDER=0><BR CLEAR=RIGHT><FONT FACE="Times New Roman Normal"><FONT SIZE=4><B>[*cVdCert1*]</B></FONT></FONT></P>')
Aadd(aTxt, '<P ALIGN=JUSTIFY STYLE="margin-bottom: 0cm"><FONT FACE="Times New Roman Normal"><FONT SIZE=4><B>[*cVdCert2*]</B></FONT></FONT></P>')
Aadd(aTxt, '<P ALIGN=JUSTIFY STYLE="margin-bottom: 0cm"><FONT FACE="Times New Roman Normal"><FONT SIZE=4><B>[*cVdCert3*]</B></FONT></FONT></P>')
Aadd(aTxt, '<P ALIGN=JUSTIFY STYLE="margin-bottom: 0.5cm"><BR><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</DIV>')
Aadd(aTxt, '<P ALIGN=CENTER STYLE="margin-bottom: 0cm; line-height: 150%"><FONT FACE="Verdana, sans-serif"><FONT SIZE=2><B><SPAN STYLE="font-variant: normal"><FONT SIZE=2 STYLE="font-size: 11pt"><SPAN STYLE="font-style: normal">C&Aacute;LCULO')
Aadd(aTxt, 'PARA ABONO PERMAN&Ecirc;NCIA (INGRESSO COMO SERVIDOR P&Uacute;BLICO')
Aadd(aTxt, 'NA PGJ ANTES DE 15/12/1998</SPAN></FONT></SPAN><SPAN STYLE="font-variant: normal"><SPAN STYLE="font-style: normal">)</SPAN></SPAN></B></FONT></FONT></P>')
Aadd(aTxt, '<P ALIGN=CENTER STYLE="margin-bottom: 0cm; font-variant: normal; font-style: normal; line-height: 150%">')
Aadd(aTxt, '<FONT FACE="Verdana, sans-serif"><FONT SIZE=2><B>[*RA_MAT*] -')
Aadd(aTxt, '[*RA_NOME*]</B></FONT></FONT></P>')
Aadd(aTxt, '<P ALIGN=CENTER STYLE="margin-bottom: 0cm; line-height: 150%"><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '<TABLE WIDTH=928 CELLPADDING=4 CELLSPACING=0>')
Aadd(aTxt, '<COL WIDTH=84>')
Aadd(aTxt, '<COL WIDTH=86>')
Aadd(aTxt, '<COL WIDTH=80>')
Aadd(aTxt, '<COL WIDTH=60>')
Aadd(aTxt, '<COL WIDTH=63>')
Aadd(aTxt, '<COL WIDTH=50>')
Aadd(aTxt, '<COL WIDTH=56>')
Aadd(aTxt, '<COL WIDTH=61>')
Aadd(aTxt, '<COL WIDTH=153>')
Aadd(aTxt, '<COL WIDTH=153>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=8 WIDTH=596 STYLE="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0.1cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>TEMPO')
Aadd(aTxt, 'DE SERVI&Ccedil;O AVERBADO </FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0.1cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border: 1px solid #000000; padding: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD WIDTH=84 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">IN&Iacute;CIO')
Aadd(aTxt, '</FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=86 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">T&Eacute;RMINO</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=80 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">INSTITUI&Ccedil;&Atilde;O')
Aadd(aTxt, '</FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=60 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">TEMPO')
Aadd(aTxt, 'BRUTO </FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=63 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">TEMPO')
Aadd(aTxt, 'L&Iacute;Q.</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=50 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">ANOS')
Aadd(aTxt, '</FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=56 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">MESES</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=61 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">DIAS</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[/FILE/\INICIALIZADORES\VDFR460_RII.HTM\FILE\]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=3 WIDTH=266 HEIGHT=17 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">TOTAL</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=60 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*A_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=63 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*A_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=50 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*A_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=56 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*A_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=61 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*A_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm" SDVAL="0" SDNUM="1046;0;@">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">A')
Aadd(aTxt, '= TOTAL DAS AVERBA&Ccedil;&Otilde;ES</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm" SDVAL="0" SDNUM="1046;0;@">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">A</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=8 WIDTH=596 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=JUSTIFY><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=JUSTIFY><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=JUSTIFY><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=8 WIDTH=596 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><A NAME="__DdeLink__308_2026848282"></A><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>TEMPO')
Aadd(aTxt, 'DE SERVI&Ccedil;O [*cVdCert6*] AT&Eacute; 15/12/1998</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD WIDTH=84 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">IN&Iacute;CIO</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=86 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">T&Eacute;RMINO</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=80 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">INSTITUI&Ccedil;&Atilde;O</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=60 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">TEMPO')
Aadd(aTxt, 'BRUTO</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=63 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">TEMPO')
Aadd(aTxt, 'LIQ.</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=50 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">ANO(S)')
Aadd(aTxt, '</FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=56 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">M&Ecirc;S(S)')
Aadd(aTxt, '</FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=61 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">DIA(S)</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[/FILE/\INICIALIZADORES\VDFR460_RII_3.HTM\FILE\]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD WIDTH=84 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm" SDVAL="0" SDNUM="1046;0;@">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*RA_ADMISSA*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=86 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">15/12/1998</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=80 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*cVdCert6*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=60 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*B_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=63 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*B_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=50 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*B_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=56 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*B_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=61 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*B_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm" SDNUM="1046;0;@">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm" SDNUM="1046;0;@">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=2 WIDTH=178 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm" SDVAL="0" SDNUM="1046;0;@">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">TOTAL</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=80 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*cVdCert6*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=60 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*BT_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=63 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*BT_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=50 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*BT_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=56 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*BT_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=61 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*BT_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm" SDVAL="0" SDNUM="1046;0;@">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>TEMPO')
Aadd(aTxt, 'TOTAL DE SERVI&Ccedil;O [*cVdCert6*] AT&Eacute; 15/12/1998</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm" SDVAL="0" SDNUM="1046;0;@">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>B</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=3 WIDTH=266 VALIGN=TOP STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=LEFT><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">OUTROS')
Aadd(aTxt, '</FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=60 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*A2_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=63 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*A2_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=50 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*A2_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=56 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*A2_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=61 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*A2_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm" SDVAL="0" SDNUM="1046;0;@">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>A</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm" SDNUM="1046;0;@">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=3 WIDTH=266 VALIGN=TOP STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=LEFT><FONT FACE="Verdana, sans-serif"><FONT SIZE=1>TEMPO ')
Aadd(aTxt, 'DE SERVI&Ccedil;O EM 15/12/1998</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=60 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*C_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=63 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*C_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=50 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*C_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=56 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*C_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=61 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*C_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm" SDVAL="0" SDNUM="1046;0;@">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>C =')
Aadd(aTxt, 'A + B</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm" SDVAL="0" SDNUM="1046;0;@">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>C</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=3 WIDTH=266 VALIGN=TOP STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=LEFT><FONT FACE="Verdana, sans-serif"><FONT SIZE=1>TEMPO')
Aadd(aTxt, 'DE SERVI&Ccedil;O EXIGIDO PARA APOSENTADORIA - INTEGRAL</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=60 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*D_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=63 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*D_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=50 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*D_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=56 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*D_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=61 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*D_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm" SDVAL="0" SDNUM="1046;0;@">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>VALOR')
Aadd(aTxt, 'FIXO DE 30 ANOS (INTEGRAL)PARA SERVIDORA OU MEMBRO FEMININO</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm" SDVAL="0" SDNUM="1046;0;@">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>D</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=3 WIDTH=266 VALIGN=TOP STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=LEFT><FONT FACE="Verdana, sans-serif"><FONT SIZE=1>TEMPO')
Aadd(aTxt, 'DE CONTRIBUI&Ccedil;&Atilde;O QUE FALTA PARA APOSENTADORIA')
Aadd(aTxt, 'INTEGRAL A PARTIR DE 15/12/1998 (SEM O PED&Aacute;GIO)</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=60 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*EFA_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=63 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*EFA_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=50 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*EFA_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=56 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*EFA_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=61 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*EFA_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm" SDVAL="0" SDNUM="1046;0;@">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>E =')
Aadd(aTxt, 'D-C</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm" SDVAL="0" SDNUM="1046;0;@">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>E</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=3 WIDTH=266 VALIGN=TOP STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=LEFT><FONT FACE="Verdana, sans-serif"><FONT SIZE=1>TEMPO')
Aadd(aTxt, 'ADICIONAL (PED&Aacute;GIO 20%)</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=60 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*FFA_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=63 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*FFA_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=50 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*FFA_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=56 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*FFA_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=61 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*FFA_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm" SDVAL="0" SDNUM="1046;0;@">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>F =')
Aadd(aTxt, 'E * 20%</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm" SDVAL="0" SDNUM="1046;0;@">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>F</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=3 WIDTH=266 VALIGN=TOP STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=LEFT><FONT FACE="Verdana, sans-serif"><FONT SIZE=1>TOTAL')
Aadd(aTxt, 'DE TEMPO QUE FALTA P/ APOSENTADORIA - INTEGRAL</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=60 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*GFA_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=63 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*GFA_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=50 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*GFA_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=56 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*GFA_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=61 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*GFA_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm" SDVAL="0" SDNUM="1046;0;@">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>G =')
Aadd(aTxt, 'F +E</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm" SDVAL="0" SDNUM="1046;0;@">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>G</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=3 WIDTH=266 VALIGN=TOP STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=LEFT><FONT FACE="Verdana, sans-serif"><FONT SIZE=1>TEMPO')
Aadd(aTxt, 'DE SERVI&Ccedil;O EXIGIDO PARA APOSENTADORIA PROPORCIONAIS</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=60 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*H_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=63 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*H_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=50 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*H_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=56 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*H_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=61 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*H_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm" SDVAL="0" SDNUM="1046;0;@">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>VALOR')
Aadd(aTxt, 'FIXO 25 ANOS (PROPORCIONAL)</FONT></FONT></P>')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>PARA')
Aadd(aTxt, 'SERVIDORA / MEMBRO FEMININO</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm" SDVAL="0" SDNUM="1046;0;@">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>H</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=3 WIDTH=266 VALIGN=TOP STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=LEFT><FONT FACE="Verdana, sans-serif"><FONT SIZE=1>TEMPO')
Aadd(aTxt, 'DE CONTRIBUI&Ccedil;&Atilde;O EM 15/12/1998</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=60 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*C_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=63 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*C_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=50 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*C_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=56 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*C_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=61 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*C_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm" SDNUM="1046;0;@">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm" SDVAL="0" SDNUM="1046;0;@">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>C</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=3 WIDTH=266 VALIGN=TOP STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=LEFT><FONT FACE="Verdana, sans-serif"><FONT SIZE=1>TEMPO')
Aadd(aTxt, 'DE CONTRIBUI&Ccedil;&Atilde;O QUE FALTA PARA APOSENTADORIA')
Aadd(aTxt, 'PROPORCIONAL A PARTIR DE 16/12/1998 (SEM O PEG&Aacute;GIO)</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=60 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*I_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=63 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*I_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=50 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*I_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=56 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*I_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=61 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*I_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm" SDVAL="0" SDNUM="1046;0;@">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>I =')
Aadd(aTxt, 'H - C</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm" SDVAL="0" SDNUM="1046;0;@">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>I</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=3 WIDTH=266 VALIGN=TOP STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=LEFT><FONT FACE="Verdana, sans-serif"><FONT SIZE=1>TEMPO')
Aadd(aTxt, 'ADICIONAL (PED&Aacute;GIO DE 40%)</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=60 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*J_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=63 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*J_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=50 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*J_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=56 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*J_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=61 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*J_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm" SDVAL="0" SDNUM="1046;0;@">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>J =')
Aadd(aTxt, 'I * 40%</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm" SDVAL="0" SDNUM="1046;0;@">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>J</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=3 WIDTH=266 VALIGN=TOP STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=LEFT><FONT FACE="Verdana, sans-serif"><FONT SIZE=1>TOTAL')
Aadd(aTxt, 'DE TEMPO QUE FALTA P/ APOSENTADORIA - PROPORCIONAL </FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=60 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*K_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=63 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*K_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=50 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*K_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=56 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*K_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=61 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*K_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>K =')
Aadd(aTxt, 'I + J </FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>K</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=8 WIDTH=596 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>TEMPO')
Aadd(aTxt, 'DE SERVI&Ccedil;O [*cVdCert6*] AP&Oacute;S 15/12/1998</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD WIDTH=84 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>16/12/1998</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=86 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm" SDVAL="40372" SDNUM="1046;0;@">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*dDataBase*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=80 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*cVdCert6*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=60 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*L_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=63 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*L_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=50 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*L_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=56 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*L_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=61 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*L_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>TEMPO')
Aadd(aTxt, 'NA PGJ AP&Oacute;S 15/12/1998</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>L</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=8 WIDTH=596 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=8 WIDTH=596 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">TEMPO')
Aadd(aTxt, 'TOTAL DE SERVI&Ccedil;O E CONTRIBUI&Ccedil;&Atilde;O</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=4 WIDTH=334 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=JUSTIFY><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">ESPECIFICA&Ccedil;&Atilde;O</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=63 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">TOTAL</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=50 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">ANO(S)')
Aadd(aTxt, '</FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=56 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">M&Ecirc;S(S)</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=61 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">DIA(S)</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=4 WIDTH=334 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=JUSTIFY><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">PGJ</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=63 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*M_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=50 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*M_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=56 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*M_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=61 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*M_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>M =')
Aadd(aTxt, 'L + B</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>M</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=4 WIDTH=334 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=JUSTIFY><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">OUTROS</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=63 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*A_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=50 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*A_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=56 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*A_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=61 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*A_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm" SDVAL="0" SDNUM="1046;0;@">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>A</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm" SDVAL="0" SDNUM="1046;0;@">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>A</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=4 WIDTH=334 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=JUSTIFY><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">TEMPO')
Aadd(aTxt, 'TOTAL DE SERVI&Ccedil;O P&Uacute;BLICO</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=63 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*N_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=50 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*N_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=56 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*N_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=61 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*N_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=4 WIDTH=334 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=JUSTIFY><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">TOTAL')
Aadd(aTxt, 'AT&Eacute; [*dDataBase*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=63 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*N_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=50 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*N_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=56 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*N_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=61 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*N_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>N =')
Aadd(aTxt, 'A +M</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>N</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=8 WIDTH=596 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>IDADE')
Aadd(aTxt, 'DO REQUERENTE</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=2 WIDTH=178 HEIGHT=40 BGCOLOR="#ffffff" STYLE="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0.1cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>DATA')
Aadd(aTxt, 'DE NASCIMENTO DO REQUERENTE</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD COLSPAN=2 WIDTH=148 BGCOLOR="#ffffff" STYLE="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0.1cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">PUBLICA&Ccedil;&Otilde;ES')
Aadd(aTxt, 'DAS EC ([*EMENDAS*]) e DATA ATUAL</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=63 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">TOTAL</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=50 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">ANO(S)</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=56 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">M&Ecirc;S(S)')
Aadd(aTxt, '</FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=61 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">DIA(S)</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=153 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[/FILE/\INICIALIZADORES\VDFR460_IDADE.HTM\FILE\]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '</TABLE>')
Aadd(aTxt, '<P ALIGN=CENTER STYLE="margin-bottom: 0cm; line-height: 150%"><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '<P ALIGN=CENTER STYLE="line-height: 150%"><BR><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '<DIV TYPE=FOOTER>')
Aadd(aTxt, '<P ALIGN=CENTER STYLE="margin-top: 0.5cm; margin-bottom: 0cm"><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</DIV>')
Aadd(aTxt, '</BODY>')
Aadd(aTxt, '</HTML>')

Return aTxt

//------------------------------------------------------------------------------
/*/{Protheus.doc} AntesMasM
FunÁ„o para retorno da matriz do arquivo vdfr460_antes_masculino_membro.htm
@sample 	AntesMasM
@return	aTxt        Matriz com o Txt a ser gravado
@author    Wagner Mobile Costa
@since		18/09/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------

Static Function AntesMasM

Local aTxt := {}

Aadd(aTxt, '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">')
Aadd(aTxt, '<HTML>')
Aadd(aTxt, '<HEAD>')
Aadd(aTxt, '<META HTTP-EQUIV="CONTENT-TYPE" CONTENT="text/html; charset=windows-1252">')
Aadd(aTxt, '<TITLE></TITLE>')
Aadd(aTxt, '<META NAME="GENERATOR" CONTENT="LibreOffice 4.0.1.2 (Windows)">')
Aadd(aTxt, '<META NAME="CREATED" CONTENT="20050318;14262800">')
Aadd(aTxt, '<META NAME="CHANGED" CONTENT="20140911;16252286">')
Aadd(aTxt, '<META NAME="Info 0" CONTENT="">')
Aadd(aTxt, '<META NAME="Info 1" CONTENT="">')
Aadd(aTxt, '<META NAME="Info 2" CONTENT="">')
Aadd(aTxt, '<META NAME="Info 3" CONTENT="">')
Aadd(aTxt, '<META NAME="SDFOOTNOTE" CONTENT=";;;;P">')
Aadd(aTxt, '<META NAME="SDENDNOTE" CONTENT="ARABIC">')
Aadd(aTxt, '<STYLE TYPE="text/css">')
Aadd(aTxt, '<!--')
Aadd(aTxt, '@page { size: 29.7cm 21cm; margin-left: 2.5cm; margin-right: 2.5cm; margin-top: 1.1cm; margin-bottom: 1.1cm }')
Aadd(aTxt, 'P { margin-bottom: 0.21cm; color: #000000 }')
Aadd(aTxt, 'TD P { margin-bottom: 0.21cm; color: #000000 }')
Aadd(aTxt, 'A:link { color: #000080; so-language: zxx; text-decoration: underline }')
Aadd(aTxt, 'A:visited { color: #800000; so-language: zxx; text-decoration: underline }')
Aadd(aTxt, '-->')
Aadd(aTxt, '</STYLE>')
Aadd(aTxt, '</HEAD>')
Aadd(aTxt, '<BODY LANG="pt-PT" TEXT="#000000" LINK="#000080" VLINK="#800000" DIR="LTR" STYLE="border: 1px solid #000000; padding: 0.05cm">')
Aadd(aTxt, '<DIV TYPE=HEADER>')
Aadd(aTxt, '<P ALIGN=JUSTIFY STYLE="margin-bottom: 0cm"><IMG SRC="vdfr460_logo.png" NAME="figura1" ALIGN=RIGHT HSPACE=9 WIDTH=84 HEIGHT=74 BORDER=0><BR CLEAR=RIGHT><FONT FACE="Times New Roman Normal"><FONT SIZE=4><B>[*cVdCert1*]</B></FONT></FONT></P>')
Aadd(aTxt, '<P ALIGN=JUSTIFY STYLE="margin-bottom: 0cm"><FONT FACE="Times New Roman Normal"><FONT SIZE=4><B>[*cVdCert2*]</B></FONT></FONT></P>')
Aadd(aTxt, '<P ALIGN=JUSTIFY STYLE="margin-bottom: 0cm"><FONT FACE="Times New Roman Normal"><FONT SIZE=4><B>[*cVdCert3*]</B></FONT></FONT></P>')
Aadd(aTxt, '<P ALIGN=JUSTIFY STYLE="margin-bottom: 0.5cm"><BR><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</DIV>')
Aadd(aTxt, '<P ALIGN=CENTER STYLE="margin-bottom: 0cm; line-height: 150%"><FONT FACE="Verdana, sans-serif"><FONT SIZE=2><B><SPAN STYLE="font-variant: normal"><FONT SIZE=2 STYLE="font-size: 11pt"><SPAN STYLE="font-style: normal">C&Aacute;LCULO')
Aadd(aTxt, 'PARA ABONO PERMAN&Ecirc;NCIA (INGRESSO COMO SERVIDOR P&Uacute;BLICO')
Aadd(aTxt, 'NA PGJ ANTES DE 15/12/1998</SPAN></FONT></SPAN><SPAN STYLE="font-variant: normal"><SPAN STYLE="font-style: normal">)</SPAN></SPAN></B></FONT></FONT></P>')
Aadd(aTxt, '<P ALIGN=CENTER STYLE="margin-bottom: 0cm; font-variant: normal; font-style: normal; line-height: 150%">')
Aadd(aTxt, '<FONT FACE="Verdana, sans-serif"><FONT SIZE=2><B>[*RA_MAT*] -')
Aadd(aTxt, '[*RA_NOME*]</B></FONT></FONT></P>')
Aadd(aTxt, '<P ALIGN=CENTER STYLE="margin-bottom: 0cm; line-height: 150%"><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '<TABLE WIDTH=853 CELLPADDING=4 CELLSPACING=0>')
Aadd(aTxt, '<COL WIDTH=77>')
Aadd(aTxt, '<COL WIDTH=86>')
Aadd(aTxt, '<COL WIDTH=80>')
Aadd(aTxt, '<COL WIDTH=52>')
Aadd(aTxt, '<COL WIDTH=62>')
Aadd(aTxt, '<COL WIDTH=45>')
Aadd(aTxt, '<COL WIDTH=47>')
Aadd(aTxt, '<COL WIDTH=55>')
Aadd(aTxt, '<COL WIDTH=123>')
Aadd(aTxt, '<COL WIDTH=143>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=8 WIDTH=561 STYLE="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0.1cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>TEMPO')
Aadd(aTxt, 'DE SERVI&Ccedil;O AVERBADO </FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0.1cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>OBSERVA&Ccedil;&Otilde;ES</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=143 STYLE="border: 1px solid #000000; padding: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD WIDTH=77 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">IN&Iacute;CIO')
Aadd(aTxt, '</FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=86 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">T&Eacute;RMINO</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=80 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">INSTITUI&Ccedil;&Atilde;O')
Aadd(aTxt, '</FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">TEMPO')
Aadd(aTxt, 'BRUTO </FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=62 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">TEMPO')
Aadd(aTxt, 'L&Iacute;Q.</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=45 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">ANO(S)')
Aadd(aTxt, '</FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=47 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">M&Ecirc;S(S)</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=55 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">DIA(S)</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=143 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[/FILE/\INICIALIZADORES\VDFR460_RII.HTM\FILE\]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=3 WIDTH=260 HEIGHT=17 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">TOTAL')
Aadd(aTxt, '= A</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*A_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=62 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*A_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=45 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*A_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=47 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*A_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=55 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*A_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">A')
Aadd(aTxt, '= SOMA DAS AVERBA&Ccedil;&Otilde;ES</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=143 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">A</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=8 WIDTH=561 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>TEMPO')
Aadd(aTxt, 'DE SERVI&Ccedil;O [*cVdCert6*] AT&Eacute; 15/12/1998</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=143 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD WIDTH=77 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">IN&Iacute;CIO</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=86 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">T&Eacute;RMINO</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=80 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">INSTITUI&Ccedil;&Atilde;O</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">TEMPO')
Aadd(aTxt, 'BRUTO</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=62 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">TEMPO')
Aadd(aTxt, 'LIQ.</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=45 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">ANO(S)')
Aadd(aTxt, '</FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=47 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">M&Ecirc;S(S)')
Aadd(aTxt, '</FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=55 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">DIA(S)</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=143 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD WIDTH=77 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*RA_ADMISSA*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=86 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">15/12/1998</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=80 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*cVdCert6*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*B_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=62 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*B_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=45 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*B_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=47 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*B_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=55 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*B_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>B =')
Aadd(aTxt, 'TEMPO NA [*cVdCert6*] AT&Eacute; <FONT COLOR="#000000">15/12/1998</FONT></FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=143 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>B</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=3 WIDTH=260 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=LEFT><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">AVERBA&Ccedil;&Otilde;ES')
Aadd(aTxt, 'A</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*A_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=62 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*A_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=45 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*A_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=47 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*A_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=55 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*A_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>A</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=143 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>A</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=3 WIDTH=260 HEIGHT=13 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=LEFT><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">TOTAL')
Aadd(aTxt, 'C</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*C_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=62 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*C_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=45 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*C_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=47 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*C_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=55 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*C_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>C =')
Aadd(aTxt, 'A+B</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=143 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>C</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=3 WIDTH=260 VALIGN=TOP STYLE="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0.1cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=LEFT><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>B&Ocirc;NUS')
Aadd(aTxt, 'DE 17% D </FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*D_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=62 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*D_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=45 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*D_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=47 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*D_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=55 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*D_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>D =')
Aadd(aTxt, 'C x 17%</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=143 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>D</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=3 WIDTH=260 VALIGN=TOP STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=LEFT><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">TOTAL')
Aadd(aTxt, 'COM B&Ocirc;NUS EM <FONT COLOR="#000000">15/12/1998</FONT></FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*E_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=62 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*E_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=45 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*E_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=47 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*E_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=55 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*E_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>E =')
Aadd(aTxt, 'C + D</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=143 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>E</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=8 WIDTH=561 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt"><B>APOSENTADORIA')
Aadd(aTxt, 'INTEGRAL (20%)</B></FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=143 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=3 WIDTH=260 VALIGN=TOP STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=LEFT><FONT FACE="Verdana, sans-serif"><FONT SIZE=1>TEMPO')
Aadd(aTxt, 'DE SERVI&Ccedil;O EXIGIDO PARA APOSENTADORIA &ndash; INTEGRAL </FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*F_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=62 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*F_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=45 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*F_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=47 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*F_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=55 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*F_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>F =')
Aadd(aTxt, 'VALOR FIXO PARA MEMBRO MASCULINO</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=143 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>F</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=3 WIDTH=260 VALIGN=TOP STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=LEFT><FONT FACE="Verdana, sans-serif"><FONT SIZE=1>TEMPO')
Aadd(aTxt, 'DE CONTRIBUI&Ccedil;&Atilde;O QUE FALTA PARA APOSENTADORIA')
Aadd(aTxt, 'INTEGRAL A PARTIR DE 16-12-1998 (SEM O PED&Aacute;GIO)</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*G_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=62 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*G_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=45 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*G_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=47 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*G_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=55 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*G_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>G =')
Aadd(aTxt, 'F - E</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=143 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>G</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=3 WIDTH=260 VALIGN=TOP STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=LEFT><FONT FACE="Verdana, sans-serif"><FONT SIZE=1>TEMPO')
Aadd(aTxt, 'ADICIONAL (PED&Aacute;GIO 20%) </FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*H_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=62 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*H_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=45 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*H_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=47 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*H_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=55 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*H_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>H =')
Aadd(aTxt, 'G x 20%</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=143 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>H</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=3 WIDTH=260 VALIGN=TOP STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=LEFT><FONT FACE="Verdana, sans-serif"><FONT SIZE=1>TOTAL')
Aadd(aTxt, 'DE TEMPO QUE FALTA P/ APOSENTADORIA &ndash; INTEGRAL </FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*I_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=62 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*I_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=45 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*I_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=47 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*I_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=55 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*I_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>I =')
Aadd(aTxt, 'G + H</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=143 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>I</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=3 WIDTH=260 VALIGN=TOP STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=LEFT><FONT FACE="Verdana, sans-serif"><FONT SIZE=1>DATA')
Aadd(aTxt, 'PROV&Aacute;VEL PARA AQUISI&Ccedil;&Atilde;O DO DIREITO (QUANTO AO')
Aadd(aTxt, 'TEMPO DE SERVI&Ccedil;O ) </FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD COLSPAN=5 WIDTH=293 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 11pt"><B>[*J_DATA_EXTENSO*]</B></FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 11pt"><B>J')
Aadd(aTxt, '= I + 16/12/1998</B></FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=143 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 11pt"><B>J</B></FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=8 WIDTH=561 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt"><B>APOSENTADORIA')
Aadd(aTxt, 'PROPORCIONAL (40%)</B></FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=143 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=3 WIDTH=260 VALIGN=TOP STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=LEFT><FONT FACE="Verdana, sans-serif"><FONT SIZE=1>TEMPO')
Aadd(aTxt, 'DE SERVI&Ccedil;O EXIGIDO PARA APOSENTADORIA PROPORCIONAIS</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*L_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=62 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*L_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=45 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*L_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=47 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*L_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=55 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*L_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>L =')
Aadd(aTxt, 'VALOR FIXO PARA MEMBRO MASCULINO</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=143 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=3 WIDTH=260 VALIGN=TOP STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=LEFT><FONT FACE="Verdana, sans-serif"><FONT SIZE=1>TEMPO ')
Aadd(aTxt, 'DE  CONTRIBUI&Ccedil;&Atilde;O  EM 15/12/1998</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*F40_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=62 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*F40_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=45 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*F40_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=47 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*F40_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=55 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*F40_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>F</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=143 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>F</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=3 WIDTH=260 VALIGN=TOP STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=LEFT><FONT FACE="Verdana, sans-serif"><FONT SIZE=1>TEMPO ')
Aadd(aTxt, 'DE CONTRIBUI&Ccedil;&Atilde;O  QUE  FALTA  PARA APOSENTADORIA ')
Aadd(aTxt, 'PROPORCIONAL  A PARTIR  DE 16/12/1998  (SEM O PEG&Aacute;GIO)</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*M_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=62 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*M_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=45 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*M_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=47 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*M_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=55 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*M_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>M =')
Aadd(aTxt, 'L - F</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=143 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>M</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=3 WIDTH=260 VALIGN=TOP STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=LEFT><FONT FACE="Verdana, sans-serif"><FONT SIZE=1>TEMPO')
Aadd(aTxt, 'ADICIONAL (PED&Aacute;GIO DE 40%)</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*N_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=62 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*N_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=45 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*N_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=47 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*N_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=55 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*N_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>N =')
Aadd(aTxt, 'M X 40%</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=143 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>N</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=3 WIDTH=260 VALIGN=TOP STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=LEFT><FONT FACE="Verdana, sans-serif"><FONT SIZE=1>TOTAL')
Aadd(aTxt, 'DE TEMPO QUE FALTA P/ APOSENTADORIA - PROPORCIONAL </FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*O_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=62 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*O_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=45 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*O_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=47 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*O_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=55 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*O_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>O =')
Aadd(aTxt, 'M + N</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=143 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>O</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=8 WIDTH=561 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>TEMPO')
Aadd(aTxt, 'DE SERVI&Ccedil;O [*cVdCert6*] AP&Oacute;S 15/12/1998</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=143 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD WIDTH=77 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>16/12/1998</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=86 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*dDataBase*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=80 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*cVdCert6*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*P_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=62 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*P_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=45 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*P_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=47 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*P_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=55 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*P_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>P =')
Aadd(aTxt, 'TEMPO DE SERVI&Ccedil;O [*cVdCert6*] AP&Oacute;S 15/12/1998</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=143 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>P</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=8 WIDTH=561 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">TEMPO')
Aadd(aTxt, 'TOTAL DE SERVI&Ccedil;O E CONTRIBUI&Ccedil;&Atilde;O</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=143 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=4 WIDTH=320 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=JUSTIFY><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">ESPECIFICA&Ccedil;&Atilde;O</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=62 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">TOTAL</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=45 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">ANO(S)')
Aadd(aTxt, '</FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=47 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">M&Ecirc;S(S)</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=55 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">DIA(S)</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=143 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=4 WIDTH=320 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=JUSTIFY><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*cVdCert6*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=62 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*Q_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=45 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*Q_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=47 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*Q_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=55 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*Q_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>Q =')
Aadd(aTxt, 'P + B</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=143 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>Q</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=4 WIDTH=320 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=JUSTIFY><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">B&Ocirc;NUS')
Aadd(aTxt, 'DE CONVERS&Atilde;O (17%)</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=62 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*D_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=45 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*D_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=47 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*D_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=55 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*D_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>D</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=143 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>D</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=4 WIDTH=320 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=JUSTIFY><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">OUTROS(AS')
Aadd(aTxt, 'AVERBA&Ccedil;&Otilde;ES)</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=62 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*A_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=45 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*A_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=47 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*A_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=55 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*A_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>A</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=143 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>A</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=4 WIDTH=320 HEIGHT=14 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=JUSTIFY><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">TOTAL')
Aadd(aTxt, 'AT&Eacute; [*dDataBase*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=62 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*R_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=45 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*R_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=47 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*R_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=55 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*R_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>R =')
Aadd(aTxt, 'Q + D + A</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=143 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>R</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=8 WIDTH=561 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>IDADE')
Aadd(aTxt, 'DO REQUERENTE</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=143 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=2 WIDTH=171 BGCOLOR="#ffffff" STYLE="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0.1cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>DATA')
Aadd(aTxt, 'DE NASCIMENTO DO REQUERENTE</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD COLSPAN=2 WIDTH=140 BGCOLOR="#ffffff" STYLE="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0.1cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">PUBLICA&Ccedil;&Otilde;ES')
Aadd(aTxt, 'DAS EC ([*EMENDAS*]) e DATA ATUAL</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=62 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">TOTAL</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=45 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">ANO(S)</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=47 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">M&Ecirc;S(S)')
Aadd(aTxt, '</FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=55 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">DIA(S)</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=143 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[/FILE/\INICIALIZADORES\VDFR460_IDADE.HTM\FILE\]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '</TABLE>')
Aadd(aTxt, '<P STYLE="margin-bottom: 0cm"><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '<P STYLE="margin-bottom: 0cm"><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '<P ALIGN=JUSTIFY STYLE="margin-bottom: 0cm; line-height: 150%"><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '<P ALIGN=JUSTIFY STYLE="margin-bottom: 0cm; line-height: 150%"><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '<P ALIGN=JUSTIFY STYLE="margin-bottom: 0cm; line-height: 150%"><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '<P ALIGN=JUSTIFY STYLE="margin-bottom: 0cm; line-height: 150%"><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '<P ALIGN=JUSTIFY STYLE="line-height: 150%"><BR><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '<DIV TYPE=FOOTER>')
Aadd(aTxt, '<P ALIGN=CENTER STYLE="margin-top: 0.5cm; margin-bottom: 0cm"><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</DIV>')
Aadd(aTxt, '</BODY>')
Aadd(aTxt, '</HTML>')

Return aTxt

//------------------------------------------------------------------------------
/*/{Protheus.doc} AntesMasS
FunÁ„o para retorno da matriz do arquivo vdfr460_antes_masculino_servidor.htm
@sample 	AntesMasS
@return	aTxt        Matriz com o Txt a ser gravado
@author    Wagner Mobile Costa
@since		18/09/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------

Static Function AntesMasS

Local aTxt := {}

Aadd(aTxt, '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">')
Aadd(aTxt, '<HTML>')
Aadd(aTxt, '<HEAD>')
Aadd(aTxt, '<META HTTP-EQUIV="CONTENT-TYPE" CONTENT="text/html; charset=windows-1252">')
Aadd(aTxt, '<TITLE></TITLE>')
Aadd(aTxt, '<META NAME="GENERATOR" CONTENT="LibreOffice 4.0.1.2 (Windows)">')
Aadd(aTxt, '<META NAME="CREATED" CONTENT="20050318;14262800">')
Aadd(aTxt, '<META NAME="CHANGED" CONTENT="20140905;17274272">')
Aadd(aTxt, '<META NAME="Info 0" CONTENT="">')
Aadd(aTxt, '<META NAME="Info 1" CONTENT="">')
Aadd(aTxt, '<META NAME="Info 2" CONTENT="">')
Aadd(aTxt, '<META NAME="Info 3" CONTENT="">')
Aadd(aTxt, '<META NAME="SDFOOTNOTE" CONTENT=";;;;P">')
Aadd(aTxt, '<META NAME="SDENDNOTE" CONTENT="ARABIC">')
Aadd(aTxt, '<STYLE TYPE="text/css">')
Aadd(aTxt, '<!--')
Aadd(aTxt, '@page { size: 29.7cm 21cm; margin-left: 2.5cm; margin-right: 2.5cm; margin-top: 1.1cm; margin-bottom: 1.1cm }')
Aadd(aTxt, 'P { margin-bottom: 0.21cm; color: #000000 }')
Aadd(aTxt, 'TD P { margin-bottom: 0.21cm; color: #000000 }')
Aadd(aTxt, 'A:link { color: #000080; so-language: zxx; text-decoration: underline }')
Aadd(aTxt, 'A:visited { color: #800000; so-language: zxx; text-decoration: underline }')
Aadd(aTxt, '-->')
Aadd(aTxt, '</STYLE>')
Aadd(aTxt, '</HEAD>')
Aadd(aTxt, '<BODY LANG="pt-PT" TEXT="#000000" LINK="#000080" VLINK="#800000" DIR="LTR" STYLE="border: 1px solid #000000; padding: 0.05cm">')
Aadd(aTxt, '<DIV TYPE=HEADER>')
Aadd(aTxt, '<P ALIGN=JUSTIFY STYLE="margin-bottom: 0cm"><IMG SRC="vdfr460_logo.png" NAME="figura1" ALIGN=RIGHT HSPACE=9 WIDTH=84 HEIGHT=74 BORDER=0><BR CLEAR=RIGHT><FONT FACE="Times New Roman Normal"><FONT SIZE=4><B>[*cVdCert1*]</B></FONT></FONT></P>')
Aadd(aTxt, '<P ALIGN=JUSTIFY STYLE="margin-bottom: 0cm"><FONT FACE="Times New Roman Normal"><FONT SIZE=4><B>[*cVdCert2*]</B></FONT></FONT></P>')
Aadd(aTxt, '<P ALIGN=JUSTIFY STYLE="margin-bottom: 0cm"><FONT FACE="Times New Roman Normal"><FONT SIZE=4><B>[*cVdCert3*]</B></FONT></FONT></P>')
Aadd(aTxt, '<P ALIGN=JUSTIFY STYLE="margin-bottom: 0.5cm"><BR><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</DIV>')
Aadd(aTxt, '<P ALIGN=CENTER STYLE="margin-bottom: 0cm; font-variant: normal; font-style: normal; line-height: 150%">')
Aadd(aTxt, '<FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 11pt"><B>C&Aacute;LCULO')
Aadd(aTxt, 'PARA ABONO PERMAN&Ecirc;NCIA (INGRESSO COMO SERVIDOR P&Uacute;BLICO')
Aadd(aTxt, 'NA PGJ ANTES DE 15/12/1998<FONT SIZE=2>)</FONT></B></FONT></FONT></P>')
Aadd(aTxt, '<P ALIGN=CENTER STYLE="margin-bottom: 0cm; font-variant: normal; font-style: normal; line-height: 150%">')
Aadd(aTxt, '<FONT FACE="Verdana, sans-serif"><FONT SIZE=2><B>[*RA_MAT*] -')
Aadd(aTxt, '[*RA_NOME*]</B></FONT></FONT></P>')
Aadd(aTxt, '<P ALIGN=CENTER STYLE="margin-bottom: 0cm; line-height: 150%"><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '<TABLE WIDTH=766 CELLPADDING=4 CELLSPACING=0>')
Aadd(aTxt, '<COL WIDTH=71>')
Aadd(aTxt, '<COL WIDTH=69>')
Aadd(aTxt, '<COL WIDTH=83>')
Aadd(aTxt, '<COL WIDTH=46>')
Aadd(aTxt, '<COL WIDTH=46>')
Aadd(aTxt, '<COL WIDTH=46>')
Aadd(aTxt, '<COL WIDTH=46>')
Aadd(aTxt, '<COL WIDTH=46>')
Aadd(aTxt, '<COL WIDTH=106>')
Aadd(aTxt, '<COL WIDTH=123>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=8 WIDTH=511 STYLE="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0.1cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">TEMPO')
Aadd(aTxt, 'DE SERVI&Ccedil;O AVERBADO </FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=106 STYLE="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0.1cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border: 1px solid #000000; padding: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD WIDTH=71 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">IN&Iacute;CIO')
Aadd(aTxt, '</FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=69 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">T&Eacute;RMINO</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=83 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">INSTITUI&Ccedil;&Atilde;O')
Aadd(aTxt, '</FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">TEMPO')
Aadd(aTxt, 'BRUTO </FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">TEMPO')
Aadd(aTxt, 'L&Iacute;Q.</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">ANOS')
Aadd(aTxt, '</FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">MESES</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">DIAS</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=106 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[/FILE/\INICIALIZADORES\VDFR460_RII.HTM\FILE\]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=3 WIDTH=239 HEIGHT=17 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">TOTAL</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*A_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*A_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*A_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*A_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*A_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=106 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">SOMA')
Aadd(aTxt, 'TOTAL DAS AVERBA&Ccedil;&Otilde;ES</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">A</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=8 WIDTH=511 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=106 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=8 WIDTH=511 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">TEMPO')
Aadd(aTxt, 'DE SERVI&Ccedil;O <FONT SIZE=2>[*cVdCert6*] </FONT>AT&Eacute;')
Aadd(aTxt, '15-12-1998</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=106 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD WIDTH=71 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">IN&Iacute;CIO</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=69 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">T&Eacute;RMINO</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=83 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">INSTITUI&Ccedil;&Atilde;O</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">TEMPO')
Aadd(aTxt, 'BRUTO</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">TEMPO')
Aadd(aTxt, 'LIQ.</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">ANO(S)')
Aadd(aTxt, '</FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">M&Ecirc;S(S)')
Aadd(aTxt, '</FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">DIA(S)</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=106 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD WIDTH=71 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*RA_ADMISSA*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=69 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1>15/12/1998</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=83 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">PGJ</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*B_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*B_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*B_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*B_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*B_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=106 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">TEMPO')
Aadd(aTxt, 'DE SERVI&Ccedil;O [*cVdCert6*] AT&Eacute; 15/12/1998</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">B</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=3 WIDTH=239 VALIGN=TOP STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=LEFT><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">OUTROS')
Aadd(aTxt, '</FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*A_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*A_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*A_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*A_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*A_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=106 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">A</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=3 WIDTH=239 VALIGN=TOP STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=LEFT><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">TEMPO')
Aadd(aTxt, 'DE SERVI&Ccedil;O EM 15/12/1998</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*C_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*C_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*C_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*C_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*C_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=106 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">C')
Aadd(aTxt, '= A + B</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">C</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=3 WIDTH=239 VALIGN=TOP STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=LEFT><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">TEMPO')
Aadd(aTxt, 'DE SERVI&Ccedil;O EXIGIDO PARA APOSENTADORIA - INTEGRAL</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*D_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*D_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*D_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*D_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*D_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=106 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">VALOR')
Aadd(aTxt, 'FIXO 35 ANOS PARA SERVIDOR (INTEGRAL)</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">D</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=3 WIDTH=239 VALIGN=TOP STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=LEFT><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt"><SPAN STYLE="background: transparent">TEMPO')
Aadd(aTxt, 'DE CONTRIBUI&Ccedil;&Atilde;O QUE FALTA PARA APOSENTADORIA')
Aadd(aTxt, 'INTEGRAL A PARTIR DE 15/12/1998 (SEM O PED&Aacute;GIO)</SPAN></FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*E_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*E_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*E_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*E_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*E_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=106 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt"><SPAN STYLE="background: transparent">E')
Aadd(aTxt, '= D - C</SPAN></FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt"><SPAN STYLE="background: transparent">E</SPAN></FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=3 WIDTH=239 VALIGN=TOP STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=LEFT><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">TEMPO')
Aadd(aTxt, 'ADICIONAL (PED&Aacute;GIO 20%)</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*F_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*F_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*F_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*F_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*F_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=106 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">F')
Aadd(aTxt, '= E x 20%</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">F</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=3 WIDTH=239 VALIGN=TOP STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=LEFT><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">TOTAL')
Aadd(aTxt, 'DE TEMPO QUE FALTA P/ APOSENTADORIA - INTEGRAL</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*GFA_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*GFA_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*GFA_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*GFA_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*GFA_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=106 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">G')
Aadd(aTxt, '= F +E</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">G</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=3 WIDTH=239 VALIGN=TOP STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=LEFT><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">TEMPO')
Aadd(aTxt, 'DE SERVI&Ccedil;O EXIGIDO PARA APOSENTADORIA PROPORCIONAIS</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*L_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*L_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*L_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*L_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*L_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=106 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">VALOR')
Aadd(aTxt, 'FIXO 30 ANOS PARA SERVIDOR (PROPORCIONAL)</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">H</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=3 WIDTH=239 VALIGN=TOP STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=LEFT><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">TEMPO')
Aadd(aTxt, 'DE CONTRIBUI&Ccedil;&Atilde;O EM 15/12/1998</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*C_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*C_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*C_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*C_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*C_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=106 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">C</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=3 WIDTH=239 VALIGN=TOP STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=LEFT><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">TEMPO')
Aadd(aTxt, 'DE CONTRIBUI&Ccedil;&Atilde;O QUE FALTA PARA APOSENTADORIA')
Aadd(aTxt, 'PROPORCIONAL A PARTIR DE 16/12/1998 (SEM O PEG&Aacute;GIO)</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*IMS_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*IMS_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*IMS_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*IMS_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*IMS_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=106 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">I')
Aadd(aTxt, '= H-C</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">I</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=3 WIDTH=239 VALIGN=TOP STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=LEFT><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">TEMPO')
Aadd(aTxt, 'ADICIONAL (PED&Aacute;GIO DE 40%)</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*JMS_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*JMS_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*JMS_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*JMS_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*JMS_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=106 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">J')
Aadd(aTxt, '= I * 40%</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">J</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=3 WIDTH=239 HEIGHT=19 VALIGN=TOP STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=LEFT><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">TOTAL')
Aadd(aTxt, 'DE TEMPO QUE FALTA P/ APOSENTADORIA - PROPORCIONAL </FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*K_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*K_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*K_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*K_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*K_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=106 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">K')
Aadd(aTxt, '= J+ I</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">K</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=8 WIDTH=511 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">TEMPO')
Aadd(aTxt, 'DE SERVI&Ccedil;O [*cVdCert6*] AP&Oacute;S 15/12/1998</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=106 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD WIDTH=71 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">16/12/1998</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=69 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm" SDVAL="40372" SDNUM="1046;0;@">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*dDataBase*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=83 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*cVdCert6*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*L_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*L_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*L_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*L_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*L_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=106 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">L')
Aadd(aTxt, '= <FONT SIZE=2>TEMPO DE SERVI&Ccedil;O </FONT>[*cVdCert6*] <FONT SIZE=2>AP&Oacute;S')
Aadd(aTxt, '15/12/1998</FONT></FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">L</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=8 WIDTH=511 HEIGHT=11 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=106 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=8 WIDTH=511 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">TEMPO')
Aadd(aTxt, 'TOTAL DE SERVI&Ccedil;O E CONTRIBUI&Ccedil;&Atilde;O</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=106 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=4 WIDTH=293 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=JUSTIFY><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">ESPECIFICA&Ccedil;&Atilde;O</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">TOTAL</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">ANO(S)')
Aadd(aTxt, '</FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">M&Ecirc;S(S)</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">DIA(S)</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=106 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=4 WIDTH=293 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=JUSTIFY><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*cVdCert6*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*M_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*M_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*M_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*M_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=106 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">M')
Aadd(aTxt, '= B + L</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">M</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=4 WIDTH=293 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=JUSTIFY><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">OUTROS')
Aadd(aTxt, '- AVERBA&Ccedil;&Otilde;ES</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*A_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*A_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*A_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*A_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=106 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">A</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=4 WIDTH=293 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=JUSTIFY><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">TEMPO')
Aadd(aTxt, 'TOTAL DE SERVI&Ccedil;O P&Uacute;BLICO AT&Eacute; [*dDataBase*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*N_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*N_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*N_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*N_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=106 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">Averba&ccedil;&otilde;es')
Aadd(aTxt, 'de servi&ccedil;o p&uacute;blico + M</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=4 WIDTH=293 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=JUSTIFY><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">TEMPO')
Aadd(aTxt, 'TOTAL DE SERVI&Ccedil;O AT&Eacute; [*dDataBase*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*N_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*N_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*N_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*N_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=106 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">N')
Aadd(aTxt, '= M + A</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=8 WIDTH=511 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">IDADE')
Aadd(aTxt, 'DO REQUERENTE</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=106 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=2 WIDTH=148 BGCOLOR="#ffffff" STYLE="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0.1cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">DATA')
Aadd(aTxt, 'DE NASCIMENTO DO REQUERENTE</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD COLSPAN=2 WIDTH=138 BGCOLOR="#ffffff" STYLE="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0.1cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">PUBLICA&Ccedil;&Otilde;ES')
Aadd(aTxt, 'DAS EC ([*EMENDAS*]) e DATA ATUAL</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">TOTAL</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">ANO(S)</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">M&Ecirc;S(S)')
Aadd(aTxt, '</FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">DIA(S)</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=106 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=123 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[/FILE/\INICIALIZADORES\VDFR460_IDADE.HTM\FILE\]')
Aadd(aTxt, '</FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '</TABLE>')
Aadd(aTxt, '<P ALIGN=CENTER STYLE="margin-bottom: 0cm; line-height: 150%"><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '<P ALIGN=CENTER STYLE="line-height: 150%"><BR><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '<DIV TYPE=FOOTER>')
Aadd(aTxt, '<P ALIGN=CENTER STYLE="margin-top: 0.5cm; margin-bottom: 0cm"><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</DIV>')
Aadd(aTxt, '</BODY>')
Aadd(aTxt, '</HTML>')

Return aTxt

//------------------------------------------------------------------------------
/*/{Protheus.doc} PerApos
FunÁ„o para retorno da matriz do arquivo vdfr460_apos.htm
@sample 	PerApos
@return	aTxt        Matriz com o Txt a ser gravado
@author    Wagner Mobile Costa
@since		16/09/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------

Static Function PerApos

Local aTxt := {}

Aadd(aTxt, '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">')
Aadd(aTxt, '<HTML>')
Aadd(aTxt, '<HEAD>')
Aadd(aTxt, '<META HTTP-EQUIV="CONTENT-TYPE" CONTENT="text/html; charset=windows-1252">')
Aadd(aTxt, '<TITLE></TITLE>')
Aadd(aTxt, '<META NAME="GENERATOR" CONTENT="LibreOffice 4.0.1.2 (Windows)">')
Aadd(aTxt, '<META NAME="CREATED" CONTENT="20050318;14262800">')
Aadd(aTxt, '<META NAME="CHANGED" CONTENT="20140905;6104610">')
Aadd(aTxt, '<META NAME="Info 0" CONTENT="">')
Aadd(aTxt, '<META NAME="Info 1" CONTENT="">')
Aadd(aTxt, '<META NAME="Info 2" CONTENT="">')
Aadd(aTxt, '<META NAME="Info 3" CONTENT="">')
Aadd(aTxt, '<META NAME="SDFOOTNOTE" CONTENT=";;;;P">')
Aadd(aTxt, '<META NAME="SDENDNOTE" CONTENT="ARABIC">')
Aadd(aTxt, '<STYLE TYPE="text/css">')
Aadd(aTxt, '<!--')
Aadd(aTxt, '@page { size: 29.7cm 21cm; margin-left: 2.5cm; margin-right: 2.5cm; margin-top: 1.1cm; margin-bottom: 1.1cm }')
Aadd(aTxt, 'P { margin-bottom: 0.21cm; color: #000000 }')
Aadd(aTxt, 'TD P { margin-bottom: 0.21cm; color: #000000 }')
Aadd(aTxt, 'A:link { color: #000080; so-language: zxx; text-decoration: underline }')
Aadd(aTxt, 'A:visited { color: #800000; so-language: zxx; text-decoration: underline }')
Aadd(aTxt, '-->')
Aadd(aTxt, '</STYLE>')
Aadd(aTxt, '</HEAD>')
Aadd(aTxt, '<BODY LANG="pt-PT" TEXT="#000000" LINK="#000080" VLINK="#800000" DIR="LTR" STYLE="border: 1px solid #000000; padding: 0.05cm">')
Aadd(aTxt, '<DIV TYPE=HEADER>')
Aadd(aTxt, '<P ALIGN=JUSTIFY STYLE="margin-bottom: 0cm"><IMG SRC="vdfr460_logo.png" NAME="figura1" ALIGN=RIGHT HSPACE=9 WIDTH=84 HEIGHT=74 BORDER=0><BR CLEAR=RIGHT><FONT FACE="Times New Roman Normal"><FONT SIZE=4><B>[*cVdCert1*]</B></FONT></FONT></P>')
Aadd(aTxt, '<P ALIGN=JUSTIFY STYLE="margin-bottom: 0cm"><FONT FACE="Times New Roman Normal"><FONT SIZE=4><B>[*cVdCert2*]</B></FONT></FONT></P>')
Aadd(aTxt, '<P ALIGN=JUSTIFY STYLE="margin-bottom: 0cm"><FONT FACE="Times New Roman Normal"><FONT SIZE=4><B>[*cVdCert3*]</B></FONT></FONT></P>')
Aadd(aTxt, '<P ALIGN=JUSTIFY STYLE="margin-bottom: 0.5cm"><BR><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</DIV>')
Aadd(aTxt, '<P ALIGN=CENTER STYLE="margin-bottom: 0cm; line-height: 150%"><FONT FACE="Verdana, sans-serif"><FONT SIZE=2><B><SPAN STYLE="font-variant: normal"><FONT SIZE=2 STYLE="font-size: 11pt"><SPAN STYLE="font-style: normal">C&Aacute;LCULO')
Aadd(aTxt, 'PARA ABONO PERMAN&Ecirc;NCIA E</SPAN></FONT></SPAN><SPAN STYLE="font-variant: normal">')
Aadd(aTxt, '</SPAN><SPAN STYLE="font-variant: normal"><FONT SIZE=2 STYLE="font-size: 11pt"><SPAN STYLE="font-style: normal">APOSENTADORIA</SPAN></FONT></SPAN><SPAN STYLE="font-variant: normal">')
Aadd(aTxt, '</SPAN></B></FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '<P ALIGN=CENTER STYLE="margin-bottom: 0cm; font-variant: normal; font-style: normal; line-height: 150%">')
Aadd(aTxt, '<FONT FACE="Verdana, sans-serif"><FONT SIZE=2><B>[*RA_MAT*] -')
Aadd(aTxt, '[*RA_NOME*]</B></FONT></FONT></P>')
Aadd(aTxt, '<P ALIGN=CENTER STYLE="margin-bottom: 0cm; line-height: 150%"><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '<TABLE WIDTH=617 CELLPADDING=4 CELLSPACING=0>')
Aadd(aTxt, '<COL WIDTH=73>')
Aadd(aTxt, '<COL WIDTH=76>')
Aadd(aTxt, '<COL WIDTH=80>')
Aadd(aTxt, '<COL WIDTH=41>')
Aadd(aTxt, '<COL WIDTH=52>')
Aadd(aTxt, '<COL WIDTH=52>')
Aadd(aTxt, '<COL WIDTH=52>')
Aadd(aTxt, '<COL WIDTH=124>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=8 WIDTH=607 VALIGN=TOP STYLE="border: 1px solid #000000; padding: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>TEMPO')
Aadd(aTxt, 'DE SERVI&Ccedil;O AVERBADO </FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD WIDTH=73 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">IN&Iacute;CIO')
Aadd(aTxt, '</FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=76 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">T&Eacute;RMINO</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=80 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">INSTITUI&Ccedil;&Atilde;O')
Aadd(aTxt, '</FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=41 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">TEMPO')
Aadd(aTxt, 'BRUTO </FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">TEMPO')
Aadd(aTxt, 'L&Iacute;Q.</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">ANO(S)')
Aadd(aTxt, '</FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">M&Ecirc;S(S)</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=124 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">DIA(S)')
Aadd(aTxt, '</FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '[/FILE/\INICIALIZADORES\VDFR460_RII_APOS.HTM\FILE\]')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=3 WIDTH=245 HEIGHT=19 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">TOTAL</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=41 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*A_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*A_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*A_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*A_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=124 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*A_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=8 WIDTH=607 VALIGN=TOP STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>TEMPO')
Aadd(aTxt, 'DE SERVI&Ccedil;O/CONTRIBUI&Ccedil;&Atilde;O [*cVdCert6*]')
Aadd(aTxt, '[/FILE/\INICIALIZADORES\VDFR460_RII_APOS_3.HTM\FILE\] </FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD WIDTH=73 VALIGN=TOP STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*RA_ADMISSA*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=76 VALIGN=TOP STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*dDataBase*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=80 VALIGN=TOP STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*cVdCert6*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=41 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*B_TB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*B_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*B_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*B_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=124 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*B_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=8 WIDTH=607 HEIGHT=10 VALIGN=TOP STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">TEMPO')
Aadd(aTxt, 'TOTAL DE SERVI&Ccedil;O E CONTRIBUI&Ccedil;&Atilde;O</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=4 WIDTH=294 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=JUSTIFY><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">ESPECIFICA&Ccedil;&Atilde;O</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">TOTAL</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">ANO(S)')
Aadd(aTxt, '</FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">M&Ecirc;S(S)</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=124 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">DIA(S)</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=4 WIDTH=294 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=JUSTIFY><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">TEMPO')
Aadd(aTxt, 'NO CARGO COMISSIONADO NA PGJ</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*BC_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*BC_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*BC_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=124 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*BC_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=4 WIDTH=294 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=LEFT><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*cVdCert6*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*B_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*B_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*B_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=124 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*B_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=4 WIDTH=294 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=JUSTIFY><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">OUTROS')
Aadd(aTxt, '(AVERBADOS)</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*A_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*A_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*A_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=124 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*A_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=4 WIDTH=294 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=JUSTIFY><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">CONTAGEM')
Aadd(aTxt, 'EM DOBRO DE LICEN&Ccedil;A PR&Ecirc;MIO</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*APL_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*APL_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*APL_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=124 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*APL_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=4 WIDTH=294 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=JUSTIFY><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">TEMPO')
Aadd(aTxt, 'TOTAL DE SERVI&Ccedil;O E CONTRIBUI&Ccedil;&Atilde;O AT&Eacute;')
Aadd(aTxt, '[*dDataBase*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*TOT_TL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*TOT_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*TOT_MES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=124 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*TOT_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD COLSPAN=8 WIDTH=607 VALIGN=TOP STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>IDADE')
Aadd(aTxt, 'DO REQUERENTE</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=2 WIDTH=157 BGCOLOR="#ffffff" STYLE="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0.1cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>DATA')
Aadd(aTxt, 'DE NASCIMENTO DO REQUERENTE</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD COLSPAN=2 WIDTH=130 BGCOLOR="#ffffff" STYLE="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0.1cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">PUBLICA&Ccedil;&Otilde;ES')
Aadd(aTxt, 'DAS EC ([*EMENDAS*]) e DATA ATUAL</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">TOTAL</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">ANO(S)</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=52 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">M&Ecirc;S(S)')
Aadd(aTxt, '</FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=124 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">DIA(S)')
Aadd(aTxt, '[/FILE/\INICIALIZADORES\VDFR460_IDADE_APOS.HTM\FILE\] </FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')
Aadd(aTxt, '</TABLE>')
Aadd(aTxt, '<P STYLE="margin-bottom: 0cm"><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '<P STYLE="margin-bottom: 0cm"><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '<P ALIGN=JUSTIFY STYLE="margin-bottom: 0cm; line-height: 150%"><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '<P ALIGN=JUSTIFY STYLE="margin-bottom: 0cm; line-height: 150%"><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '<P ALIGN=JUSTIFY STYLE="margin-bottom: 0cm; line-height: 150%"><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '<P ALIGN=JUSTIFY STYLE="margin-bottom: 0cm; line-height: 150%"><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '<P ALIGN=JUSTIFY STYLE="line-height: 150%"><BR><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '<DIV TYPE=FOOTER>')
Aadd(aTxt, '<P ALIGN=CENTER STYLE="margin-top: 0.5cm; margin-bottom: 0cm"><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</DIV>')
Aadd(aTxt, '</BODY>')
Aadd(aTxt, '</HTML>')

Return aTxt

//------------------------------------------------------------------------------
/*/{Protheus.doc} HtmIdade
FunÁ„o para retorno da matriz do arquivo vdfr460_idade.htm
@sample 	HtmIdade
@return	aTxt        Matriz com o Txt a ser gravado
@author    Wagner Mobile Costa
@since		18/09/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------

Static Function HtmIdade

Local aTxt := {}

Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=2 WIDTH=147 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*RA_NASC*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD COLSPAN=2 WIDTH=142 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*IDA_DTAPUB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=66 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*IDA_TOTAL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=47 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*IDA_ANOS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=50 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*IDA_MESES*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=60 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*IDA_DIAS*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=128 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=147 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')

Return aTxt

//------------------------------------------------------------------------------
/*/{Protheus.doc} IdadePos
FunÁ„o para retorno da matriz do arquivo vdfr460_idade_apos.htm
@sample 	IdadePos
@return	aTxt        Matriz com o Txt a ser gravado
@author    Wagner Mobile Costa
@since		18/09/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------

Static Function IdadePos

Local aTxt := {}

Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=2 WIDTH=144 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*RA_NASC*]')
Aadd(aTxt, '</FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD COLSPAN=2 WIDTH=137 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*IDA_DTAPUB*]')
Aadd(aTxt, '</FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=60 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*IDA_TOTAL*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=44 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*IDA_ANOS*]')
Aadd(aTxt, '</FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*IDA_MESES*]')
Aadd(aTxt, '</FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=120 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*IDA_DIAS*]')
Aadd(aTxt, '</FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')

Return aTxt

//------------------------------------------------------------------------------
/*/{Protheus.doc} HtmRI5
FunÁ„o para retorno da matriz do arquivo vdfr460_ri5.htm
@sample 	HtmRI5
@return	aTxt        Matriz com o Txt a ser gravado
@author    Wagner Mobile Costa
@since		18/09/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------

Static Function HtmRI5

Local aTxt := {}

Aadd(aTxt, '<TR VALIGN=TOP>')
Aadd(aTxt, '<TD COLSPAN=2 WIDTH=147 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*RA_NASC*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD COLSPAN=2 WIDTH=142 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>[*RI5_DTAPUB*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=66 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*RI5_T*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=47 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*RI5_A*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=50 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*RI5_M*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=60 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2 STYLE="font-size: 9pt">[*RI5_D*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=128 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=147 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')

Return aTxt

//------------------------------------------------------------------------------
/*/{Protheus.doc} HtmRII
FunÁ„o para retorno da matriz do arquivo vdfr460_rii.htm
@sample 	HtmRII
@return	aTxt        Matriz com o Txt a ser gravado
@author    Wagner Mobile Costa
@since		18/09/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------

Static Function HtmRII

Local aTxt := {}

Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD WIDTH=62 HEIGHT=17 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*DTOC(QRY->RII_PERDE)*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=69 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*DTOC(QRY->RII_PERATE)*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=107 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=LEFT><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*ALLTRIM(QRY->RII_ORGEXP)*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=53 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*AllTrim(Str(QRY->RII_TMPBRU))*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=65 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*AllTrim(Str(QRY->RII_TMPLIQ))*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=46 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*StrZero(M->RII_TMPANO, 2)*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=50 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*StrZero(M->RII_TMPMES, 2)*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=59 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*StrZero(M->RII_TMPDIA, 2)*]</FONT></FONT></P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=126 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=134 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><BR>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')

Return aTxt

//------------------------------------------------------------------------------
/*/{Protheus.doc} HtmRIIPos
FunÁ„o para retorno da matriz do arquivo vdfr460_rii_apos.htm
@sample 	HtmRIIPos
@return	aTxt        Matriz com o Txt a ser gravado
@author    Wagner Mobile Costa
@since		18/09/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------

Static Function HtmRIIPos

Local aTxt := {}

Aadd(aTxt, '<TR>')
Aadd(aTxt, '<TD WIDTH=77 HEIGHT=17 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*DTOC(QRY->RII_PERDE)*]')
Aadd(aTxt, '</FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=86 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*DTOC(QRY->RII_PERATE)*]')
Aadd(aTxt, '</FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=80 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 6pt"><FONT SIZE=1 STYLE="font-size: 8pt">[*ALLTRIM(QRY->RII_ORGEXP)*]</FONT>')
Aadd(aTxt, '</FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=53 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*AllTrim(Str(QRY->RII_TMPBRU))*]')
Aadd(aTxt, '</FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=70 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*AllTrim(Str(QRY->RII_TMPLIQ))*]')
Aadd(aTxt, '</FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=50 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*StrZero(M->RII_TMPANO, 2)*] </FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=56 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*StrZero(M->RII_TMPMES, 2)*] </FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '<TD WIDTH=61 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
Aadd(aTxt, '<P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=1 STYLE="font-size: 8pt">[*StrZero(M->RII_TMPDIA, 2)*] </FONT></FONT>')
Aadd(aTxt, '</P>')
Aadd(aTxt, '</TD>')
Aadd(aTxt, '</TR>')

Return aTxt


//------------------------------------------------------------------------------
/*/{Protheus.doc} VD460Macro
Macro substituiÁ„o de uma string com comando advpl
@sample 	VD2460Macro(cTexto)
@param		cTexto 		Texto que sera substituido.
@return	cRetorno  	Texto com as devidas alteraÁıes.
@author    Wagner Mobile Costa
@since		31/07/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------

Function VD460Macro(cTexto, nHandle, cFile)

Local aArea := GetArea(), aSX3 := {}, cCmd := cTagIni := cTagEnd := cCampo := cTemp := "", nInicial := 0, nAux := 0

	While AT("[*", Upper(cTexto)) > 0 .Or. AT("[{*", Upper(cTexto)) > 0
		cTagIni  := "[*"
		cTagEnd  := "*]"
		If AT(cTagIni, Upper(cTexto)) == 0
			cTagIni := "[{*"
			cTagEnd := "*}]"
		EndIf

		nInicial := AT(cTagIni, Upper(cTexto))

		cCmd := Subs(cTexto, nInicial + Len(cTagIni))

		If AT(cTagEnd, Upper(cCmd)) - 1 <= 0
			MsgInfo("AtenÁ„o. Comando [" + cCmd + "] sem tag de fechamento !")
			Exit
		EndIf

		cCmd := Left(cCmd, AT(cTagEnd, Upper(cCmd)) - 1)

		//-- AverbaÁıes
		If cCmd == "A_TB"
			nA_TB := M->RII_TMPBRU
			cCmd := "AllTrim(Str(nA_TB))"
		ElseIf cCmd == "A_TL"
			If cMV_VDFMTAP == "1"	// Bruto e Liquido Diferenciado
  			   nA_TL := M->RII_TMPLIQ
			Else
  			   nA_TL := nA_TB
			EndIf
			cCmd := "AllTrim(Str(nA_TL))"

			fDias2Anos(M->RII_TMPLIQ,@nA_ANOS,@nA_MES,@nA_DIAS)
		ElseIf cCmd == "A_ANOS"
			cCmd := "StrZero(nA_ANOS, 2)"
		ElseIf cCmd == "A_MES"
			cCmd := "StrZero(nA_MES, 2)"
		ElseIf cCmd == "A_DIAS"
			cCmd := "StrZero(nA_DIAS, 2)"

		ElseIf cCmd == "A2_TB"
			cCmd := "AllTrim(Str(nA2_TB))"
		ElseIf cCmd == "A2_TL"
			cCmd := "AllTrim(Str(nA2_TL))"
		ElseIf cCmd == "A2_ANOS"
			cCmd := "StrZero(nA2_ANOS, 2)"
		ElseIf cCmd == "A2_MES"
			cCmd := "StrZero(nA2_MES, 2)"
		ElseIf cCmd == "A2_DIAS"
			cCmd := "StrZero(nA2_DIAS, 2)"

		ElseIf cCmd == "RA_MAT"
			cCmd := "SRA->RA_MAT"
		ElseIf cCmd == "RA_NOME"
			cCmd := "SRA->RA_NOME"
		ElseIf cCmd == "RA_ADMISSA"
			cCmd := "SRA->RA_ADMISSA"
		ElseIf cCmd == "RA_NASC"
			cCmd := "SRA->RA_NASC"

		ElseIf cCmd == "B_TB"
			nB_TB := M->RA_TMPBRU
			cCmd  := "AllTrim(Str(M->RA_TMPBRU))"
		ElseIf cCmd == "B_TL"
			If cMV_VDFMTAP == "1"	// Bruto e Liquido Diferenciado
   			   nB_TL := M->RA_TMPLIQ
			Else
			   nB_TL := nB_TB
			EndIf

			nBT_TB += nB_TB
			nBT_TL += nB_TL

			fDias2Anos(M->RA_TMPLIQ,@M->RA_TMPANOT,@M->RA_TMPMEST,@M->RA_TMPDIAT)
			cCmd := "AllTrim(Str(M->RA_TMPLIQ))"
		ElseIf cCmd == "B_ANOS"
			nB_ANOS := M->RA_TMPANOT
			cCmd := "StrZero(M->RA_TMPANOT, 2)"
		ElseIf cCmd == "B_MES"
			nB_MES := M->RA_TMPMEST
			cCmd := "StrZero(M->RA_TMPMEST, 2)"
		ElseIf cCmd == "B_DIAS"
			nB_DIAS := M->RA_TMPDIAT
			cCmd := "StrZero(M->RA_TMPDIAT, 2)"

		ElseIf cCmd == "BC_TL"
			If cMV_VDFMTAP == "1"	// Bruto e Liquido Diferenciado
   			   nB_TL := M->RA_TMPLIQ
			Else
   			   nB_TL := nB_TB
			EndIF

			fDias2Anos(nBC_TL,@nBC_ANOS,@nBC_MES,@nBC_DIAS)
			cCmd := "AllTrim(Str(nBC_TL))"
		ElseIf cCmd == "BC_ANOS"
			cCmd := "StrZero(nBC_ANOS, 2)"
		ElseIf cCmd == "BC_MES"
			cCmd := "StrZero(nBC_MES, 2)"
		ElseIf cCmd == "BC_DIAS"
			cCmd := "StrZero(nBC_DIAS, 2)"

		ElseIf cCmd == "BT_TB"
			cCmd  := "AllTrim(Str(nBT_TB))"
		ElseIf cCmd == "BT_TL"
			If cMV_VDFMTAP <> "1"	// Bruto e Liquido Diferenciado
			   nB_TL := nB_TB
			EndIf

			fDias2Anos(nBT_TL,@nBT_ANOS,@nBT_MES,@nBT_DIAS)
			cCmd := "AllTrim(Str(nBT_TL))"
		ElseIf cCmd == "BT_ANOS"
			cCmd := "StrZero(nBT_ANOS, 2)"
		ElseIf cCmd == "BT_MES"
			cCmd := "StrZero(nBT_MES, 2)"
		ElseIf cCmd == "BT_DIAS"
			cCmd := "StrZero(nBT_DIAS, 2)"

		//-- C + B
		ElseIf cCmd == "C_TB"
			nC_TB := M->RII_TMPBRU + M->RA_TMPBRU
			cCmd := "AllTrim(Str(nC_TB))"
		ElseIf cCmd == "C_TL"
			If cMV_VDFMTAP == "1"	// Bruto e Liquido Diferenciado
  			   nC_TL := M->RII_TMPLIQ + M->RA_TMPLIQ
			Else
  			   nC_TL := nC_TB
			EndIf

			fDias2Anos(nC_TL,@nC_ANOS,@nC_MES,@nC_DIAS)
			cCmd := "AllTrim(Str(nC_TL))"
		ElseIf cCmd == "C_ANOS"
			cCmd := "StrZero(nC_ANOS, 2)"
		ElseIf cCmd == "C_MES"
			cCmd := "StrZero(nC_MES, 2)"
		ElseIf cCmd == "C_DIAS"
			cCmd := "StrZero(nC_DIAS, 2)"
		EndIf

		//-- TEMPO PARA APOSENTADORIA INTEGRAL (20%)
		If cCmd == "D_TB" .And. lServidorM
			nD_TB := 12775
			cCmd := "AllTrim(Str(nD_TB))"
		ElseIf cCmd == "D_TL" .And. lServidorM
			nD_TL := 12775
			cCmd := "AllTrim(Str(nD_TL))"
		ElseIf cCmd == "D_ANOS" .And. lServidorM
			nD_ANOS := 35
			cCmd := "AllTrim(Str(nD_ANOS))"
		ElseIf cCmd == "D_MES" .And. lServidorM
			nD_MES := 0
			cCmd := "AllTrim(Str(nD_MES))"
		ElseIf cCmd == "D_DIAS" .And. lServidorM
			nD_DIAS := 0
			cCmd := "AllTrim(Str(nD_DIAS))"
		//-- TEMPO DE SERVI«O EXIGIDO PARA APOSENTADORIA PROPORCIONAIS E/OU ANTES 15/12/1998 - FEMININO - TEMPO DE SERVI«O EXIGIDO PARA APOSENTADORIA - INTEGRAL
		ElseIf cCmd == "D_TB" .And. lFeminino
			nD_TB := 10950
			cCmd := "AllTrim(Str(nD_TB))"
		ElseIf cCmd == "D_TL" .And. lFeminino
			nD_TL := 10950
			cCmd := "AllTrim(Str(nD_TL))"
		ElseIf cCmd == "D_ANOS" .And. lFeminino
			nD_ANOS := 30
			cCmd := "AllTrim(Str(nD_ANOS))"
		ElseIf cCmd == "D_MES" .And. lFeminino
			nD_MES := 0
			cCmd := "AllTrim(Str(nD_MES))"
		ElseIf cCmd == "D_DIAS" .And. lFeminino
			nD_DIAS := 0
			cCmd := "AllTrim(Str(nD_DIAS))"

		//-- Bonus de 17%
		ElseIf cCmd == "D_TB"
			nD_TB := RoundR460(nC_TB * 0.17, 0.60)
			cCmd := "AllTrim(Str(nD_TB))"
		ElseIf cCmd == "D_TL"
			If cMV_VDFMTAP == "1"	// Bruto e Liquido Diferenciado
			   nD_TL := RoundR460(nC_TL * 0.17, 0.60)
			Else
			   nD_TL := nD_TB
			EndIf

			fDias2Anos(nD_TL,@nD_ANOS,@nD_MES,@nD_DIAS)
			cCmd := "AllTrim(Str(nD_TL))"
		ElseIf cCmd == "D_ANOS"
			cCmd := "StrZero(nD_ANOS, 2)"
		ElseIf cCmd == "D_MES"
			cCmd := "StrZero(nD_MES, 2)"
		ElseIf cCmd == "D_DIAS"
			cCmd := "StrZero(nD_DIAS, 2)"

		//-- ANTES 15/12/98 - MASCULINO - SERVIDOR - TEMPO DE CONTRIBUI«√O QUE FALTA PARA APOSENTADORIA INTEGRAL A PARTIR DE 15-12-1998 (SEM O PED¡GIO)
		ElseIf cCmd == "E_TB" .And. lServidorM
			nE_TB := nD_TB - nC_TB
			cCmd := "AllTrim(Str(nE_TB))"
		ElseIf cCmd == "E_TL" .And. lServidorM
			If cMV_VDFMTAP == "1"	// Bruto e Liquido Diferenciado
			   nE_TL := nD_TL - nC_TL
			Else
			   nE_TL := nE_TB
			EndIf

			fDias2Anos(nE_TL,@nE_ANOS,@nE_MES,@nE_DIAS)
			cCmd := "AllTrim(Str(nE_TL))"

		//-- Total com Bonus de 17% (C+D)
		ElseIf cCmd == "E_TB"
			nE_TB := nC_TB + nD_TB
			cCmd := "AllTrim(Str(nE_TB))"
		ElseIf cCmd == "E_TL"
			If cMV_VDFMTAP == "1"	// Bruto e Liquido Diferenciado
			   nE_TL := nC_TL + nD_TL
			Else
			   nE_TL := nE_TB
			EndIf

			fDias2Anos(nE_TL,@nE_ANOS,@nE_MES,@nE_DIAS)
			cCmd := "AllTrim(Str(nE_TL))"

		ElseIf cCmd == "E_ANOS"
			cCmd := "AllTrim(Str(nE_ANOS))"
		ElseIf cCmd == "E_MES"
			cCmd := "AllTrim(Str(nE_MES))"
		ElseIf cCmd == "E_DIAS"
			cCmd := "AllTrim(Str(nE_DIAS))"

		//-- FEMININO - ANTES 15/12/1998 - TEMPO DE CONTRIBUI«√O QUE FALTA PARA APOSENTADORIA INTEGRAL A PARTIR DE 15-12-1998 (SEM O PED¡GIO)
		ElseIf cCmd == "EFA_TB"
			nEFA_TB := nD_TB - nC_TB
			cCmd := "AllTrim(Str(nEFA_TB))"
		ElseIf cCmd == "EFA_TL"
			If cMV_VDFMTAP == "1"	// Bruto e Liquido Diferenciado
   			   nEFA_TL := nD_TL - nC_TL
			Else
   			   nEFA_TL := nEFA_TB
			EndIF

			fDias2Anos(nEFA_TL,@nEFA_ANOS,@nEFA_MES,@nEFA_DIAS)
			cCmd := "AllTrim(Str(nEFA_TL))"
		ElseIf cCmd == "EFA_ANOS"
			cCmd := "AllTrim(Str(nEFA_ANOS))"
		ElseIf cCmd == "EFA_MES"
			cCmd := "AllTrim(Str(nEFA_MES))"
		ElseIf cCmd == "EFA_DIAS"
			cCmd := "AllTrim(Str(nEFA_DIAS))"

		//-- MASCULINO/SERVIDOR - ANTES 15/12/1998 - TEMPO ADICIONAL (PED¡GIO 20%)
		ElseIf cCmd == "F_TB" .And. lServidorM
			nF_TB := RoundR460(nE_TB * 0.20, 0.60)
			cCmd := "AllTrim(Str(nF_TB))"
		ElseIf cCmd == "F_TL" .And. lServidorM
			If cMV_VDFMTAP == "1"	// Bruto e Liquido Diferenciado
			   nF_TL := RoundR460(nE_TL * 0.20, 0.60)
			Else
			   nF_TL := nF_TB
			EndIf

			fDias2Anos(nF_TL,@nF_ANOS,@nF_MES,@nF_DIAS)
			cCmd := "AllTrim(Str(nF_TL))"

		ElseIf cCmd == "F_ANOS" .And. lServidorM
			cCmd := "StrZero(nF_ANOS, 2)"
		ElseIf cCmd == "F_MES" .And. lServidorM
			cCmd := "StrZero(nF_MES, 2)"
		ElseIf cCmd == "F_DIAS" .And. lServidorM
			cCmd := "StrZero(nF_DIAS, 2)"

		//-- TEMPO PARA APOSENTADORIA INTEGRAL (20%)
		ElseIf cCmd == "F_TB"
			nF_TB := 12775
			cCmd := "AllTrim(Str(nF_TB))"
		ElseIf cCmd == "F_TL"
			nF_TL := 12775
			cCmd := "AllTrim(Str(nF_TL))"
		ElseIf cCmd == "F_ANOS"
			nF_ANOS := 35
			cCmd := "AllTrim(Str(nF_ANOS))"
		ElseIf cCmd == "F_MES"
			nF_MES := 0
			cCmd := "AllTrim(Str(nF_MES))"
		ElseIf cCmd == "F_DIAS"
			nF_DIAS := 0
			cCmd := "AllTrim(Str(nF_DIAS))"

		//-- MASCULINO/MEMBRO - ANTES 15/12/1998 - TEMPO DE CONTRIBUI«√O EM 15/12/1998
		ElseIf cCmd == "F40_TB" .And. lMembroM
			nF40_TB	:= nE_TB
			nF40_TL	:= nE_TL
			nF40_ANOS	:= nE_ANOS
			nF40_MES  	:= nE_MES
			nF40_DIAS	:= nE_DIAS

			cCmd := "AllTrim(Str(nF40_TB))"
		ElseIf cCmd == "F40_TL" .And. lMembroM
			cCmd := "AllTrim(Str(nF40_TL))"
		ElseIf cCmd == "F40_ANOS" .And. lMembroM
			cCmd := "AllTrim(Str(nF40_ANOS))"
		ElseIf cCmd == "F40_MES" .And. lMembroM
			cCmd := "AllTrim(Str(nF40_MES))"
		ElseIf cCmd == "F40_DIAS" .And. lMembroM
			cCmd := "AllTrim(Str(nF40_DIAS))"

		//-- FEMININO - ANTES 15/12/1998 - TEMPO DE CONTRIBUI«√O QUE FALTA PARA APOSENTADORIA INTEGRAL A PARTIR DE 15-12-1998 (SEM O PED¡GIO)
		ElseIf cCmd == "FFA_TB"
			nFFA_TB := RoundR460(nEFA_TB * 0.20, 0.60)
			cCmd := "AllTrim(Str(nFFA_TB))"
		ElseIf cCmd == "FFA_TL"
			If cMV_VDFMTAP == "1"	// Bruto e Liquido Diferenciado
			   nFFA_TL := RoundR460(nEFA_TL * 0.20, 0.60)
			Else
			   nFFA_TL := nFFA_TB
			EndIf

			fDias2Anos(nFFA_TL,@nFFA_ANOS,@nFFA_MES,@nFFA_DIAS)
			cCmd := "AllTrim(Str(nFFA_TL))"
		ElseIf cCmd == "FFA_ANOS"
			cCmd := "AllTrim(Str(nFFA_ANOS))"
		ElseIf cCmd == "FFA_MES"
			cCmd := "AllTrim(Str(nFFA_MES))"
		ElseIf cCmd == "FFA_DIAS"
			cCmd := "AllTrim(Str(nFFA_DIAS))"

		//-- TEMPO DE CONTRIBUI«√O QUE FALTA PARA APOSENTADORIA INTEGRAL A PARTIR DE 16-12-1998 (SEM O PED¡GIO)
		ElseIf cCmd == "G_TB"
			nG_TB := nF_TB - nE_TB
			If nG_TB < 0
				nG_TB := 0
			EndIf
			cCmd := "AllTrim(Str(nG_TB))"
		ElseIf cCmd == "G_TL"
			If cMV_VDFMTAP == "1"	// Bruto e Liquido Diferenciado
			   nG_TL := nF_TL - nE_TL
			   If nG_TL < 0
				nG_TL := 0
			   EndIf
			Else
			   nG_TL := nG_TB
			EndIf

			fDias2Anos(nG_TL,@nG_ANOS,@nG_MES,@nG_DIAS)
			cCmd := "AllTrim(Str(nG_TL))"
		ElseIf cCmd == "G_ANOS"
			cCmd := "AllTrim(Str(nG_ANOS))"
		ElseIf cCmd == "G_MES"
			cCmd := "AllTrim(Str(nG_MES))"
		ElseIf cCmd == "G_DIAS"
			cCmd := "AllTrim(Str(nG_DIAS))"

		//-- FEMININO - ANTES 15/12/1998 - TEMPO DE CONTRIBUI«√O QUE FALTA PARA APOSENTADORIA INTEGRAL A PARTIR DE 15-12-1998 (SEM O PED¡GIO)
		ElseIf cCmd == "GFA_TB"
			nGFA_TB := nFFA_TB + nF_TB + nEFA_TB + nE_TB
			cCmd := "AllTrim(Str(nGFA_TB))"
		ElseIf cCmd == "GFA_TL"
			If cMV_VDFMTAP == "1"	// Bruto e Liquido Diferenciado
			   nGFA_TL := nFFA_TL + nF_TL + nEFA_TL + nE_TL
			Else
			   nGFA_TL := nGFA_TB
			EndIf
			fDias2Anos(nGFA_TL,@nGFA_ANOS,@nGFA_MES,@nGFA_DIAS)
			cCmd := "AllTrim(Str(nGFA_TL))"
		ElseIf cCmd == "GFA_ANOS"
			cCmd := "AllTrim(Str(nGFA_ANOS))"
		ElseIf cCmd == "GFA_MES"
			cCmd := "AllTrim(Str(nGFA_MES))"
		ElseIf cCmd == "GFA_DIAS"
			cCmd := "AllTrim(Str(nGFA_DIAS))"

		//-- TEMPO DE SERVI«O EXIGIDO PARA APOSENTADORIA PROPORCIONAIS
		ElseIf cCmd == "H_TB" .And. lServidorM
			nH_TB := 10950
			cCmd := "AllTrim(Str(nH_TB))"
		ElseIf cCmd == "H_TL" .And. lServidorM
			nH_TL := 10950
			cCmd := "AllTrim(Str(nH_TL))"
		ElseIf cCmd == "H_ANOS" .And. lServidorM
			nH_ANOS := 30
			cCmd := "AllTrim(Str(nH_ANOS))"
		ElseIf cCmd == "H_MES" .And. lServidorM
			nH_MES := 0
			cCmd := "AllTrim(Str(nH_MES))"
		ElseIf cCmd == "H_DIAS" .And. lServidorM
			nH_DIAS := 0
			cCmd := "AllTrim(Str(nH_DIAS))"

		//-- FEMININO - ANTES 15/12/1998 - TEMPO  DE SERVI«O  EXIGIDO  PARA  APOSENTADORIA  PROPORCIONAIS
		ElseIf cCmd == "H_TB" .And. lFeminino
			nH_TB := 9125
			cCmd := "AllTrim(Str(nH_TB))"
		ElseIf cCmd == "H_TL" .And. lFeminino
			nH_TL := 9125
			cCmd := "AllTrim(Str(nH_TL))"
		ElseIf cCmd == "H_ANOS" .And. lFeminino
			nH_ANOS := 25
			cCmd := "StrZero(nH_ANOS, 2)"
		ElseIf cCmd == "H_MES" .And. lFeminino
			nH_MES := 0
			cCmd := "StrZero(nH_MES, 2)"
		ElseIf cCmd == "H_DIAS" .And. lFeminino
			nH_DIAS := 0
			cCmd := "StrZero(nH_DIAS, 2)"

		//-- TEMPO ADICIONAL (PED¡GIO 20%)
		ElseIf cCmd == "H_TB"
			nH_TB := RoundR460(nG_TB * 0.20, 0.60)
			cCmd := "AllTrim(Str(nH_TB))"
		ElseIf cCmd == "H_TL"
			If cMV_VDFMTAP == "1"	// Bruto e Liquido Diferenciado
			   nH_TL := RoundR460(nG_TL * 0.20, 0.60)
			Else
			   nH_TL := nH_TB
			EndIF
			fDias2Anos(nH_TL,@nH_ANOS,@nH_MES,@nH_DIAS)
			cCmd := "AllTrim(Str(nH_TL))"
		ElseIf cCmd == "H_ANOS"
			cCmd := "StrZero(nH_ANOS, 2)"
		ElseIf cCmd == "H_MES"
			cCmd := "StrZero(nH_MES, 2)"
		ElseIf cCmd == "H_DIAS"
			cCmd := "StrZero(nH_DIAS, 2)"

		//-- FEMININO - ANTES 15/12/1998 - TEMPO  DE CONTRIBUI«√O  QUE FALTA  PARA APOSENTADORIA  PROPORCIONAL  A  PARTIR DE 16-12-1998  (SEM O PEG¡GIO)
		ElseIf cCmd == "I_TB" .And. lFeminino
			nI_TB := nH_TB - nC_TB
			If nI_TB < 0
				nI_TB := 0
			EndIf
			cCmd := "AllTrim(Str(nI_TB))"
		ElseIf cCmd == "I_TL" .And. lFeminino
			If cMV_VDFMTAP == "1"	// Bruto e Liquido Diferenciado
			   nI_TL := nH_TL - nC_TL
			   If nI_TL < 0
				nI_TL := 0
			   EndIf
			Else
			   nI_TL := nI_TB
			EndIf
			fDias2Anos(nI_TL,@nI_ANOS,@nI_MES,@nI_DIAS)
			cCmd := "AllTrim(Str(nI_TL))"
		ElseIf cCmd == "I_ANOS" .And. lFeminino
			cCmd := "AllTrim(Str(nI_ANOS))"
		ElseIf cCmd == "I_MES" .And. lFeminino
			cCmd := "AllTrim(Str(nI_MES))"
		ElseIf cCmd == "I_DIAS" .And. lFeminino
			cCmd := "AllTrim(Str(nI_DIAS))"

		//-- TOTAL DE TEMPO QUE FALTA P/ APOSENTADORIA ñ INTEGRAL
		ElseIf cCmd == "I_TB"
			nI_TB := nG_TB + nH_TB
			cCmd := "AllTrim(Str(nI_TB))"
		ElseIf cCmd == "I_TL"
			If cMV_VDFMTAP == "1"	// Bruto e Liquido Diferenciado
			   nI_TL := nG_TL + nH_TL
			Else
			   nI_TL := nI_TB
			EndIf
			fDias2Anos(nI_TL,@nI_ANOS,@nI_MES,@nI_DIAS)
			cCmd := "AllTrim(Str(nI_TL))"
		ElseIf cCmd == "I_ANOS"
			cCmd := "AllTrim(Str(nI_ANOS))"
		ElseIf cCmd == "I_MES"
			cCmd := "AllTrim(Str(nI_MES))"
		ElseIf cCmd == "I_DIAS"
			cCmd := "AllTrim(Str(nI_DIAS))"

		//-- ANTES 15/12/1998 - MASCULINO OU FEMININO - SERVIDOR - TEMPO DE CONTRIBUI«√O QUE FALTA PARA APOSENTADORIA PROPORCIONAL A PARTIR DE 16-12-1998 (SEM O PEG¡GIO)
		ElseIf cCmd == "IMS_TB"
			nIMS_TB := nH_TB - nC_TB
			If nI_TB < 0
				nI_TB := 0
			EndIf
			cCmd := "AllTrim(Str(nIMS_TB))"
		ElseIf cCmd == "IMS_TL"
			If cMV_VDFMTAP == "1"	// Bruto e Liquido Diferenciado
			   nIMS_TL := nH_TL - nC_TL
			   If nI_TL < 0
				nI_TL := 0
			   EndIf
			Else
			   nIMS_TL := nIMS_TB
			EndIf
			fDias2Anos(nIMS_TL,@nIMS_ANOS,@nIMS_MES,@nIMS_DIAS)
			cCmd := "AllTrim(Str(nIMS_TL))"
		ElseIf cCmd == "IMS_ANOS"
			cCmd := "AllTrim(Str(nIMS_ANOS))"
		ElseIf cCmd == "IMS_MES"
			cCmd := "AllTrim(Str(nIMS_MES))"
		ElseIf cCmd == "IMS_DIAS"
			cCmd := "AllTrim(Str(nIMS_DIAS))"

		//-- DATA PROV¡VEL PARA AQUISI«√O  DO DIREITO (QUANTO AO TEMPO DE SERVI«O )
		ElseIf cCmd == "J_DATA_EXTENSO"
			cCmd  := "Alltrim(STR(DAY(dPOS_C + nI_TL))+' de '+ MesExtenso( MONTH(dPOS_C + nI_TL) )+' de '+ " +;
			          "Alltrim(STR(YEAR(dPOS_C + nI_TL)))+'.')"

		//-- ANTES 15/12/1998 - MASCULINO - SERVIDOR - TEMPO ADICIONAL (PED¡GIO DE 40%)
		ElseIf cCmd == "JMS_TB"
			nJMS_TB := RoundR460(nIMS_TB * 0.40, 0.60)
			cCmd := "AllTrim(Str(nJMS_TB))"
		ElseIf cCmd == "JMS_TL"
			If cMV_VDFMTAP == "1"	// Bruto e Liquido Diferenciado
			   nJMS_TL := RoundR460(nIMS_TL * 0.40, 0.60)
			Else
			   nJMS_TL := nJMS_TB
			EndIF
			fDias2Anos(nJMS_TL,@nJMS_ANOS,@nJMS_MES,@nJMS_DIAS)
			cCmd := "AllTrim(Str(nJMS_TL))"
		ElseIf cCmd == "JMS_ANOS"
			cCmd := "StrZero(nJMS_ANOS, 2)"
		ElseIf cCmd == "JMS_MES"
			cCmd := "StrZero(nJMS_MES, 2)"
		ElseIf cCmd == "JMS_DIAS"
			cCmd := "StrZero(nJMS_DIAS, 2)"

		//-- ANTES 15/12/1998 - FEMININO - SERVIDOR - TEMPO ADICIONAL (PED¡GIO DE 40%)
		ElseIf cCmd == "J_TB" .And. lFeminino
			nJ_TB := RoundR460(nI_TB * 0.40, 0.60)
			cCmd := "AllTrim(Str(nJ_TB))"
		ElseIf cCmd == "J_TL" .And. lFeminino
			If cMV_VDFMTAP == "1"	// Bruto e Liquido Diferenciado
			   nJ_TL := RoundR460(nI_TL * 0.40, 0.60)
   			Else
			   nJ_TL := nJ_TB
			EndIf

			fDias2Anos(nJ_TL,@nJ_ANOS,@nJ_MES,@nJ_DIAS)
			cCmd := "AllTrim(Str(nJ_TL))"
		ElseIf cCmd == "J_ANOS" .And. lFeminino
			cCmd := "StrZero(nJ_ANOS, 2)"
		ElseIf cCmd == "J_MES" .And. lFeminino
			cCmd := "StrZero(nJ_MES, 2)"
		ElseIf cCmd == "J_DIAS" .And. lFeminino
			cCmd := "StrZero(nJ_DIAS, 2)"

		//-- ANTES 15/12/1998 - MASCULINO/FEMININO - SERVIDOR - TOTAL DE TEMPO QUE FALTA P/ APOSENTADORIA - PROPORCIONAL
		ElseIf cCmd == "K_TB"
			nK_TB := nJMS_TB + nJ_TB + nIMS_TB + nI_TB
			cCmd := "AllTrim(Str(nK_TB))"
		ElseIf cCmd == "K_TL"
			If cMV_VDFMTAP == "1"	// Bruto e Liquido Diferenciado
			   nK_TL := nJMS_TL + nJ_TL + nIMS_TL + nI_TL
			Else
			   nK_TL := nK_TB
			EndIf
			fDias2Anos(nK_TL,@nK_ANOS,@nK_MES,@nK_DIAS)

			cCmd := "AllTrim(Str(nK_TL))"
		ElseIf cCmd == "K_ANOS"
			cCmd := "AllTrim(Str(nK_ANOS))"
		ElseIf cCmd == "K_MES"
			cCmd := "AllTrim(Str(nK_MES))"
		ElseIf cCmd == "K_DIAS"
			cCmd := "AllTrim(Str(nK_DIAS))"

		//-- TEMPO DE SERVI«O EXIGIDO PARA APOSENTADORIA PROPORCIONAIS E/OU ANTES 15/12/1998 - FEMININO - TEMPO DE SERVI«O EXIGIDO PARA APOSENTADORIA - INTEGRAL
		ElseIf cCmd == "L_TB" .And. lMembroM
			nL_TB := 10950
			cCmd := "AllTrim(Str(nL_TB))"
		ElseIf cCmd == "L_TL" .And. lMembroM
			nL_TL := 10950
			cCmd := "AllTrim(Str(nL_TL))"
		ElseIf cCmd == "L_ANOS" .And. lMembroM
			nL_ANOS := 30
			cCmd := "AllTrim(Str(nL_ANOS))"
		ElseIf cCmd == "L_MES" .And. lMembroM
			nL_MES := 0
			cCmd := "AllTrim(Str(nL_MES))"
		ElseIf cCmd == "L_DIAS" .And. lMembroM
			nL_DIAS := 0
			cCmd := "AllTrim(Str(nL_DIAS))"

		//-- ANTES 15/12/1998 - MASCULINO/SERVIDOR
		ElseIf cCmd == "L_TB" .And. (lServidorM .Or. lFeminino)
			MsProcTxt(STR0007 + " [" + Dtoc(dPOS_C) + " - " + Dtoc(dDataBase) + "] ...")		// 'Calculando o periodo ['
			ProcessMessage()

			VD460TEMPO(@nL_TB, @nL_TL, dPOS_C, dDataBase)

			cCmd := "AllTrim(Str(nL_TB))"
		ElseIf cCmd == "L_TL" .And. (lServidorM .Or. lFeminino)
			If cMV_VDFMTAP <> "1"	// Bruto e Liquido Diferenciado
			   nL_TL := nL_TB
			EndIf

			fDias2Anos(nL_TL,@nL_ANOS,@nL_MES,@nL_DIAS)
			cCmd := "AllTrim(Str(nL_TL))"
		ElseIf cCmd == "L_ANOS" .And. (lServidorM .Or. lFeminino)
			cCmd := "AllTrim(Str(nL_ANOS))"
		ElseIf cCmd == "L_MES" .And. (lServidorM .Or. lFeminino)
			cCmd := "AllTrim(Str(nL_MES))"
		ElseIf cCmd == "L_DIAS" .And. (lServidorM .Or. lFeminino)
			cCmd := "AllTrim(Str(nL_DIAS))"

		ElseIf cCmd == "M_TB" .And. lMembroM		// TEMPO DE CONTRIBUI«√O QUE FALTA PARA APOSENTADORIA PROPORCIONAL A PARTIR DE 16/12/1998 (SEM O PEG¡GIO)
			nM_TB := nL_TB - nF40_TB
			cCmd := "AllTrim(Str(nM_TB))"
		ElseIf cCmd == "M_TL" .And. lMembroM
			If cMV_VDFMTAP == "1"	// Bruto e Liquido Diferenciado
			   nM_TL := nL_TL - nF40_TL
			Else
			   nM_TL := nM_TB
			EndIf
			cCmd := "AllTrim(Str(nM_TL))"

			fDias2Anos(nM_TL,@nM_ANOS,@nM_MES,@nM_DIAS)
		ElseIf cCmd == "M_TB" .And. lServidorM		// TEMPO  DE CONTRIBUI«√O  QUE  FALTA  PARA APOSENTADORIA  PROPORCIONAL  A PARTIR  DE 16/12/1998  (SEM O PEG¡GIO)
			nM_TB := nB_TB + nL_TB
			cCmd := "AllTrim(Str(nM_TB))"
		ElseIf cCmd == "M_TL" .And. lServidorM
			If cMV_VDFMTAP == "1"	// Bruto e Liquido Diferenciado
			   nM_TL := nB_TL + nL_TL
			Else
			   nM_TL := nM_TB
			EndIf
			cCmd := "AllTrim(Str(nM_TL))"

			fDias2Anos(nM_TL,@nM_ANOS,@nM_MES,@nM_DIAS)

		//-- TEMPO  DE CONTRIBUI«√O  QUE  FALTA  PARA APOSENTADORIA  PROPORCIONAL  A PARTIR  DE [99/99/9999]  (SEM O PEG¡GIO)
		ElseIf cCmd == "M_TB"
			nM_TB := nL_TB - nE_TB
			If nM_TB < 0
				nM_TB := 0
			EndIf
			cCmd := "AllTrim(Str(nM_TB))"

		//-- ANTES 15/12/1998 - MASCULINO/SERVIDOR
		ElseIf cCmd == "M_TL" .And. (lServidorM .OR. lFeminino)
			If cMV_VDFMTAP == "1"	// Bruto e Liquido Diferenciado
			   nM_TL := nB_TL + nL_TL
			Else
			   nM_TL := nM_TB
			EndIf
			cCmd := "AllTrim(Str(nM_TL))"

			fDias2Anos(nM_TL,@nM_ANOS,@nM_MES,@nM_DIAS)
		ElseIf cCmd == "M_TL"
			If cMV_VDFMTAP == "1"	// Bruto e Liquido Diferenciado
			   nM_TL := nL_TL - nE_TL
			   If nM_TL < 0
				nM_TL := 0
			   EndIf
			Else
			   nM_TL := nM_TB
			EndIf
			cCmd := "AllTrim(Str(nM_TL))"
			fDias2Anos(nM_TL,@nM_ANOS,@nM_MES,@nM_DIAS)

		ElseIf cCmd == "M_ANOS"
			cCmd := "StrZero(nM_ANOS, 2)"
		ElseIf cCmd == "M_MES"
			cCmd := "StrZero(nM_MES, 2)"
		ElseIf cCmd == "M_DIAS"
			cCmd := "StrZero(nM_DIAS, 2)"

		//-- TEMPO ADICIONAL (PED¡GIO DE 40%)
		ElseIf cCmd == "N_TB"
			nN_TB := RoundR460(nM_TB * 0.40, 0.60)
			cCmd := "AllTrim(Str(nN_TB))"

		//-- ANTES 15/12/1998 - MASCULINO/SERVIDOR
		ElseIf cCmd == "N_TL" .And. (lServidorM .Or. lFeminino)
			If cMV_VDFMTAP == "1"	// Bruto e Liquido Diferenciado
			   nN_TL := nM_TL + nA_TL
			Else
			   nN_TL := nN_TB
			EndIf
			fDias2Anos(nN_TL,@nN_ANOS,@nN_MES,@nN_DIAS)

			cCmd := "AllTrim(Str(nN_TL))"

		ElseIf cCmd == "N_TL"
			If cMV_VDFMTAP == "1"	// Bruto e Liquido Diferenciado
			   nN_TL := RoundR460(nM_TL * 0.40, 0.60)
			Else
			   nN_TL := nN_TB
			EndIf
			fDias2Anos(nN_TL,@nN_ANOS,@nN_MES,@nN_DIAS)
			cCmd := "AllTrim(Str(nN_TL))"
		ElseIf cCmd == "N_ANOS"
			cCmd := "StrZero(nN_ANOS, 2)"
		ElseIf cCmd == "N_MES"
			cCmd := "StrZero(nN_MES, 2)"
		ElseIf cCmd == "N_DIAS"
			cCmd := "StrZero(nN_DIAS, 2)"

		//-- TOTAL DE TEMPO QUE FALTA P/ APOSENTADORIA - PROPORCIONAL
		ElseIf cCmd == "O_TB"
			nO_TB := nM_TB + nN_TB
			cCmd := "AllTrim(Str(nO_TB))"
		ElseIf cCmd == "O_TL"
			If cMV_VDFMTAP == "1"	// Bruto e Liquido Diferenciado
			   nO_TL := nM_TL + nN_TL
			Else
			   nO_TL := nO_TB
			EndIf

			cCmd := "AllTrim(Str(nO_TL))"
			fDias2Anos(nO_TL,@nO_ANOS,@nO_MES,@nO_DIAS)
		ElseIf cCmd == "O_ANOS"
			cCmd := "StrZero(nO_ANOS, 2)"
		ElseIf cCmd == "O_MES"
			cCmd := "StrZero(nO_MES, 2)"
		ElseIf cCmd == "O_DIAS"
			cCmd := "StrZero(nO_DIAS, 2)"

		ElseIf cCmd == "P_TB"
			M->RA_TMPBRU  := 0
			M->RA_TMPLIQ  := 0

			MsProcTxt(STR0007 + " [" + Dtoc(dPOS_C) + " - " + Dtoc(dDataBase) + "] ...")		// 'Calculando o periodo ['
			ProcessMessage()

			VD460TEMPO(@M->RA_TMPBRU, @M->RA_TMPLIQ, dPOS_C, dDataBase)

			If cMV_VDFMTAP <> "1"	// Bruto e Liquido Diferenciado
			   M->RA_TMPLIQ := M->RA_TMPBRU
			EndIf

			M->RA_TMPANOT := 0
			M->RA_TMPMEST := 0
			M->RA_TMPDIAT := 0

			nP_TB := M->RA_TMPBRU

			// Calculo dos anos meses e dias do tempo liquido
			fDias2Anos(M->RA_TMPLIQ,@M->RA_TMPANOT,@M->RA_TMPMEST,@M->RA_TMPDIAT)

			cCmd := "AllTrim(Str(M->RA_TMPBRU))"
		ElseIf cCmd == "P_TL"
			nP_TL := M->RA_TMPLIQ
			cCmd := "AllTrim(Str(M->RA_TMPLIQ))"
		ElseIf cCmd == "P_ANOS"
			nP_ANOS := M->RA_TMPANOT
			cCmd := "StrZero(M->RA_TMPANOT, 2)"
		ElseIf cCmd == "P_MES"
			nP_MES := M->RA_TMPMEST
			cCmd := "StrZero(M->RA_TMPMEST, 2)"
		ElseIf cCmd == "P_DIAS"
			nP_DIAS := M->RA_TMPDIAT
			cCmd := "StrZero(M->RA_TMPDIAT, 2)"

		// -- PGJ
		ElseIf cCmd == "Q_TB"
			nQ_TB := nP_TB + nB_TB

			cCmd := "AllTrim(Str(nQ_TB))"
		ElseIf cCmd == "Q_TL"
			If cMV_VDFMTAP = "1"	// Bruto e Liquido Diferenciado
			   nQ_TL := nP_TL + nB_TL
			Else
			   nQ_TL := nQ_TB
			EndIf
			fDias2Anos(nQ_TL,@nQ_ANOS,@nQ_MES,@nQ_DIAS)

			cCmd := "AllTrim(Str(nQ_TL))"
		ElseIf cCmd == "Q_ANOS"
			cCmd := "StrZero(nQ_ANOS, 2)"
		ElseIf cCmd == "Q_MES"
			cCmd := "StrZero(nQ_MES, 2)"
		ElseIf cCmd == "Q_DIAS"
			cCmd := "StrZero(nQ_DIAS, 2)"

		// -- TOTAL AT…
		ElseIf cCmd == "R_TB"
			nR_TB := nQ_TB + nD_TB + nA_TB

			cCmd := "AllTrim(Str(nR_TB))"
		ElseIf cCmd == "R_TL"
			If cMV_VDFMTAP = "1"	// Bruto e Liquido Diferenciado
			    nR_TL := nQ_TL + nD_TL + nA_TL
			Else
			    nR_TL := nR_TB
			EndIf

			fDias2Anos(nR_TL,@nR_ANOS,@nR_MES,@nR_DIAS)

			cCmd := "AllTrim(Str(nR_TL))"
		ElseIf cCmd == "R_ANOS"
			cCmd := "StrZero(nR_ANOS, 2)"
		ElseIf cCmd == "R_MES"
			cCmd := "StrZero(nR_MES, 2)"
		ElseIf cCmd == "R_DIAS"
			cCmd := "StrZero(nR_DIAS, 2)"

		ElseIf cCmd == "APL_TL"
			BeginSql Alias "QRY"
			   SELECT SUM(RII_TMPLIQ) AS RII_TMPLIQ, SUM(RII_TMPBRU) AS RII_TMPBRU
                             FROM %table:RII%
                            WHERE %notDel% AND RII_FILIAL = %Exp:mv_par01% AND RII_MAT = %Exp:mv_par02% AND RII_TIPAVE= %Exp:'2'%
			EndSql

			nAPL_TL := QRY->RII_TMPBRU
			If cMV_VDFMTAP = "1"	// Bruto e Liquido Diferenciado
			   nAPL_TL := QRY->RII_TMPLIQ
			EndIf

			fDias2Anos(nAPL_TL,@nAPL_ANOS,@nAPL_MES,@nAPL_DIAS)

			DbClosearea()

			cCmd := "AllTrim(Str(nAPL_TL))"
		ElseIf cCmd == "APL_ANOS"
			cCmd := "StrZero(nAPL_ANOS, 2)"
		ElseIf cCmd == "APL_MES"
			cCmd := "StrZero(nAPL_MES, 2)"
		ElseIf cCmd == "APL_DIAS"
			cCmd := "StrZero(nAPL_DIAS, 2)"

		// -- TOTAL AT…
		ElseIf cCmd == "TOT_TL"
			If cMV_VDFMTAP = "1"	// Bruto e Liquido Diferenciado
			   nR_TL := nAPL_TL + nA_TL + nB_TL + nBC_TL + nC_TL
			Else
			   nR_TL := nR_TB
			EndIf
			fDias2Anos(nR_TL,@nR_ANOS,@nR_MES,@nR_DIAS)

			cCmd := "AllTrim(Str(nR_TL))"
		ElseIf cCmd == "TOT_ANOS"
			cCmd := "StrZero(nR_ANOS, 2)"
		ElseIf cCmd == "TOT_MES"
			cCmd := "StrZero(nR_MES, 2)"
		ElseIf cCmd == "TOT_DIAS"
			cCmd := "StrZero(nR_DIAS, 2)"

		// -- TEXTO DAS EMENDAS
		ElseIf cCmd == "EMENDAS"
			LoadEmenda()
			cEmenda := ''
			For nAux := 1 To Len(aEmenda)
				If ! Empty(cEmenda)
					If nAux == Len(aEmenda)
						cEmenda += " E "
					Else
						cEmenda += ", "
					EndIf
				EndIf
				cEmenda += aEmenda[nAux][1]
			Next
			cCmd := "cEmenda"
		EndIf

		cTabela := cCampo := ""
		If At("->", cCmd) == 4
			cTabela := Left(cCmd, 3)
			cCampo  := Subs(cCmd, At("->", cCmd) + 2)

			aSX3 := VD460TAB(cTabela,cCampo)
			If !Empty(aSX3[1,1])
				If aSX3[1,1] == 'D'
					cCmd := DTOC(&(cTabela+'->'+cCampo))
				ElseIf aSX3[1,1] == 'C'
					cCmd := ALLTRIM(&(cTabela+'->'+cCampo))
				ElseIf aSX3[1,1] == 'N'
					cCmd := ALLTRIM(Transform(&(cTabela+'->'+cCampo),aSX3[1,2]))
				Else
					cCmd := &(cTabela+'->'+cCampo)
				Endif
			Endif
		Else
			cTemp := cCmd
			If type("&cTemp") == "C"
				cCmd := ALLTRIM(&cTemp)+ ' '
			ElseIf type("&cTemp") == "D"
				cCmd := dtoc(&cTemp)+ ' '
			ElseIf type("&cTemp") == "N"
				cCmd := AllTrim(Str(&cTemp))+ ' '
			Else
				cCmd := "*********"
			Endif
		EndIf
		cTexto := Left(cTexto, nInicial - 1) + cCmd + Subs(cTexto, AT(cTagEnd, Upper(cTexto)) + Len(cTagEnd))
	EndDo

	RestArea( aArea )

Return(cTexto)

//------------------------------------------------------------------------------
/*/{Protheus.doc} RoundR460
Acha o campos na SX3 e verifica o tipo.
@sample 	RoundR460(nValor, nDecRound)
@param		nValor  	Valor com n casas decimais
			nDecRound	Nome do campo para pesquisa.
@return	nValor    	Valor Arredondando
@author	Wagner Mobile Costa
@since		12/08/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------

Function RoundR460(nValor, nDecRound)

Local nDif := nValor - Int(nValor)

If nDif > 0
	nValor := Int(nValor)
	If nDif >= nDecRound
		nValor += 1
	EndIf
EndIf

Return nValor

//------------------------------------------------------------------------------
/*/{Protheus.doc} VD460TAB
Acha o campos na SX3 e verifica o tipo.
@sample 	VD460TAB(cTabela,cCampo)
@param		cTabela 	Tabela para pesquisa.
cCampo		Nome do campo para pesquisa.
@return	cRetorno  	Tipo do campo.
@author	Nivia Ferreira
@since		17/06/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static function VD460TAB(cTabela,cCampo)
	Local cRetorno:= {{,}}

	SX3->(dbSetOrder(1))
	SX3->(DbSeek(cTabela))
	While SX3->(!EOF())

		If (AllTrim(SX3->X3_CAMPO)==cCampo)
	        cRetorno[1][1] := SX3->X3_TIPO
	        cRetorno[1][2] := SX3->X3_PICTURE
		Endif
		SX3->(dbSkip())
	End
Return (cRetorno)

//------------------------------------------------------------------------------
/*/{Protheus.doc} LOADEMENDA
Carrega as emendas do relatÛrio (Tabela S117) para Static aEmenda
@sample 	LOADEMENDA
@author	Wagner Mobile Costa
@since		28/08/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static function LOADEMENDA

Local aArea := GetArea()

If Len(aEmenda) > 0
	Return
EndIf

BeginSql Alias "QRY"
	COLUMN DATA AS DATE

	SELECT SUBSTRING(RCC_CONTEU, 1, 4) AS EMENDA, SUBSTRING(RCC_CONTEU, 5, 8) AS DATA
     FROM %table:RCC% RCC
    WHERE %notDel% AND RCC_FILIAL = %Exp:xFilial("RCC")% AND RCC_CODIGO = %Exp:'S117'%
      AND CASE WHEN RCC_FIL = %Exp:' '% THEN %Exp:cFilAnt% ELSE RCC_FIL END = %Exp:cFilAnt%
      AND R_E_C_N_O_ IN (%Exp:QryUtRCC({4, 8})%)
    GROUP BY SUBSTRING(RCC_CONTEU, 1, 4), SUBSTRING(RCC_CONTEU, 5, 8)
    ORDER BY SUBSTRING(RCC_CONTEU, 5, 8)
EndSql

While ! Eof()
	Aadd(aEmenda, { EMENDA, DATA })
	DbSkip()
EndDo
DbClosearea()

RestArea(aArea)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} VD460TEMPO
Calcula o tempo bruto e liquido de um periodo de datas
@sample 	VD460TEMPO(nBruto, nLiquido, dInicio, dFim)
@author	Wagner Mobile Costa
@since		05/09/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static function VD460TEMPO(nBruto, nLiquido, dInicio, dFim)

Local aRetorno	:= {}
Local aFaltas		:= {}
Local aDevols		:= {}
Local aLicencas	:= {}
Local aCaracts	:= {"1","2","3","4","5"}		//Considera: 1=LicenÁa;2=LicenÁa sem Subsidios;3=Suspens„o;4=Disponibilidade e 5=Outros
Local cPD0054  	:= fGetCodFol("0054")	//Faltas I
Local cPD0242  	:= fGetCodFol("0242")	//Faltas II
Local cPD1364  	:= fGetCodFol("1364")	//Faltas III
Local cPD1365  	:= fGetCodFol("1365")	//Faltas IV
Local cPD0244  	:= fGetCodFol("0244")	//Dev.Faltas I
Local cPD1363  	:= fGetCodFol("1363")	//Dev.Faltas II
Local cPD1366  	:= fGetCodFol("1366")	//Dev.Faltas III
Local cPD1367  	:= fGetCodFol("1367")	//Dev.Faltas IV
Local cJFaltas	:= "'" + AllTrim(cPD0054) + Iif(!Empty(cPD0054) .And. !Empty(cPD0242), ";", "") + AllTrim(cPD0242) + "'"
Local cNJFaltas	:= "'" + AllTrim(cPD1364) + Iif(!Empty(cPD1364) .And. !Empty(cPD1365), ";", "") + AllTrim(cPD1365) + "'"
Local cJDevols	:= "'" + AllTrim(cPD0244) + Iif(!Empty(cPD0244) .And. !Empty(cPD1363), ";", "") + AllTrim(cPD1363) + "'"
Local cNJDevols	:= "'" + AllTrim(cPD1366) + Iif(!Empty(cPD1366) .And. !Empty(cPD1367), ";", "") + AllTrim(cPD1367) + "'"
Local niPd			:= 0
Local niCaracs	:= 0
Local aTmpBru		:= {}

//No MP s„o consideradas as seguintes faltas/devoluÁıes:
//[1]-Faltas Justificadas-I;     [2]-Faltas Justificadas-II;     [3]-Faltas Nao Justificadas-III;     [4]-Faltas Nao Justificadas-IV
//[5]-Dev.Faltas Justificadas-I; [6]-Dev.Faltas Justificadas-II; [7]-Dev.Faltas Nao Justificadas-III; [8]-Dev.Faltas Nao Justificadas-IV

M->RIF_FALJUS := 0
M->RIF_FALNJU := 0
M->RIF_LICENC := 0
M->RIF_LICSUB := 0
M->RIF_SUSPEN := 0
M->RIF_DISPON := 0
M->RIF_OUTRAS := 0
M->RIF_SOMA	:= 0

//Apura Tempo Bruto Ano a Ano
aTmpBru := fGetTmpBru(dInicio,dFim)

nBruto := 0
nLiquido := 0
For niPd := 1 to Len(aTmpBru)
	nBruto   	+= aTmpBru[niPd][2]
	nLiquido 	+= aTmpBru[niPd][2]
	MsUnlock()
Next niPd

//Apura Faltas Justificadas e N„o Justificadas Ano a Ano
aRetorno := fGetFalDev(SRA->RA_FILIAL,SRA->RA_MAT,dInicio,dFim,,,.F.,aTmpBru)	//Devolve: Ano, Verba, Valor
aFaltas  := aClone(aRetorno[1])
aDevols  := aClone(aRetorno[2])

For niPd := 1 to Len(aFaltas)
	If aFaltas[niPd][2] $ (cJFaltas)		//Faltas Justificadas
		M->RIF_FALJUS	+= aFaltas[niPd][3]
	ElseIf aFaltas[niPd][2] $ (cNJFaltas)	//Faltas N„o Justificadas
		M->RIF_FALNJU	+= aFaltas[niPd][3]
	EndIf
	M->RIF_SOMA := (M->RIF_FALJUS + M->RIF_FALNJU + M->RIF_LICENC + M->RIF_SUSPEN + M->RIF_OUTRAS)
	nLiquido := (nBruto - M->RIF_SOMA)
Next niPd

For niPd := 1 to Len(aDevols)
	If aDevols[niPd][2] $ (cJDevols)		//DevoluÁıes de Faltas Justificadas
		M->RIF_FALJUS	-= aDevols[niPd][3]
	ElseIf aDevols[niPd][2] $ (cNJDevols)	//DevoluÁıes de Faltas N„o Justificadas
		M->RIF_FALNJU	-= aDevols[niPd][3]
	EndIf
	M->RIF_SOMA := (M->RIF_FALJUS + M->RIF_FALNJU + M->RIF_LICENC + M->RIF_SUSPEN + M->RIF_OUTRAS)
	nLiquido    := (nBruto - M->RIF_SOMA)
Next niPd

//Apura dias de LicenÁas
For niCaracs	:= 1 to Len(aCaracts)
	aLicencas	:= fGetLicencas(SRA->RA_FILIAL,SRA->RA_MAT,dInicio,dFim,aCaracts[niCaracs])

	For niPd := 1 to Len(aLicencas)
		If aCaracts[niCaracs] == "1"			//LicenÁas
			M->RIF_LICENC	+= aLicencas[niPd][2]
		ElseIf aCaracts[niCaracs] == "2"	//LicenÁas sem Subsidios
			M->RIF_LICSUB	+= aLicencas[niPd][2]
		ElseIf aCaracts[niCaracs] == "3"	//Suspensıes
			M->RIF_SUSPEN	+= aLicencas[niPd][2]
		ElseIf aCaracts[niCaracs] == "4"	//Disponibilidade
			M->RIF_DISPON	+= aLicencas[niPd][2]
		ElseIf aCaracts[niCaracs] == "5"	//Outros Afastamentos
			M->RIF_OUTRAS	+= aLicencas[niPd][2]
		EndIf
		M->RIF_SOMA := (M->RIF_FALNJU + M->RIF_LICENC + M->RIF_LICSUB + M->RIF_SUSPEN + M->RIF_DISPON + M->RIF_OUTRAS)
		nLiquido := (nBruto - M->RIF_SOMA)
    Next niPd
Next niCaracs

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} ZerVar
Zera as variaveis utilizadas para geraÁ„o do relatÛrio
@sample 	ZerVar()
@author	Wagner Mobile Costa
@since		09/09/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static function ZerVar

nA_TB := nA_TL := nA_ANOS := nA_MES := nA_DIAS := 0
nA2_TB := nA2_TL := nA2_ANOS := nA2_MES := nA2_DIAS := 0	//-- 2=Tempo Ferias e Licencas

nB_TB := nB_TL := nB_ANOS := nB_MES := nB_DIAS := 0
nBC_TB := nBC_TL := nBC_ANOS := nBC_MES := nBC_DIAS := 0
nBT_TB := nBT_TL := nBT_ANOS := nBT_MES := nBT_DIAS := 0

nC_TB := nC_TL := nC_ANOS := nC_MES := nC_DIAS := 0
nD_TB := nD_TL := nD_ANOS := nD_MES := nD_DIAS := 0

nE_TB := nE_TL := nE_ANOS := nE_MES := nE_DIAS := 0
nEFA_TB := nEFA_TL := nEFA_ANOS := nEFA_MES := nEFA_DIAS := 0

nF_TB := nF_TL := nF_ANOS := nF_MES := nF_DIAS := 0
nFFA_TB := nFFA_TL := nFFA_ANOS := nFFA_MES := nFFA_DIAS := 0

nG_TB := nG_TL := nG_ANOS := nG_MES := nG_DIAS := 0
nGFA_TB := nGFA_TL := nGFA_ANOS := nGFA_MES := nGFA_DIAS := 0

nH_TB := nH_TL := nH_ANOS := nH_MES := nH_DIAS := 0

nI_TB := nI_TL := nI_ANOS := nI_MES := nI_DIAS := 0
nIMS_TB := nIMS_TL := nIMS_ANOS := nIMS_MES := nIMS_DIAS := 0

nJ_TB := nJ_TL := nJ_ANOS := nJ_MES := nJ_DIAS := 0
nJMS_TB := nJMS_TL := nJMS_ANOS := nJMS_MES := nJMS_DIAS := 0

nK_TB := nK_TL := nK_ANOS := nK_MES := nK_DIAS := 0

nL_TB := nL_TL := nL_ANOS := nL_MES := nL_DIAS := 0
nM_TB := nM_TL := nM_ANOS := nM_MES := nM_DIAS := 0
nN_TB := nN_TL := nN_ANOS := nN_MES := nN_DIAS := 0
nO_TB := nO_TL := nO_ANOS := nO_MES := nO_DIAS := 0
nP_TB := nP_TL := nP_ANOS := nP_MES := nP_DIAS := 0
nQ_TB := nQ_TL := nQ_ANOS := nQ_MES := nQ_DIAS := 0
nR_TB := nR_TL := nR_ANOS := nR_MES := nR_DIAS := 0

nAPL_TL  := nAPL_ANOS := nAPL_MES := nAPL_DIAS := 0

Return
