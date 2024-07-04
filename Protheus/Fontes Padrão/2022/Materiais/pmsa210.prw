#include "pmsa210.ch"
#include "protheus.ch"
#include "dbtree.ch"
#include "pmsicons.ch"

/*/{Protheus.doc} PMSA210
Programa de Controle de Revisao dos Projetos.

@param nCallOpcx, numérico, (Descrição do parâmetro)
@return ${return}, ${return_description}

@author Edson Maricate
@since 09-02-2001
@version 1.0
/*/
Function PMSA210(nCallOpcx)
PRIVATE cCadastro	:= STR0001 //"Controle de Revisao"
Private aCores    := {	{ 'AF8_STATUS=="2"', 'BR_AMARELO', STR0047 },;	//Revisao //"Projeto em Revisao"
							{ 'AF8_STATUS="1".Or.Empty(AF8_STATUS)' , 'ENABLE', STR0048}} // Livre para revisao //"Projeto Livre para Revisao"
PRIVATE aRotina := MenuDef()

	If AMIIn(44) .And. !PMSBLKINT()

		If nCallOpcx <> Nil
			&(aRotina[nCallOpcx,2]+'("AF8",'+Str(AF8->(RecNo()))+','+Str(nCallOpcx)+')')
		Else
			mBrowse(6,1,22,75,"AF8",,,,,,aCores)
		EndIf
	EndIf

Return


/*/{Protheus.doc} PMS210Leg
Programa de Exibicao de Legendas

@param cAlias, character, (Descrição do parâmetro)
@param nReg, numérico, (Descrição do parâmetro)
@param nOpcx, numérico, (Descrição do parâmetro)

@return ${return}, ${return_description}

@author  Fabio Rogerio Pereira
@since 19-03-2002
@version 1.0
/*/
Function PMS210Leg(cAlias,nReg,nOpcx)
Local aLegenda:= {}
Local i       := 0

	For i:= 1 To Len(aCores)
		Aadd(aLegenda,{aCores[i,2],aCores[i,3]})
	Next i

	aLegenda:= aSort(aLegenda,,,{|x,y| x[1] < y[1]})

	BrwLegenda(cCadastro,STR0015,aLegenda) //"Legenda"

Return(.T.)


/*/{Protheus.doc} PMS210Hst

Programa de Consulta de Historicos da Revisao.

@param cAlias, character, (Descrição do parâmetro)
@param nReg, numérico, (Descrição do parâmetro)
@param nOpcx, numérico, (Descrição do parâmetro)
@return ${return}, ${return_description}

@author  Edson Maricate
@since 09-02-2001
@version 1.0
/*/
Function PMS210Hst(cAlias,nReg,nOpcx)
Local aRotina		:= {{STR0050,"PMS210Det",0,2},; //"Detalhes"
						{STR0007,"PMS210VHst",0,2},;//"Visualizar"
						{STR0044,"PMS210VUsu",0,2}}  //"Usuarios"
Local aSize		:= MsAdvSize(,.F.,430)
Local aUsRotina	:= {}

	If ExistBlock( "PMA210ROT" )
		If ValType( aUsRotina := ExecBlock( "PMA210ROT", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf
	FATPDLogUser('PMS210HST')
	MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro,"AFE",,aRotina,"AFE_TIPO=='2'","xFilial('AFE')+AF8->AF8_PROJET","xFilial('AFE')+AF8->AF8_PROJET",.F.,{{'ENABLE',STR0068},{'BR_CINZA',STR0069}},,{{STR0051,1}},xFilial('AFE')+AF8->AF8_PROJET) //"Versao do projeto" // versao simulada

Return .T.


/*/{Protheus.doc} PMS210VHst
Programa de Visualizacao do Historico de Orcamentos.

@param cAlias, character, (Descrição do parâmetro)
@param nReg, numérico, (Descrição do parâmetro)
@param nOpcx, numérico, (Descrição do parâmetro)
@return ${return}, ${return_description}

@author Edson Maricate
@since 09-02-2001
@version 1.0
/*/
Function PMS210VHst(cAlias,nReg,nOpcx)
Local aArea := GetArea()

	PMSA200(2,AFE->AFE_REVISA)

	RestArea(aArea)
Return .T.


/*/{Protheus.doc} PMS210Rvs
Programa de Criacao de Revisoes no Projeto.

@param cAlias, character, (Descrição do parâmetro)
@param nReg, numérico, (Descrição do parâmetro)
@param nOpcx, numérico, (Descrição do parâmetro)
@return ${return}, ${return_description}

@author Edson Maricate
@since 09-02-2001
@version 1.0
/*/
Function PMS210Rvs(cAlias,nReg,nOpcx)
Local bCampo    := {|n| FieldName(n) }
Local bOk
Local cEncerra  := ""
Local cNextVer  := ""
Local lContinua := .T.
Local lGravaOk  := .F.
Local lLancaPco := .F.
Local lTudoOk   := ExistBLock('PMA210Ok')
Local nx        := 0
Local oDlg
Local oMemo
Local oMemo2
Local oSize
Local a1stRow	:= {,,,}
Local a2ndRow	:= {,,,}
Local a3rdRow	:= {,,,}

Private cFaseAnt			:=	AF8->AF8_FASE //Variaveis para serem utilizadas na integracao com o PCO
Private M->AF8_FASE		:=	AF8->AF8_FASE //Variaveis para serem utilizadas na integracao com o PCO
Private M->AFE_COMENT	:= ""
Private M->AFE_MEMO		:= CriaVar("AFE_MEMO")
PRIVATE cSavScrVT,;
		cSavScrVP,;
		cSavScrHT,;
		cSavScrHP,;
		CurLen,;
		nPosAtu:=0,;
		nPosAnt:=9999,;
		nColAnt:=9999

	If PmsChkUser(AF8->AF8_PROJET, , Padr(AF8->AF8_PROJET, Len(AFC->AFC_EDT)), ;
			"  ", 3, "ESTRUT", AF8->AF8_REVISA)
		// verifica se o projeto nao esta reservado
		If AF8->AF8_STATUS=="2"
			Help("  ",1,"PMSA2101")
			lContinua := .F.
		EndIf

		// verifica se a fase do projeto pode gerar revisao
		If lContinua .and. !PmsVldFase("AF8",AF8->AF8_PROJET,"71")
			lContinua := .F.
		EndIf

		// trava o registro do AF8
		If !SoftLock("AF8")
			lContinua := .F.
		Endif

		//***************************
		// Integração com o SIGAPCO *
		//***************************
		PcoIniLan("000350")
		PcoIniLan('000351')

		If lContinua
			// atribui o conteudo do campo AF8_ENCPRJ que será utilizado na chamada da funcao PMSPCOFASE
			cEncerra := AF8->AF8_ENCPRJ

			// carrega as variaveis de memoria AFE
			dbSelectArea("AFE")
			RegToMemory("AFE",.F.)
			M->AFE_PROJET	:= AF8->AF8_PROJET
			M->AFE_DATAI	:= MsDate()
			M->AFE_HORAI	:= Time()
			M->AFE_REVISA	:= AF8->AF8_REVISA
			M->AFE_DESCRI	:= AF8->AF8_DESCRI
			M->AFE_USERI	:= RetCodUsr()
			M->AFE_NOMEI	:= UsrRetName(M->AFE_USERI)
			M->AFE_FULLI	:= USRFULLNAME(M->AFE_USERI)
			M->AFE_COMENT	:= ""
			M->AFE_DATAF	:= ctod("  /  /    ")
			M->AFE_HORAF	:= ""
			M->AFE_USERF	:= ""
			M->AFE_NOMEF	:= ""
			M->AFE_FULLF	:= ""
			M->AFE_COMENT	:= ""
			M->AFE_MEMO	:= ""

			If nOpcx == 3
				Inclui := .T.
			EndIf

			M->AFE_FASE   := AF8->AF8_FASE
			M->AFE_FASEOR := AF8->AF8_FASE

			DEFINE MSDIALOG oDlg TITLE cCadastro FROM 0,0 TO 45,80 OF oMainWnd
			oSize := FwDefSize():New(.T.,,,oDlg)
			
			oSize:lLateral := .F. //Indica se os objetos serao dispostos lateralmente
			oSize:lProp	:= .T. //Indica se mantem a proporcao de tamanho dos objetos dimensionáveis

			oSize:AddObject( "1STROW" ,  100, 65, .T., .T. ) // Totalmente dimensionavel
			oSize:AddObject( "2NDROW" ,  100, 08, .T., .T. ) // Totalmente dimensionavel
			oSize:AddObject( "3RDROW" ,  100, 22, .T., .T. ) // Totalmente dimensionavel

			oSize:aMargins := { 2, 2, 2, 2 } // Espaco ao lado dos objetos 0, entre eles 2

			oSize:Process() // Dispara os calculos		

			a1stRow := {NoRound(oSize:GetDimension("1STROW","LININI")),;
						NoRound(oSize:GetDimension("1STROW","COLINI")),;
						NoRound(oSize:GetDimension("1STROW","LINEND")),;
						NoRound(oSize:GetDimension("1STROW","XSIZE"))}

			a2ndRow := {NoRound(oSize:GetDimension("2NDROW","LININI")),;
						NoRound(oSize:GetDimension("2NDROW","COLINI")),;
						315,;
						NoRound(oSize:GetDimension("2NDROW","YSIZE") * 0.66)}

			a3rdRow := {NoRound(oSize:GetDimension("3RDROW","LININI")),;
						NoRound(oSize:GetDimension("3RDROW","COLINI")),;
						315,;
						NoRound(oSize:GetDimension("3RDROW","COLEND") * 0.1818)}
			
			oEnch := MsMGet():New("AFE",nReg,nOpcx,,,,,a1stRow,,,,,,oDlg)

			@ a2ndRow[1] + 001,a2ndRow[2] + 000 Say STR0066 of oDlg Pixel  //"Comentarios resumido"
			@ a2ndRow[1] + 010,a2ndRow[2] + 000 GET oMemo VAR M->AFE_MEMO MEMO SIZE a2ndRow[3],a2ndRow[4] VALID MEMOVALID() PIXEL OF oDlg

			@ a3rdRow[1] + 001,a3rdRow[2] + 000 Say STR0067 of oDlg Pixel  //"Comentarios completo"
			@ a3rdRow[1] + 010,a3rdRow[2] + 000 GET oMemo2 VAR M->AFE_COMENT MEMO SIZE a3rdRow[3],a3rdRow[4] PIXEL OF oDlg

			If lTudoOk
				bOk	:=	{|| M->AF8_FASE :=M->AFE_FASE, lGravaOk:=(M->AFE_FASE==AF8->AF8_FASE .Or. PmsFasePco(@cEncerra)) .And. ExecBlock('PMA210Ok',.F.,.F.,{'1'}),oDlg:End()}
			Else
				bOk	:=	{|| M->AF8_FASE :=M->AFE_FASE, lGravaOk:=(M->AFE_FASE==AF8->AF8_FASE .Or. PmsFasePco(@cEncerra)) ,oDlg:End()}
			Endif
			FATPDLogUser("PMS210RVS")
			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,{|| oDlg:End()}) CENTERED

			If lGravaOk
				Begin Transaction

					// estorna fase atual no PCO
					lLancaPco	:=	.F.
					If M->AFE_FASE<>AF8->AF8_FASE
						lLancaPco	:=	.T.
						PmsLancPco(2)
					Endif
					cNextVer := Soma1(AF8->AF8_REVISA)

					// verifica se a versao nao existe e pega a proxima
					dbSelectArea("AFE")
					dbSetOrder(1)
					While dbSeek(xFilial()+AF8->AF8_PROJET+cNextVer)
						cNextVer := Soma1(cNextVer)
					EndDo
					RecLock("AFE",.T.)
					For nx := 1 TO FCount()
						FieldPut(nx,M->&(EVAL(bCampo,nx)))
					Next nx
					AFE->AFE_FILIAL := xFilial("AFE")
					AFE->AFE_REVISA := cNextVer
					AFE->AFE_TIPO   := "1"
					MSMM(,TamSx3("AFE_COMENT")[1],,M->AFE_COMENT,1,,,"AFE","AFE_CODMEM")
					// Define como projeto normal.
					MsUnlock()

					//***************************
					// Integração com o SIGAPCO *
					//   Lançamento historico   *
					//***************************
					If PcoExistLc('000350','02',"1")
						DbSelectArea('AF9')
						DbSetOrder(1)
						DbSeek(xFilial()+AF8->AF8_PROJET+AF8->AF8_REVISA)
						While !AF9->(Eof()) .And. xFilial()+AF8->AF8_PROJET+AF8->AF8_REVISA == AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA
							PmsIncProc(.T.)
							PcoDetLan('000350','02')
							AF9->(DbSkip())
						Enddo
					Endif

					MaPmsRevisa(AF8->(RecNo()),,,cNextVer)

					//***************************
					// Integração com o SIGAPCO *
					//    Lançamento revisado   *
					//***************************
					If PcoExistLc('000350','01',"1")
						DbSelectArea('AF9')
						DbSetOrder(1)
						DbSeek(xFilial()+AF8->AF8_PROJET+cNextVer)
						While !AF9->(Eof()) .And. xFilial()+AF8->AF8_PROJET+cNextVer == AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA
							PmsIncProc(.T.)
							PcoDetLan('000350','01')
							AF9->(DbSkip())
						Enddo
					Endif
					RecLock("AF8",.F.)
					AF8->AF8_STATUS := "2"
					AF8->AF8_ENCPRJ := cEncerra

					AF8->AF8_FASE := M->AFE_FASE

					MsUnlock()

					// lanca nova fase no PCO
					If lLancaPco
						PmsLancPco(1)
					Endif
				End Transaction

			EndIf
			MsUnlockAll()
		EndIf

		//***************************
		// Integração com o SIGAPCO *
		//***************************
		PcoFinLan('000350')
		PcoFinLan('000351')

		If ExistBlock("PMA210IRV")
			ExecBlock("PMA210IRV", .F., .F., {lGravaOK})
		EndIf
	Else
		Aviso(STR0056, STR0057, {STR0058}, 2)
	EndIf

Return .F.


/*/{Protheus.doc} MEMOVALID
Programa de validacao do campo memo
@param ${param},${identify}, ${description}
@return ${return}, ${return_description}

@author Daniel Tadashi
@since 08-02-2008
@version 1.0
/*/
Static Function MEMOVALID()
Local lRetorno := .T.
Local nTamMemo := TamSX3("AFE_MEMO")[1]

	If nTamMemo < Len(AllTrim(M->AFE_MEMO))
		MsgAlert(STR0059+AllTrim(Str(nTamMemo))+STR0060,STR0040) //"O comentário deve ser inferior a "###" caracteres.","Atencao"
		lRetorno := .F.
	EndIf

Return lRetorno


/*/{Protheus.doc} PMS210Frv
Programa de Finalizacao da revisao no Projeto.
@param cAlias, character, (Descrição do parâmetro)
@param nReg, numérico, (Descrição do parâmetro)
@param nOpcx, numérico, (Descrição do parâmetro)
@return ${return}, ${return_description}

@author Edson Maricate
@since 09-02-2001
@version 1.0
/*/
Function PMS210Frv(cAlias,nReg,nOpcx)
Local bCampo		:= {|n| FieldName(n) }
Local bOk
Local lContinua	:= .T.
Local lGravaOk	:= .F.
Local lLancaPco	:= .F.
Local lTudoOk		:= ExistBLock('PMA210Ok')
Local nx 			:= 0
Local oDlg
Local oEnch
Local oMemo
Local oMemo2
Local oSize
Local a1stRow	:= {,,,}
Local a2ndRow	:= {,,,}
Local a3rdRow	:= {,,,}

Private M->AFE_MEMO		:= CriaVar("AFE_MEMO")
Private M->AFE_COMENT	:= CriaVar("AFE_COMENT")
PRIVATE cSavScrVT,;
		cSavScrVP,;
		cSavScrHT,;
		cSavScrHP,;
		CurLen,;
		nPosAtu:=0,;
		nPosAnt:=9999,;
		nColAnt:=9999
Private M->AF8_FASE   := Space(2)
Private cFaseAnt      := AF8->AF8_FASE
Private M->AF8_FASEOR := AF8->AF8_FASE

	If PmsChkUser(AF8->AF8_PROJET, , Padr(AF8->AF8_PROJET, Len(AFC->AFC_EDT)), ;
			"  ", 3, "ESTRUT", AF8->AF8_REVISA)
		// verifica se o projeto nao esta reservado
		If AF8->AF8_STATUS<>"2"
			Help("  ",1,"PMSA2102")
			lContinua := .F.
		EndIf

		// verifica se a fase do projeto pode encerrar a revisao
		If lContinua .and. !PmsVldFase("AF8",AF8->AF8_PROJET,"72")
			lContinua := .F.
		EndIf

		// trava o registro do AF8
		If !SoftLock("AF8")
			lContinua := .F.
		Endif

		If lContinua
			If nOpcx == 3
				Inclui := .F.
			EndIf

			// carrega as variaveis de memoria AFE
			dbSelectArea("AFE")
			dbSeek(xFilial()+AF8->AF8_PROJET+AF8->AF8_REVISA)
			RegToMemory("AFE",.F.)
			M->AFE_DATAF	:= MsDate()
			M->AFE_HORAF	:= Time()
			M->AFE_USERF	:= RetCodUsr()
			M->AFE_NOMEF	:= USRRETNAME(M->AFE_USERF)
			M->AFE_FULLF	:= USRFULLNAME(M->AFE_USERF)
			M->AFE_MEMO	:= AFE->AFE_MEMO

			// inicia lancamento do PCO
			PcoIniLan('000351')
			
			DEFINE MSDIALOG oDlg TITLE cCadastro FROM 0,0 TO 45,80 OF oMainWnd
			oSize := FwDefSize():New(.T.,,,oDlg)
			
			oSize:lLateral := .F. //Indica se os objetos serao dispostos lateralmente
			oSize:lProp	:= .T. //Indica se mantem a proporcao de tamanho dos objetos dimensionáveis

			oSize:AddObject( "1STROW" ,  100, 65, .T., .T. ) // Totalmente dimensionavel
			oSize:AddObject( "2NDROW" ,  100, 08, .T., .T. ) // Totalmente dimensionavel
			oSize:AddObject( "3RDROW" ,  100, 22, .T., .T. ) // Totalmente dimensionavel

			oSize:aMargins := { 2, 2, 2, 2 } // Espaco ao lado dos objetos 0, entre eles 2

			oSize:Process() // Dispara os calculos		

			a1stRow := {NoRound(oSize:GetDimension("1STROW","LININI")),;
						NoRound(oSize:GetDimension("1STROW","COLINI")),;
						NoRound(oSize:GetDimension("1STROW","LINEND")),;
						NoRound(oSize:GetDimension("1STROW","XSIZE"))}

			a2ndRow := {NoRound(oSize:GetDimension("2NDROW","LININI")),;
						NoRound(oSize:GetDimension("2NDROW","COLINI")),;
						315,;
						NoRound(oSize:GetDimension("2NDROW","YSIZE") * 0.66)}

			a3rdRow := {NoRound(oSize:GetDimension("3RDROW","LININI")),;
						NoRound(oSize:GetDimension("3RDROW","COLINI")),;
						315,;
						NoRound(oSize:GetDimension("3RDROW","COLEND") * 0.1818)}
			
			oEnch := MsMGet():New("AFE",nReg,nOpcx,,,,,a1stRow,,,,,,oDlg)

			@ a2ndRow[1] + 001,a2ndRow[2] + 000 Say STR0066 of oDlg Pixel  //"Comentarios resumido"
			@ a2ndRow[1] + 010,a2ndRow[2] + 000 GET oMemo VAR M->AFE_MEMO MEMO SIZE a2ndRow[3],a2ndRow[4] VALID MEMOVALID() PIXEL OF oDlg
			
			@ a3rdRow[1] + 001,a3rdRow[2] + 000 Say STR0067 of oDlg Pixel  //"Comentarios completo"
			@ a3rdRow[1] + 010,a3rdRow[2] + 000 GET oMemo2 VAR M->AFE_COMENT MEMO SIZE a3rdRow[3],a3rdRow[4] PIXEL OF oDlg

			If lTudoOk
				bOk	:=	{|| M->AF8_FASE :=M->AFE_FASEOR, lGravaOk:=((Empty(M->AFE_FASEOR).Or.M->AFE_FASEOR==AF8->AF8_FASE .Or. PmsFasePco()) .And. ExecBlock('PMA210Ok',.F.,.F.,{'2'})),oDlg:End()}
			Else
				bOk	:=	{|| M->AF8_FASE :=M->AFE_FASEOR, lGravaOk:=(Empty(M->AFE_FASEOR).Or.M->AFE_FASEOR==AF8->AF8_FASE .Or. PmsFasePco()), lGravaOk:=.T.,oDlg:End()}
			Endif
			FATPDLogUser("PMS210FRV")
			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,{|| oDlg:End()}) CENTERED

			If lGravaOk
				Begin Transaction
					If !Empty(M->AFE_FASEOR)
						If M->AFE_FASEOR <> AF8->AF8_FASE
							lLancaPco	:=	.T.
							PmsLancPco(2)
						Endif
					Endif

					RecLock("AF8",.F.)
					AF8->AF8_STATUS	:= "1"

					If !Empty(M->AFE_FASEOR)
						AF8->AF8_FASE   := M->AFE_FASEOR
					EndIf

					MsUnlock()
					RecLock("AFE",.F.)
					For nx := 1 TO FCount()
						FieldPut(nx,M->&(EVAL(bCampo,nx)))
					Next nx
					AFE->AFE_FILIAL := xFilial("AFE")
					MSMM(AFE->AFE_CODMEM,TamSx3("AFE_COMENT")[1],,M->AFE_COMENT,1,,,"AFE","AFE_CODMEM")
					MsUnlock()

					// lanca nova fase no PCO
					If lLancaPco
						PmsLancPco(1)
					Endif
				End Transaction
				PcoFinLan('000351')
				PcoFreeBlq('000351')
			EndIf
			MsUnlockAll()
		EndIf

		If ExistBlock("PMA210FR")
			ExecBlock("PMA210FR", .F., .F., {lGravaOK})
		EndIf

	Else
		Aviso(STR0056, STR0057, {STR0058}, 2)
		Return
	EndIf

Return .T.


/*/{Protheus.doc} PMS210Det
Programa de Visualizacao dos detalhes da reserva

@param cAlias, character, (Descrição do parâmetro)
@param nReg, numérico, (Descrição do parâmetro)
@param nOpcx, numérico, (Descrição do parâmetro)
@return ${return}, ${return_description}

@author Edson Maricate
@since 09-02-2001
@version 1.0
/*/
Function PMS210Det(cAlias,nReg,nOpcx)
Local cGetMemo	:= CriaVar("AFE_MEMO")
Local lContinua	:= .T.
Local oDlg
Local oEnch
Local oMemo
Local oMemo2
Local oPanel

Private M->AFE_COMENT	:= CriaVar("AFE_COMENT")
PRIVATE cSavScrVT,;
		cSavScrVP,;
		cSavScrHT,;
		cSavScrHP,;
		CurLen,;
		nPosAtu:=0,;
		nPosAnt:=9999,;
		nColAnt:=9999

	If lContinua
		RegToMemory("AFE",.F.)
		M->AFE_COMENT	:= MSMM(AFE->AFE_CODMEM)
		cGetMemo		:= AFE->AFE_MEMO

		DEFINE MSDIALOG oDlg TITLE cCadastro FROM 8,0 TO 31,78 OF oMainWnd

		oEnch := MsMGet():New("AFE",nReg,nOpcx,,,,, {16,1,90,307},,,,,,oDlg)
		oEnch:oBox:Align := CONTROL_ALIGN_TOP

		oPanel := TPanel():New(1,2,"",oDlg,NIL,.T.,.F.,NIL,NIL,2,4,.T.,.F. )
		oPanel:Align := CONTROL_ALIGN_ALLCLIENT

		@ 1,2 Say STR0066 of oPanel Pixel  //"Comentarios resumido"
		@ 10,2 GET oMemo VAR M->AFE_MEMO MEMO SIZE 306,20 VALID MEMOVALID() PIXEL OF oPanel
		@ 30,2 Say STR0067 of oPanel Pixel  //"Comentarios completo"
		@ 40,2 GET oMemo2 VAR M->AFE_COMENT MEMO SIZE 306,55 PIXEL OF oPanel

		FATPDLogUser("PMS210DET")

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{|| oDlg:End()}) CENTERED

	EndIf

Return .T.


/*/{Protheus.doc} PMS210Ver
Programa de comparacao das versoes do Projeto.
@param cAlias, character, (Descrição do parâmetro)
@param nReg, numérico, (Descrição do parâmetro)
@param nOpcx, numérico, (Descrição do parâmetro)
@return ${return}, ${return_description}

@author Fabio Rogerio Pereira
@since  27/12/2001
@version 1.0
/*/
Function PMS210Ver(cAlias,nReg,nOpcx)
Local aVersoes := {}
Local aPerg    := {}

	aVersoes:= PmsVersoes(AF8->AF8_PROJET)

	If ParamBox( {	{2,STR0009,"01",aVersoes,50,"",.F.},;//"Comparar Versao"
		{2,STR0010,"01",aVersoes,50,"",.F.}},STR0011,@aPerg)//"Com Versao""Parametros"

		Processa({||PMS210Cmp(aPerg)},STR0012,STR0013,.F.)//"Processando""Comparando as versoes do projeto..."
	EndIf
Return(.T.)


/*/{Protheus.doc} PMS210Cmp
Programa de comparacao das versoes do Projeto.
@param aVersoes, array, (Descrição do parâmetro)
@return ${return}, ${return_description}

@author Fabio Rogerio Pereira
@since  27/12/2001
@version 1.0
/*/
Static Function PMS210Cmp(aVersoes)
Local oDlg
Local oTree
Local oTree2
Local oMenu
Local oMenu2
Local aProjComp:= {}
Local aOrigem  := {}
Local aDestino := {}
Local aButtons := {}
Local aObjects := {}
Local aPosObj  := {}
Local aInfo    := {}
Local aSize    := MsAdvSize(.T.)

	/*
	ESTRUTURA DO RETORNO DA PMS210TreeEDT
	[1] - Alias
	[2] - Chave
	[3] - Descricao
	[4] - Cargo
	[5] - Cargo Pai
	[6] - Tipo Diferenca (N - Normal, C - Change, E - Deleted, I - Inserted)
	[7] - E Recurso ? (Truee,False)
	*/

	// monta um array com a estrutura do tree do projeto que sera utilizado
	// como base na comparacao
	aOrigem := PMS210TreeEDT(aVersoes[1])

	// monta um array com a estrutura do tree do projeto que sera utilizado
	// como na comparacao
	aDestino:= PMS210TreeEDT(aVersoes[2])

	// monta um array com a estrutura do tree do projeto da comparacao entre
	// as versoes
	aProjComp:= PMS210Compara(aOrigem,aDestino)

	// monta a tela com o tree da versao base e com o tree da versao
	// resultado da comparacao
	aAdd( aObjects, { 100, 100, .T., .T., .F. } )
	aAdd( aObjects, { 100, 100, .T., .T., .F. } )
	aInfo  := { aSize[1],aSize[2],aSize[3],aSize[4],3,3 }
	aPosObj:= MsObjSize( aInfo, aObjects, .T.,.T. )

	DEFINE MSDIALOG oDlg TITLE STR0014 FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL //"Comparacao de Versoes"
	MENU oMenu POPUP
		MENUITEM STR0007 ACTION PMSA210VisDet(@oTree,aOrigem) //"Visualizar"
	ENDMENU

	MENU oMenu2 POPUP
		MENUITEM STR0007 ACTION PMSA210VisDet(@oTree2,aProjComp)//"Visualizar"
		MENUITEM STR0006 ACTION PMS210Item(oTree,oTree2,aOrigem,aProjComp,aVersoes[1],aVersoes[2])//"Comparar"
	ENDMENU

	If GetVersao(.F.) == "P10"
		oTree:= dbTree():New(aPosObj[1,1], aPosObj[1,2],aPosObj[1,3],aPosObj[1,4], oDlg,,,.T.)
		oTree:bRClicked := {|o,x,y|  oMenu:Activate(x,y,oTree) } // Posição x,y em relação a Dialog
		oTree:bChange   := {|| PMS210CtrMenu(1,oMenu,oTree)}
		oTree:lShowHint := .F.
		PMS210MontaTree(@oTree,aOrigem)

		oTree2:= dbTree():New(aPosObj[2,1], aPosObj[2,2],aPosObj[2,3],aPosObj[2,4], oDlg,,,.T.)
		oTree2:bRClicked := {|o,x,y|  oMenu2:Activate(x,y,oTree2) } // Posição x,y em relação a Dialog
		oTree2:bChange   := {|| PMS210CtrMenu(2,oMenu2,oTree2)}
		oTree2:lShowHint := .F.
	Else
		//Acoes relacionadas
		oTree:= dbTree():New(aPosObj[1,1], aPosObj[1,2],aPosObj[1,3],aPosObj[1,4], oDlg,,,.T.)
		oTree:bRClicked := {|o,x,y|  oMenu:Activate(775,23,oTree) } // Posição x,y em relação a Dialog
		oTree:bChange   := {|| PMS210CtrMenu(1,oMenu,oTree)}
		oTree:lShowHint := .F.
		PMS210MontaTree(@oTree,aOrigem)

		oTree2:= dbTree():New(aPosObj[2,1], aPosObj[2,2],aPosObj[2,3],aPosObj[2,4], oDlg,,,.T.)
		oTree2:bRClicked := {|o,x,y|  oMenu2:Activate(775,23,oTree2) } // Posição x,y em relação a Dialog
		oTree2:bChange   := {|| PMS210CtrMenu(2,oMenu2,oTree2)}
		oTree2:lShowHint := .F.
	Endif

	PMS210MontaTree(@oTree2,aProjComp)

	AAdd( aButtons, { "DBG09"   , { || PMSA210Inf() }, STR0015, STR0052 } ) //"Legenda"##"Legenda"
	AAdd( aButtons, { BMP_SETA_DOWN, { || PMSA210Nav(1,aProjComp,@oTree,@oTree2) }, STR0016, STR0053 } )  //"Proxima Diferenca"##"Proxima"
	AAdd( aButtons, { BMP_SETA_UP  , { || PMSA210Nav(2,aProjComp,@oTree,@oTree2) }, STR0017, STR0054 } )  //"Diferenca Anterior"##"Anterior"
	AAdd( aButtons, { BMP_IMPRESSAO ,{ || IIf((Len(aOrigem) > 0) .And. (Len(aProjComp) > 0),PMSR211(aOrigem,aProjComp,aVersoes[1],aVersoes[2]),"") }, STR0042, STR0055} )   //"Impressao Diferencas"##"Diferenças"

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {||oDlg:End()} ,{||oDlg:End()},,aButtons)

Return(.T.)


/*/{Protheus.doc} PMSVersoes
Retorna as versoes do Projeto.
@param cProjeto, character, (Descrição do parâmetro)
@return ${return}, ${return_description}

@author Fabio Rogerio Pereira
@since  27/12/2001
@version 1.0
/*/
Static Function PMSVersoes(cProjeto)
Local aArea   := GetArea()
Local aVersoes:= {}

	// retorna um array com todas as versoes do projeto

	dbSelectArea("AFE")
	dbSetOrder(1)

	If MsSeek(xFilial("AFE") + cProjeto)
		While !Eof() .And. (xFilial("AFE") + cProjeto == AFE->AFE_FILIAL + AFE->AFE_PROJET)
			Aadd(aVersoes,AFE->AFE_REVISA)
			dbSkip()
		End
	Else
		Aadd(aVersoes,"")
	EndIf

	RestArea(aArea)
Return(aVersoes)


/*/{Protheus.doc} PMS210MontaTree
Cria o tree a partir do array.
@param oTree, objeto, (Descrição do parâmetro)
@param aTree, array, (Descrição do parâmetro)

@return ${return}, ${return_description}

@author Fabio Rogerio Pereira
@since  27/12/2001
@version 1.0
/*/
Static Function PMS210MontaTree(oTree,aTree)
Local nItem := 0
Local cRes  := ""
Local cTipo := ""

	// monta um tree a partir do array com a estrutura informados

	ProcRegua(Len(aTree))

	oTree:Reset()
	oTree:BeginUpdate()

	For nItem:= 1 To Len(aTree)
		cTipo:= aTree[nItem,6]

		Do Case

			// verifica os bitmaps do Projeto e EDT
		Case (aTree[nItem,1] $ "AF8AFC")
			If (cTipo == "N")
				cRes:= BMP_EDT4
			ElseIf (cTipo == "I")
				cRes:= BMP_EDT4_INCLUIDO
			ElseIf (cTipo == "E")
				cRes:= BMP_EDT4_EXCLUIDO
			Else
				cRes:= BMP_EDT4_ALTERADO
			EndIf

			//verifica os bitmaps da Tarefa
		Case (aTree[nItem,1] == "AF9")
			If (cTipo == "N")
				cRes:= BMP_TASK3
			ElseIf (cTipo == "I")
				cRes:= BMP_TASK3_INCLUIDO
			ElseIf (cTipo == "E")
				cRes:= BMP_TASK3_EXCLUIDO
			Else
				cRes:= BMP_TASK3_ALTERADO
			EndIf

			// verifica os bitmaps do relacionamento
		Case (aTree[nItem,1] == "AFD")
			If (cTipo == "N")
				cRes:= BMP_RELAC_DIREITA_PQ
			ElseIf (cTipo == "I")
				cRes:= BMP_RELACIONAMENTO_INCLUIDO
			ElseIf (cTipo == "E")
				cRes:= BMP_RELACIONAMENTO_EXCLUIDO
			Else
				cRes:= BMP_RELACIONAMENTO_ALTERADO
			EndIf

			// verifica os bitmaps do Recurso
		Case (aTree[nItem,1] == "AFA") .And. aTree[nItem,7]
			If (cTipo == "N")
				cRes:= BMP_RECURSO
			ElseIf (cTipo == "I")
				cRes:= BMP_RECURSO_INCLUIDO
			ElseIf (cTipo == "E")
				cRes:= BMP_RECURSO_EXCLUIDO
			Else
				cRes:= BMP_RECURSO_ALTERADO
			EndIf

		OtherWise

			If (cTipo == "N")

				// verifica o bitmap do produto/servico
				If (aTree[nItem,1] == "AFA")
					If aTree[nItem,7]
						cRes:= BMP_RECURSO
					Else
						cRes:= BMP_MATERIAL
					EndIf

					// verifica o bitmap da despesa
				ElseIf (aTree[nItem,1] == "AFB")
					cRes:= BMP_BUDGET

					// verifica o bitmap do documento
				ElseIf (aTree[nItem,1] == "ACB")
					cRes:= BMP_DOCUMENT

					// verifica o bitmap do insumo
				ElseIf (aTree[nItem,1] == "AEL")
					cRes:= BMP_MATERIAL

					// verifica o bitmap da subcomposicao
				ElseIf (aTree[nItem,1] == "AEN")
					cRes:= BMP_PROJ_ESTRUTURA

				EndIf

			ElseIf (cTipo == "I")
				cRes:= BMP_CHECKED
			ElseIf (cTipo == "E")
				cRes:= BMP_NOCHECKED
			Else
				cRes:= BMP_SDUPROP
			EndIf

		EndCase

		oTree:TreeSeek(aTree[nItem,5])
		oTree:AddItem(aTree[nItem,3],aTree[nItem,4],cRes,cRes,,,2)

		IncProc()
	Next nItem

	DBENDTREE oTree
	oTree:TreeSeek(aTree[1,4])
	oTree:EndUpdate()
	oTree:Refresh()

Return(.T.)


/*/{Protheus.doc} Pms210TreeEDT
Funcao que monta o Tree do Projeto por EDT
@param cVersao, character, (Descrição do parâmetro)

@return ${return}, ${return_description}

@author Edson Maricate
@since  09-02-2001
@version 1.0
/*/
Function PMS210TreeEDT(cVersao)
Local cCargoPai:= ""
Local cCargo   := ""
Local aTree    := {}
Local aDocAF8  := {}
Local nx
Local aArea    := GetArea()
Local lAF8comAJT := AF8ComAJT(AF8->AF8_PROJET)

	cVersao := PadR(cVersao,4)

	// monta um array com a estrutura da versao do projeto informado

	If lAF8comAJT
		ProcRegua(AFC->(RecCount()) + AF9->(RecCount()) + AEL->(RecCount()) + AEN->(RecCount()) + AFB->(RecCount()) + AFD->(RecCount()))
	Else
		ProcRegua(AFC->(RecCount()) + AF9->(RecCount()) + AFA->(RecCount()) + AFB->(RecCount()) + AFD->(RecCount()))
	EndIf

	// insere o projeto
	cCargoPai:= Pad("AF8"+AF8->AF8_FILIAL+AF8->AF8_PROJET,50)
	Aadd(aTree,{"AF8",AF8->AF8_FILIAL+AF8->AF8_PROJET,AllTrim(AF8->AF8_DESCRI) + " - " + STR0018 + cVersao + Space(200),cCargoPai,StrZero(0,50),"N",.F.}) //" - Versao: "

	// insere os documentos do projeto no Tree
	MsDocument("AF8",AF8->(RecNo()),3,,4,@aDocAF8)
	For nX := 1 to Len(aDocAF8)
		ACB->(dbGoto(aDocAF8[nx]))

		cCargo:= Pad("ACB"+ACB->ACB_FILIAL+ACB->ACB_CODOBJ,50)
		Aadd(aTree,{"ACB",ACB->ACB_FILIAL+ACB->ACB_CODOBJ,AllTrim(ACB->ACB_DESCRI),cCargo,cCargoPai,"N",.F.})
	Next nX

	// verifica todas as EDT's da versao do projeto
	dbSelectArea("AFC")
	dbSetOrder(3)
	MsSeek(xFilial()+AF8->AF8_PROJET+cVersao+"001")
	While !Eof() .And. AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA+;
			AFC->AFC_NIVEL==xFilial("AFC")+AF8->AF8_PROJET+cVersao+"001"
		PMS210EDTTrf(@aTree,AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT,cCargoPai)

		IncProc()
		dbSkip()
	End

	RestArea(aArea)

Return(aTree)


/*/{Protheus.doc} PMSEDTTrf
Funcao que monta o Tree do Projeto por EDT
@param aTree, array, (Descrição do parâmetro)
@param cChave, character, (Descrição do parâmetro)
@param cCargoPai, character, (Descrição do parâmetro)

@return ${return}, ${return_description}

@author Edson Maricate
@since  09-02-2001
@version 1.0
/*/
Static Function PMS210EDTTrf(aTree,cChave,cCargoPai)
Local cCargo		:= ""
Local nx			:= 0
Local lTipoTree	:= .F.
Local aArea		:= GetArea()
Local aAreaAFC	:= AFC->(GetArea())
Local aAreaAF9	:= AF9->(GetArea())
Local aAuxArea
Local aDocAFC		:= {}

	If PmsChkUser(AFC->AFC_PROJET,,AFC->AFC_EDT,AFC->AFC_EDTPAI,1,"ESTRUT",AFC->AFC_REVISA)

		// insere os documentos da EDT no Tree
		If PmsChkUser(AFC->AFC_PROJET,,AFC->AFC_EDT,AFC->AFC_EDTPAI,2,"DOCUME",AFC->AFC_REVISA)
			MsDocument("AFC",AFC->(RecNo()),3,,4,@aDocAFC)
			For nx := 1 to Len(aDocAFC)
				ACB->(dbGoto(aDocAFC[nx]))

				// insere a EDT no array
				If !lTipoTree
					cCargo   := Pad("AFC"+AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_EDT,50)
					Aadd(aTree,{"AFC",AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT,AllTrim(AFC->AFC_DESCRI),cCargo,cCargoPai,"N",.F.})
					cCargoPai:= cCargo
				Endif
				lTipoTree := .T.

				cCargo:= Pad("ACB"+ACB->ACB_FILIAL+ACB->ACB_CODOBJ,50)
				Aadd(aTree,{"ACB",ACB->ACB_FILIAL+ACB->ACB_CODOBJ,AllTrim(ACB->ACB_DESCRI),cCargo,cCargoPai,"N",.F.})
			Next
		EndIf
	EndIf

	// verifica todas as tarefas da versao do projeto
	dbSelectArea("AF9")
	dbSetOrder(2)
	MsSeek(xFilial()+cChave)
	While !Eof() .And. AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA+;
			AF9->AF9_EDTPAI==xFilial("AF9")+cChave

		// insere a EDT no array
		If !lTipoTree .And. PmsChkUser(AFC->AFC_PROJET,,AFC->AFC_EDT,AFC->AFC_EDTPAI,1,"ESTRUT",AFC->AFC_REVISA)
			cCargo:= Pad("AFC"+AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_EDT,50)
			Aadd(aTree,{"AFC",AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT,AllTrim(AFC->AFC_DESCRI),cCargo,cCargoPai,"N",.F.})
			cCargoPai:= cCargo

			lTipoTree:= .T.
		EndIf

		If PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,1,"ESTRUT",AF9->AF9_REVISA)
			PMS210AddTrf(@aTree,AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA,cCargoPai)
		EndIf

		IncProc()
		dbSkip()
	End

	// verifica todas as EDT's filhas da EDT atual
	dbSelectArea("AFC")
	dbSetOrder(2)
	MsSeek(xFilial()+cChave)
	While !Eof() .And. AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA+;
			AFC->AFC_EDTPAI==xFilial("AFC")+cChave
		aAuxArea	:= GetArea()
		RestArea(aAreaAFC)

		// insere a EDT no array
		If !lTipoTree .And. PmsChkUser(AFC->AFC_PROJET,,AFC->AFC_EDT,AFC->AFC_EDTPAI,1,"ESTRUT",AFC->AFC_REVISA)
			cCargo:= Pad("AFC"+AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_EDT,50)
			Aadd(aTree,{"AFC",AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT,AllTrim(AFC->AFC_DESCRI),cCargo,cCargoPai,"N",.F.})
			cCargoPai:= cCargo

			lTipoTree:= .T.
		EndIf
		RestArea(aAuxArea)

		PMS210EDTTrf(@aTree,AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT,cCargoPai)

		IncProc()
		dbSkip()
	EndDo

	RestArea(aAreaAFC)

	// insere a EDT no array
	If !lTipoTree .And. PmsChkUser(AFC->AFC_PROJET,,AFC->AFC_EDT,AFC->AFC_EDTPAI,1,"ESTRUT",AFC->AFC_REVISA)
		cCargo:= Pad("AFC"+AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_EDT,50)
		Aadd(aTree,{"AFC",AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT,AllTrim(AFC->AFC_DESCRI),cCargo,cCargoPai,"N",.F.})
	EndIf

	RestArea(aAreaAF9)
	RestArea(aAreaAFC)
	RestArea(aArea)

Return(.T.)


/*/{Protheus.doc} PMSAddTrf
Funcao que monta a tarefa no Tree do Projeto.
@param aTree, array, (Descrição do parâmetro)
@param cChave, character, (Descrição do parâmetro)
@param cCargoPai, character, (Descrição do parâmetro)

@return ${return}, ${return_description}

@author Edson Maricate
@since  09-02-2001
@version 1.0
/*/
Static Function Pms210AddTrf(aTree,cChave,cCargoPai)
Local nx
Local aDocAF9		:= {}
Local aArea		:= GetArea()
Local aAreaAF9	:= AF9->(GetArea())
Local aAreaAFA	:= AFA->(GetArea())
Local aAreaAFB	:= AFB->(GetArea())
Local aAreaAFC	:= AFC->(GetArea())
Local lTipoTree	:= .F.
Local lAF8comAJT	:= AF8ComAJT(AF8->AF8_PROJET)
Local cObfNRecur    := ""

	If PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,1,"DOCUME",AF9->AF9_REVISA)

		// insere os documentos da Tarefa no Tree
		MsDocument("AF9",AF9->(RecNo()),3,,4,@aDocAF9)
		For nx := 1 to Len(aDocAF9)

			// insere a tarefa no array
			If !lTipoTree
				cCargo:= Pad("AF9"+AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_TAREFA,50)
				Aadd(aTree,{"AF9",AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA,AllTrim(AF9->AF9_DESCRI),cCargo,cCargoPai,"N",.F.})
				cCargoPai:= cCargo

				lTipoTree := .T.
			EndIf

			ACB->(dbGoto(aDocAF9[nx]))
			cCargo:= Pad("ACB"+ACB->ACB_FILIAL+ACB->ACB_CODOBJ,50)
			Aadd(aTree,{"ACB",ACB->ACB_FILIAL+ACB->ACB_CODOBJ,AllTrim(ACB->ACB_DESCRI),cCargo,cCargoPai,"N",.F.})
		Next
	EndIf


	// inclui as despesas da tarefa AFB
	dbSelectArea("AFB")
	dbSetOrder(1)
	MsSeek(xFilial("AFB")+cChave)
	While !Eof() .And. AFB->AFB_FILIAL+AFB->AFB_PROJET+AFB->AFB_REVISA+;
			AFB->AFB_TAREFA==xFilial("AFB")+cChave

		// insere a tarefa no array
		If !lTipoTree .And. PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,1,"ESTRUT",AF9->AF9_REVISA)
			cCargo:= Pad("AF9"+AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_TAREFA,50)
			Aadd(aTree,{"AF9",AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA,AllTrim(AF9->AF9_DESCRI),cCargo,cCargoPai,"N",.F.})
			cCargoPai:= cCargo

			lTipoTree:= .T.
		EndIf

		cCargo:= Pad("AFB" + AFB->AFB_FILIAL + AFB->AFB_PROJET + AFB->AFB_TAREFA + AFB->AFB_ITEM,50)
		Aadd(aTree,{"AFB",AFB->AFB_FILIAL+AFB->AFB_PROJET+AFB->AFB_REVISA+AFB->AFB_TAREFA+AFB->AFB_ITEM,AllTrim(AFB->AFB_DESCRI),cCargo,cCargoPai,"N",.F.})

		IncProc()
		dbSelectArea("AFB")
		dbSkip()
	End

	// inclui os Relacionamentos AFD
	dbSelectArea("AFD")
	dbSetOrder(1)
	MsSeek(xFilial()+cChave)
	While !Eof() .And. AFD->AFD_FILIAL+AFD->AFD_PROJET+AFD->AFD_REVISA+;
			AFD->AFD_TAREFA==xFilial("AFD")+cChave

		// insere a tarefa no array
		If !lTipoTree .And. PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,1,"ESTRUT",AF9->AF9_REVISA)
			cCargo:= Pad("AF9"+AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_TAREFA,50)
			Aadd(aTree,{"AF9",AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA,AllTrim(AF9->AF9_DESCRI),cCargo,cCargoPai,"N",.F.})
			cCargoPai:= cCargo

			lTipoTree:= .T.
		EndIf

		aAuxArea := AF9->(GetArea())
		AF9->(dbSetOrder(1))
		AF9->(MsSeek(xFilial()+AFD->AFD_PROJET+AFD->AFD_REVISA+AFD->AFD_PREDEC))

		cCargo:= Pad("AFD"+AFD->AFD_FILIAL+AFD->AFD_PROJET+AFD->AFD_TAREFA + AFD->AFD_ITEM,50)
		Aadd(aTree,{"AFD",AFD->AFD_FILIAL+AFD->AFD_PROJET+AFD->AFD_REVISA+AFD->AFD_TAREFA+AFD->AFD_ITEM,AllTrim(AF9->AF9_DESCRI),cCargo,cCargoPai,"N",.F.})

		RestArea(aAuxArea)

		IncProc()
		dbSelectArea("AFD")
		dbSkip()
	EndDo


	If lAF8comAJT
		// inclui os insumos da tarefa AEL
		dbSelectArea("AEL")
		dbSetOrder(1) // AEL_FILIAL+AEL_PROJET+AEL_REVISA+AEL_TAREFA+AEL_ITEM
		MsSeek(xFilial()+cChave)
		While !Eof() .And. AEL->AEL_FILIAL+AEL->AEL_PROJET+AEL->AEL_REVISA+;
				AEL->AEL_TAREFA==xFilial("AEL")+cChave

			// insere a tarefa no array
			If !lTipoTree .And. PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,1,"ESTRUT",AF9->AF9_REVISA)
				cCargo:= Pad("AF9"+AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_TAREFA,50)
				Aadd(aTree,{"AF9",AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA,AllTrim(AF9->AF9_DESCRI),cCargo,cCargoPai,"N",.F.})
				cCargoPai:= cCargo

				lTipoTree:= .T.
			EndIf

			cCargo:= Pad("AEL" + AEL->AEL_FILIAL + AEL->AEL_PROJET + AEL->AEL_TAREFA + AEL->AEL_ITEM + AEL->AEL_INSUMO, 50)

			Aadd(aTree,{"AEL",AEL->AEL_FILIAL+AEL->AEL_PROJET+AEL->AEL_REVISA+AEL->AEL_TAREFA+AEL->AEL_ITEM,AllTrim(PMSCpoCoUn('AEL_DESCRI')),cCargo,cCargoPai,"N",.T.})

			IncProc()
			dbSelectArea("AEL")
			dbSkip()
		End


		// inclui as subcomposicoes da tarefa AEN
		dbSelectArea("AEN")
		dbSetOrder(1) // AEN_FILIAL+AEN_PROJET+AEN_REVISA+AEN_TAREFA+AEN_ITEM
		MsSeek(xFilial()+cChave)
		While !Eof() .And. AEN->AEN_FILIAL+AEN->AEN_PROJET+AEN->AEN_REVISA+;
				AEN->AEN_TAREFA==xFilial("AEN")+cChave

			// insere a tarefa no array
			If !lTipoTree .And. PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,1,"ESTRUT",AF9->AF9_REVISA)
				cCargo:= Pad("AF9"+AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_TAREFA,50)
				Aadd(aTree,{"AF9",AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA,AllTrim(AF9->AF9_DESCRI),cCargo,cCargoPai,"N",.F.})
				cCargoPai:= cCargo

				lTipoTree:= .T.
			EndIf

			cCargo:= Pad("AEN" + AEN->AEN_FILIAL + AEN->AEN_PROJET + AEN->AEN_TAREFA + AEN->AEN_ITEM + AEN->AEN_SUBCOM, 50)

			Aadd(aTree,{"AEN",AEN->AEN_FILIAL+AEN->AEN_PROJET+AEN->AEN_REVISA+AEN->AEN_TAREFA+AEN->AEN_ITEM,AllTrim(PMSCpoCoUn('AEN_DESCRI')),cCargo,cCargoPai,"N",.T.})

			IncProc()
			dbSelectArea("AEN")
			dbSkip()
		End

	Else
		cObfNRecur  := IIF(FATPDIsObfuscate("AE8_DESCRI",,.T.),FATPDObfuscate("RESOURCE NAME","AE8_DESCRI",,.T.),"")
		// inclui os produtos da tarefa AFA
		dbSelectArea("AFA")
		dbSetOrder(1)
		MsSeek(xFilial()+cChave)
		While !Eof() .And. AFA->AFA_FILIAL+AFA->AFA_PROJET+AFA->AFA_REVISA+;
				AFA->AFA_TAREFA==xFilial("AFA")+cChave

			// insere a tarefa no array
			If !lTipoTree .And. PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,1,"ESTRUT",AF9->AF9_REVISA)
				cCargo:= Pad("AF9"+AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_TAREFA,50)
				Aadd(aTree,{"AF9",AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA,AllTrim(AF9->AF9_DESCRI),cCargo,cCargoPai,"N",.F.})
				cCargoPai:= cCargo

				lTipoTree:= .T.
			EndIf

			cCargo:= Pad("AFA" + AFA->AFA_FILIAL + AFA->AFA_PROJET + AFA->AFA_TAREFA + AFA->AFA_ITEM + AFA->AFA_PRODUT + AFA->AFA_RECURS,50)

			If !Empty(AFA->AFA_RECURS)
				AE8->(dbSetOrder(1))
				AE8->(MsSeek(xFilial("AE8")+AFA->AFA_RECURS))
				Aadd(aTree,{"AFA",AFA->AFA_FILIAL+AFA->AFA_PROJET+AFA->AFA_REVISA+AFA->AFA_TAREFA+AFA->AFA_ITEM,IIF(Empty(cObfNRecur),AllTrim(AE8->AE8_DESCRI),cObfNRecur),cCargo,cCargoPai,"N",.T.})
			Else
				SB1->(dbSetOrder(1))
				SB1->(MsSeek(xFilial("SB1")+AFA->AFA_PRODUT))
				Aadd(aTree,{"AFA",AFA->AFA_FILIAL+AFA->AFA_PROJET+AFA->AFA_REVISA+AFA->AFA_TAREFA+AFA->AFA_ITEM,AllTrim(SB1->B1_DESC),cCargo,cCargoPai,"N",.F.})
			EndIf

			IncProc()
			dbSelectArea("AFA")
			dbSkip()
		End
	EndIf


	// insere a tarefa no array
	If !lTipoTree .And. PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,1,"ESTRUT",AF9->AF9_REVISA)
		cCargo:= Pad("AF9"+AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_TAREFA,50)
		Aadd(aTree,{"AF9",AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA,AllTrim(AF9->AF9_DESCRI),cCargo,cCargoPai,"N",.F.})
	EndIf

	RestArea(aAreaAF9)
	RestArea(aAreaAFA)
	RestArea(aAreaAFB)
	RestArea(aAreaAFC)
	RestArea(aArea)
FATPDLogUser("PMS210ADDT")
Return(.T.)


/*/{Protheus.doc} PMS210Compara
Compara as versoes do Projeto em forma de array.
@param aOrigem, array, (Descrição do parâmetro)
@param aDestino, array, (Descrição do parâmetro)

@return ${return}, ${return_description}

@author Fabio Rogerio Pereira
@since  27/12/2001
@version 1.0
/*/
Function PMS210Compara(aOrigem,aDestino)
Local aArea    := GetArea()
Local aProjComp:= {}
Local nItem    := 0
Local nPos     := 0

	// realiza a comparacao de todos os itens das versoes do projeto
	// e informa se existem modificacoes ou nao

	// analisa a estrutura da versao base
	For nItem:= 1 To Len(aOrigem)

		// verifica se existe o item no projeto a ser comparado
		nPos:= Ascan(aDestino,{|x| x[4] == aOrigem[nItem,4]})
		If (nPos > 0)
			If PMS210Check(aOrigem[nItem,1],aOrigem[nItem,2],aDestino[nPos,2])
				Aadd(aProjComp,{aDestino[nPos,1],aDestino[nPos,2],aDestino[nPos,3],;
					aDestino[nPos,4],aDestino[nPos,5],aDestino[nPos,6],aDestino[nPos,7]})
			Else
				Aadd(aProjComp,{aDestino[nPos,1],aDestino[nPos,2],aDestino[nPos,3] + STR0019,; //" - MODIFICADO"
				aDestino[nPos,4],aDestino[nPos,5],"M",aDestino[nPos,7]})
			EndIf
		Else
			Aadd(aProjComp,{aOrigem[nItem,1],aOrigem[nItem,2],aOrigem[nItem,3] + STR0020,; //" - EXCLUIDO"
			aOrigem[nItem,4],aOrigem[nItem,5],"E",aOrigem[nItem,7]})
		EndIf

	Next nItem

	// analisa a existencia de novos itens na estrutura
	For nItem:= 1 To Len(aDestino)

		// verifica se existe o item no projeto a ser comparado
		nPos:= Ascan(aOrigem,{|x| x[4] == aDestino[nItem,4]})
		If (nPos == 0)
			Aadd(aProjComp,{aDestino[nItem,1],AllTrim(aDestino[nItem,2]),aDestino[nItem,3] + STR0021,; //" - INCLUIDO"
			aDestino[nItem,4],aDestino[nItem,5],"I",aDestino[nItem,7]})
		EndIf

	Next nItem

	RestArea(aArea)

Return(aProjComp)


/*/{Protheus.doc} PMS210Check
Verifica os dados das versoes do Projeto.
@param cAlias, character, (Descrição do parâmetro)
@param cOrigem, character, (Descrição do parâmetro)
@param cDestino, character, (Descrição do parâmetro)

@return ${return}, ${return_description}

@author Fabio Rogerio Pereira
@since  27/12/2001
@version 1.0
/*/
Static Function PMS210Check(cAlias,cOrigem,cDestino)
Local lRet  	:= .T.
Local aStrut	:= {}
Local aDados	:= {}
Local nCampo	:= 0

	// analisa cada item das versoes do projeto para identificar as alteracoes
	dbSelectArea(cAlias)
	dbSetOrder(1)
	If dbSeek(cOrigem,.T.)
		aStrut:= &(cAlias + "->(dbStruct())")
		aDados:= Array(1,Len(aStrut))

		AEval(aStrut,{|cValue,nIndex| aDados[1,nIndex]:= {aStrut[nIndex,1],FieldGet(FieldPos(aStrut[nIndex,1]))}})

		If dbSeek(cDestino,.T.)
			For	nCampo:= 1 To Len(aDados[1])
			If !("REVISA" $ aDados[1,nCampo,1]) .And. (aDados[1,nCampo,2] <> FieldGet(nCampo))
				lRet:= .F.
				Exit
			EndIf
		Next
	EndIf
EndIf

Return(lRet)


/*/{Protheus.doc} PMSA210Inf
Monta uma tela de informacao sobre a fase do projeto.

@param ${param},${identify}, ${description}

@return ${return}, ${return_description}

@author Fabio Rogerio Pereira
@since  02-01-2002
@version 1.0
/*/
Static Function PMSA210Inf()
Local oDlg
Local oBmp1
Local oBmp2
Local oBmp3
Local oBmp4
Local oBmp5
Local oBmp6
Local oBmp7
Local oBmp8
Local oBmp9
Local oBmp10
Local oBmp11
Local oBmp12
Local oBmp13
Local oBmp14
Local oBmp15
Local oBmp16
Local lAF8comAJT := AF8ComAJT(AF8->AF8_PROJET)

	// cria tela com os bitmaps utilizados no tree para correta identificacao
	DEFINE MSDIALOG oDlg TITLE STR0015 OF oMainWnd PIXEL FROM 0,0 TO 250,550 //"Legenda"

	@ 2,2 TO 110,275 LABEL STR0015 PIXEL //"Legenda"

	@ 8,10 BITMAP oBmp1 RESNAME BMP_EDT4_EXCLUIDO SIZE 16,16 NOBORDER PIXEL
	@ 8,23 SAY STR0022 OF oDlg PIXEL  //"EDT Excluida"

	@ 20,10 BITMAP oBmp2 RESNAME BMP_EDT4_ALTERADO SIZE 16,16 NOBORDER PIXEL
	@ 20,23 SAY STR0023 OF oDlg PIXEL //"EDT Modificada"

	@ 32,10 BITMAP oBmp3 RESNAME BMP_EDT4_INCLUIDO SIZE 16,16 NOBORDER PIXEL
	@ 32,23 SAY STR0024 OF oDlg PIXEL //"EDT Incluida"

	@ 44,10 BITMAP oBmp4 RESNAME BMP_EDT4 SIZE 16,16 NOBORDER PIXEL
	@ 44,23 SAY STR0025 OF oDlg PIXEL //"EDT Nao Alterada"

	@ 56,10 BITMAP oBmp5 RESNAME BMP_DOCUMENT SIZE 16,16 NOBORDER PIXEL
	@ 56,23 SAY STR0026 OF oDlg PIXEL //"Documento - Banco de conhecimentos"

	@ 68,10 BITMAP oBmp6 RESNAME BMP_RELACIONAMENTO_DIREITA SIZE 16,16 NOBORDER PIXEL
	@ 68,23 SAY STR0027 OF oDlg PIXEL //"Relacionamento"

	@ 80,10 BITMAP oBmp7 RESNAME BMP_BUDGET SIZE 16,16 NOBORDER PIXEL
	@ 80,23 SAY STR0028 OF oDlg PIXEL //"Despesa"

	@ 92,10 BITMAP oBmp8 RESNAME BMP_SDUPROP SIZE 16,16 NOBORDER PIXEL
	If lAF8comAJT
		@ 92,23 SAY STR0065 OF oDlg PIXEL //"Insumo/Subcomposicao/Despesa Modificada"

	Else
		@ 92,23 SAY STR0029 OF oDlg PIXEL //"Produto/Servico/Recurso/Despesa Modificada"
	EndIf

	@ 8,150 BITMAP oBmp9 RESNAME BMP_TASK3_EXCLUIDO SIZE 16,16 NOBORDER PIXEL
	@ 8,163 SAY STR0030 OF oDlg PIXEL //"Tarefa Excluida"

	@ 20,150 BITMAP oBmp10 RESNAME BMP_TASK3_ALTERADO SIZE 16,16 NOBORDER PIXEL
	@ 20,163 SAY STR0031 OF oDlg PIXEL //"Tarefa Modificada"

	@ 32,150 BITMAP oBmp11 RESNAME BMP_TASK3_INCLUIDO SIZE 16,16 NOBORDER PIXEL
	@ 32,163 SAY STR0032 OF oDlg PIXEL //"Tarefa Incluida"

	@ 44,150 BITMAP oBmp12 RESNAME BMP_TASK3 SIZE 16,16 NOBORDER PIXEL
	@ 44,163 SAY STR0033 OF oDlg PIXEL //"Tarefa Nao Alterada"

	@ 56,150 BITMAP oBmp13 RESNAME BMP_MATERIAL SIZE 16,16 NOBORDER PIXEL

	If lAF8comAJT
		@ 56,163 SAY STR0061 OF oDlg PIXEL //"Insumo"
		@ 68,150 BITMAP oBmp14 RESNAME BMP_PROJ_ESTRUTURA SIZE 16,16 NOBORDER PIXEL
		@ 68,163 SAY STR0062 OF oDlg PIXEL //"Subcomposicao"
	Else
		@ 56,163 SAY STR0034 OF oDlg PIXEL //"Produto / Servico"
		@ 68,150 BITMAP oBmp14 RESNAME BMP_RECURSO SIZE 16,16 NOBORDER PIXEL
		@ 68,163 SAY STR0035 OF oDlg PIXEL //"Recurso"
	EndIf

	@ 80,150 BITMAP oBmp15 RESNAME BMP_CHECKED SIZE 16,16 NOBORDER PIXEL

	If lAF8comAJT
		@ 80,163 SAY STR0063 OF oDlg PIXEL //"Insumo/Subcomposicao/Despesa Incluida"

	Else
		@ 80,163 SAY STR0036 OF oDlg PIXEL //"Produto/Servico/Recurso/Despesa Incluida"
	EndIf

	@ 92,150 BITMAP oBmp16 RESNAME BMP_NOCHECKED SIZE 16,16 NOBORDER PIXEL

	If lAF8comAJT
		@ 92,163 SAY STR0064 OF oDlg PIXEL //"Insumo/Subcomposicao/Despesa Excluida"
	Else
		@ 92,163 SAY STR0037 OF oDlg PIXEL //"Produto/Servico/Recurso/Despesa Excluida"
	EndIf

	@ 115,230 BUTTON STR0038 SIZE 40 ,9   FONT oDlg:oFont ACTION {||oDlg:End()}  OF oDlg PIXEL //"Fechar"

	ACTIVATE MSDIALOG oDlg CENTERED

Return(.T.)


/*/{Protheus.doc} PMSA210Nav

Posiciona nas diferencas entre as versoes.

@param nTipo, numérico, (Descrição do parâmetro)
@param aProjComp, array, (Descrição do parâmetro)
@param oTree, objeto, (Descrição do parâmetro)
@param oTree2, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}

@author Fabio Rogerio Pereira
@since 02-01-2002
@version 1.0
/*/
Static Function PMSA210Nav(nTipo,aProjComp,oTree,oTree2)
Local cCargoAtu:= oTree2:GetCargo()
Local nStep    := IIf(nTipo == 1,1,-1)
Local nPos     := Ascan(aProjComp,{|x| x[4] == cCargoAtu})

	// posiciona o tree nas diferencas entre as versoes do projeto
	For nPos:= IIf(nPos == 0,1,nPos+nStep) TO IIf(nTipo == 1,Len(aProjComp),1) STEP nStep
		If aProjComp[nPos,6] <> "N"
			oTree:TreeSeek(aProjComp[nPos,4])
			oTree2:TreeSeek(aProjComp[nPos,4])

			oTree:Refresh()
			oTree2:Refresh()

			Exit
		EndIf
	Next nPos

	If (nTipo == 1) .And. (nPos > Len(aProjComp))
		oTree2:SetFocus()
		Aviso(STR0040,STR0039,{STR0038},2) //"Atencao""Proxima diferenca nao encontrada"###"Fechar"
	ElseIf (nTipo == 2) .And. (nPos < 1)
		oTree2:SetFocus()
		Aviso(STR0040,STR0041,{STR0038},2) //"Atencao""Diferenca anterior nao encontrada"###"Fechar"
	EndIf

Return(.T.)


/*/{Protheus.doc} PMSA210VisDet
Posiciona nas diferencas entre as versoes.

@param oTree, objeto, (Descrição do parâmetro)
@param aTree, array, (Descrição do parâmetro)
@return ${return}, ${return_description}

@author Fabio Rogerio Pereira
@since 02-01-2002
@version 1.0
/*/
Static Function PMSA210VisDet(oTree,aTree)
Local cCargo	:= oTree:GetCargo()
Local aArea 	:= GetArea()
Local nPos  	:= Ascan(aTree,{|x| x[4] == cCargo})
Local cAlias	:= aTree[nPos,1]
Local cSeek 	:= aTree[nPos,2]

	RegToMemory("AFA",.T.)
	RegToMemory("AFB",.T.)

	dbSelectArea(cAlias)
	dbSetOrder(1)
	dbSeek(cSeek)

	If (cAlias == "AFC")
		PMSA201(2,,"000")
	ElseIf (cAlias == "AF9")
		PMSA203(2,,"000")
	EndIf

	RestArea(aArea)
Return(.T.)


/*/{Protheus.doc} PMS210CtrMenu
Funcao que controla as propriedades do Menu PopUp.

@param nTree, numérico, (Descrição do parâmetro)
@param oMenu, objeto, (Descrição do parâmetro)
@param oTree, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}

@author Fabio Rogerio Pereira
@since 08-01-2002
@version 1.0
/*/
Static Function PMS210CtrMenu(nTree,oMenu,oTree)
Local cAlias	:= SubStr(oTree:GetCargo(),1,3)

	If (cAlias $ "AFCAF9")
		oMenu:aItems[1]:Enable()

		If (nTree == 2)
			oMenu:aItems[2]:Enable()
		EndIf
	Else
		oMenu:aItems[1]:Disable()

		If (nTree == 2)
			oMenu:aItems[2]:Enable()
		EndIf
	EndIf

Return(.T.)


/*/{Protheus.doc} PMS210Item
Funcao que exibe os dados a serem comparados.

@param oTree, objeto, (Descrição do parâmetro)
@param oTree2, objeto, (Descrição do parâmetro)
@param aOrigem, array, (Descrição do parâmetro)
@param aProjComp, array, (Descrição do parâmetro)
@param cVersao1, character, (Descrição do parâmetro)
@param cVersao2, character, (Descrição do parâmetro)
@return ${return}, ${return_description}

@author Fabio Rogerio Pereira
@since 08-01-2002
@version 1.0
/*/
Static Function PMS210Item(oTree,oTree2,aOrigem,aProjComp,cVersao1,cVersao2)
Local aDados   := {}
Local nPosComp := 0
Local nPosOrig := 0
Local cAlias   := ""
Local cSeekComp:= ""
Local cSeekOrig:= ""

	Aadd(aDados,{"",{STR0018 + cVersao1,CLR_BLACK},{STR0018 + cVersao2,CLR_BLACK}}) //Versao

	// verifica as informacoes do item que se deseja comparar
	nPosComp := Ascan(aProjComp,{|x| x[4] == oTree2:GetCargo()})
	If (nPosComp > 0)
		cAlias   := aProjComp[nPosComp,1]
		cSeekComp:= aProjComp[nPosComp,2]
		oTree:TreeSeek(aProjComp[nPosComp,4])

		// posiciona e armazena os dados do item a ser comparado
		dbSelectArea(cAlias)
		dbSetOrder(1)
		If dbSeek(cSeekComp)
			aStrut:= Pms210Strut(cAlias)

			AEval(aStrut,{|cValue,nIndex| Aadd(aDados,{ aStrut[nIndex,1],;
				{"",CLR_BLACK}	 ,;
				{Transform(FieldGet(FieldPos(aStrut[nIndex,2])),aStrut[nIndex,3]),CLR_BLACK}})})
		EndIf
	EndIf

	// verifica os dados dos itens a serem comparados
	nPosOrig:= Ascan(aOrigem,{|x| x[4] == oTree2:GetCargo()})
	If (nPosOrig > 0)
		cAlias   := aOrigem[nPosOrig,1]
		cSeekOrig:= aOrigem[nPosOrig,2]
		oTree2:TreeSeek(aOrigem[nPosOrig,4])

		// posiciona e armazena os dados do item comparado
		If dbSeek(cSeekOrig)
			AEval(aStrut,{|cValue,nIndex| (aDados[nIndex+1,2,1]:= Transform(FieldGet(FieldPos(aStrut[nIndex,2])),aStrut[nIndex,3])),;
				(aDados[nIndex+1,2,2]:= aDados[nIndex+1,3,2]:=If(aDados[nIndex+1,2,1] == aDados[nIndex+1,3,1],CLR_BLACK,CLR_RED)) })
		EndIf
	EndIf

	PmsDispBox(aDados,3,"",{40,120,120},,3,,RGB(250,250,250))

Return(.T.)


/*/{Protheus.doc} PMS210Strut
Funcao que retorna a estrutura do alias selecionado.

@param cAlias, character, (Descrição do parâmetro)
@return ${return}, ${return_description}

@author Fabio Rogerio Pereira
@since 08-01-2002
@version 1.0
/*/
Static Function PMS210Strut(cAlias)
Local aArea:= GetArea()
Local aRet := {}

	DbSelectArea("SX3")
	DbSetOrder(1)
	MsSeek(cAlias)
	While !EOF() .AND. (X3_ARQUIVO == cAlias)

		If X3USO(X3_USADO) .AND. cNivel >= X3_NIVEL .AND. (! TRIM(SX3->X3_CAMPO) $ "_FILIAL" );
				.AND. X3_CONTEXT != "V" .AND. X3_TIPO != "M"
			AADD(aRet,{	TRIM(X3TITULO()),;
				X3_CAMPO,;
				X3_PICTURE,;
				X3_TAMANHO,;
				X3_DECIMAL,;
				X3_VALID,;
				X3_USADO,;
				X3_TIPO,;
				X3_ARQUIVO,;
				X3_CONTEXT 	} )

		EndIf
		dbSkip()
	End

	RestArea(aArea)

Return(aRet)


/*/{Protheus.doc} PMSA210Usu
Funcao para inclusao de usuarios na revisao.

@param cAlias, character, (Descrição do parâmetro)
@param nReg, numérico, (Descrição do parâmetro)
@param nOpcx, numérico, (Descrição do parâmetro)
@return ${return}, ${return_description}

@author Fabio Rogerio Pereira
@since 15-01-2002
@version 1.0

/*/
Function PMSA210Usu(cAlias,nReg,nOpcx)
Local aArea:= GetArea()

	// verifica se o projeto nao esta reservado
	If AF8->AF8_STATUS<>"2"
		Aviso(STR0045,STR0049,{STR0038},2)  //"Gerenciamento de Revisoes"######"Fechar" //"Este projeto nao se encontra em revisao. Esta funcao e utilizada para conceder direitos aos usuarios na estrutura do projeto durante a revisao e so podera ser utilizada apos o inicio da revisao."
		Return(.F.)
	EndIf

	// executa a tela de usuarios no projeto
	PMSUser(nOpcx,AF8->AF8_REVISA,AF8->AF8_REVISA)

	RestArea(aArea)
Return(.T.)


/*/{Protheus.doc} PMS210VUsu
Funcao para visualizar os usuarios da revisao.

@param cAlias, character, (Descrição do parâmetro)
@param nReg, numérico, (Descrição do parâmetro)
@param nOpcx, numérico, (Descrição do parâmetro)
@return ${return}, ${return_description}

@author Fabio Rogerio Pereira
@since 17-01-2002
@version 1.0
/*/
Function PMS210VUsu(cAlias,nReg,nOpcx)
Local aArea:= GetArea()

	// exibe a revisao do projeto com os usuarios
	PmsUser(nOpcx,AFE->AFE_REVISA,AFE->AFE_REVISA)

	RestArea(aArea)
Return(.T.)


/*/{Protheus.doc} MenuDef
Utilizacao de menu Funcional

@return ${return}, ${return_description}

@author Ana Paula N. Silva
@since 30/11/06
@version 1.0
@obs
Parametros do array a Rotina:
	1. Nome a aparecer no cabecalho
	2. Nome da Rotina associada
	3. Reservado
	4. Tipo de Transa‡„o a ser efetuada:
		1 - Pesquisa e Posiciona em um Banco de Dados
		2 - Simplesmente Mostra os Campos
		3 - Inclui registros no Bancos de Dados
		4 - Altera o registro corrente
		5 - Remove o registro corrente do Banco de Dados
	5. Nivel de acesso
	6. Habilita Menu Funcional

/*/
Static Function MenuDef()
Local aRotina := {{STR0002, "AxPesqui" ,  0, 1, , .F.}, ;   //"Pesquisar"
					{STR0003, "PMS210Hst",  0, 2}, ;   //"Historico"
					{STR0004, "PMS210Rvs",  0, 4}, ;//"Iniciar Revisao"
					{STR0005, "PMS210Frv",  0, 4}, ;//"Finalizar Revisao"
					{STR0006, "PMS210Ver",  0, 5}, ;//"Comparar"
					{STR0043, "PMSA210Usu", 0, 6}, ;  //"Usuario Revisao"
					{STR0015, "PMS210Leg",  0, 2, , .F.}}    //"Legenda"
Return aRotina


//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDIsObfuscate
    @description
    Verifica se um campo deve ser ofuscado, esta função deve utilizada somente após 
    a inicialização das variaveis atravez da função FATPDLoad.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado
    @return lObfuscate, Lógico, Retorna se o campo será ofuscado.
    @example FATPDIsObfuscate("A1_CGC",Nil,.T.)
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDIsObfuscate(cField, cSource, lLoad)
    
	Local lObfuscate := .F.

    If FATPDActive()
		lObfuscate := FTPDIsObfuscate(cField, cSource, lLoad)
    EndIf 

Return lObfuscate


//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue   

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informações enviadas, 
    quando a regra de auditoria de rotinas com campos sensíveis ou pessoais estiver habilitada
	Remover essa função quando não houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que será utilizada no log das tabelas
    @param nOpc, Numerico, Opção atribuída a função em execução - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria não esteja aplicada, também retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Função que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  

