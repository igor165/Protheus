#INCLUDE "PCOA120.ch"
#INCLUDE "PROTHEUS.CH"
#include "pcoicons.ch"
#include "DBTREE.CH"

Static oMenu
Static oMenu2

/*/
_F_U_N_C_ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ PCOA120  ³ AUTOR ³ Edson Maricate        ³ DATA ³ 17-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Programa de manutecao das revisoes do orcamento              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ SIGAPCO                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_DOCUMEN_ ³ PCOA120                                                      ³±±
±±³_DESCRI_  ³ Programa de manutecao da planilha orcamentaria.              ³±±
±±³_FUNC_    ³ Esta funcao podera ser utilizada com a sua chamada normal a  ³±±
±±³          ³ partir do Menu .                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_PARAMETR_³ Nenhum                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOA120()

PRIVATE cCadastro	:= STR0001 //"Revisoes da Planilha Orcamentaria"

PRIVATE aCores    := {	{ 'AK1_STATUS=="2"', 'BR_AMARELO', STR0002 },; //"Planilha em Revisao"
						{ 'AK1_STATUS="1".Or.Empty(AK1_STATUS)' , 'ENABLE', STR0003}}  //"Planilha Livre para Revisao"
PRIVATE aRotina := MenuDef()						


Set Key VK_F12 To A120Perg()
Pergunte("PCO120",.F.)

If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	mBrowse(6,1,22,75,"AK1",,,,,,aCores)
EndIf

Return 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pco120Hst³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Consulta de Historicos da Revisao.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pco120Hst(cAlias,nReg,nOpcx)

Local aSize		:= MsAdvSize(,.F.,430)

Local aRotina := {	{STR0010,"Pco120Det",0,2},;  //"Detalhes"
					{STR0011,"Pco120VHst",0,2}}   //"Visualizar"

MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro,"AKE",,aRotina,,"xFilial('AKE')+AK1->AK1_CODIGO","xFilial('AKE')+AK1->AK1_CODIGO",.F.,,,{{STR0012,1}},xFilial('AKE')+AK1->AK1_CODIGO)  //"Versao"

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pco120IRv³ Autor ³ Edson Maricate         ³ Data ³ 17-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Criacao de Revisoes da PLanilha Orcamentaria     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PCOA120                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pco120IRv(cAlias,nReg,nOpcx)

Local oDlg
Local lGravaOk	:= .F.
Local lContinua	:= .T.
Local bCampo 	:= {|n| FieldName(n) }
Local oMemo
Local cGetMemo	:= CriaVar("AKE_MEMO")
Local nX		:= 0
Local aAreaAK1		:= AK1->(GetArea())
Local cAK1Fase 	:= AK1->AK1_FASE
Local lP120Ini := ExistBlock("P120INI")

PRIVATE 	cSavScrVT,;
			cSavScrVP,;
			cSavScrHT,;
			cSavScrHP,;
			CurLen,;
			nPosAtu:=0,;
			nPosAnt:=9999,;
			nColAnt:=9999
			
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a planilha nao esta em revisao           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If !(PcoVldFase("AMR",cAK1Fase,"0017",.T.)) // Evento Iniciar Revisão
	Return
EndIf


If AK1->AK1_STATUS=="2"
	Help("  ",1,"PCOA1201")
	lContinua := .F.
EndIf

If lContinua .And. !PcoChkUser(AK1->AK1_CODIGO,Padr(AK1->AK1_CODIGO, Len(AK3->AK3_CO)),SPACE(LEN(AK3->AK3_CO)),3,"REVISA",AK1->AK1_VERSAO)
   Aviso(STR0019, STR0043, {"Ok"})//"Atencao"###"Usuario sem direito a iniciar revisao da planilha orcamentaria."
	lContinua := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trava o registro do AK1                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lContinua .And. !SoftLock("AK1")
	lContinua := .F.
Endif

If lContinua
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega as variaveis de memoria AKE                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AKE")
	RegToMemory("AKE",.T.)
	M->AKE_ORCAME	:= AK1->AK1_CODIGO
	M->AKE_DATAI	:= MsDate()
	M->AKE_HORAI	:= Time()
	M->AKE_REVISA	:= AK1->AK1_VERSAO
	M->AKE_DESCRI	:= AK1->AK1_DESCRI
	M->AKE_USERI	:= __cUserId
	
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM 8,0 TO 30,78 OF oMainWnd
		oEnch := MsMGet():New("AKE",nReg,nOpcx,,,,,{16,1,90,307},,3,,,,oDlg)
		oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lGravaOk:=.T.,iif (lP120Ini,lGravaOk := Execblock("P120INI",.F.,.F.),lGravaOk:=.T.),oDlg:End()},{|| oDlg:End()}) CENTERED
	
	If lGravaOk
//		PcoIniLan("000252")
//		Begin Transaction
			PcoRevisa(AK1->(RecNo()),,,,,.T.,.F.,.T./*lGravaAKE*/)
//		End Transaction
//		PcoFinLan("000252")
	EndIf
	MsUnlockAll()
EndIf	

RestArea(aAreaAK1)
Return .F.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pco120Frv³ Autor ³ Edson Maricate         ³ Data ³ 18-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Finalizacao da revisao na Planilha Orcamentaria  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PCOA120                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pco120Frv(cAlias,nReg,nOpcx,cR1,cR2,lAuto,cTexto)

Local oDlg
Local lGravaOk	:= .F.
Local lContinua	:= .T.
Local aAreaAK1		:= AK1->(GetArea())
Local aAreaAKE		:= AKE->(GetArea())
Local oMemo
Local cGetMemo	:= CriaVar("AKE_MEMO")
Local bCampo 	:= {|n| FieldName(n) }
Local nX		:= 0
Local lRet := .T.
Local nRecAKE
Local cAK1Fase 	:= AK1->AK1_FASE
Local lPcoa1202 := ExistBlock("PCOA1202")                                          
Local nMultThread   := SuperGetMv("MV_PCOMTHR",.T.,0)   // Default 0 - sem multithread, 1 - com multthread
Local lOtimizado := If( (Alltrim(Upper(TcGetDb())) $ "MSSQL7|ORACLE|DB2|POSTGRES"),.T., .F.) .and. nMultThread == 1

DEFAULT lAuto := .F.
DEFAULT cTexto := ""

PRIVATE 	cSavScrVT,;
			cSavScrVP,;
			cSavScrHT,;
			cSavScrHP,;
			CurLen,;
			nPosAtu:=0,;
			nPosAnt:=9999,;
			nColAnt:=9999
			

If !(PcoVldFase("AMR",cAK1Fase,"0018",.T.)) //Evento Finalizar Revisão
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o projeto nao esta reservado.            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If AK1->AK1_STATUS<>"2"
	If !lAuto
		Help("  ",1,"PCOA1202")
	EndIf	
	lContinua := .F.
	lRet := .F.
EndIf

If lContinua .And. !PcoChkUser(AK1->AK1_CODIGO,Padr(AK1->AK1_CODIGO, Len(AK3->AK3_CO)),SPACE(LEN(AK3->AK3_CO)),3,"REVISA",AK1->AK1_VERSAO)
   Aviso(STR0019, STR0044, {"Ok"})//"Atencao"###"Usuario sem direito a finalizar revisao da planilha orcamentaria."
	lContinua := .F.
	lRet := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trava o registro do AK1                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lContinua .And. !SoftLock("AK1")
	lContinua := .F.
	lRet := .F.
Endif

If lContinua
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega as variaveis de memoria AKE                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AKE")
	dbSetOrder(1)
	If ! dbSeek(xFilial()+AK1->AK1_CODIGO+AK1->AK1_VERREV)
		lContinua := .F.
		lGravaOk := .F.
	EndIf
	If lContinua
		nRecAKE := AKE->(Recno())
		RegToMemory("AKE",.F.)
		M->AKE_DATAF	:= MsDate()
		M->AKE_HORAF	:= Time()
		M->AKE_USERF	:= __cUserId
		cGetMemo		:= AKE->AKE_MEMO
		
		If !lAuto
			DEFINE MSDIALOG oDlg TITLE cCadastro FROM 8,0 TO 30,78 OF oMainWnd
			oEnch := MsMGet():New("AKE",nReg,nOpcx,,,,,{16,1,90,307},,3,,,,oDlg)
			oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT	
			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lGravaOk:=.T.,oDlg:End()},{|| oDlg:End()}) CENTERED
		Else
			cGetMemo		:= cTexto
			M->AKE_MEMO := cTexto
			lGravaOk:=.T.		
		EndIf	
	EndIf
	If lGravaOk
		lGravaOk := .F.
		If lOtimizado
			lGravaOk := PcoFinRev()
		Else
			lGravaOk := .T.
			//PLANILHA VERSAO ATUAL VIGENTE ATE FINALIZACAO DA REVISAO
			PcoIniLan("000252")
			dbSelectArea("AK2")
			dbSetOrder(1)
			dbSeek(xFilial()+AK1->AK1_CODIGO+AK1->AK1_VERSAO)
			While !Eof() .And. xFilial()+AK1->AK1_CODIGO+AK1->AK1_VERSAO==AK2->AK2_FILIAL+AK2->AK2_ORCAME+AK2->AK2_VERSAO
			    //observacao: DEVE ESTAR NESTA SEQUENCIA (NAO MUDAR)
				PcoDetLan("000252","04","PCOA100")  							//GRAVAR SALDO HISTORICO PREVISTO PARA VERSAO
				PcoDetLan("000252","01","PCOA100", .T., "00025202;00025204")  	//DELETAR VERSAO ATUAL DA PLANILHA
				dbSelectArea("AK2")
				dbSkip()
			End
			PcoFinLan("000252")
            //PLANILHA VERSAO REVISADA TORNANDO-SE EM ATUAL
			PcoIniLan("000252")
			dbSelectArea("AK2")
			dbSetOrder(1)
			dbSeek(xFilial()+AK1->AK1_CODIGO+M->AKE_REVISA)
			While !Eof() .And. xFilial()+AK1->AK1_CODIGO+M->AKE_REVISA==AK2->AK2_FILIAL+AK2->AK2_ORCAME+AK2->AK2_VERSAO
			
				If ExistBlock("PCOA1202")
					ExecBlock("PCOA1202",.F.,.F.)
				EndIf   
				
			    //observacao: DEVE ESTAR NESTA SEQUENCIA (NAO MUDAR)
				PcoDetLan("000252","01","PCOA100")           					//GRAVANDO COMO ATUALIZACAO DA PLANILHA
				PcoDetLan("000252","02","PCOA100",.T., "00025201;00025204")    //DELETAR REVISAO PRESERVANDO ITEM ANTERIOR + HISTORICO
				dbSelectArea("AK2")
				dbSkip()
			End
			PcoFinLan("000252")
		EndIf
		If lGravaOk
			Begin Transaction
			dbSelectArea("AKE")
			dbGoto(nRecAKE)
			RecLock("AK1",.F.)
			AK1->AK1_STATUS	:= "1"
			AK1->AK1_VERSAO	:= AKE->AKE_REVISA
			AK1->AK1_VERREV	:= ""
			MsUnlock()
			RecLock("AKE",.F.)
			For nx := 1 TO FCount()
				FieldPut(nx,M->&(EVAL(bCampo,nx)))
			Next nx
			AKE->AKE_FILIAL := xFilial("AKE")
			MsUnlock()
			End Transaction
		EndIf
	EndIf
	MsUnlockAll()
EndIf	
	
RestArea(aAreaAK1)
RestArea(aAreaAKE)
Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pco120Rev³ Autor ³ Edson Maricate         ³ Data ³ 18-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Revisao da Planilha Orcamentaria                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PCOA120                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pco120Rev(cAlias,nReg,nOpcx)
Local lContinua	:= .T.


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a planilha esta em revisao               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If AK1->AK1_STATUS=="1"
	Help("  ",1,"PCOA1203")
	lContinua := .F.
EndIf

If lContinua
	SaveInter()
	PCOA100(4,AK1->AK1_VERREV, .T.)
	RestInter()
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pco120Det³ Autor ³ Edson Maricate         ³ Data ³ 18-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de visualizacao dos detalhes da Planilha Orcament.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PCOA120                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pco120Det(cAlias,nReg,nOpcx)

Local oDlg
Local lGravaOk	:= .F.
Local lContinua	:= .T.
Local oMemo
Local cGetMemo		:= CriaVar("AKE_MEMO")
Local bCampo 	:= {|n| FieldName(n) }
PRIVATE 	cSavScrVT,;
			cSavScrVP,;
			cSavScrHT,;
			cSavScrHP,;
			CurLen,;
			nPosAtu:=0,;
			nPosAnt:=9999,;
			nColAnt:=9999
			

RegToMemory("AKE",.F.)
M->AKE_DATAF	:= MsDate()
M->AKE_HORAF	:= Time()
M->AKE_USERF	:= __cUserId
cGetMemo		:= AKE->AKE_MEMO

DEFINE MSDIALOG oDlg TITLE cCadastro FROM 8,0 TO 30,78 OF oMainWnd
oEnch := MsMGet():New("AKE",nReg,nOpcx,,,,,{16,1,90,307},,3,,,,oDlg)
oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT	
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lGravaOk:=.T.,oDlg:End()},{|| oDlg:End()}) CENTERED



Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pco120VHst³ Autor ³ Edson Maricate        ³ Data ³ 18-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de visualizacao da Planilha orcamentaria            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PCOA120                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pco120VHst(cAlias,nReg,nOpcx)
Local aArea := GetArea()
Local cAliasAnt := Alias()
Local aAreaAK1 := AK1->(GetArea())
Local aAreaAKE := AKE->(GetArea())

SaveInter()
PCOA100(2,AKE->AKE_REVISA,.T.)
RestInter()

RestArea(aAreaAK1)
RestArea(aAreaAKE)
RestArea(aArea)
dbSelectArea(cAliasAnt)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Pco120CMP ºAutor  ³Paulo Carnelossi    º Data ³  03/01/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Compara as Versoes - mostrando as diferencas entre elas na º±±
±±º          ³ forma de arvore                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pco120CMP()
Local aVersoes := {}	
Local aPerg    := {}

aVersoes:= PcoVersoes(AK1->AK1_CODIGO)

If ParamBox( {	{2,STR0014,"01",aVersoes,50,"",.F.},; //"Comparar Versao"
				{2,STR0015,"01",aVersoes,50,"",.F.}},STR0016,@aPerg) //"Com Versao"###"Parametros"
    If aPerg[1] <> aPerg[2]
		Processa({||Pco120Comp(aPerg)},STR0017,STR0018,.F.) //"Processando"###"Comparando as versoes da planilha orcamentaria..."
	Else
		Aviso(STR0019,STR0020,{STR0021},2) //"Atencao"###"Nenhuma diferenca encontrada!"###"Fechar"
	EndIf	
EndIf

Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PCOVersoes³ Autor ³Paulo Carnelossi       ³ Data ³ 03/01/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna as versoes da Planilha Orcamentaria.               	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PCOVersoes(cPlanilha)
Local aArea   := GetArea()
Local aVersoes:= {}	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna um array com todas as versoes do projeto.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("AKE")
dbSetOrder(1)

If MsSeek(xFilial("AKE") + cPlanilha)
	While !Eof() .And. (xFilial("AKE") + cPlanilha == AKE->AKE_FILIAL + AKE->AKE_ORCAME)
	    Aadd(aVersoes,AKE->AKE_REVISA)
		dbSkip()
	End
Else
	Aadd(aVersoes,"")
EndIf


RestArea(aArea)
Return(aVersoes)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pco120Comp ³ Autor ³Paulo Carnelossi      ³ Data ³ 03/01/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de comparacao das versoes da Planilha Orcamentaria. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pco120Comp(aVersoes)
Local oDlg
Local oTree
Local oTree2
Local aPlanComp:= {}
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta um array com a estrutura do tree do projeto que sera utilizado ³
//³como base na comparacao.                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aOrigem := Pco120TreeEDT(aVersoes[1])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta um array com a estrutura do tree do projeto que sera utilizado ³
//³como na comparacao.                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aDestino:= Pco120TreeEDT(aVersoes[2])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta um array com a estrutura do tree do projeto da comparacao entre³
//³as versoes.				                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aPlanComp:= Pco120_Compara(aOrigem,aDestino)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta a  tela com o tree da versao base e com o tree da versao³
//³resultado da comparacao.                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd( aObjects, { 100, 100, .T., .T., .F. } )  
aAdd( aObjects, { 100, 100, .T., .T., .F. } )  
aInfo  := { aSize[1],aSize[2],aSize[3],aSize[4],3,3 } 
aPosObj:= MsObjSize( aInfo, aObjects, .T.,.T. )  

DEFINE MSDIALOG oDlg TITLE STR0022  FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL //"Comparacao de Versoes"
	
	oTree:= dbTree():New(aPosObj[1,1], aPosObj[1,2],aPosObj[1,3],aPosObj[1,4], oDlg,,,.T.)
	oTree:bRClicked := {|o,x,y| PCOFpopM1(x,y,oTree,aOrigem,@oMenu),Pco120CtrMenu(1,oMenu,oTree) } // Posição x,y em relação a Dialog 
	oTree:lShowHint := .F. 
	Pco120MontaTree(@oTree,aOrigem)
	
	oTree2:= dbTree():New(aPosObj[2,1], aPosObj[2,2],aPosObj[2,3],aPosObj[2,4], oDlg,,,.T.)
	oTree2:bRClicked := {|o,x,y| PCOFpopM2(x,y,oTree,oTree2,aOrigem,aPlanComp,aVersoes,@oMenu2),Pco120CtrMenu(2,@oMenu2,oTree2) }
	oTree2:lShowHint := .F. 
	Pco120MontaTree(@oTree2,aPlanComp)
	
	AAdd( aButtons, { "DBG09"   , { || PcoA120Inf() }, STR0009, STR0009 } )  //"Legenda"###"Legenda"
	AAdd( aButtons, { "PMSSETADOWN", { || PcoA120Nav(1,aPlanComp,@oTree,@oTree2) }, STR0024, STR0023 } )   //"Diferenca"###"Proxima Diferenca"
	AAdd( aButtons, { "PMSSETAUP"  , { || PcoA120Nav(2,aPlanComp,@oTree,@oTree2) }, STR0024, STR0025 } )   //"Diferenca"###"Diferenca Anterior"
	AAdd( aButtons, { "IMPRESSAO",{ || IIf((Len(aOrigem) > 0) .And. (Len(aPlanComp) > 0),PcoR211(aOrigem,aPlanComp,aVersoes[1],aVersoes[2]),"") }, STR0026, STR0027 } )    //"Impressao Diferencas"###"Imprimir"

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {||oDlg:End()} ,{||oDlg:End()},,aButtons)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pco120TreeEDT³ Autor ³ Paulo Carnelossi      ³ Data ³ 03/01/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que monta o Tree do Planilha por Conta Orcamentaria       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pco120TreeEDT(cVersao)
Local cCargoPai:= ""
Local aTree    := {}
Local aArea    := GetArea()


cVersao := PadR(cVersao,4)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta um array com a estrutura da versao do projeto informado.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

ProcRegua(AK3->(RecCount()) + AK2->(RecCount()))


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Insere a Planilha Orcamentaria.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCargoPai:= Pad("AK1"+AK1->AK1_FILIAL+AK1->AK1_CODIGO,80)
Aadd(aTree,{"AK1",AK1->AK1_FILIAL+AK1->AK1_CODIGO,AllTrim(AK1->AK1_DESCRI) + "  -- " + STR0028 + cVersao + Space(200),cCargoPai,StrZero(0,50),"N",.F.})  //" Versao: "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica todas as EDT's da versao do projeto.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("AK3")
dbSetOrder(3)
MsSeek(xFilial()+AK1->AK1_CODIGO+cVersao+"001")
While !Eof() .And. AK3->AK3_FILIAL+AK3->AK3_ORCAME+AK3->AK3_VERSAO+AK3->AK3_NIVEL==;
					xFilial("AK3")+AK1->AK1_CODIGO+cVersao+"001"
	Pco120EDTTrf(@aTree,AK3->AK3_ORCAME+AK3->AK3_VERSAO+AK3->AK3_CO,cCargoPai)
	IncProc()
	dbSkip()
End

RestArea(aArea)

Return(aTree)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pco120EDTTrf³ Autor ³ Paulo Carnelossi    ³ Data ³ 03/01/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que monta o a Tarefa no Tree do Planilha Orcamentaria. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSXFUN                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pco120EDTTrf(aTree,cChave,cCargoPai)
Local cCargo    := ""
Local lTipoTree	:= .F.
Local aArea		:= GetArea()
Local aAreaAK3	:= AK3->(GetArea())
Local aAreaAK2	:= AK2->(GetArea())
Local aAuxArea

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica todas as tarefas da versao do projeto.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("AK2")
dbSetOrder(1)
MsSeek(xFilial()+cChave)
While !Eof() .And. AK2->AK2_FILIAL + AK2->AK2_ORCAME + AK2->AK2_VERSAO +;
					AK2->AK2_CO == xFilial("AK2") + cChave
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Insere a EDT no array.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lTipoTree .And. PcoChkUser(AK3->AK3_ORCAME,AK3->AK3_CO,AK3->AK3_PAI,1,"ESTRUT",AK3->AK3_VERSAO)
		cCargo:= Pad("AK3"+AK3->AK3_FILIAL+AK3->AK3_ORCAME+AK3->AK3_CO,80)
		Aadd(aTree,{"AK3",AK3->AK3_FILIAL+AK3->AK3_ORCAME+AK3->AK3_VERSAO+AK3->AK3_CO,AllTrim(AK3->AK3_DESCRI),cCargo,cCargoPai,"N",.F.})
		cCargoPai:= cCargo
		lTipoTree:= .T.
	EndIf

	If PcoChkUser(AK2->AK2_ORCAME,AK2->AK2_CO,AK3->AK3_PAI,1,"ESTRUT",AK2->AK2_VERSAO)
		Pco120AddTrf(@aTree,AK2->AK2_ORCAME+AK2->AK2_VERSAO+AK2->AK2_CO,cCargoPai)
    EndIf
    
	IncProc()
	dbSkip()
End	


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica todas as EDT's filhas da EDT atual.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("AK3")
dbSetOrder(2)
MsSeek(xFilial()+cChave)
While !Eof() .And. AK3->AK3_FILIAL+AK3->AK3_ORCAME+AK3->AK3_VERSAO+AK3->AK3_PAI==;
						xFilial("AK3")+cChave
	aAuxArea	:= GetArea()
	RestArea(aAreaAK3)	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Insere a EDT no array.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lTipoTree .And. PcoChkUser(AK3->AK3_ORCAME,AK3->AK3_CO,AK3->AK3_PAI,1,"ESTRUT",AK3->AK3_VERSAO)
		cCargo:= Pad("AK3"+AK3->AK3_FILIAL+AK3->AK3_ORCAME+AK3->AK3_CO,80)
		Aadd(aTree,{"AK3",AK3->AK3_FILIAL+AK3->AK3_ORCAME+AK3->AK3_VERSAO+AK3->AK3_CO,AllTrim(AK3->AK3_DESCRI),cCargo,cCargoPai,"N",.F.})
		cCargoPai:= cCargo
		lTipoTree:= .T.
	EndIf
	RestArea(aAuxArea)

	Pco120EDTTrf(@aTree,AK3->AK3_ORCAME+AK3->AK3_VERSAO+AK3->AK3_CO,cCargoPai)

	IncProc()
	dbSkip()
EndDo

RestArea(aAreaAK3)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Insere a EDT no array.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lTipoTree .And. PcoChkUser(AK3->AK3_ORCAME,AK3->AK3_CO,AK3->AK3_PAI,1,"ESTRUT",AK3->AK3_VERSAO)
	cCargo:= Pad("AK3"+AK3->AK3_FILIAL+AK3->AK3_ORCAME+AK3->AK3_CO,80)
	Aadd(aTree,{"AK3",AK3->AK3_FILIAL+AK3->AK3_ORCAME+AK3->AK3_VERSAO+AK3->AK3_CO,AllTrim(AK3->AK3_DESCRI),cCargo,cCargoPai,"N",.F.})
EndIf

RestArea(aAreaAK2)
RestArea(aAreaAK3)
RestArea(aArea)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pco120AddTrf³ Autor ³ Paulo Carnelossi    ³ Data ³ 03/01/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que monta os itens da conta orcamentaria Tree Planilha.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSXFUN                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pco120AddTrf(aTree,cChave,cCargoPai)

Local aArea		:= GetArea()
Local aAreaAK2	:= AK2->(GetArea())
Local aAreaAK3	:= AK3->(GetArea())
Local lTipoTree	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Insere a tarefa no array. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lTipoTree .And. PcoChkUser(AK2->AK2_ORCAMET,AK2->AK2_CO,AK3->AK3_PAI,1,"ESTRUT",AK2->AK2_VERSAO)
	cCargo:= Pad("AK2"+AK2->(AK2_FILIAL+AK2_ORCAME+AK2_CO+DTOS(AK2_PERIOD)+AK2_ID),80)
	Aadd(aTree,{"AK2",AK2->(AK2_FILIAL+AK2_ORCAME+AK2_VERSAO+AK2_CO+DTOS(AK2_PERIOD)+AK2_ID),;
					AllTrim(DtoC(AK2->AK2_PERIOD)+"- "+STR0046+AK2->AK2_ID+"-"+AK2->AK2_DESCRI),;	// Item:
					cCargo,cCargoPai,"N",.F.})
EndIf

RestArea(aAreaAK2)
RestArea(aAreaAK3)
RestArea(aArea)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pco120_Compara ³ Autor ³Paulo Carnelossi     ³ Data ³ 03/01/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Compara as versoes do Planilha em forma de array.    		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico         	                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pco120_Compara(aOrigem,aDestino)
Local aArea    := GetArea()
Local aPlanComp:= {}
Local nItem    := 0
Local nPos     := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza a comparacao de todos os itens das versoes do projeto³
//³e informa se existem modificacoes ou nao.                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Analisa a estrutura da versao base.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nItem:= 1 To Len(aOrigem)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existe o item no projeto a ser comparado.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPos:= Ascan(aDestino,{|x| x[4] == aOrigem[nItem,4]})
	If (nPos > 0)
		If Pco120Check(aOrigem[nItem,1],aOrigem[nItem,2],aDestino[nPos,2])
			Aadd(aPlanComp,{aDestino[nPos,1],aDestino[nPos,2],aDestino[nPos,3],;
							aDestino[nPos,4],aDestino[nPos,5],aDestino[nPos,6],aDestino[nPos,7]})
		Else
			Aadd(aPlanComp,{aDestino[nPos,1],aDestino[nPos,2],aDestino[nPos,3] +  STR0029,; //" - MODIFICADO"
							aDestino[nPos,4],aDestino[nPos,5],"M",aDestino[nPos,7]})
		EndIf
	Else         
		Aadd(aPlanComp,{aOrigem[nItem,1],aOrigem[nItem,2],aOrigem[nItem,3] + STR0030,; //" - EXCLUIDO"
						aOrigem[nItem,4],aOrigem[nItem,5],"E",aOrigem[nItem,7]})
	EndIf
																	
Next nItem


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Analisa a existencia de novos itens na estrutura.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nItem:= 1 To Len(aDestino)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existe o item no projeto a ser comparado.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPos:= Ascan(aOrigem,{|x| x[4] == aDestino[nItem,4]})
	If (nPos == 0)
		Aadd(aPlanComp,{aDestino[nItem,1],AllTrim(aDestino[nItem,2]),aDestino[nItem,3] + STR0031,;  //" - INCLUIDO"
						aDestino[nItem,4],aDestino[nItem,5],"I",aDestino[nItem,7]})
	EndIf
																	

Next nItem

RestArea(aArea)

Return(aPlanComp)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pco120Check  ³ Autor ³Fabio Rogerio Pereira  ³ Data ³ 27/12/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica os dados das versoes do Projeto.	    			   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico         	                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pco120Check(cAlias,cOrigem,cDestino)
Local lRet  := .T.
Local aStrut:= {}
Local aDados:= {}
Local nCampo:= 0


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Analisa cada item das versoes do projeto para identificar as alteracoes.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAlias)
dbSetOrder(1)
If dbSeek(cOrigem,.T.)
	aStrut:= &(cAlias + "->(dbStruct())")
	aDados:= Array(1,Len(aStrut))

	AEval(aStrut,{|cValue,nIndex| aDados[1,nIndex]:= {aStrut[nIndex,1],FieldGet(FieldPos(aStrut[nIndex,1]))}})
	
	If dbSeek(cDestino,.T.)
		For	nCampo:= 1 To Len(aDados[1])	
			If !("VERSAO" $ aDados[1,nCampo,1]) .And. (aDados[1,nCampo,2] <> FieldGet(nCampo))
				lRet:= .F.
				Exit
			EndIf
		Next
	EndIf
EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoA120Inf³ Autor ³Fabio Rogerio Pereira  ³ Data ³ 02-01-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta uma tela de informacao sobre a fase do projeto.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoA120Inf()
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


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria tela com os bitmaps utilizados no tree para correta identificacao.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DEFINE MSDIALOG oDlg TITLE STR0009 OF oMainWnd PIXEL FROM 0,0 TO 250,550 //"Legenda"

@ 2,2 TO 110,275 LABEL STR0009 PIXEL  //"Legenda"

@ 8,10 BITMAP oBmp1 RESNAME "EXCLUIR" SIZE 16,16 NOBORDER PIXEL
@ 8,23 SAY STR0032 OF oDlg PIXEL   //"CO Excluida"

@ 20,10 BITMAP oBmp2 RESNAME "NOTE" SIZE 16,16 NOBORDER PIXEL
@ 20,23 SAY STR0033 OF oDlg PIXEL  //"CO Modificada"

@ 32,10 BITMAP oBmp3 RESNAME "BMPINCLUIR" SIZE 16,16 NOBORDER PIXEL
@ 32,23 SAY STR0034 OF oDlg PIXEL  //"CO Incluida"

@ 44,10 BITMAP oBmp4 RESNAME "MDIVISIO" SIZE 16,16 NOBORDER PIXEL
@ 44,23 SAY STR0035 OF oDlg PIXEL //"CO Nao Alterada"

@ 8,150 BITMAP oBmp9 RESNAME "EXCLUIR" SIZE 16,16 NOBORDER PIXEL
@ 8,163 SAY STR0036 OF oDlg PIXEL //"Item CO Excluido"

@ 20,150 BITMAP oBmp10 RESNAME "NOTE" SIZE 16,16 NOBORDER PIXEL
@ 20,163 SAY STR0037 OF oDlg PIXEL //"Item CO Modificada"

@ 32,150 BITMAP oBmp11 RESNAME "BMPINCLUIR" SIZE 16,16 NOBORDER PIXEL
@ 32,163 SAY STR0038 OF oDlg PIXEL  //"Item CO Incluido"

@ 44,150 BITMAP oBmp12 RESNAME "MDIVISIO" SIZE 16,16 NOBORDER PIXEL
@ 44,163 SAY STR0039 OF oDlg PIXEL //"Item CO Nao Alterado"

@ 115,230 BUTTON STR0021 SIZE 40 ,9   FONT oDlg:oFont ACTION {||oDlg:End()}  OF oDlg PIXEL //"Fechar"

ACTIVATE MSDIALOG oDlg CENTERED

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoA120Nav³ Autor ³Paulo Carnelossi       ³ Data ³ 03-01-2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Posiciona nas diferencas entre as versoes.       				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoA120Nav(nTipo,aPlanComp,oTree,oTree2)
Local cCargoAtu:= oTree2:GetCargo()
Local nStep    := IIf(nTipo == 1,1,-1)
Local nPos     := Ascan(aPlanComp,{|x| x[4] == cCargoAtu})


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona o tree nas diferencas entre as versoes do projeto.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nPos:= IIf(nPos == 0,1,nPos+nStep) TO IIf(nTipo == 1,Len(aPlanComp),1) STEP nStep
	If aPlanComp[nPos,6] <> "N"
		oTree:TreeSeek(aPlanComp[nPos,4])
		oTree2:TreeSeek(aPlanComp[nPos,4])

		oTree:Refresh()
		oTree2:Refresh()
		
		Exit
	EndIf	
Next nPos

If (nTipo == 1) .And. (nPos > Len(aPlanComp))
	oTree2:SetFocus()
	Aviso(STR0019,STR0040,{STR0021},2) //"Atencao"###"Proxima diferenca nao encontrada"###"Fechar"
ElseIf (nTipo == 2) .And. (nPos < 1)
	oTree2:SetFocus()
	Aviso(STR0019,STR0041,{STR0021},2) //"Atencao"###"Diferenca anterior nao encontrada"###"Fechar"
EndIf

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoA120VisDet³ Autor ³Paulo Carnelossi    ³ Data ³ 03/01/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Visualiza as contas orcamentarias ou itens.       		    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoA120VisDet(oTree,aTree)
Local cCargo:= oTree:GetCargo()
Local aArea := GetArea()       
Local nPos  := Ascan(aTree,{|x| x[4] == cCargo})
Local cAlias:= aTree[nPos,1]
Local cSeek := aTree[nPos,2]

Local aCamposAK2 := {}

Local aObjects := {}
Local aPosObj  := {}
Local aSize    := MsAdvSize(.T.)
Local oDlg, oEnch, nX

AADD(aObjects,{100,020,.T.,.F.,.F.})
aInfo  := { aSize[1],aSize[2],aSize[3],aSize[4],3,3 } 
aPosObj:= MsObjSize( aInfo, aObjects, .T.,.F. )  

dbSelectArea(cAlias)
dbSetOrder(1)
dbSeek(cSeek)

If (cAlias == "AK3")
	PCOA101(2,,"000")

ElseIf (cAlias == "AK2")

		//monta array aCamposAK2
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Montagem do aHeader do AK2                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("AK2")
		While !EOF() .And. (x3_arquivo == "AK2")
			If (X3USO(X3_USADO) .AND. cNivel >= X3_NIVEL .AND.;
				 (! TRIM(SX3->X3_CAMPO) $ "_FILIAL" );
					.AND. X3_CONTEXT != "V" .AND. X3_TIPO != "M")

				AADD(aCamposAK2,SX3->X3_CAMPO)

			EndIf
			
			dbSkip()
			
		End
		aAdd(aCamposAK2, "AK2_VALOR")
		aAdd(aCamposAK2, "AK2_DATAI")
		aAdd(aCamposAK2, "AK2_DATAF")
		
        dbSelectArea("AK2")

		For nX := 1 TO AK2->(FCOUNT())
			cAux := AK2->(FieldName(nX))
			&("M->"+cAux) := AK2->(FieldGet(nX))
		Next

		DEFINE MSDIALOG oDlg TITLE STR0012 OF oMainWnd PIXEL FROM aSize[7],0 TO aSize[6],aSize[5] //"Visualizacao do Item Orcamentario"
	
		oEnch := MsMGet():New("AK2",AK2->(RecNo()),2,,,,aCamposAK2,{aSize[1],aSize[2],aSize[3],aSize[4]},,3,,,,oDlg,,.T.,)
		oEnch:oBox:Align := CONTROL_ALIGN_TOP
		
		ACTIVATE MSDIALOG oDlg On Init EnchoiceBar(oDlg,{|| oDlg:End()},{|| oDlg:End()},,)
EndIf	

RestArea(aArea)
Return(.T.)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pco120MontaTree³ Autor ³Paulo Carnelossi       ³ Data ³ 03/01/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria o tree a partir do array.				    			     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico         	                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pco120MontaTree(oTree,aTree)
Local nItem := 0
Local cRes  := ""
Local cTipo := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta um tree a partir do array com a estrutura informados.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

ProcRegua(Len(aTree))

oTree:Reset()
oTree:BeginUpdate()	

For nItem:= 1 To Len(aTree)
	cTipo:= aTree[nItem,6]
    
	Do Case
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica os bitmaps do Projeto e EDT.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case (aTree[nItem,1] $ "AK1AK3")
			If (cTipo == "N")
				cRes:= "MDIVISIO"
			ElseIf (cTipo == "I")
				cRes:= "BMPINCLUIR"
			ElseIf (cTipo == "E")
				cRes:= "EXCLUIR"
			Else
				cRes:= "NOTE"
			EndIf
    

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica os bitmaps da Tarefa.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    	Case (aTree[nItem,1] == "AK2")
			If (cTipo == "N")
				cRes:= "MDIVISIO"
			ElseIf (cTipo == "I")
				cRes:= "BMPINCLUIR"
			ElseIf (cTipo == "E")
				cRes:= "EXCLUIR"
			Else
				cRes:= "NOTE"
			EndIf
	

	    OtherWise
	     
			If (cTipo == "N")
				 cRes:= "PMSMATE"
			ElseIf (cTipo == "I")
				cRes:= "CHECKED"
			ElseIf (cTipo == "E")
				cRes:= "NOCHECKED"
			Else
				cRes:= "SDUPROP"
			EndIf
	     
	EndCase 
	     
	oTree:TreeSeek(aTree[nItem,5])
	oTree:AddItem(aTree[nItem,3],aTree[nItem,4],cRes,cRes,,,2)

	IncProc()
Next

DBENDTREE oTree
oTree:TreeSeek(aTree[1,4])
oTree:EndUpdate()
oTree:Refresh()

Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pco120CtrMenu³ Autor ³Paulo Carnelossi      ³ Data ³ 03/01/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que controla as propriedades do Menu PopUp.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA210                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pco120CtrMenu(nTree,oMenu,oTree)
Local cAlias	:= SubStr(oTree:GetCargo(),1,3)

If (cAlias $ "AK3AK2")
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

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pco120Item   | Autor ³Paulo Carnelossi      ³ Data ³ 03/01/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que exibe os dados a serem comparados.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA210                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pco120Item(oTree,oTree2,aOrigem,aProjComp,cVersao1,cVersao2)
Local aDados   := {}
Local nPosComp := 0
Local nPosOrig := 0
Local cAlias   := ""
Local cSeekComp:= ""
Local cSeekOrig:= ""
Local nTamIni := 0
Local nTamChv := 0

Aadd(aDados,{"",{STR0042  + cVersao1,CLR_BLACK},{STR0042  + cVersao2,CLR_BLACK}}) //"Versao: "###"Versao: "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica as informacoes do item que se deseja comparar.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosComp := Ascan(aProjComp,{|x| x[4] == oTree2:GetCargo()})
If (nPosComp > 0)
	cAlias   := aProjComp[nPosComp,1]
	cSeekComp:= aProjComp[nPosComp,2]
	oTree:TreeSeek(aProjComp[nPosComp,4])

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciona e armazena os dados do item a ser comparado.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cAlias)
	dbSetOrder(1)
	If dbSeek(cSeekComp)
		aStrut:= Pco120Strut(cAlias)
	
		If aProjComp[nPosComp,6] == "E" 
			If Alltrim(cAlias) == "AK3"
				nTamIni:= TamSx3("AK3_FILIAL")[1] + TamSx3("AK3_ORCAME")[1]
				cSeekComp:=SubStr(aProjComp[nPosComp,2],1,nTamIni)
				cSeekComp+=Padr(cVersao2,TamSx3("AK3_VERSAO")[1])
				nTamChv:=Len(aProjComp[nPosComp,2]) - Len(cSeekComp)
				cSeekComp+=SubStr(aProjComp[nPosComp,2],(nTamIni+Len(cVersao2)+1),nTamChv)
			ElseIf Alltrim(cAlias) == "AK2"
				nTamIni:= TamSx3("AK2_FILIAL")[1] + TamSx3("AK2_ORCAME")[1]
				cSeekComp:=SubStr(aProjComp[nPosComp,2],1,nTamIni)
				cSeekComp+=Padr(cVersao2,TamSx3("AK2_VERSAO")[1])
				nTamChv:=Len(aProjComp[nPosComp,2]) - Len(cSeekComp)
				cSeekComp+=SubStr(aProjComp[nPosComp,2],(nTamIni+Len(cVersao2)+1),nTamChv)
			EndIf
			dbSeek(cSeekComp)
		EndIf
	
		AEval(aStrut,{|cValue,nIndex| Aadd(aDados,{ aStrut[nIndex,1],;
													{"",CLR_BLACK}	 ,;	
													{Transform(FieldGet(FieldPos(aStrut[nIndex,2])),If (Empty(aStrut[nIndex,3]),"@!",aStrut[nIndex,3])),CLR_BLACK}})})													
		If aProjComp[nPosComp,6] == "E" .And. 		Alltrim(cAlias) == "AK2"
			aDados[12,3,1] := "" 
		EndIf								
												
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica os dados dos itens a serem comparados.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosOrig:= Ascan(aOrigem,{|x| x[4] == oTree2:GetCargo()})
If (nPosOrig > 0)
	cAlias   := aOrigem[nPosOrig,1]
	cSeekOrig:= aOrigem[nPosOrig,2]
	oTree2:TreeSeek(aOrigem[nPosOrig,4])

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciona e armazena os dados do item comparado.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If dbSeek(cSeekOrig)
		AEval(aStrut,{|cValue,nIndex| (aDados[nIndex+1,2,1]:= Transform(FieldGet(FieldPos(aStrut[nIndex,2])),If (Empty(aStrut[nIndex,3]),"@!",aStrut[nIndex,3]))),;
									   (aDados[nIndex+1,2,2]:= aDados[nIndex+1,3,2]:=If(aDados[nIndex+1,2,1] == aDados[nIndex+1,3,1],CLR_BLACK,CLR_RED)) })
	EndIf       	
EndIf

PmsDispBox(aDados,3,"",{40,120,120},,3,,RGB(250,250,250))

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pco120Strut  | Autor ³Paulo Carnelossi      ³ Data ³ 03/01/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que retorna a estrutura do alias selecionado.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA210                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pco120Strut(cAlias)
Local aArea:= GetArea()
Local aRet := {}
Local bCondic

If cAlias == "AK2"
	bCondic := {||(X3USO(X3_USADO) .AND. cNivel >= X3_NIVEL .AND. (! TRIM(SX3->X3_CAMPO) $ "_FILIAL" );
		.AND. X3_CONTEXT != "V" .AND. X3_TIPO != "M").OR.;
		TRIM(SX3->X3_CAMPO) == "AK2_VALOR" .OR. ;
		TRIM(SX3->X3_CAMPO) == "AK2_DATAI" .OR. ;
		TRIM(SX3->X3_CAMPO) == "AK2_DATAF" }
Else
	bCondic := {||X3USO(X3_USADO) .AND. cNivel >= X3_NIVEL .AND. (! TRIM(SX3->X3_CAMPO) $ "_FILIAL" );
		.AND. X3_CONTEXT != "V" .AND. X3_TIPO != "M"}
EndIf		

DbSelectArea("SX3")
DbSetOrder(1)
MsSeek(cAlias)
While !EOF() .AND. (X3_ARQUIVO == cAlias)
	
	If Eval(bCondic)
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


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PCO120Leg ³ Autor ³ Paulo Carnelossi     ³ Data ³03/01/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Legenda de status das planilhas orcamentarias              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PCO120Leg                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ AP                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PCO120Leg(cAlias)
Local aLegenda := 	{ 	{"BR_VERDE"   , STR0003 },; //"Planilha Livre para Revisao"
						{"BR_AMARELO", STR0002 }} //"Planilha em Revisao"
Local aRet := {}
aRet := {}

If cAlias == Nil
	Aadd(aRet, { 'AK1_STATUS != "2"', aLegenda[1][1] } )
	Aadd(aRet, { 'AK1_STATUS == "2"', aLegenda[2][1] } )
Else
	BrwLegenda(cCadastro,STR0009, aLegenda) //"Legenda"
Endif

Return aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Pco120RevFin ºAutor ³Paulo Carnelossi   º Data ³  27/07/05  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Finaliza revisao de forma automatica passando os parametros º±±
±±º          ³codigo do orcamento e texto finalizacao revisao             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pco120RevFin(cOrcame, cTexto)
Local lRet := .F.
Local aArea := GetArea()
Local aAreaAK1 := AK1->(GetArea())
Local lPCO120GRV := ExistBlock("PCO120GRV")
DEFAULT cOrcame := AK1->AK1_CODIGO
DEFAULT cTexto  := ""

dbSelectArea("AK1")
dbSetOrder(1)
lRet := dbSeek(xFilial("AK1")+cOrcame)
If lRet 
	lRet := Pco120Frv("AK1",AK1->(Recno()),4,NIL,NIL,.T.,cTexto)
EndIf

If lPCO120GRV .And. lRet
	ExecBlock("PCO120GRV",.F.,.F.)
Endif

RestArea(aAreaAK1)
RestArea(aArea)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³12/12/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Local aRotina 	:= {	{ STR0004,"AxPesqui" , 0 , 1, ,.F.},;    //"Pesquisar"
							{ STR0005,"Pco120Hst", 0 , 2},;    //"Historico"
							{ STR0006,"Pco120IRv", 0 , 4, 1},; //"Iniciar Revisao"
							{ STR0013,"Pco120FRv", 0 , 4, 1},; //"Finalizar Revisao"
							{ STR0007,"Pco120CMP", 0 , 5, 1},; //"Comparar"
							{ STR0008,"Pco120Rev", 0 , 4, 1},; //"Revisar"
							{ STR0009,"Pco120Leg", 0 , 2, ,.F.}} //"Legenda"

If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiciona botoes do usuario no Browse                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock( "PCOA1201" )
		//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//P_E³ Ponto de entrada utilizado para inclusao de funcoes de usuarios no     ³
		//P_E³ browse da tela de orcamentos                                           ³
		//P_E³ Parametros : Nenhum                                                    ³
		//P_E³ Retorno    : Array contendo as rotinas a serem adicionados na enchoice ³
		//P_E³               Ex. :  User Function PCOA1201                            ³
		//P_E³                      Return {{"Titulo", {|| U_Teste() } }}             ³
		//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ValType( aUsRotina := ExecBlock( "PCOA1201", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf
EndIf
Return(aRotina)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PcoFinRev ºAutor  ³Microsiga           º Data ³  19/06/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Modo otimizado de finalizacao da Revisao                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PcoFinRev()
Local lRet 		:= .F.
Local lAtSld 	:= .T.
Pergunte("PCO120",.F.)
lAtSld 	:= ( mv_par01 == 1 )
/*
If Aviso(STR0047,STR0048+CRLF+;  //"Atencao", "Atualizacao Saldos dos cubos "
					STR0049+CRLF+; // "Caso nao atualize, os cubos deverao ser reprocessados ao termino."
					STR0050, {STR0051, STR0052},3) == 2  //"Prossegue atualizando saldos dos Cubos ? ", "Sim", "Nao"
	lAtSld 	:= .F.
EndIf
	*/
Processa( {|| lRet := PCOA123( AK1->AK1_CODIGO, AK1->AK1_VERSAO,  M->AKE_REVISA,  .F., .T., lAtSld, AK1->( Recno() ) )} )
//-----------------------------codigo planilha,----versao atual,versao revisada,lSimu,lRevisa,lAtSld

If !lRet
	ConoutR(STR0053)  //"Revisao da Planilha com erros. Verifique!"
EndIf

Return(lRet)


Static Function A120Perg()
Pergunte("PCO120", .T.)
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} PCOA120
Função de criação do Menu PopUp de opções da comparação de revisões de planilhas orçamentárias

@author marylly.araujo
@since 16/07/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function PCOFpopM1(nLeft,nTop,oTree,aOrigem,oMenu)
MENU oMenu POPUP
	MENUITEM STR0011 ACTION PcoA120VisDet(@oTree,aOrigem)  //"Visualizar"
ENDMENU

ACTIVATE POPUP oMenu AT nLeft, nTop

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PCOA120
Função de criação do Menu PopUp de opções da comparação de revisões de planilhas orçamentárias

@author marylly.araujo
@since 16/07/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function PCOFpopM2(nLeft,nTop,oTree,oTree2,aOrigem,aPlanComp,aVersoes,oMenu)
MENU oMenu POPUP
	MENUITEM STR0011 ACTION PcoA120VisDet(@oTree2,aPlanComp) //"Visualizar"
	MENUITEM STR0007 ACTION Pco120Item(oTree,oTree2,aOrigem,aPlanComp,aVersoes[1],aVersoes[2]) //"Comparar"
ENDMENU

ACTIVATE POPUP oMenu AT nLeft, nTop
	
Return
