#INCLUDE "PMSC010.CH"
#INCLUDE "Protheus.CH"

Static nPmsShowWar := 1

/*/{Protheus.doc} PMSC010

Integracao do Projeto com o MS-Project.

@author Edson Maricate
@since 27.06.2001
@version P10 R4

@param nulo, nulo, nulo

@return nulo

/*/
Function PMSC010()
PRIVATE aRotina	:= MenuDef()
PRIVATE aMemos	:= {{"AF8_CODMEM","AF8_OBS"}}
PRIVATE aCores	:= PmsAF8Color()
PRIVATE cCadastro	:= STR0002 //"Integracao SIGAPMS : Microsoft Project 2000"
PRIVATE lUsaAJT	:= .F.

If PMSBLKINT()
	Return Nil
EndIf

mBrowse(6,1,22,75,"AF8",,,,,,aCores)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMC010Expor³ Autor ³ Edson Maricate       ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Exporataco para o MS-Project                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPMS                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMC010Expor(cAlias,nReg,nOpcx)
Local lNewModel	:= (SuperGetMv("MV_PMSXMSP",,"0") == '1' ) //0 = USO MODELO ANTIGO DE INTEGRAÇÃO / 1 = HABILITA NOVO MODELO.
Local uRet

If lNewModel
	uRet := PMC010BExp(cAlias,nReg,nOpcx)
Else
	uRet := PMC010AExp(cAlias,nReg,nOpcx)
EndIf

Return uRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMC010AExp³ Autor ³ Edson Maricate       ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Geracao do arquivo MS-Project (modelo1)						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPMS                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PMC010AExp(cAlias,nReg,nOpcx)

Local oApp
Local aConfig		:= {}
Local aEDTs
Local nFindPrj	:= 0
Local nIDProject	:= 0

Private aRecAmarr := {}

PmsNewProc()
If ParamBox({	{3,STR0018,1,{STR0019,STR0020,STR0063},90,,.F.},;
			{6,STR0054,SPACE(200),"","Empty(mv_par02).Or.FILE(mv_par02)","", 65 ,.F.,STR0048,,GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE},; //"Projetos MS-Project *.MPP |*.MPP"
			{4,STR0049,.T.,STR0050,70,,.F.},;  //"Exportar : "###"Planilha de Recursos"
			{4,"",.T.,STR0051,80,,.F.},; 			 //"Recursos Alocados"
			{4,"",.T.,STR0052,70,,.F.},; //"Relacionamentos"
			{4,"",.T.,STR0053,80,,.F.},;
			{3,STR0064,1,{STR0065,STR0066},80,,.F.};//"Exportar"###'Projeto completo'###'Selecionar EDT'
			},STR0021,aConfig)  //"Selecione a versao do MS-Project"###"Microsoft Project 2000 Portugues"###"Microsoft Project 2000 Ingles"###"Configuracoes" //"Progresso Físico"


	While nFindPrj < 10 .And. !ApOleClient( "MsProject" )
		nFindPrj++
	End

	lUsaAJT := AF8ComAJT( AF8->AF8_PROJET )
	If nFindPrj < 10
		If aConfig[7]==2
			PmsSetF3('AF9',2)
			aRet := PmsSelTsk(STR0067,"AF9/AFC","AFC",,"AF8",AF8->AF8_PROJET,.F.,.F.)    //"Selecione as tarefas a exportar"
			lContinua	:= Len(aRet)	>0
			If lContinua
				AFC->(MsGoTo(aRet[2]))
				aEDTs	:=	{AFC->AFC_EDT}
				AFC->(DbSetOrder(2))
				PMSAFCFilh(@aEDTs,AFC->AFC_EDT)
			Endif
		Else
			lContinua	:=	.T.
		Endif
		If lContinua
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Realiza a exportacao para o Microsoft Project        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oApp := MsProject():New()
			Processa({|| Aux010Sinc(cAlias,nReg,nOpcx,@oApp,aConfig[1],aConfig[2],aConfig[3],aConfig[4],aConfig[5],aConfig[6],,,aEDTs,@nIDProject) },STR0008) //"Carregando Microsoft Project. Aguarde..."
			Aviso(STR0009,STR0010+CHR(10)+CHR(13)+CHR(10)+CHR(13)+STR0011+STR0012,{STR0013},3) //"Assistente de integracao."###"O projeto selecionado esta disponivel no Microsoft Project para atualizacao."###"- Selecione a opcao '###' para finalizar a integracao com o Microsoft Project."###"Sair"
			oApp:Quit( 0 )
			oApp:Destroy()

		Endif
	Else
		MsgStop( STR0014 ) //'Microsoft Project 2000 nao instalado.'
	EndIf
EndIf


Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ADDFilhos ³ Autor ³ Bruno Sobieski        ³ Data ³ 13-12-2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera um array com todas as EDTS filhas de uma determinada EDT³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPMS                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSAFCFilh(aEDTs,cEdt)
Local nRecno	:=	0
If AFC->(MsSeek(xFilial()+AF8->AF8_PROJET+AF8->AF8_REVISA+cEDT))
	While !AFC->(EOF()) .And. AFC->AFC_FILIAL+AFC->AFC_PROJETO+AFC->AFC_REVISA+AFC->AFC_EDTPAI == xFilial('AFC')+AF8->AF8_PROJET+AF8->AF8_REVISA+cEDT
		AAdd(aEDTs, AFC->AFC_EDT)
		nRecno	:=	AFC->(Recno())
		PMSAFCFilh(@aEDTs,AFC->AFC_EDT)
		AFC->(MsGoTo(nRecno))
		AFC->(DbSkip())
	Enddo
Endif
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMC010Sinc³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Sincronizacao do Projeto com o MS-Project        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPMS                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMC010Sinc(cAlias,nReg,nOpcx)
Local lNewModel	:= (SuperGetMv("MV_PMSXMSP",,"0") == '1' ) //0 = USO MODELO ANTIGO DE INTEGRAÇÃO / 1 = HABILITA NOVO MODELO.
Local lContinua	:= .T.
Local lRetPE		:= .T.

If ExistBlock("PMC010SIN")
	lRetPE := ExecBlock("PMC010SIN",.F.,.F.)
	If ValType(lRetPE)=="L"
		lContinua := lRetPE 
	EndIf
EndIf

If lContinua 
	If lNewModel
		PMSC010B(cAlias,nReg,nOpcx)
	Else
		PMC010ASi(cAlias,nReg,nOpcx)
	EndIf
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMC010ASi³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Sincronizacao do Projeto com o MS-Project (modelo 1) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPMS                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PMC010ASi(cAlias,nReg,nOpcx)
Local oApp
Local nOpc 		:= 1
Local nFindPrj	:= 0
Local nOpc1		:= 3
Local nIDProject	:= 0
Local lContinua	:= .T.
Local aConfig		:= {}
Local lQuestRev 	:= SuperGetMv("MV_PMSREV",,.F.)

Private aRecAmarr	:= {}
Private cRevisa	:= AF8->AF8_REVISA

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o projeto nao esta reservado.            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If AF8->AF8_PRJREV=="1" .And. AF8->AF8_STATUS<>"2" .And. GetNewPar("MV_PMSRBLQ","N")=="S"
	Aviso(STR0015,STR0016,{STR0017},2) //"Gerenciamento de Revisoes"###"Este projeto nao se encontra em revisao. Para realizar uma alteracao no projeto, deve-se primeiro Iniciar uma revisao no projeto atraves do Gerenciamento de Revisoes."###"Fechar"
	lContinua := .F.
EndIf

If lContinua
	PmsNewProc()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o evento de alteracao na fase atual ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lContinua := PmsVldFase("AF8",AF8->AF8_PROJET,"11")
    If lContinua
		Aviso(STR0045,STR0046,{STR0047},2)  //"Integracao Microsoft Project 2000"###"Atencao! Certifique-se de que o formato da data no Microsoft Project (Ferramentas - Opcoes) esta configurado corretamente : 31/12/00 12:33" //"Ok"
		lContinua := ParamBox({	{3,STR0018,1,{STR0019,STR0020,STR0063},90,,.F.},;
								{6,STR0054,SPACE(200),"","Empty(mv_par02).Or.FILE(mv_par02)","", 65 ,.F.,STR0048,,GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE},; //"Projeto Modelo"###"Projetos MS-Project *.MPP |*.MPP"
								{4,STR0049,.T.,STR0050,90,,.F.},;  //"Exportar : "###"Planilha de Recursos"
								{4,"",.T.,STR0051,80,,.F.},;  //"Recursos Alocados"
								{4,"",.T.,STR0052,70,,.F.},; //"Relacionamentos"
								{4,"",.T.,STR0053,80,,.F.},;  //"Progresso Físico"
								{4,"",.T.,STR0085,80,,.F.},;  //"Estrutura do Projeto"
								{3,STR0074,1,{STR0075,STR0076,STR0077},90,,.F.},;
								{4,"",.T.,STR0078,70,,.F.}},STR0021,aConfig)  //"Selecione a versao do MS-Project"###"Microsoft Project 2000 Portugues"###"Microsoft Project 2000 Ingles"###"Configuracoes" //"Progresso Físico"
    EndIf
EndIf

If lContinua

	PmsShowWar(aConfig[8])
	PMSC10SetW(.F.)

	While nFindPrj < 10 .And. !ApOleClient( "MsProject" )
		nFindPrj++
	End

	lUsaAJT	:= AF8ComAJT( AF8->AF8_PROJET )
	If nFindPrj < 10

		oApp := MsProject():New()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Realiza a exportacao para o Microsoft Project        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Processa({|| Aux010Sinc(cAlias,nReg,nOpcx,@oApp,aConfig[1],aConfig[2],aConfig[3],aConfig[4],aConfig[5],aConfig[6],aConfig[7],,@nIDProject) },STR0008) //"Carregando Microsoft Project. Aguarde..."
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta o assistent de importacao do Microsoft Project ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While nOpc == 1 .Or. nOpc == 2
			nOpc := Aviso(STR0009,STR0010+CHR(10)+CHR(13)+CHR(10)+CHR(13)+STR0011+STR0022+CHR(13)+CHR(10)+STR0011+STR0023+CHR(10)+CHR(13)+STR0011+STR0012,{STR0024,STR0025,STR0013},3) //"Assistente de integracao."###"O projeto selecionado esta disponivel no Microsoft Project para atualizacao."###"- Selecione a opcao '###' para realizar a atualizacao dos dados do projeto a partir do Microsoft Project. "###"- Selecione a opcao '###' para consultar a estrutura do projeto."###"- Selecione a opcao '###' para finalizar a integracao com o Microsoft Project."###"Importar"###"Visualizar"###"Sair"
			PmsNewProc()
			If nOpc == 1
				If PMS200Rev()
					If lQuestRev
						nOpc1 := Aviso(STR0069,STR0070,{STR0071, STR0072, STR0073},3) // 'Controle'// 'Para realizar importação se faz necessário criar uma nova revisão do Projeto. A revisão já foi criada?'
						If nOpc1 == 1
							Processa({|| Aux010Write(cAlias,nReg,nOpcx,@oApp,aConfig[1],aConfig[2],aConfig[3],aConfig[4],aConfig[5],aConfig[6],@aRecAmarr, !aConfig[9],@nIDProject) },STR0026) //"Atualizando Projeto. Aguarde..."
						Elseif nOpc1 == 2
							PMSA210(4) //Finaliza
							PMSA210(3) //Inicia
							Processa({|| Aux010Write(cAlias,nReg,nOpcx,@oApp,aConfig[1],aConfig[2],aConfig[3],aConfig[4],aConfig[5],aConfig[6],@aRecAmarr, !aConfig[9],@nIDProject) },STR0026) //"Atualizando Projeto. Aguarde..."
						Else
							nOpc := 2
						Endif
					Else
						Processa({|| Aux010Write(cAlias,nReg,nOpcx,@oApp,aConfig[1],aConfig[2],aConfig[3],aConfig[4],aConfig[5],aConfig[6],@aRecAmarr, !aConfig[9],@nIDProject) },STR0026) //"Atualizando Projeto. Aguarde..."
					Endif
				EndIf
			EndIf
			If nOpc == 2
				PMSA200(2,AF8->AF8_REVISA)
			EndIf
		End
		oApp:Quit( 0 )
		oApp:Destroy()
		if PMSC10SetW() // Ha erros logados
			MsgStop( STR0079 )
		endif

	Else
		MsgStop( STR0014 ) //'Microsoft Project 2000 nao instalado.'
	EndIf
EndIf

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsReadData³ Autor ³ Edson Maricate       ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de leitura da data a partir do campo no MS-Project     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPMS                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsReadData(nVersao,cRead)

Local dRet
Local cDtStart
Local nBarSt1
Local nBarSt2
Local cDiaStart
Local cMesStart

DEFAULT cRead := ""

If .T.
	dRet := CTOD(Substr(cRead,1,8))
Else
	nPosSep1 := AT(" ",cRead)
	cDtStart := Substr(cRead,1,(nPosSep1-1))
	nBarSt1 := AT("/",cDtStart)
	nBarSt2 := RAT("/",cDtStart)
	If nBarSt1 == 2
		cMesStart := StrZero(Val(Substr(cDtStart,1,1)),2)
	Else
		cMesStart := StrZero(Val(Substr(cDtStart,1,2)),2)
	Endif
	If nBarSt2 == 4
		cDiaStart := StrZero(Val(Substr(cDtStart,3,1)),2)
	Elseif nBarSt2 == 6
		cDiaStart := StrZero(Val(Substr(cDtStart,4,2)),2)
	Elseif nBarSt2 == 5
		If nBarSt1 == 2
			cDiaStart := StrZero(Val(Substr(cDtStart,3,2)),2)
		Else
			cDiaStart := StrZero(Val(Substr(cDtStart,4,1)),2)
		Endif
	Endif
	dRet := CTOD(cDiaStart+"/"+cMesStart+"/"+Substr(cDtStart,(Len(cDtStart)-1),2))
EndIf

Return dRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsReadHora³ Autor ³ Edson Maricate       ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de leitura da hora a partir do campo no MS-Project     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPMS                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsReadHora(nVersao,cRead)
Local cHora
Local nPosSep1

Default cRead := ""

If .T.
	cHora := Substr(cRead,Len(cRead)-4,5)
Else
	nPosSep1 := AT(" ",cRead)
	cHora  := Substr(cRead,(nPosSep1+1),((Len(cRead)-nPosSep1)-3))
	If Len(Alltrim(cHora)) == 4
		cHora := "0" + Alltrim(cHora)
	Endif
	If Substr(cRead,(Len(cRead)-1),2) == "PM"
		If Substr(cHora,1,2) <> "12"
			cHora := StrZero((Val(Substr(cHora,1,2))+12),2) + Substr(cHora,3,3)
		Endif
	Else
		If Substr(cHora,1,2) == "12"
			cHora := "00" + Substr(cHora,3,3)
		Endif
	Endif
EndIf

Return cHora

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsReadCale³ Autor ³ Edson Maricate       ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de leitura do Calendario do campo no MS-Project        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPMS                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsReadCale(nVersao,cRead,cAllCalend)
Local cRet
Local aArea	:= GetArea()
Local aRet	:= {}
Local lRet	:= .F.

Default cRead := ""

dbSelectArea("SH7")
dbSetOrder(1)
If !Empty(cRead) .And. dbSeek(xFilial()+Alltrim(cRead))
	cRet := cRead
Else
	If Empty(cAllCalend)
		if PmsShowWar() <> 2
			While !lRet
				lRet := ParamBox({	{1,STR0036,AllTrim(cRead),"@",'.F.',,'.F.',30,.F.},; //"Calendario incorreto"
								{1,STR0037,CriaVar('H7_CODIGO'),"@!",'ExistCpo("SH7",mv_par02)','SH7','.T.',30,.T.},; //"Selecione "
								{5,STR0038,.F.,100,,.F.};  //"Aplicar a todos calendarios invalidos."
								},STR0039,aRet) //"Calendario invalido. Selecione o calendario correto."
			End
			cRet := aRet[2]
			If aRet[3]
				cAllcalend	:= cRet
			EndIf
		endif
		if PmsShowWar() <> 1
			cRet :=  AF8->AF8_CALEND
			cAllCalend := cRet
			PMSLogInt("AF9" , .F. ,,,STR0036+STR0080)
		endif
	Else
		cRet := cAllCalend
	EndIf
EndIf

RestArea(aArea)
Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsReadRela³ Autor ³ Edson Maricate       ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de leitura dos relacionamentos do campo do MS-Project  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPMS                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsReadRela(nVersao,cRead,aTasks, nID, nCodigo)
Local aTipos
Local cRelacs  := ""
Local nCntRel  := 0
Local cRelac1	:= ""
Local nPosSep  := 0
Local nPosPred := 0
Local nHRetar 	:= 0
Local lPerTip
Local aRelac	:= {}
Local nCntTip  := 0
Local cTipo	:= ""
Local nPosPlus	:= 0

Default cRead 	:= ""
Default aTasks	:= {}
Default nID 	:= 0
Default nCodigo:= 0

If len(cRead) > 1
	nPosPlus := At("+",cRead)
	cTipo := If(nPosPlus > 0,;
	           SubStr(cRead,nPosPlus-2,2),;
	           SubStr(cRead,len(cRead)-1,2))

	If cTipo $  "TI/II/TT/IT"
		nVersao := 1
		aTipos := {"TI","II","TT","IT"}
	ElseIf cTipo $ "FC/CC/CF"
		nVersao := 3
		aTipos := {"FC","CC","FF","CF"}
	Endif
EndIf

If aTipos = Nil 
	If nVersao==1
		aTipos := {"TI","II","TT","IT"}
	ElseIf nVersao == 3
		aTipos := {"FC","CC","FF","CF"}
	Else
		aTipos := {"FS","SS","FF","SF"}
	Endif
EndIf

If !Empty(cRead)
	cRelacs := cRead
	nCntRel := 0
	While Len(cRelacs) > 0
		nPosSep := At(";",cRelacs)
		
		cRelac1 := Substr(cRelacs,1,If(nPosSep==0,Len(cRelacs),nPosSep-1))
		nCntRel++
		nPosTipo := 0
		cTipoRel := ""
		aAdd(aRelac,{Nil,Nil,Nil})
		nHRetar := 0
		lPerTip := .F.
		For nCntTip := 1 to Len(aTipos)
			If aTipos[nCntTip] $ cRelac1
				lPerTip := .T.
			Endif
		Next
		If Len(Alltrim(cRelac1)) == 1 .or. (Len(Alltrim(cRelac1)) > 1 .and. !lPerTip)
			cTipoRel := "1"
			If (nID>0) .and. (nCodigo>0)
				nPosPred := aScan(aTasks, {|x| x[nID]==AllTrim(cRelac1)})
				If nPosPred > 0
					aRelac[Len(aRelac)][1] := aTasks[nPosPred,nCodigo]
				Endif
			EndIf
		Else
			If aTipos[1] $ cRelac1
				nPosTipo := At(aTipos[1],cRelac1)
				cTipoRel := "1"
			ElseIf aTipos[2] $ cRelac1
				nPosTipo := At(aTipos[2],cRelac1)
				cTipoRel := "2"
			ElseIf aTipos[3] $ cRelac1
				nPosTipo := At(aTipos[3],cRelac1)
				cTipoRel := "3"
			ElseIf aTipos[4] $ cRelac1
				nPosTipo := At(aTipos[4],cRelac1)
				cTipoRel := "4"
			Endif
			If At("d",cRelac1) > 0
				nHRetar := 24 * Val(Substr(cRelac1,IIf(At("+",cRelac1) == 0, At("-",cRelac1),At("+",cRelac1)),(At("d",cRelac1)-2)))
			Endif
			If At("h",cRelac1) > 0
				cRelac1 := Iif(At(",", cRelac1) > 0, StrTran(cRelac1, ',', '.'), cRelac1)
				nHRetar := Val(Substr(cRelac1,IIf(At("+",cRelac1) == 0, At("-",cRelac1),At("+",cRelac1)),(At("h",cRelac1)-2)))
			Endif
			If (nID>0) .and. (nCodigo>0)
				nPosPred := aScan(aTasks, {|x| x[nID]==AllTrim(SubStr(cRelac1,1,(nPosTipo-1)))})
				If nPosPred > 0
					aRelac[Len(aRelac)][1] := aTasks[nPosPred,nCodigo]
				Endif
			Else
				aRelac[Len(aRelac)][1] := AllTrim(Substr(cRelac1,1,(nPosTipo-1)))
			EndIf
		Endif
		aRelac[Len(aRelac)][2] := cTipoRel
		aRelac[Len(aRelac)][3] := nHRetar

		cRelacs := Substr(cRelacs,(Len(cRelac1)+2),(Len(cRelacs)-Len(cRelac1)))
	End
Endif

Return aRelac

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsReadRecs³ Autor ³ Edson Maricate       ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de leitura dos relacionamentos do campo do MS-Project  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPMS                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsReadRecs(nVersao,cRead,aRecAmarr)
Local nPosSep
Local nPosSep2
Local aRecursos	:= {}
Local aRet			:= {}
Local cRecAux		:= ""
Local nPosElem	:= 0
Local lThread		:= Type("lThread")=='L'
Local nTamRecurs	:= TamSX3("AE8_RECURS")[1]*5
Local nTamRecInv	:= 0
Local lPMC010REC	:= ExistBlock("PMC010REC")
Local cFilAE8			:= xFilial("AE8")

Default cRead := ""

If !Empty(cRead)
	cRecursos := cRead
	While Len(cRecursos) > 0
		nPosElem := 0
		nPosSep := At(";",cRecursos)
		cAuxRec := Substr(cRecursos,1,If(nPosSep==0,Len(cRecursos),nPosSep-1))
		nPosSep2:= At("[",cAuxRec)
		If nPosSep2 > 0
			cRecurso := Substr(cAuxRec,1,nPosSep2-1)
			cAloc	 := Substr(cAuxRec,nPosSep2+1,AT("]",cAuxRec)-nPosSep2-1)
			cAloc	 := StrTran(cAloc,".","")
			cAloc	 := StrTran(cAloc,",",".")
			If "%"$cAloc
				nAloc := Val(StrTran(cAloc,"%",""))
			Else
				nAloc := Val(cAloc)*100
			EndIf
			nPosElem := aScan(aRecAmarr, { |x| x[2]==cRecurso })
			//Ponto de entrada para tratamento do recurso quando feita importacao do MSPROJECT para o PMS
 			If lPMC010REC
  				cRecAux := ExecBlock("PMC010REC",.F.,.F.,{cAuxRec})
				If ValType(cRecAux) == "C" .and. !Empty(cRecAux)
					//Caso o ponto de entrada retorne um recurso que não existe, sera exibida a parambox para tratamento de recurso invalido
					AE8->(dbSetOrder(1))
					If AE8->(dbSeek(cFilAE8+cRecAux))
						aAdd(aRecursos,{AE8->AE8_RECURS+"-"+AE8->AE8_DESCRI,100})
						nPosElem := 1
					EndIf
				EndIf
			EndIf
			If nPosElem <= 0
				if !lThread .AND. PMSShowWar()<> 2
					nTamRecInv	:= Len(cRecurso)*5
					nTamRecInv := iIf(nTamRecInv>150,100,nTamRecInv)
					If ParamBox({	{9,STR0058,200,,.F.},; //"Recurso invalido. Selecione o recurso correto."
									{1,STR0055,cRecurso,"@",'.F.',,'.F.',nTamRecInv,.F.,.T.},; //"Recurso invalido"
									{1,STR0056,CriaVar('AE8_RECURS'),"@!",'ExistCpo("AE8",MV_PAR03)','AE8','.T.',nTamRecurs,.T.},; //"Selecione "
									{5,STR0057,.F.,100,,.F.}; //"Associar sempre a este recurso."
								},"",aRet)
						AE8->(dbSetOrder(1))
						If AE8->(dbSeek(cFilAE8+aRet[3]))
							If aRet[4]
								aAdd(aRecAmarr, { AE8->AE8_RECURS+"-"+AE8->AE8_DESCRI, cRecurso} )
							Else
								aAdd(aRecursos,{AE8->AE8_RECURS+"-"+AE8->AE8_DESCRI,nAloc})
							EndIf
						EndIf
					EndIf
				endif
				if PMSShowWar()<> 1
					PMSLogInt("AF9" , .F. ,,,STR0081+cRecurso+STR0082)
				endif
			EndIf

			nPosElem := aScan(aRecAmarr, { |x| x[2]==cRecurso })
			If nPosElem > 0
				aAdd(aRecursos,{aRecAmarr[nPosElem][1],nAloc})
			EndIf
		Else
			nPosElem := aScan(aRecAmarr, { |x| x[2]==cAuxRec })
			//Ponto de entrada para tratamento do recurso quando feita importacao do MSPROJECT para o PMS
 			If lPMC010REC
  				cRecAux := ExecBlock("PMC010REC",.F.,.F.,{cAuxRec})
				If ValType(cRecAux) == "C" .and. !Empty(cRecAux)
					//Caso o ponto de entrada retorne um recurso que não existe, sera exibida a parambox para tratamento de recurso invalido
					AE8->(dbSetOrder(1))
					If AE8->(dbSeek(cFilAE8+cRecAux))
						aAdd(aRecursos,{AE8->AE8_RECURS+"-"+AE8->AE8_DESCRI,100})
						nPosElem := 1
					EndIf

				EndIf

			EndIf

			If nPosElem <= 0
				if !lThread .AND. PMSShowWar() <> 2
					nTamRecInv	:= Len(cAuxRec)*5
					nTamRecInv := iIf(nTamRecInv>150,100,nTamRecInv)
					If ParamBox({	{9,STR0062,200,,.F.},; //"Recurso invalido. Selecione o recurso correto."
									{1,STR0059,cAuxRec,"@",'.F.',,'.F.',nTamRecInv,.F.,.T.},; //"Recurso invalido"
									{1,STR0056,CriaVar('AE8_RECURS'),"@!",'ExistCpo("AE8",MV_PAR03)','AE8','.T.',nTamRecurs,.T.},; //"Selecione "
									{5,STR0061,.F.,100,,.F.}; //"Associar sempre a este recurso."
									},"",aRet)
						AE8->(dbSetOrder(1))
						If AE8->(dbSeek(cFilAE8+aRet[3]))
							If aRet[4]
								aAdd(aRecAmarr, { AE8->AE8_RECURS+"-"+AE8->AE8_DESCRI, cAuxRec } )
							Else
								aAdd(aRecursos,{AE8->AE8_RECURS+"-"+AE8->AE8_DESCRI,100})
							EndIf
						EndIf
					EndIf
				endif
				if PMSShowWar() <> 1
					PMSLogInt("AF9" , .F. ,'',,STR0081+cAuxRec+STR0082)
				endif
			EndIf
			nPosElem := aScan(aRecAmarr, { |x| x[2]==cAuxRec })

			If nPosElem > 0
				aAdd(aRecursos,{aRecAmarr[nPosElem][1], 100})
			EndIf
		EndIf
		cRecursos := Substr(cRecursos,(Len(cAuxRec)+2),(Len(cRecursos)-Len(cAuxRec)))
	End
EndIf
FATPDLogUser("PMSREADREC")
Return aRecursos

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsReadUM³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de leitura e correcao da unidade de medida.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPMS                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsReadUM(cRead,cTarefa,cAllUM)
Local aArea	:= GetArea()
Local aRet	:= {,,AllTrim(cRead),}
Local lRet	:= .F.
Local cRet  := Iif(!Empty(cRead),cRead,"")
Local lThread := Type("lThread")=='L'
Default cRead := ""

dbSelectArea("SAH")
dbSetOrder(1)
If !Empty(cRead) .And. !dbSeek(xFilial()+AllTrim(cRead))
	If Empty(cAllUM)
		if !lThread .AND. PMSShowWar() <> 2
			While !lRet
				lRet := ParamBox({	{1,STR0040,AllTrim(cTarefa)," ",'.F.',,'.F.',85,.F.},;//"Tarefa :"###
							{1,STR0041,AllTrim(cRead)," ",'.F.',,'.F.',25,.F.},;//"Unidade incorreta"###
							{1,STR0042,CriaVar('AH_UNIMED'),"@!",'ExistCpo("SAH",mv_par03)','SAH','.T.',25,.T.},; //"Selecione a UM "
							{5,STR0043,.F.,95,,.F.}; //"Aplicar a todas Unidades invalidas."
							},STR0044,aRet) //"Unidade de medida invalida. Selecione a UM correta."
			End
			cRet := aRet[3]
			If aRet[4]
				cAllUM	:= cRet
			EndIf
		endif
		if PMSShowWar() <> 1
			PMSLogInt("AF9" , .F. ,,,STR0083+cRead+STR0084)
		endif
	Else
		cRet := cAllUM
	EndIf
EndIf

RestArea(aARea)
Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsWrHora³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Converte a hora para o formato MS-Project                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsWrHora(nVersao,cHora)
Local cRet := ""

If cHora != Nil
	cRet := cHora
EndIf
Return cRet

/*/{Protheus.doc} MenuDef

Utilizacao de menu Funcional.

@author Ana Paula N. Silva

@since 01/12/06

@version P10 R4

@param nenhum

@return aRotina, Array, Contem as opcoes da rotina.

/*/
Static Function MenuDef()
Local aRotina := {}

	aRotina  :=	{	{ STR0003,	"AxPesqui"  , 0 , 1,,.F.},;   //"Pesquisar"
						{ STR0004,	"PMC010Expor" , 0 , 2},; //"Exportar"
						{ STR0005,	"PMC010Sinc" , 0 , 2},; //"Sincronizar"
						{ STR0006,	"PMS200Leg" , 0 , 6, , .F.}} //"Legenda"

Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSSHOWWARºAutor  ³Microsiga           º Data ³  03/09/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Indica se as mensagens de Alerta serão apresentadas         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSSHOWWAR(nSetShow)

if nSetShow <> NIL
	nPmsShowWar := nSetShow
endif

Return nPMSShowWar

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

