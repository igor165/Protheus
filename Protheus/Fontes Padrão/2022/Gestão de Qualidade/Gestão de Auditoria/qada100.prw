#include "PROTHEUS.CH"
#include "Folder.ch"        
#Include "Font.ch"
#Include "Colors.ch"     
#Include "QADA100.CH"
 
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QADA100  ³ Autor ³ Paulo Emidio de Barros³ Data ³ 24/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Auditorias												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQAD                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Robson Ramir³14/05/02³ Meta ³Alteracao do alias da familia QU para QA  ³±±
±±³Robson Ramir³16/05/02³ Meta ³Alteracao da estrutura da tela para padrao³±±
±±³            ³        ³      ³enchoice e melhorias                      ³±±
±±³            ³        ³      ³Adaptacao das alteracoes feitas na J&J    ³±±
±±³            ³        ³      ³Alteracao de campo carac. para memo       ³±±
±±³Eduardo S.  ³14/10/02³------³Alterado para apresentar 4 fases de status³±±
±±³Eduardo S.  ³15/10/02³------³Alteracao no lay-out dos emails.          ³±±
±±³Eduardo S.  ³16/10/02³------³Acerto na inclusao para verificar se ja   ³±±
±±³            ³        ³      ³existe o numero da auditoria na gravacao. ³±±
±±³Eduardo S.  ³28/11/02³------³Alterado para gravar os check-lists / to- ³±±
±±³            ³        ³      ³picos auditados por Area Auditada.        ³±±
±±³Eduardo S.  ³28/11/02³------³Alterado para permitir somente o acesso de³±±
±±³            ³        ³      ³Auditores envolvidos na Auditoria.        ³±±
±±³Eduardo S.  ³10/01/03³------³Alterado para permitir pesquisar usuarios ³±±
±±³            ³        ³      ³ entre filiais na consulta padrao.        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function MenuDef()

Local aRotina := {{ STR0001, "AxPesqui"  , 0, 1,,.F.},;      //"Pesquisar"
                  { STR0002, "Qad100Man",  0, 2 },;   		 //"Visualizar"
                  { STR0003, "Qad100Man" , 0, 3 },;   		 //"Incluir"
                  { STR0004, "Qad100Man" , 0, 4 },; 		 //"Alterar"
                  { STR0005, "Qad100Man" , 0, 5 },; 		 //"Excluir"
                  { STR0006, "Qad100Leg" , 0, 5,,.F.}}    	 //"Legenda"

Return aRotina

Function QADA100()
Local aCores := {}
Local i := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := OemtoAnsi(STR0007) //"Auditorias"
PRIVATE cFilMat   := cFilAnt
Private lPEQ100Leg := ExistBlock("Q100LEG")
Private aLegenda := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aRotina := MenuDef()

//Avisa o cliente sobre as atualizações que serão realizadas no SIGAQAD.
//QAvisoQad()

If lPEQ100Leg
	aLegenda := ExecBlock("Q100LEG")
EndIf

If !lPEQ100Leg
	aCores:=	{{'QUB->QUB_STATUS == "1"','ENABLE'    },;
				 { 'QUB->QUB_STATUS == "2"','BR_AMARELO'},;
				 { 'QUB->QUB_STATUS == "3"','BR_PRETO'  },;
				 { 'QUB->QUB_STATUS == "4"','DISABLE'   }}
Else
   For i := 1 to Len(aLegenda)
   		Aadd(aCores,{aLegenda[i][3],aLegenda[i][1]})
   Next
EndIf

mBrowse( 6, 1,22,75,"QUB",,,,,,aCores)

Return(NIL)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Qad100Man ³ Autor ³ Paulo Emidio de Barros³ Data ³24/10/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao do a Amarracao Auditoria x Auditores		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: Alias posicionado                                   ³±±
±±³          ³ ExpN1: Numero do registro posicionado                      ³±±
±±³          ³ ExpN2: Opcao do menu selecionada                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Qad100Man(cAlias,nReg,nOpc)

Local nOpca   	:= 0
Local oDlg		:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis utilizadas na montagem do Folder					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aTitulos := {}
Local aPaginas := {}
Local nControl := 0
Local nX                 
Local bSendMail
Local aCpos    
Local nOpcGD
Local aUsrMat	:= QA_USUARIO()
Local cMatFil	:= aUsrMat[2]
Local cMatCod	:= aUsrMat[3]
Local lSoLider	:= Empty(QUB->QUB_ENCREA) .And. GetMv("MV_AUDSLID", .F., .F.)
Local aButtons  := {}
Local aHeaReu   := {}
Local aColReu   := {}
Local aRet		:= {}
Local oPanel
Local oStruQUB

Private aMsSize		:= MsAdvSize()
Private aObjects  := {{ 100, 100, .T., .T., .T. }}
Private aInfo		:= { aMsSize[ 1 ], aMsSize[ 2 ], aMsSize[ 3 ], aMsSize[ 4 ], 4, 4 } 
Private aPosObj	:= MsObjSize( aInfo, aObjects, .T. , .T. )

Private nSaveSX8	:= GetSX8Len()
Private nQAConpad:= 1

If nOpc == 3 .Or.nOpc ==4
	nOpcGD := GD_UPDATE+GD_INSERT+GD_DELETE
Else
	nOpcGD := 0
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para tratamento dos dados da enchoice				   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aGets := {}
Private aTela := {}

RegToMemory("QUB",(nOpc == 3))       

Private lEditEnc := .F. //Indica que o Campo Encerramento nao sera editado na inclusao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Objetos de Retorno da Getdados								 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private oGetArea 
Private oGetAudit 
Private oGetCheck
Private oGetMail 
Private oFolder

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define as variaveis utilizadas na selecao das questoes                                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private oButtQst
Private aDadosQst := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define as posicoes a salvas no aCols 						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nPosFilAud //Codigo Auditoria 
Private nPosCodAud //Codigo Auditoria 
Private nPosMaiQUC //Email

Private nPosNumAud
Private nPosNumSeq
Private nPosChkAud //Check List 
Private nPosChkRev //Revisao Check List 
Private nPosNivRes //Nivel do Resultado 
Private nPosEfeChk //Efetivacao do Check List associado 
Private nPosDesChk //Descricao do CheckList
Private nPosAli    //Alias
Private nPosRec    //Recno

Private nPosSeq    //Sequencia da Area auditada 
Private nPosFilRes //Filial do Auditor
Private nPosDesAud //Destino da Auditoria 
Private nPosEfeAud //Efetivacao da area auditada 
Private nPosMaiQUH //Email 

Private nPosUseNam //Nome do Usuario 
Private nPosMaiQUI //Email
Private oGetEAud   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o Usuario Logado eh auditor nesta Auditoria.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc > 3 .Or. (nOpc = 2 .And. Empty(QUB->QUB_ENCREA))
	If !QADCkAudit(QUB->QUB_NUMAUD,, lSolider)
		Return(NIL)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a Auditoria esta encerrada						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 4 .Or. nOpc == 5
	If !QADvAudEnc(QUB->QUB_NUMAUD)
		Return(NIL)
	EndIf			
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica os campos que serao editados na Enchoice			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCpos := {}
oStruQUB := FWFormStruct(3, "QUB")

For nX := 1 to Len(oStruQUB[3])
	If !AllTrim(oStruQUB[3][nX][1]) $ "QUB_CONCLU/QUB_DESCR1/QUB_ENCREA/QUB_SUGOBS/QUB_DESCHV/QUB_OK/QUB_CHAVE/QUB_SUGCHV/QUB_STATUS"
		aAdd(aCpos, oStruQUB[3][nX][1])
	EndIf
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada para permitir que o usuário manipule os campos que    ³
//³ serão apresentados na tela de auditoria.                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                       

If ExistBlock("QD100Cpo")
 	aRet := ExecBlock("QD100Cpo",.F.,.F.,{aCpos})
 	If ValType(aRet) == "A"
 	   aCpos := AClone(aRet)
 	EndIf   
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o Check List Padrao									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Q100ChkPad()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os vetores com as opcoes no Folder					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aTitulos,OemToAnsi(STR0012))//"Descricao"
Aadd(aPaginas,"DESCRICAO")
nControl++
Aadd(aTitulos,OemToAnsi(STR0013))//"Areas Auditadas"
Aadd(aPaginas,"AREAS AUDITADAS")
nControl++                                         
Aadd(aTitulos,OemToAnsi(STR0014))//"Equipe de Apoio"
Aadd(aPaginas,"AUDITORES")
nControl++
Aadd(aTitulos,OemToAnsi(STR0016))//"e-mail"
Aadd(aPaginas,"E-MAIL") 
nControl++

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a integridade 										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QUB")
dbSetOrder(1)      

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis para edicao do dados				         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aHeader := {}
Private aCols   := {}
Private nUsado  := 0                       
Private N       := 1

Private nAreaAtu := 1 //posicao da Area Atual

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis para salvar as posicoes do aCols e aHeader	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aHeadSav  := Afill(Array(5),NIL)
Private aDadosAud := Afill(Array(5),NIL)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Armazena os registros a serem manipulados					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aFiles   := {}

Aadd(aFiles,"QUH") 
Aadd(aFiles,"QUC")
Aadd(aFiles,"QUI")       

If aMsSize[5] > 1200    //garante montar o folder em resoluções maior que 1200
   aMsSize[5] := 1200
Endif

DEFINE MSDIALOG oDlg FROM aMsSize[7],000 TO aMsSize[6],iif(SetMDIChild(),aMsSize[5]-200,aMsSize[5]) TITLE cCadastro OF oMainWnd Pixel

IF aMsSize[4] <= 206 //800x600
	oGetEAud:=MsMGet():New("QUB",nReg,nOpc,,,,aCpos,{034,003,IF(aMsSize[4]<=206,100,140),344},aCpos,,,,,oDlg)
Else
	oGetEAud:=MsMGet():New("QUB",nReg,nOpc,,,,aCpos,{024,003,IF(aMsSize[4]<=206,100,140),344},aCpos,,,,,oDlg)
Endif

oGetEAud:oBox:Align := CONTROL_ALIGN_TOP

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem do Folder											 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oFolder := TFolder():New(07.8,.2,aTitulos, aPaginas,oDlg,,,, .F., .F.,342,112)
oFolder:Align := CONTROL_ALIGN_ALLCLIENT
	
oFolder:aPrompts[1] := OemToAnsi(STR0012) //"Descricao"
oFolder:aPrompts[2] := OemToAnsi(STR0013) //"Areas Auditadas" 
oFolder:aPrompts[3] := OemToAnsi(STR0014) //"Equipe de Apoio"
oFolder:aPrompts[4] := OemToAnsi(STR0016) //"e-mail"

oFolder:SetOption(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ (FOLDER 04) emails associados a auditoria					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                 


RegToMemory("QUI",(nOpc == 3))
Q100FilaCols("QUI",nOpc,1,5,@aHeadSav,@aDadosAud)
nUsado       := Len(aHeader)    
nPosUseNam   := Ascan(aHeader,{|x|AllTrim(x[2]) == "QUI_USERNA"})
nPosMaiQUI   := Ascan(aHeader,{|x|Alltrim(x[2]) == "QUI_EMAIL"})
oGetMail     := MsNewGetDados():New(002,02,097,500,nOpcGD,{||Q100MAILOk()},,"+QUI_ITEM",,,9999,,,,oFolder:aDialogs[4],aHeadSav[5],aDadosAud[5])
oGetMail:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ (FOLDER 03) Amarracao Equipe de Apoio x Auditoria	    	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("QUC",(nOpc == 3))
Q100FilaCols("QUC",nOpc,1,4,@aHeadSav,@aDadosAud)
nUsado       := Len(aHeader)
nPosFilAud   := Ascan(aHeader,{|x|AllTrim(x[2]) == "QUC_FILMAT"})
nPosCodAud   := Ascan(aHeader,{|x|AllTrim(x[2]) == "QUC_CODAUD"})
nPosMaiQUC   := Ascan(aHeader,{|x|AllTrim(x[2]) == "QUC_EMAIL" })
oGetAudit    := MsNewGetDados():New(002,02,097,500,nOpcGD,{||Q100AudLOk()},,"+QUC_ITEM",,,9999,,,,oFolder:aDialogs[3],aHeadSav[4],aDadosAud[4])
oGetAudit:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ (FOLDER 02.1) Areas auditadas e auditores					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("QUH",(nOpc == 3)) 
Q100FilaCols("QUH",nOpc,1,2,@aHeadSav,@aDadosAud, If(nOpc == 2 .And. lSoLider .And.;
((cMatFil+cMatCod) != (QUB->QUB_FILMAT+QUB->QUB_AUDLID)), cMatFil+cMatCod, ""))
nUsado       := Len(aHeader)                
nPosSeq      := Ascan(aHeader,{|x|AllTrim(x[2]) == "QUH_SEQ"}) 
nPosDesAud   := Ascan(aHeader,{|x|AllTrim(x[2]) == "QUH_DESTIN"})
nPosEfeAud   := Ascan(aHeader,{|x|AllTrim(x[2]) == "QUH_EFETIV"})
nPosMaiQUH   := Ascan(aHeader,{|x|Alltrim(x[2]) == "QUH_EMAIL"})
nPosFilRes   := Ascan(aHeader,{|x|Alltrim(x[2]) == "QUH_FILMAT"})
nPosAudRes   := Ascan(aHeader,{|x|Alltrim(x[2]) == "QUH_CODAUD"})
oGetArea     := MsNewGetDados():New(002,02,IF(aMsSize[4]<=206,050,070),500,nOpcGD,{||Q100AdtLOk()},,"+QUH_SEQ",,,9999,,,,oFolder:aDialogs[2],aHeadSav[2],aDadosAud[2])
oGetArea:oBrowse:Align := CONTROL_ALIGN_TOP


oGetArea:oBrowse:bChange := {|| nAreaAtu:=oGetArea:oBrowse:nAt,;
If(Len(oGetArea:aCols) > Len(aDadosAud[3]) ,Aadd(aDadosAud[3],Q100FilaCols("QUJ",3,1,3,@aHeadSav,@aDadosAud,,.T.)),;
IF(Len(oGetArea:aCols) < Len(aDadosAud[3]),(Adel(aDadosAud[3],Len(aDadosAud[3])),Asize(aDadosAud[3],nAreaAtu)),Nil)),;
If(Len(oGetArea:aCols) > Len(aDadosQst),    Aadd(aDadosQst,{{{" "," "," "," "," "," "," "," "," "}}} ),;
IF(Len(oGetArea:aCols) < Len(aDadosQst),	(Adel(aDadosQst,Len(aDadosQst)),Asize(aDadosQst,nAreaAtu)),Nil)),;		
oGetCheck:aCols:=aDadosAud[3,nAreaAtu],oGetArea:oBrowse:Refresh(),	oGetCheck:oBrowse:Refresh()}
oGetArea:oBrowse:bGotFocus := { || aDadosAud[3,oGetArea:oBrowse:nAt] := AClone(oGetCheck:aCols)}
oGetArea:oBrowse:bLostFocus := { || aDadosAud[3,oGetArea:oBrowse:nAt] := AClone(oGetCheck:aCols)}

oGetArea:oBrowse:bDelOk := {||Q100DelArea()}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ (FOLDER 02.2) CheckLists associados as Areas Auditadas		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("QUJ",(nOpc == 3))                 
aHeader      := aClone(APBuildHeader("QUJ"))
// Alterações de dicionáio necessáias para que a tela normal e a MVC rodem ao mesmo tempo.
nPosNumAud := Ascan(aHeader,{|x| AllTrim(x[2]) == "QUJ_NUMAUD"})
If nPosNumAud > 0 
	aDel(aHeader, nPosNumAud)
	aSize(aHeader, Len(aHeader)-1)
EndIF

nPosNumSeq := Ascan(aHeader,{|x| AllTrim(x[2]) == "QUJ_SEQ" })
If nPosNumSeq > 0 
	aDel(aHeader, nPosNumSeq)
	aSize(aHeader, Len(aHeader)-1)
EndIf
//-----------------------------
ADHeadRec("QUJ",aHeader)
nUsado       := Len(aHeader)    
nPosChkAud   := Ascan(aHeader,{|x| AllTrim(x[2]) == "QUJ_CHKLST"})
nPosChkRev   := Ascan(aHeader,{|x| AllTrim(x[2]) == "QUJ_REVIS" })
nPosChkItem  := Ascan(aHeader,{|x| AllTrim(x[2]) == "QUJ_CHKITE"})
nPosDesChk   := Ascan(aHeader,{|x| AllTrim(x[2]) == "QUJ_DESCRI"})
nPosNivRes   := Ascan(aHeader,{|x| AllTrim(x[2]) == "QUJ_NIVEL" })
nPosEfeChk   := Ascan(aHeader,{|x| AllTrim(x[2]) == "QUJ_EFETIV"})
nPosAli      := Ascan(aHeader,{|x| AllTrim(x[2]) == "QUJ_ALI_WT"})
nPosRec      := Ascan(aHeader,{|x| AllTrim(x[2]) == "QUJ_REC_WT"})
aHeadSav[3]  := aClone(aHeader)
aDadosAud[3] := aClone(Q100FilChkLst(nOpc))

if !SetMDIChild()
	IF aMsSize[4] <= 206 //800x600
		oGetCheck    := MsNewGetDados():New(047,000,093,395,nOpcGD,{||Q100ChkLOk()},,,,,9999,,,,oFolder:aDialogs[2],aHeadSav[3],aDadosAud[3,nAreaAtu])
	Else
//		oGetCheck    := MsNewGetDados():New(067,000,150,635,nOpcGD,{||Q100ChkLOk()},,,,,9999,,,,oFolder:aDialogs[2],aHeadSav[3],aDadosAud[3,nAreaAtu])
		oGetCheck    := MsNewGetDados():New(067,000,aMsSize[4]-149,aMsSize[3],nOpcGD,{||Q100ChkLOk()},,,,,9999,,,,oFolder:aDialogs[2],aHeadSav[3],aDadosAud[3,nAreaAtu])
	Endif
Else
	oGetCheck    := MsNewGetDados():New(067,000,aMsSize[4]-149,aMsSize[3],nOpcGD,{||Q100ChkLOk()},,,,,9999,,,,oFolder:aDialogs[2],aHeadSav[3],aDadosAud[3,nAreaAtu])	
EndIf 
		
oGetCheck:oBrowse:bDelOk := {||Q100DeChkAs()}

oGetCheck:oBrowse:bGotFocus := { || aDadosAud[3,oGetArea:oBrowse:nAt] := AClone(oGetCheck:aCols),Q100AtuQst() }
// Caso mude o foco valida a linha digitada e se nao for valida volta o foco para o Check-list
oGetCheck:oBrowse:bLostFocus := { || aDadosAud[3,oGetArea:oBrowse:nAt] := AClone(oGetCheck:aCols),If((nOpc==3 .OR. nOpc==4),IF(!Q100ChkLOk(oGetCheck:aCols,oGetCheck:oBrowse:nAt),(oGetCheck:oBrowse:SetFocus(),oGetCheck:oBrowse:Refresh()),""),"")}

IF aMsSize[4] <= 206 //800x600
	@ 00,00 MSPANEL oPanel PROMPT "" SIZE 035,013.5 OF oFolder:aDialogs[2]
	oPanel:Align := CONTROL_ALIGN_BOTTOM	
	@ 02, 02 BUTTON oButtQst Prompt OemToAnsi(STR0062)+chr(13)+chr(10)+OemToAnsi(STR0063) ACTION If(Q100ChkTOk(),QAD100LIST(oGetArea:oBrowse:nAt,oGetCheck:oBrowse:nAt,nOpc,oDlg),NIL) SIZE 60,12 OF oPanel Pixel
Else               
	@ 00,00 MSPANEL oPanel PROMPT "" SIZE 035,020 OF oFolder:aDialogs[2]
	oPanel:Align := CONTROL_ALIGN_BOTTOM
	@ 02, 02 BUTTON oButtQst Prompt OemToAnsi(STR0062)+" "+OemToAnsi(STR0063) ACTION If(Q100ChkTOk(),QAD100LIST(oGetArea:oBrowse:nAt,oGetCheck:oBrowse:nAt,nOpc,oDlg),NIL) SIZE 60,12 OF oPanel Pixel
Endif			

oGetCheck:oBrowse:bChange := { || aDadosAud[3,oGetArea:oBrowse:nAt] := AClone(oGetCheck:aCols),oGetCheck:oBrowse:Refresh(),Q100AtuQst() }

oGetCheck:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ (FOLDER 01) Descricao da Auditoria                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aDadosAud[1] := If(nOpc # 3,MsMM(QUB->QUB_DESCHV,TamSX3("QUB_DESCR1")[1]),'')	

@ 003,002.5 GET oGetDesAud VAR aDadosAud[1] MEMO NO VSCROLL VALID CheckSX3("QUB_DESCR1",aDadosAud[1]); 
	WHEN VisualSX3("QUB","QUB_DESCR1");
	Size 336,94 Of oFolder:aDialogs[1] Pixel 
oGetDesAud:lReadOnly := If(Inclui .Or. Altera,.F.,.T.)	   	         
oGetDesAud:Align := CONTROL_ALIGN_ALLCLIENT

aAdd(aButtons,{"GROUP",{|| IF(!EMPTY(M->QUB_NUMAUD),Q100Reun(nOpc,M->QUB_NUMAUD,@aHeaReu,@aColReu,oDlg),"") } ,OemtoAnsi(STR0055),OemtoAnsi(STR0055) } )  //"Reunião"###"Reunião"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada criado para inclusao de botoes auxiliares na enchoicebar  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("QD100BUT")              
	aButtons := ExecBlock("QD100BUT",.F., .F., {nOpc,aButtons})
EndIf

If (nOpc # 2) 
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||If(Obrigatorio(aGets,aTela) .And.;
 	q100VldGet({oGetArea,oGetAudit,oGetCheck,oGetMail},nOpc,(oFolder:nOption-1),oDlg),;
 	(nOpcA := 1, (aDadosAud[3,oGetArea:oBrowse:nAt] := AClone(oGetCheck:aCols),Q100AtuQst()),oDlg:End()),)},;
 	{||lOk := .F.,nOpcA := 0,oDlg:End()},,aButtons)
Else
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()},,aButtons)
EndIf	  
  
If nOpcA == 1
             
	//Salva o objeto da getdados 	
	aDadosAud[2] := aClone(oGetArea:aCols) //Areas Auditadas
	aDadosAud[4] := aClone(oGetAudit:aCols)//Equipe de Apoio 
	aDadosAud[5] := aClone(oGetMail:aCols) //emails associados

	Begin Transaction
	
	    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Realiza a gravacao dos dados								 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	

		If nOpc == 3 .Or. nOpc == 4  //Inclusao //Alteracao
 
	        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Realiza a gravacao dos dados								 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			QAD100Grav(nOpc)

	        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Realiza a gravacao das Reunioes	e copias das Atas       	 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
			Q100GrREu(M->QUB_NUMAUD,aHeaReu,aColReu)
		
		ElseIf nOpc == 5 //Exclusao                                        
		
    	    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Realiza a exclusao dos dados								 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			Q100DelREu(M->QUB_NUMAUD) 
			Q100DelAud(oDlg)                            						
		EndIf				

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Processa os gatilhos										 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		EvalTrigger()          
				
	End Transaction

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia e-mails aos envolvidos na Auditoria					 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	     
	If nOpc <> 5 .AND. MsgYesNo(STR0017) //"Deseja enviar email agora ? "
	    cMessage  := STR0018 //Enviando e-mail comunicando a programacao da Auditoria."
	    cTitle    := STR0019 //"Envio de e-mail"
		bSendMail := {||Q100SendAud(oDlg,nOpc)}
		MsgRun(cMessage,cTitle,bSendMail)
    EndIf
			
	If ExistBlock( "Q100GAUD" )
		ExecBlock( "Q100GAUD", .f., .f.,{nOpc} )
	Endif
	
ElseIf  nOpc = 3 
	While (GetSX8Len() > nSaveSx8)
		RollBackSx8()
	Enddo	
Endif
                      
//Restaura a Area original
dbSelectArea(cAlias)

Return(nOpca)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QAD100Grav³ Autor ³ Marcelo Iuspa			³ Data ³24/10/00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava os dados referentes a Auditoria					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q100GrvAud(nOpc,cNumAud, cMotAud,cTipAud,dRefAud,dIniAud,; ³±±
±±³          ³	dEncAud,cAudLid,cAudRsp,cDesAud,cCodFor,cLojFor,nIQSFor)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QAD100Grav(nOpc)

Local lRetorno	:= .T.	
Local bCampo	:= { |nCPO| Field(nCPO) }
Local nX
Local nZ   
Local nCont
Local nPos01    := 0
Local nW := 1
Local cStatusQUB := "1"  // Auditoria Iniciada
Local lStatus   := .F.
Local nSemAval  := 0
Local cTxtEvi   := ""
Local cChave    := ""
Local nMin      := 0
Local nMax      := 0
Local nPeso     := 0
Local nPontos   := 0
Local nPesoTotal:= 0
Local nNota     := 0
Local nConAval  := 0
Local lAltern   := .F.
Local lQstZer   := GetMv("MV_QADQZER",.T.,.T.)
Local nPONOBT   := 0
Local lVerEvid  := GetMv("MV_QADEVI",.T.,.F.)
Local nQst      :=1
Local lQUJDel := .T.
Local nJ
Local lBlqEvi	:= .F.    
Local i
Local nI		:= 0
Local aMemUser	:= {}
Local lQA100MEM := Existblock("QA100MEM")
   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Efetua a gravacao do Cabecalho da Auditoria							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 3
	//Inclusao
	RecLock("QUB",.T.)
Else
	//Alteracao
	RecLock("QUB",.F.)
EndIf		

IF Empty(M->QUB_STATUS)
	M->QUB_STATUS := cStatusQUB
Endif

For nCont := 1 To FCount()
	If "_FILIAL"$Field(nCont)
		FieldPut(nCont,xFilial("QUB"))
	Elseif "_ENCREA"$Field(nCont)
		Loop // Nao executa gravacao deste campo
	Else
		FieldPut(nCont,M->&(EVAL(bCampo,nCont)))
	Endif
Next nCont

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava a pontuacao possivel da Auditoria								 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// A GRAVAÇÃO DA PONTUAÇÃO É INFORMADA NO MOMENTO DO RESULTADO, CONSIDERANDO O RESULTADO INFORMADO.
//QUB->QUB_PONPOS := QADSomPon(M->QUB_NUMAUD) //Grava a pontuacao maxima na Auditoria
MsUnLock()
FKCOMMIT()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para adicao de campos memo do usuario       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lQA100MEM
	If ValType (aMemUser := ExecBlock( "QA100MEM", .F., .F. ) ) == "A" 
		For nI := 1 to Len(aMemUser)
			If  (nOpc == 3 .And. !Empty(&("M->"+aMemUser[nI,2]))) .Or. ;
				(nOpc == 4 .And. !Empty(aMemUser[nI,1])) .Or. ;
				(nOpc == 4 .And. !Empty(&("M->"+aMemUser[nI,2])) .And. Empty(aMemUser[nI,1]))
				MSMM(&(aMemUser[nI,1]),,,&("M->"+aMemUser[nI,2]),1,,,"QUB",aMemUser[nI,1])
			EndIf
		Next
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava a Descricao da Auditoria										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsMM(QUB_DESCHV,,,aDadosAud[1],1,,,"QUB","QUB_DESCHV")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua a gravacao dos dados contidos no aColsSav, salvos pela 	     ³
//³ GetDados nos Folders.												 ³
//³ aHeadSav[2]	= aHeader contendo os dados do QUH - Areas auditadas     ³
//³ aHeadSav[3]	= aHeader contendo os dados do QUJ - Check Lists associa-³
//³				  dos a Area Auditada									 ³
//³ aHeadSav[4]	= aHeader contendo os dados do QUC - Amarracao Auditoria ³
//³               x Auditores											 ³
//³ aHeadSav[5]	= aHeader contendo os dados do QUI - e-mails a serem envi³
//³				  ados 													 ³
//³ aDadosAud[2]= aCols contendo os dados do QUH - Areas auditadas		 ³
//³ aDadosAud[3]= aCols contendo os dados do QUJ - Check List,s associa- ³
//³				  dos a Auditoria										 ³
//³ aDadosAud[4]= aCols contendo os dados do QUC - amarracao Auditoria   ³
//³ 			  x Auditores											 ³
//³ aDadosAud[5]= aCols contendo os dados do QUI - e-mails a serem envia-³
//³				  dos													 ³
//| aDadosQst = Array contendo as questoes a serem selecionadas          |
//|            /1-QUD_SEQ                                                |
//|            |2-QUD_CHKLST                                             |
//|            |3-QUD_REVIS                                              |
//|  Colunas-->|4-QUD_CHKITE                                             |
//|            |5-QUD_QSTITE                                             |
//|            |6-QUD_APLICA                                             |
//|            \7-QUD_TIPO                                               |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

For nX := 1 to Len(aDadosAud[2])
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava as Areas auditadas											 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    dbSelectArea("QUH")
    dbSetorder(1)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o registro esta marcado para delecao. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aDadosAud[2,nX,Len(aHeadSav[2])+1] == .F.
	    If QUH->(DbSeek(xFilial("QUH")+M->QUB_NUMAUD+aDadosAud[2,nX,nPosSeq]))
			RecLock("QUH",.F.)             
		Else
			RecLock("QUH",.T.)             
			QUH->QUH_FILIAL := xFilial("QUH")  
			QUH->QUH_NUMAUD := QUB->QUB_NUMAUD
		EndIf	
		For nZ := 1 to Len(aHeadSav[2])
		    If aHeadSav[2,nZ,10] # "V"
				QUH->(FieldPut(FieldPos(AllTrim(aHeadSav[2,nZ,2])),aDadosAud[2,nX,nZ]))	    
		    EndIf
		Next nZ	
		QUH->QUH_EFETIV := "1"
		MsUnLock()
		FKCOMMIT()
	Else
		If QUH->(DbSeek(xFilial("QUH")+M->QUB_NUMAUD+aDadosAud[2,nX,nPosSeq]))
			q100DelChk(QUH->QUH_NUMAUD,"QUH",QUH->QUH_NUMAUD+aDadosAud[2,nX,nPosSeq])
			RecLock("QUH",.F.)
			DbDelete()
			MsUnlock()
			FKCOMMIT()
		EndIf
		lStatus  := .T.
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava os CheckLists associados as Areas Auditadas					 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nZ := 1 to Len(aDadosAud[3,nX])
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o registro esta marcado para delecao. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aDadosAud[3,nX,nZ,Len(aHeadSav[3])+1] == .F. .And. aDadosAud[2,nX,Len(aHeadSav[2])+1] == .F.
			If QUJ->(DbSeek(xFilial("QUJ")+QUH->QUH_NUMAUD+QUH->QUH_SEQ+aDadosAud[3,nX,nZ,nPosChkAud]+aDadosAud[3,nX,nZ,nPosChkRev]+aDadosAud[3,nX,nZ,nPosChkItem]))
				RecLock("QUJ",.F.)
			Else
				RecLock("QUJ",.T.)
			EndIf
			QUJ->QUJ_FILIAL := xFilial("QUJ")
			QUJ->QUJ_NUMAUD := QUH->QUH_NUMAUD
			QUJ->QUJ_SEQ    := QUH->QUH_SEQ
			For nW := 1 to Len(aHeadSav[3])
				If aHeadSav[3,nW,10] # "V"
					QUJ->(FieldPut(FieldPos(AllTrim(aHeadSav[3,nW,2])),aDadosAud[3,nX,nZ,nW]))
				EndIf
			Next nW
			QUJ->QUJ_EFETIV := "1"
			MsUnLock()
			FKCOMMIT()

			If Len(aDadosQst[nX]) > 0  
				If nz <= Len(aDadosQst[nX])
				For nQst:=1 to Len(aDadosQst[nX,nZ])
					IF !Empty(aDadosQst[nX,nZ,nQst,1])
						If !QUD->(DbSeek(xFilial("QUD")+QUJ->QUJ_NUMAUD+aDadosQst[nX,nZ,nQst,1]+aDadosQst[nX,nZ,nQst,2]+aDadosQst[nX,nZ,nQst,3]+aDadosQst[nX,nZ,nQst,4]+aDadosQst[nX,nZ,nQst,5]))
							RecLock("QUD",.T.)
						Else
							RecLock("QUD",.F.)
						Endif
						QUD->QUD_FILIAL := xFilial("QUD")
				   		QUD->QUD_NUMAUD := QUJ->QUJ_NUMAUD
						QUD->QUD_SEQ    := aDadosQst[nX,nZ,nQst,1]
						QUD->QUD_CHKLST := aDadosQst[nX,nZ,nQst,2]
						QUD->QUD_REVIS  := aDadosQst[nX,nZ,nQst,3]
						QUD->QUD_CHKITE := aDadosQst[nX,nZ,nQst,4]
						QUD->QUD_QSTITE := aDadosQst[nX,nZ,nQst,5]
						QUD->QUD_APLICA := aDadosQst[nX,nZ,nQst,6]
						QUD->QUD_TIPO   := aDadosQst[nX,nZ,nQst,7]
						MsUnLock()
						FKCOMMIT()
					Else
						If Len(aDadosQst[nX,nZ]) > 1 .AND. Alltrim(QUJ->QUJ_CHKLST) <> '999999'
							If !Empty(aDadosQst[nX,nZ,nQst+1,1]) // Para acertar primeira questao do Checklist quando houver mais de um topico
								If !QUD->(DbSeek(xFilial("QUD")+QUJ->QUJ_NUMAUD+aDadosQst[nX,nZ,nQst+1,1]+aDadosQst[nX,nZ,nQst+1,2]+aDadosQst[nX,nZ,nQst+1,3]+aDadosQst[nX,nZ,nQst+1,4]+STRZERO(Val(aDadosQst[nX,nZ,nQst+1,5])-1,3)))
									RecLock("QUD",.T.)
									QUD->QUD_FILIAL := xFilial("QUD")
				   					QUD->QUD_NUMAUD := QUJ->QUJ_NUMAUD
									QUD->QUD_SEQ    := aDadosQst[nX,nZ,nQst+1,1]
									QUD->QUD_CHKLST := aDadosQst[nX,nZ,nQst+1,2]
									QUD->QUD_REVIS  := aDadosQst[nX,nZ,nQst+1,3]
									QUD->QUD_CHKITE := aDadosQst[nX,nZ,nQst+1,4]
									QUD->QUD_QSTITE := STRZERO(Val(aDadosQst[nX,nZ,nQst+1,5])-1,3)
									QUD->QUD_APLICA := aDadosQst[nX,nZ,nQst+1,6]
									QUD->QUD_TIPO   := aDadosQst[nX,nZ,nQst+1,7]
									MsUnLock()
									FKCOMMIT()
								Endif
							Endif
						Endif
					Endif
					
				Next
				Endif
            Endif
		Else
			lQUJDel := .T.
			For nJ:=1 to Len(aDadosAud[3,nX])
				If aDadosAud[3,nX,nZ,nPosChkAud]+aDadosAud[3,nX,nZ,nPosChkRev]+aDadosAud[3,nX,nZ,nPosChkItem] == aDadosAud[3,nX,nJ,nPosChkAud]+aDadosAud[3,nX,nJ,nPosChkRev]+aDadosAud[3,nX,nJ,nPosChkItem] .And. ;
					nZ <> nJ
					lQUJDel := .F.
				Endif
			Next
			If lQUJDel
				If QUJ->(DbSeek(xFilial("QUJ")+QUH->QUH_NUMAUD+QUH->QUH_SEQ+aDadosAud[3,nX,nZ,nPosChkAud]+aDadosAud[3,nX,nZ,nPosChkRev]+aDadosAud[3,nX,nZ,nPosChkItem]))
					q100DelChk(QUJ->QUJ_NUMAUD,"QUJ",QUH->QUH_NUMAUD+QUH->QUH_SEQ+;
					aDadosAud[3,nX,nZ,nPosChkAud]+aDadosAud[3,nX,nZ,nPosChkRev]+;
					aDadosAud[3,nX,nZ,nPosChkItem])
					
					RecLocK("QUJ",.F.)
					DbDelete()
					MsUnLock()
					FKCOMMIT()
				EndIf
				lStatus  := .T.
			Endif
		EndIf
	Next nZ
	
Next nX
                          
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava os Auditores da Equipe de Apoio a Auditoria  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QUC->(DbSetOrder(2))
nPos01:= Ascan(aHeadSav[4],{|x|AllTrim(x[2]) == "QUC_ITEM"})

For nX := 1 to Len(aDadosAud[4])
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o registro esta marcado para delecao. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aDadosAud[4,nX,Len(aHeadSav[4])+1] == .F.

		If !Empty(aDadosAud[4,nX,nPosFilAud]) .And. !Empty(aDadosAud[4,nX,nPosCodAud])

		    If QUC->(DbSeek(xFilial("QUC")+M->QUB_NUMAUD+aDadosAud[4,nX,nPos01]))
				RecLock("QUC",.F.)             
			Else
				RecLock("QUC",.T.)             
			EndIf
			QUC->QUC_FILIAL := xFilial("QUC")
			QUC->QUC_NUMAUD := QUB->QUB_NUMAUD
	
			For nZ := 1 to Len(aHeadSav[4])
			    If aHeadSav[4,nZ,10] # "V"
					QUC->(FieldPut(FieldPos(AllTrim(aHeadSav[4,nZ,2])),aDadosAud[4,nX,nZ]))	    
		    	EndIf
			Next nZ   
			MsUnLock()
            FKCOMMIT()
        EndIf
	Else
	    If QUC->(DbSeek(xFilial("QUC")+M->QUB_NUMAUD+aDadosAud[4,nX,nPos01]))
			RecLock("QUC",.F.)
			DbDelete()
			MsUnlock()
			FKCOMMIT()
		EndIf
	EndIf
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava os emails associados a Auditoria								 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPos01:= Ascan(aHeadSav[5],{|x|AllTrim(x[2]) == "QUI_ITEM"})

For nX := 1 to Len(aDadosAud[5])
 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o registro esta marcado para delecao. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aDadosAud[5,nX,Len(aHeadSav[5])+1] == .F.

		If !Empty(aDadosAud[5,nX,nPosUseNam])
		
		    If QUI->(DbSeek(xFilial("QUI")+M->QUB_NUMAUD+aDadosAud[5,nX,nPos01]))
				RecLock("QUI",.F.)             
			Else
				RecLock("QUI",.T.)             
			EndIf
			QUI->QUI_FILIAL := xFilial("QUI")
			QUI->QUI_NUMAUD := QUB->QUB_NUMAUD
	
			For nZ := 1 to Len(aHeadSav[5])
			    If aHeadSav[3,nZ,10] # "V"
					QUI->(FieldPut(FieldPos(AllTrim(aHeadSav[5,nZ,2])),aDadosAud[5,nX,nZ]))	    
		    	EndIf
			Next nZ   
			MsUnLock()
			FKCOMMIT() 
        EndIf
	Else
	    If QUI->(DbSeek(xFilial("QUI")+M->QUB_NUMAUD+aDadosAud[5,nX,nPos01]))
			RecLock("QUI",.F.)             
			DbDelete()
			MsUnlock()
			FKCOMMIT()
		EndIf
	EndIf
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava a Questoes referente as Areas Auditadas X CheckLists/Topicos	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//If !lCpoApl			
//	Q100GrvChk()
//Endif

If nOpc = 3 
	While (GetSX8Len() > nSaveSx8)
		ConfirmSx8()
	Enddo	
	For i:=1 to len(adadosaud[3,1])
		If adadosaud[3,1,i,1]== "999999"
			RecLock("QUB",.F.)
			QUB->QUB_STATUS := "3"
			MsUnlock()
			FKCOMMIT()
		Endif
	next i
Else
	dbSelectArea("QUD")
	dbSeek(xFilial("QUD") + QUB->QUB_NUMAUD)
	While QUD->(!Eof()) .and. (QUD->QUD_FILIAL + QUD->QUD_NUMAUD) == (xFilial("QUD") + QUB->QUB_NUMAUD)
        If QUD->QUD_APLICA == "2"
			QUD->(DbSkip())
			Loop
        Endif

		If lVerEvid 
			cTxtEvi := MsMM(QUD->QUD_EVICHV,TamSX3('QUD_EVIDE1')[1])
			If Empty(cTxtEvi) 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Resultados Parcialmente Respondido   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lBlqEvi:=.T.
		    EndIf
		EndIf

		cChave := QUD->QUD_CHKLST + QUD->QUD_REVIS + QUD->QUD_CHKITE + QUD->QUD_QSTITE
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ QUD_TIPO = 1) Padrao 										 ³
		//³			   2) Adicional 									 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If QUD->QUD_TIPO = "2"    
			QUE->(dbSeek(xFilial("QUE") + QUD->QUD_NUMAUD + cChave))
			nMin  := QUE->QUE_FAIXIN
			nMax  := QUE->QUE_FAIXFI
			nPeso := If(QUE->QUE_PESO==0,1,QUE->QUE_PESO)
			lAltern := If(QUE->QUE_USAALT=="1",.T.,.F.)
		Else
			QU4->(dbSeek(xFilial("QU4") + cChave))
			nMin  := QU4->QU4_FAIXIN
			nMax  := QU4->QU4_FAIXFI
			nPeso := If(QU4->QU4_PESO==0,1,QU4->QU4_PESO)
			lAltern := If(QU4->QU4_USAALT=="1",.T.,.F.)
		Endif	
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a nota informada na questao Alternativa e igual  ³
		//³ a Faixa Inicial, se o MV_QADQZER for igual a .T., a nota da  ³
		//³ questao sera sugerida como Zero para efeito de calculo.      ³ 
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    nNota := QUD->QUD_NOTA 
		If lQstZer .And. lAltern
			If nNota == nMin
				nNota := 0
			EndIf	
		EndIf
		nSemAval   += If(Empty(QUD->QUD_DTAVAL), 1, 0)
		nPontos	   += (((nNota * nPeso)*100)/nMax)
		nPesoTotal += (nPeso)
		nConAval++
		QUD->(DbSkip())
	Enddo	     	
	
	If nSemAval > 0
		IF nConAval == nSemAval
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³"Auditorias Sem Resultado"  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cStatusQUB:= "1"	
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Resultados Parcialmente Respondido   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cStatusQUB:= "2"
		Endif
	Else
		IF lBlqEvi //Evidencia Não Preenchida
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Resultados Parcialmente Respondido   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cStatusQUB:= "2"
		Else	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Liberada para Encerramento           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cStatusQUB:= "3"
			nPONOBT := nPontos / nPesoTotal
		Endif
	Endif
			
	RecLock("QUB",.F.)
	QUB->QUB_STATUS := cStatusQUB
	QUB->QUB_PONOBT := nPONOBT
	MsUnlock()
	FKCOMMIT()
Endif	      


Return(lRetorno)
                      
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³q100GrvChk³ Autor ³ Marcelo Iuspa			³ Data ³24/10/00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza a gravacao do arquivo de movimentos QUD			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ q100GrvChk(cNumAud)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
/*Static Function q100GrvChk()

Local aOldArea := GetArea()

QUJ->(DbSetOrder(1))
QUJ->(DbSeek(xFilial("QUJ")+M->QUB_NUMAUD))
While QUJ->(!Eof()) .And. QUJ->QUJ_FILIAL == xFilial("QUJ") .And.;
	QUJ->QUJ_NUMAUD == M->QUB_NUMAUD
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso o Check List associado a Area nao exista no QUD, o registro e   ³
	//³ incluido, os movimentos no QUD nao sao alterados					 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QUD->(DbSetOrder(1))
	If !QUD->(DbSeek(xFilial("QUD")+QUJ->QUJ_NUMAUD+QUJ->QUJ_SEQ+QUJ->QUJ_CHKLST+QUJ->QUJ_REVIS+QUJ->QUJ_CHKITE))
		QU4->(dbSetOrder(1))		
		QU4->(dbSeek(xFilial("QU4")+QUJ->QUJ_CHKLST+QUJ->QUJ_REVIS+QUJ->QUJ_CHKITE))
		While QU4->(!Eof()) .And. (QU4->QU4_CHKLST+QU4->QU4_REVIS+QU4->QU4_CHKITE) == (QUJ->QUJ_CHKLST+QUJ->QUJ_REVIS+QUJ->QUJ_CHKITE)
			RecLock("QUD",.T.)
			QUD->QUD_FILIAL := xFilial("QUD") 
			QUD->QUD_NUMAUD := QUJ->QUJ_NUMAUD                        
			QUD->QUD_SEQ    := QUJ->QUJ_SEQ
			QUD->QUD_CHKLST := QU4->QU4_CHKLST
			QUD->QUD_REVIS  := QU4->QU4_REVIS
			QUD->QUD_CHKITE := QU4->QU4_CHKITE
			QUD->QUD_QSTITE := QU4->QU4_QSTITE
			QUD->QUD_TIPO   := "1"
			MsUnLock()
			FKCOMMIT()
			QU4->(dbSkip())                   
		EndDo		       
	EndIf
	QUJ->(dbSkip())
EndDo

RestArea(aOldArea)

Return(NIL)
*/                 
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q100DelAud³ Autor ³ Marcelo Iuspa			³ Data ³24/10/00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza a exclusao da Auditoria							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q100DelAud()     										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                            								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Q100DelAud(oDlg)

Local lRetorno := .T.    
Local nX		:= 0
Local aMemUser	:= {}
Local lQA100MEM := Existblock("QA100MEM")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a Auditoria possui Questoes respondidas			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
QUD->(dbSetOrder(1))
QUD->(dbSeek(xFilial("QUD")+M->QUB_NUMAUD))
While QUD->(!Eof()) .And. xFilial("QUD") == QUD->QUD_FILIAL .And.;
	QUD->QUD_NUMAUD == M->QUB_NUMAUD
	If !Empty(QUD->QUD_DTAVAL) 
		Help("",1,"100ADTRESP")
		lRetorno := .F.
		Exit
	EndIf
	QUD->(dbSkip())
EndDo	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³	Verifica se existem nao-conformidades associadas			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
QUG->(dbSetOrder(1))
QUG->(dbSeek(xFilial("QUG")+M->QUB_NUMAUD))
If QUG->QUG_NUMAUD == M->QUB_NUMAUD
	Help("",1,"100ADTNAOC")
	lRetorno := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³	Realiza a exclusao dos arquivos utilizados na Auditoria      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
If lRetorno

   If MsgYesNo(STR0017) //"Deseja enviar email agora ? "
	   cMessage  := STR0074 //"Envio de E-mail comunicando a Exclusão da Auditoria"
	   cTitle    := STR0019 //"Envio de e-mail"
	   bSendMail := {||Q100SendAud(oDlg,5)}
	   MsgRun(cMessage,cTitle,bSendMail)
   EndIf	
		
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Areas Auditadas e Auditores   							   ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
   QUH->(dbSetOrder(1))
   QUH->(dbSeek(xFilial("QUH")+M->QUB_NUMAUD))
   While QUH->(!Eof()) .And. xFilial("QUH") == QUH->QUH_FILIAL .And.;
   	   QUH->QUH_NUMAUD == M->QUB_NUMAUD
   	   RecLock("QUH",.F.,.T.)
   	   QUH->(dbDelete())	
   	   QUH->(MsUnlock())
   	   FKCOMMIT()
   	   QUH->(dbSkip())	
   EndDo

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Equipe de Apoio											    ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
   QUC->(dbSetOrder(1))
   QUC->(dbSeek(xFilial("QUC")+M->QUB_NUMAUD))
   While QUC->(!Eof()) .And. xFilial("QUC") == QUC->QUC_FILIAL .And.;
	   QUC->QUC_NUMAUD == M->QUB_NUMAUD
   	   RecLock("QUC",.F.,.T.)
   	   QUC->(dbDelete())	
   	   QUC->(MsUnlock())
   	   FKCOMMIT()
   	   QUC->(dbSkip())
   EndDo	   	   	

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Check List's associados   									³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
   QUJ->(dbSetOrder(1))
   QUJ->(dbSeek(xFilial("QUJ")+M->QUB_NUMAUD))
   While QUJ->(!Eof()) .And. xFilial("QUJ") == QUJ->QUJ_FILIAL .And.;
   	   QUJ->QUJ_NUMAUD == M->QUB_NUMAUD
   	   RecLock("QUJ",.F.,.T.)
   	   QUJ->(dbDelete())	
   	   QUJ->(MsUnlock())
   	   FKCOMMIT()
   	   QUJ->(dbSkip())	   	   
   EndDo	   	   	

  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  //³ Emails Associados											   ³
  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
   QUI->(dbSetOrder(1))
   QUI->(dbSeek(xFilial("QUI")+M->QUB_NUMAUD))
   While QUI->(!Eof()) .And. xFilial("QUI") == QUI->QUI_FILIAL .And.;
   	   QUI->QUI_NUMAUD == M->QUB_NUMAUD
   	   RecLock("QUI",.F.,.T.)
   	   QUI->(dbDelete())	
   	   QUI->(MsUnlock())
   	   FKCOMMIT()
   	   QUI->(dbSkip())	
   EndDo

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Movimento (Itens Auditados)									³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	QUD->(dbSetOrder(1))
	QUD->(dbSeek(xFilial("QUD")+M->QUB_NUMAUD))
	While QUD->(!Eof()) .And. xFilial("QUD") == QUD->QUD_FILIAL .And.;
		QUD->QUD_NUMAUD == M->QUB_NUMAUD
		RecLock("QUD",.F.,.T.)
		QUD->(dbDelete())
		QUD->(MsUnlock())
		FKCOMMIT()
		QUD->(dbSkip())
	EndDo	   	   	

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Nao-conformidades associadas									³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
   	QUG->(dbSetOrder(1))
  	QUG->(dbSeek(xFilial("QUG")+M->QUB_NUMAUD))
   	While QUG->(!Eof()) .And. xFilial("QUG") == QUG->QUG_FILIAL .And.;
   	   	QUG->QUG_NUMAUD == M->QUB_NUMAUD
		MsMM(QUG->QUG_DESCHV,,,,2)
   	   	RecLock("QUG",.F.,.T.)
   	   	QUG->(dbDelete())
   	   	QUG->(MsUnlock())
   	   	FKCOMMIT()
   	   	QUG->(dbSkip())   	   
   	EndDo
   	
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Cabecalho da Auditoria										³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	

   MSMM(QUB->QUB_DESCHV,,,,2)
   MSMM(QUB->QUB_SUGCHV,,,,2)
   
   RecLock("QUB",.F.,.T.)
   QUB->(dbDelete())
   QUB->(MsUnlock())
   FKCOMMIT()
   
   	If lQA100MEM
		If ValType (aMemUser := ExecBlock( "QA100MEM", .F., .F. ) ) == "A"
			For nX := 1 To Len(aMemUser)
				MSMM(&("QUB->"+aMemUser[nX,1]),,,,2)
			Next
		EndIf
	EndIf
   
   QUB->(dbSkip())
EndIf
	
Return(lRetorno)



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q100FilaCols³ Autor ³ Paulo Emidio de Barros³ Data ³31/10/00³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta o aCols utilizado na Rotina       					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Q100FilaCols(EXPC1,EXPN1,EXPN2,EXPN3,EXPA1,EXPA2,EXPC2,EXPL1)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Alias 											  ³±±
±±³			 ³ EXPN1 = Opcao aRotina									  ³±±
±±³			 ³ EXPN2 = Ordem Chave										  ³±±
±±³			 ³ EXPN3 = Posicao do aHeader 								  ³±±
±±³			 ³ EXPA1 = Array que armazena os aHeader de todas as getdados ³±±
±±³			 ³ EXPA2 = Array que armazena os aCols de todas as getdados   ³±±
±±³			 ³ EXPC2 = Usario logado    								  ³±±
±±³			 ³ EXPL1 = Indica de onde vem a chamada da função			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ EXPA1 = Array com o aCols montado						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Q100FilaCols(cAlias,nOpc,nOrdem,nHeader,aHeadSav,aColsSav,cAuditor,lGet)

Local aOldArea 	:= GetArea()
Local aColsAux 	:= {}
Local cCpoGrv
Local nX := 1
Local nPos
Local nPosItem
Local nPosFMat
Local nPosMat
Local aNoFields := {"QUC_NUMAUD", "QUH_NUMAUD", "QUI_NUMAUD", "QUJ_NUMAUD", "QUJ_SEQ"}

DEFAULT cAuditor := ""
DEFAULT lGet := .F.//Se .T. =  chamada eh feita do cobeblock da get oGetArea

aHeader := {}
aCols   := {}

dbSelectArea(cAlias)
dbSetOrder(nOrdem)
dbSeek(xFilial(cAlias)+M->QUB_NUMAUD)

cSeek  :=  xFilial(cAlias)+ &(cAlias+"_NUMAUD")
cWhile :=  (cAlias+"_FILIAL"+"+"+cAlias+"_NUMAUD")

If nOpc == 3
	  FillGetDados(nOpc,cAlias,nOrdem,       ,         ,         , aNoFields,          ,        ,      ,         ,  .T.  ,          ,        ,          ,           ,            ,)
	//FillGetDados(nOpc,Alias ,nOrdem,cSeek  ,bSeekWhile,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,
	If cAlias $ "QUI | QUC | QUH"//Inicializa a primeira posicao dos campos de sequencia
		nPosItem := Ascan(aHeader,{|X| Upper(Alltrim(X[2])) $ cAlias+"_ITEM"+cAlias+"_SEQ"})
		aCols[Len(aCols),nPosItem] := "01"
	EndIf
Else
	  FillGetDados(nOpc,cAlias,nOrdem,cSeek ,{|| &cWhile},         , aNoFields,          ,        ,      ,        ,       ,          ,        ,          ,           ,            ,)
	//FillGetDados(nOpcX,Alias ,nOrdem,cSeek  ,bSeekWhile  ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,
	   	If cAlias $ "QUI | QUC | QUH"//Inicializa a primeira posicao dos campos de sequencia
			nPosItem := Ascan(aHeader,{|X| Upper(Alltrim(X[2])) $ cAlias+"_ITEM"+cAlias+"_SEQ"})
			If EMPTY(aCols[Len(aCols),nPosItem])
				aCols[Len(aCols),nPosItem] := "01"
			Endif
	    EndIf
EndIf

nUsado := Len(aHeader)

//Caso o parametro MV_AUDSLID seja .T., qualquer pessoa que nao seja o auditor
//lider podera visualizar somente a sua area
If cAlias == "QUH" .And. nOpc == 2 .And. cAuditor <> ""
	nPosFMat  := Ascan(aHeader,{|X| Upper( Alltrim(X[2])) == "QUH_FILMAT"})
	nPosMat   := Ascan(aHeader,{|X| Upper( Alltrim(X[2])) == "QUH_CODAUD"})
	While nX <= Len(aCols)
		If aCols[nX][nPosFMat]+aCols[nX][nPosMat] <> cAuditor
			aDel(aCols,nX)
			aSize(aCols,Len(aCols)-1)
		Else
			nx++
		EndIf
	EndDo
EndIf

If cAlias != "QUJ" .And. nOpc == 3 .And. !lGet
	aHeadSav[nHeader] := aClone(aHeader)
	aColsSav[nHeader] := aClone(aCols)
ElseIf !lGet
	aHeadSav[nHeader] := aClone(aHeader)
	aColsSav[nHeader] := aClone(aCols)
EndIf

//Retorna a area corrente
RestArea(aOldArea)   

Return aCols

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q100AdtLOk³ Autor ³ Paulo Emidio de Barros³ Data ³01/11/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida a Linha corrente das Areas auditadas				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ 	Q100AdtLOk()											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .t. ou .f.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Q100AdtLOk()

Local lRetorno   := .T.
Local nX         := 0
Local nOcoAreaAud:= 0
Local nOcoChkArea:= 0
Local nPosDepRes := Ascan(aHeadSav[2],{|x|Alltrim(x[2]) == "QUH_CCUSTO"})
Local nPosConfid := Ascan(aHeadSav[2],{|x|Alltrim(x[2]) == "QUH_CONFID"})

nUsado    := Len(aHeader)

If lRetorno
	For nX := 1 To Len(aCols)
		If !(aCols[N,nUsado+1])
			If aCols[nX,nPosDesAud] == aCols[N,nPosDesAud]
				If !(aCols[nX,nUsado+1])
					nOcoAreaAud++
				EndIf	
			EndIf
		EndIf	
	Next
	
	If nOcoAreaAud > 1
		Help("",1,"100EXISARE")  // "Exitem areas cadastradas em duplicidade" ### "para esta auditoria."
		lRetorno := .F.
	Else
		If !(aCols[N,nUsado+1])
			If Empty(aCols[N,nPosDesAud]) .Or. Empty(aCols[N,nPosFilRes]) .Or. ;
			   	Empty(aCols[N,nPosAudRes]) .Or. ;
			   	Empty(aCols[N,nPosConfid]) .Or. ;
			   	(Empty(M->QUB_CODFOR) .AND. Empty(M->QUB_LOJA) .AND. Empty(aCols[N,nPosDepRes]))
				Help("",1,"OBRIGAT")
				lRetorno := .F.
			EndIf	
		EndIf
	EndIf	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se foi cadastrado check-list / topico para a Area Auditada. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetorno .And. !oGetArea:Acols[oGetArea:oBrowse:nAt,Len(oGetArea:aHeader)+1]
	nOcoChkArea := 0
	For nX := 1 To Len(oGetCheck:aCols)
		If ! oGetCheck:Acols[nX,Len(oGetCheck:aHeader)+1]
			nOcoChkArea ++
		Endif
	Next
	If nOcoChkArea = 0 .Or. Empty(oGetCheck:Acols[1,1])
		Help("",1,"100CHKITEM") // "Nao existem check-lists relacionados para a" ### "Area Auditada"
		lRetorno:= .F.
	Endif
EndIf
             
If lRetorno
	lRetorno := QADVDATAUD ("QUB", "QUH", "LIN", Nil, Nil, aCols, aHeader, oGetArea:oBrowse:nAt)
EndIf

Return(lRetorno)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q100AdtTOk³ Autor ³ Paulo Emidio de Barros³ Data ³01/11/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida todas as linhas nas Areas Auditadas            	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q100AdtTOk()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .t. ou .f.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Q100AdtTOk()

Local lRetorno    := .T.
Local nX          := 0
Local aAreaRep    := {}
Local nPosDepRes  := Ascan(oGetArea:aHeader,{|x|Alltrim(x[2]) == "QUH_CCUSTO"})
Local nPosConfid  := Ascan(oGetArea:aHeader,{|x|Alltrim(x[2]) == "QUH_CONFID"})
Local nPosFilial  := Ascan(oGetArea:aHeader,{|x|Alltrim(x[2]) == "QUH_FILMAT"})
Local nPosAuditor := Ascan(oGetArea:aHeader,{|x|Alltrim(x[2]) == "QUH_CODAUD"})
Local lAudDepto   := GetMV("MV_QADDEP",.T.,.F.)
Local nOcoChkArea := 0
Local nPos

nUsado    := Len(oGetArea:aHeader)

For nX := 1 to Len(oGetArea:Acols)
   	If !oGetArea:Acols[nX,nUsado+1]
		If Empty(oGetArea:Acols[nX,nPosDesAud])
			Help("",1,"100AREAVAZ")
			lRetorno := .F.
		ElseIf Empty(oGetArea:Acols[nX,nPosDesAud]) .Or. Empty(oGetArea:Acols[nX,nPosFilRes]) .Or. ;
		   	Empty(oGetArea:Acols[nX,nPosAudRes]) .Or.;
		   	Empty(oGetArea:Acols[nX,nPosConfid]) .Or. ;
		   	(Empty(M->QUB_CODFOR) .AND. Empty(M->QUB_LOJA) .AND. Empty(oGetArea:Acols[nX,nPosDepRes]))
			Help("",1,"OBRIGAT")
			lRetorno := .F.					
		Else
    		nPos := Ascan(aAreaRep,oGetArea:Acols[nX,nPosDesAud])
   			If nPos > 0
				Help("",1,"100EXISARE") // "Exitem areas cadastradas em duplicidade" ### "para esta auditoria."
				lRetorno := .F.
				Exit
   			Else 
				Aadd(aAreaRep,oGetArea:Acols[nX,nPosDesAud])
	    	Endif
   		EndIf
    EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se o depto auditado nao e o mesmo o qual pertence o auditor selecionado. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If lAudDepto 
		If !Empty(oGetArea:Acols[nX,nPosDesAud])
			QAA->(dbSetOrder(1))
			If QAA->(DBSeek(oGetArea:aCols[nX,nPosFilial]+oGetArea:aCols[nX,nPosAuditor]))
				If !oGetArea:Acols[nX,Len(oGetArea:aHeader)+1] 
			   		If QAA->QAA_CC == oGetArea:Acols[nX,nPosDepRes]
			  			Aviso('',OemToAnsi(STR0071),{'Ok'}) //"O auditor selecionado nao pode auditar seu proprio departamento !"				
			        	lRetorno:= .F.
			   		EndIf
			   	EndIf	
	        EndIf
		EndIf
	EndIf
	
Next     
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se foi cadastrado check-list / topico para a Area Auditada. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !oGetArea:Acols[oGetArea:oBrowse:nAt,Len(oGetArea:aHeader)+1]
	nOcoChkArea := 0
	For nX := 1 To Len(oGetCheck:aCols)
		If ! oGetCheck:Acols[nX,Len(oGetCheck:aHeader)+1]
			nOcoChkArea ++
		Endif
	Next
	If nOcoChkArea = 0 .Or. Empty(oGetCheck:Acols[1,1])
		Help("",1,"100CHKITEM") // "Nao existem check-lists relacionados para a" ### "Area Auditada"
		lRetorno:= .F.
	Endif
EndIf

If lRetorno
	lRetorno := QADVDATAUD ("QUB", "QUH", "ALL", Nil, Nil, oGetArea:aCols, oGetArea:aHeader, oGetArea:oBrowse:nAt)
EndIf

Return(lRetorno)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q100AudLOk³ Autor ³ Paulo Emidio de Barros³ Data ³01/11/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida  a linha corrente em Equipe de Apoio   			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q100AudLOk()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .t. ou .f.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Q100AudLOk()

Local lRetorno   := .T.
Local nOcoCodAud := 0
Local nX

nUsado := Len(aHeader)

For nX := 1 To Len(aCols)
	If !(aCols[N,nUsado+1])
		If aCols[nX,nPosFilAud]+aCols[nX,nPosCodAud] == aCols[N,nPosFilAud]+aCols[N,nPosCodAud]
			If !(aCols[nX,nUsado+1])
				nOcoCodAud++
			EndIf	
		EndIf
	EndIf	
Next

If nOcoCodAud > 1
	Help("",1,"100EXISAUD")
	lRetorno := .F.
Else
	If Empty(aCols[N,nPosFilAud]) .Or. Empty(aCols[N,nPosCodAud])
		If !(aCols[N,nUsado+1])
			Help("",1,"100NEXIAUD")
			lRetorno := .F.
		EndIf	
	EndIf
EndIf	
	
Return(lRetorno)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q100AudTOk³ Autor ³ Paulo Emidio de Barros³ Data ³01/11/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida todas as linhas em Equipe de Apoio			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q100AudTOk()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .t. ou .f.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Q100AudTOk()

Local lRetorno := .T.
Local nX
Local nPos
Local aAudRep  := {}

nUsado := Len(oGetAudit:aHeader)

If Len(oGetAudit:Acols) > 1 .Or. (Len(oGetAudit:Acols) == 1 .And. !Empty(oGetAudit:Acols[1,nPosCodAud]))

	For nX := 1 to Len(oGetAudit:aCols)

	   	If !oGetAudit:aCols[nX,nUsado+1]
			If Empty(oGetAudit:aCols[nX,nPosFilAud]) .Or. Empty(oGetAudit:aCols[nX,nPosCodAud])
				Help("",1,"100NEXIAUD")
				lRetorno := .F.
			Else
    			nPos:= Ascan(aAudRep,oGetAudit:aCols[nX,nPosFilAud]+oGetAudit:aCols[nX,nPosCodAud])
	   			If nPos > 0
					Help("",1,"100EXISAUD")
					lRetorno := .F.
					Exit
	   			Else 
					Aadd(aAudRep,oGetAudit:aCols[nX,nPosFilAud]+oGetAudit:aCols[nX,nPosCodAud])
		    	Endif
	   		EndIf
	    EndIf
	Next     
EndIf

Return(lRetorno)       

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q100ChkLOk³ Autor ³ Paulo Emidio de Barros³ Data ³01/11/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida a linha corrente do  Check-List				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q100ChkLOk()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .t. ou .f.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Q100ChkLOk(aColsG,nLinha)

Local lRetorno   := .T.
Local nOcoChkAud := 0
Local nX
Default nLinha := N
Default aColsG := aClone(aCols)

nUsado := Len(aHeader)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o Check List esta efetivado						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aColsG[nLinha,nPosChkAud])
	If !(aColsG[nLinha,Len(aColsG[nLinha])])
		lRetorno := QadChkEfet(aColsG[nLinha,nPosChkAud]+aColsG[nLinha,nPosChkRev],.T.,,.T.)
	EndIf
EndIf		

For nX := 1 To Len(aColsG)
	If !(aColsG[nLinha,Len(aColsG[nLinha])])
		If aColsG[nX,nPosChkAud] == aColsG[nLinha,nPosChkAud] .And. ;
		    aColsG[nX,nPosChkRev] == aColsG[nLinha,nPosChkRev] .And. ;
			aColsG[nX,nPosChkItem] == aColsG[nLinha,nPosChkItem]
			If !(aColsG[nX,Len(aColsG[nX])])
				nOcoChkAud++
			EndIf	
		EndIf
	EndIf	
Next
	
If nOcoChkAud > 1
	Help("",1,"100CHKDUPL")
	lRetorno := .F.
Else
	If !(aColsG[nLinha,Len(aColsG[nLinha])])
		If Empty(aColsG[nLinha,nPosChkAud]) .Or. Empty(aColsG[nLinha,nPosChkRev]) .Or. Empty(aColsG[nLinha,nPosChkItem])
			Help("",1,"100CHKNINF")
			lRetorno := .F.
		EndIf	
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o nivel esta vazio 								 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetorno
	If Empty(aColsG[nLinha,nPosNivRes])
		If !(aColsG[nLinha,Len(aColsG[nLinha])])
			Help("",1,"100NIVNINF")
			lRetorno := .F.
		EndIf
	EndIf              
EndIf

If lRetorno
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Preenchimento no array da selecao de questoes do check-list³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	nCnt := 0
	
	If !Empty(aColsG[nLinha,nPosChkAud]) .And. !Empty(aColsG[nLinha,nPosChkRev]) .And. !Empty(aColsG[nLinha,nPosChkItem])			 
		If Len(aColsG) > Len(aDadosQst[oGetArea:oBrowse:nAt])
			While Len(aColsG) > Len(aDadosQst[oGetArea:oBrowse:nAt])
				Aadd(aDadosQst[oGetArea:oBrowse:nAt],{{" "," "," "," "," "," "," "}} )
			enddo
		Endif
		
		If Empty(aDadosQst[oGetArea:oBrowse:nAt,nLinha,1,2])
			
			QU4->(dbSetOrder(1))		
			QU4->(dbSeek(xFilial("QU4")+aColsG[nLinha,nPosChkAud]+aColsG[nLinha,nPosChkRev]+aColsG[nLinha,nPosChkItem]))
			While QU4->(!Eof()) .And. (QU4->QU4_CHKLST+QU4->QU4_REVIS+QU4->QU4_CHKITE) == (aColsG[nLinha,nPosChkAud]+aColsG[nLinha,nPosChkRev]+aColsG[nLinha,nPosChkItem])
					nCnt++
					If nCnt > Len(aDadosQst[oGetArea:oBrowse:nAt,nLinha])
						aAdd(aDadosQst[oGetArea:oBrowse:nAt,nLinha],{oGetArea:aCols[oGetArea:oBrowse:nAt,nPosSeq], QU4->QU4_CHKLST,QU4->QU4_REVIS,QU4->QU4_CHKITE,QU4->QU4_QSTITE," ","1"} )
					Else
						aDadosQst[oGetArea:oBrowse:nAt,nLinha,nCnt]:= {oGetArea:aCols[oGetArea:oBrowse:nAt,nPosSeq], QU4->QU4_CHKLST,QU4->QU4_REVIS,QU4->QU4_CHKITE,QU4->QU4_QSTITE," ","1"} 
					Endif
				QU4->(dbSkip())                   
			EndDo		       
	    Endif
	Endif			

Endif
Return(lRetorno)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q100ChkTOk³ Autor ³ Paulo Emidio de Barros³ Data ³01/11/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida todas as linhas do Check-List						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q100ChkTOk()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .t. ou .f.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Q100ChkTOk()

Local lRetorno := .T.
Local nX
Local nPos
Local aChkRep := {}
Local nCont:=0  
Local lTem99:= .F.

nUsado := Len(oGetCheck:aHeader)
Aeval( oGetCheck:aCols, { |x| If(x[Len(oGetCheck:aHeader)+1] == .T. ,nCont++,nCont)})

For nX := 1 to Len(oGetCheck:aCols)

   	If !oGetCheck:aCols[nX,nUsado+1] .And. !oGetArea:Acols[Len(oGetArea:Acols),Len(oGetArea:aHeader)+1]
 	
		If Empty(oGetCheck:aCols[nX,nPosChkAud]) .Or. Empty(oGetCheck:aCols[nX,nPosChkRev]) .Or. Empty(oGetCheck:aCols[nX,nPosChkItem])
			Help("",1,"100CHKNINF")
			lRetorno := .F.
		Else     
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o Check List esta efetivado						 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !(lRetorno := QadChkEfet(oGetCheck:aCols[nX,nPosChkAud]+oGetCheck:aCols[nX,nPosChkRev],.T.,,.T.))
				Exit
			EndIf			

    		nPos := Ascan(aChkRep,(oGetCheck:aCols[nX,nPosChkAud]+oGetCheck:aCols[nX,nPosChkItem]))
   			If nPos > 0
				Help("",1,"100CHKDUPL")
				lRetorno := .F.
				Exit
    		Else 
				Aadd(aChkRep,(oGetCheck:aCols[nX,nPosChkAud]+oGetCheck:aCols[nX,nPosChkItem]))    	
    		Endif
    	EndIf               

    	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o Nivel esta vazio						     		³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    	If Empty(oGetCheck:aCols[nX,nPosNivRes])
    		Help("",1,"100NIVNINF")
    		lRetorno := .F.
    		Exit
    	EndIf	
	    	
    	If oGetCheck:aCols[nX,nPosChkAud] == "999999"
    		lTem99:= .T.
    	Endif
    EndIf
Next 
If lTem99 .and. ((Len(oGetCheck:aCols)- nCont) > 1)
	MessageDlg(STR0073) //"Para auditorias com o Checklist 999999 não poderá possuir outros checklists"
	lRetorno:=.F.
Endif

Return(lRetorno)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q100MAILOk³ Autor ³ Paulo Emidio de Barros³ Data ³01/11/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida a linha corrente do e-mail associado				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q100MAILOk()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .t. ou .f.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Q100MAILOk()

Local lRetorno  := .T.
Local nX        := 0
Local nOcoUseNam:= 0

nUsado := Len(aHeader)

For nX := 1 To Len(aCols)
	If !(aCols[N,nUsado+1])
		If aCols[nX,nPosUseNam] == aCols[N,nPosUseNam]
			If !(aCols[nX,nUsado+1])
				nOcoUseNam++
			EndIf	
		EndIf
	EndIf	
Next

If nOcoUseNam > 1
	Help("",1,"100EXISMAI") // "Exitem email's cadastrados em duplicidade" ### "para esta auditoria."
	lRetorno := .F.
Else
	If Empty(aCols[N,nOcoUseNam])
		If !(aCols[N,nUsado+1])
			Help("",1,"100UNUSER") 
			lRetorno := .F.
		EndIf	
	EndIf
EndIf	
	
Return(lRetorno)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q100MAITOk³ Autor ³ Paulo Emidio de Barros³ Data ³01/11/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida todas as linhas dos e-mails associados			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q100MAITOk()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .t. ou .f.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Q100MAITOk()

Local lRetorno := .T.
Local nX       := 0
Local aMailRep := {}   
Local nPos

nUsado := Len(oGetMail:aHeader)

If Len(oGetMail:Acols) > 1 .Or. (Len(oGetMail:Acols) == 1 .And. !Empty(oGetMail:Acols[1,nPosUseNam]))

	For nX := 1 to Len(oGetMail:aCols)
	   	If !oGetMail:aCols[nX,nUsado+1]
			If Empty(oGetMail:aCols[nX,nPosUseNam])
				Help("",1,"100UNUSER") 
				lRetorno := .F.
			Else
	    		nPos := Ascan(aMailRep,oGetMail:aCols[nX,nPosUseNam])
	   			If nPos > 0
						Help("",1,"100EXISMAI") // "Exitem email's cadastrados em duplicidade" ### "para esta auditoria."
					lRetorno := .F.
					Exit
	   			Else 
					Aadd(aMailRep,oGetMail:aCols[nX,nPosUseNam])    	
		    	Endif
	   		EndIf
	    EndIf
	Next     

EndIf

Return(lRetorno)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³q100VldGet³ Autor ³ Paulo Emidio de Barros³ Data ³01/11/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ efetua todas as validacoes da Auditoria, antes da gravacao ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ q100VldGet(EXPC1,EXPC2,EXPC3,EXPD1,EXPD2,EXPD3,EXPC4,;     ³±±
±±³			 ³       	   EXPA1,EXPN1,EXPN2)				              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPA1 = Array com objetos das Getdados a serem validados	  ³±±
±±³			 ³ EXPN1 = Opcao do aRotina									  ³±±
±±³			 ³ EXPN2 = Posicao da Folder corrente						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .t. ou .f.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function q100VldGet(aGetDad,nOpc,nPosFldGet,oDlg)

Local lRetorno   := .T.
Local nRegQUB     := 0                 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa as validacoes, somente na Inclusao ou Alteracao	     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ          
If !(nOpc == 3 .Or. nOpc == 4)
	Return(.T.)
EndIf           

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se durante o cadastro, o numero da Auditoria 		 ³
//³ nao foi utilizado por outro usuario.						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetorno .And. nOpc == 3
	nRegQUB:= QUB->(RecNo())
	If QUB->(DbSeek(xFilial("QUB")+M->QUB_NUMAUD))
		Help(" ",1,"AUDJAEXIST") // Ja existe auditoria cadastrada com o numero informado.
		lRetorno:= .F.
	EndIf
	QUB->(DbGoto(nRegQUB))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se as datas informadas no Cabecalho estao corretas  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ          
If lRetorno
	lRetorno := Q100VldDat(M->QUB_REFAUD,M->QUB_INIAUD)
EndIf	

If lRetorno 
	lRetorno := Q100VldDat(M->QUB_INIAUD,M->QUB_ENCAUD)
EndIf               

IF Empty(aDadosAud[1])
	Help("",1,"OBRIGAT",,OemToAnsi(STR0012),5,0) //"Descricao"
	lRetorno := .F.	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ verifica o preenchimento dos Gets do Cabecalho da Auditoria  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ          
If Empty(M->QUB_NUMAUD) 
	Help("",1,"100NNUMAD")
	lRetorno := .F.
ElseIf Empty(M->QUB_TIPAUD)
	Help("",1,"100NTIPAD")
	lRetorno := .F.
ElseIf Empty(M->QUB_MOTAUD)
	Help("",1,"100NMOTAD")
	lRetorno := .F.
ElseIf Empty(M->QUB_INIAUD) 
	Help("",1,"100NINIAD")
	lRetorno := .F.
ElseIf Empty(M->QUB_ENCAUD) 
	Help("",1,"100NENCAD")
	lRetorno := .F.
ElseIf Empty(M->QUB_AUDLID) 
	Help("",1,"100NAUDAD")
	lRetorno := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza a validacao na Getdados da Area Auditada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Q100AdtTOk() .And. lRetorno
	lRetorno:= .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza a validacao na Getdados de Check-List	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Q100ChkTOk() .And. lRetorno
	lRetorno:= .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza a validacao na Getdados de Equipe de Apoio ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Q100AudTOk() .And. lRetorno
	lRetorno:= .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza a validacao na Getdados de Emails    	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Q100MAITOk() .And. lRetorno
	lRetorno:= .F.
EndIf		  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida se o auditor esta alocaco em uma Auditoria no mesmo periodo  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !QAD100AUD(oDlg) .And. lRetorno
   lRetorno:=.F.
EndIf
	
Return(lRetorno)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q100VldDat³ Autor ³ Paulo Emidio de Barros³ Data ³01/11/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se a Data Inicio e maior que a Data Final         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q100VldDat(EXPD1,EXPD2)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPD1 = Data Inicio da Auditoria						 	  ³±±
±±³			 ³ EXPD2 = Data Final da Auditoria							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .t. ou .f.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Q100VldDat(dGet1,dGet2)

Local lRetorno := .T.
If (dGet1 # Ctod('')) .And. (dGet2 # Ctod(''))
	If dGet1 > dGet2
		Help("",1,"100INVDATA") // A data informada e invalida       
		lRetorno := .F.
	EndIf		
EndIf		

Return(lRetorno)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q100ChkPad³ Autor ³ Paulo Emidio de Barros³ Data ³01/11/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua a criacao do Check-List padrao					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q100ChkPad()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Q100ChkPad()

Local cChkLstPad := Alltrim(GetMv("MV_QCHKPAD"))
Local cRevi      := "00"
Local nTamChkPad := TAMSX3("QU2_CHKLST")[1]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento para evitar falha do tamanho da variavel no DbSeek ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF LEN(cChkLstPad) < nTamChkPad
	cChkLstPad+=Space(nTamChkPad - LEN(cChkLstPad))
Else
	cChkLstPad:=SUBS(cChkLstPad,1,nTamChkPad)
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pesquisa a existencia do Check List Padrao se nao existir, o ³
//³ mesmo ser gravado.											 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QU2->(dbSetOrder(1))
If QU2->(!dbSeek(xFilial("QU2")+cChkLstPad+cRevi))
	Begin Transaction
	
		RecLock("QU2",.T.)
		QU2->QU2_FILIAL := xFilial("QU2")
		QU2->QU2_CHKLST := cChkLstPad
		QU2->QU2_REVIS  := cRevi
		QU2->QU2_DESCRI := OemToAnsi(STR0020) //"CHECK LIST PADRAO"
		QU2->QU2_OBSERV := OemToAnsi(STR0021) //"UTILIZADO PARA AUDITORIA COM QUESTIONARIO UNICO"
		QU2->QU2_ULTREV := dDatabase
		QU2->QU2_EFETIV := "1" //efetiva o Check List
		MsUnLock()
		FKCOMMIT()
			
		RecLock("QU3",.T.)
		QU3->QU3_FILIAL := xFilial("QU3")
		QU3->QU3_CHKLST := cChkLstPad
		QU3->QU3_REVIS  := cRevi
		QU3->QU3_CHKITE := "0001"
		QU3->QU3_DESCRI := OemToAnsi(STR0022) //"TOPICO DO CHECK LIST PADRAO"
		QU3->QU3_OBSERV := OemToAnsi(STR0021) //"UTILIZADO PARA AUDITORIA COM QUESTIONARIO UNICO"
		QU3->QU3_ULTREV := QU2->QU2_ULTREV
		MsUnLock()
		FKCOMMIT()

	End Transaction
			 
EndIf

Return(NIL)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q100RecQDU³ Autor ³ Paulo Emidio de Barros³ Data ³01/11/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Salva a posicao dos registros do QUD						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q100RecQDU()     										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .t. ou .f.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Q100RecQDU()

Local aRecMov := {}

QUD->(dbSetOrder(1))
QUD->(dbSeek(xFilial("QUD")+M->QUB_NUMAUD))
While QUD->(!Eof()) .And.QUD->QUD_FILIAL == xFilial("QUD") .And.;
	QUD->QUD_NUMAUD == M->QUB_NUMAUD
	Aadd(aRecMov,{QUD->(Recno()),QUD->QUD_CHKLST,QUD->QUD_SEQ,.F.})
    QUD->(dbSkip())
EndDo

Return(aRecMov)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q100HidGet³ Autor ³ Paulo Emidio de Barros³ Data ³01/11/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inibe a edicao dos dados gravados na Auditoria			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q100HidGet()              								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .t. ou .f.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Q100HidGet()

Local lRetorno := .T.
Local cCtdGetDad := ReadVar()
                                       
If cCtdGetDad == "M->QUH_DESTIN"
	If oGetArea:aCols[N,nPosEfeAud] == "1"
		lRetorno := .F.
	EndIf
ElseIf cCtdGetDad == "M->QUH_FILMAT"
	If oGetArea:aCols[N,nPosEfeAud] == "1"
		lRetorno := .F.
	EndIf
ElseIf cCtdGetDad == "M->QUH_CODAUD"
	If oGetArea:aCols[N,nPosEfeAud] == "1"
		lRetorno := .F.
	EndIf	
ElseIf cCtdGetDad == "M->QUH_CCUSTO"
	If oGetArea:aCols[N,nPosEfeAud] == "1"
		lRetorno := .F.
	EndIf
ElseIf cCtdGetDad == "M->QUH_CONFID"
	If oGetArea:aCols[N,nPosEfeAud] == "1"
		lRetorno := .F.
	EndIf
ElseIf cCtdGetDad == "M->QUJ_CHKLST"
	If oGetCheck:aCols[N,nPosEfeChk]	== "1" 
		lRetorno := .F.
	EndIf
	If !Empty(oGetCheck:aCols[N,nPosChkAud])
		lRetorno := .F.	
	Endif
ElseIf cCtdGetDad == "M->QUJ_REVIS"       
	If oGetCheck:aCols[N,nPosEfeChk] == "1" 
		lRetorno := .F.
	EndIf
ElseIf cCtdGetDad == "M->QUJ_CHKITE"
	If oGetCheck:aCols[N,nPosEfeChk] == "1" 
		lRetorno := .F.
	EndIf
ElseIf cCtdGetDad == "M->QUJ_NIVEL"       
	If oGetCheck:aCols[N,nPosEfeChk] == "1" 
		lRetorno := .F.
	EndIf
EndIf	

Return(lRetorno)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q100SendAud³ Autor ³Paulo Emidio de Barros³ Data ³01/11/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envia e-mail referente a Auditoria para areas envolvidas   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Q100SendAud(EXPC1,EXPD1,EXPD2,EXPC2,EXPO1,EXPN1)			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPO1 = Objeto da Tela Principal							  ³±±
±±³			 ³ EXPN1 = Opcao selecionada no aRotina					 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Q100SendAud(oDlg,nOpc)

Local nX        := 0
Local aUserMail := {}
Local aUserMail2:= {}
Local cSubject  := ""
Local cInsFil   := ""
Local cMail     := AllTrim(Posicione("QAA", 1, M->QUB_FILMAT+M->QUB_AUDLID,"QAA_EMAIL"))	// E-Mail Auditor Lider
Local cAudMail	:= ""
Local nCont		:= 0
Local nI			:= 0
Local nJ			:= 0	

cSubject:= Iif(nOpc <> 5, OemToAnsi(STR0024), OemToAnsi(STR0075)) + " - " + QUB->QUB_NUMAUD //"Realizacao de Auditoria"###"Auditoria Excluida"

If QUB->QUB_INIAUD # M->QUB_INIAUD .Or. QUB->QUB_ENCAUD # M->QUB_ENCAUD
	If nOpc == 4
		cSubject := OemToAnsi(STR0025) //"Alteracao na Data da Auditoria"
	EndIf	
EndIf   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta e-mail da Realizacao de Auditoria em Html. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cInsFil	 :=	 ""	 
For nX := 1 To Len(oGetArea:aCols)
	If !(oGetArea:aCols[nX,Len(oGetArea:aHeader)+1]) // marca de exclusao
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³e-mail da Area Auditada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(oGetArea:aCols[nX,nPosMaiQUH])
			Aadd(aUSerMail,{oGetArea:aCols[nX,nPosMaiQUH],cSubject,Q100AudMail(1,cSubject,.t., nOpc),cInsFil})
		Endif             
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³e-mail do Auditor³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(oGetArea:aCols[nX,nPosAudRes])
			QAA->(dbSetOrder(1))
			If QAA->(DBSeek(oGetArea:aCols[nX,nPosFilRes]+oGetArea:aCols[nX,nPosAudRes]))
				If !EMPTY(QAA->QAA_EMAIL) .And. QAA->QAA_RECMAI == "1"
					cAudMail:=QAA->QAA_EMAIL
					Aadd(aUSerMail,{cAudMail,cSubject,Q100AudMail(1,cSubject,.t., nOpc),cInsFil})
				EndIf
			EndIf
		EndIf
	EndIf
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³e-mail da Equipe de Apoio ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len(oGetAudit:aCols)
	If !(oGetAudit:aCols[nX,Len(oGetAudit:aHeader)+1]) // marca de exclusao
		If !Empty(oGetAudit:aCols[nX,nPosMaiQUC])	
			Aadd(aUSerMail,{oGetAudit:aCols[nX,nPosMaiQUC],cSubject,Q100AudMail(1, cSubject, Nil, nOpc),cInsFil})
		EndIf
	EndIf
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³e-mail dos  emails Associados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len(oGetMail:aCols)
	If !(oGetMail:aCols[nX,Len(oGetMail:aHeader)+1]) // marca de exclusao
	
		If !Empty(oGetMail:aCols[nX,nPosMaiQUI])	
			Aadd(aUSerMail,{oGetMail:aCols[nX,nPosMaiQUI],cSubject,Q100AudMail(1, cSubject, Nil, nOpc),cInsFil})
		EndIf
	EndIf
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³e-mail do Auditor Lider ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Ascan(aUserMail, { |x| Trim(Upper(x[1])) == Upper(Trim(cMail)) }) = 0	// Verifica se o auditor lider
	Aadd(aUSerMail,{cMail,cSubject,Q100AudMail(1,cSubject, Nil, nOpc),cInsFil})	// ja teve o e-mail incluido
Endif

//verifica se há e-mails duplicados
nCont++
While nCont <= Len(aUserMail)
	if Ascan(aUserMail2,{|X| X[1] == aUserMail[nCont,1]}) == 0 
		aAdd (aUserMail2,aUserMail[nCont])
	EndiF
	nCont++
EndDo														
         
//realiza a Conexao com o servidor
QAudEnvMail(aUserMail,,,,.T.,"2")

Return(NIL)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QAD100Leg  ³ Autor ³Paulo Emidio de Barros³ Data ³01/11/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exibe a legenda da Auditoria								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³QAD100Leg()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QAD100Leg()
Local aLegen := {}
Local i := 0
if !lPEQ100Leg
	BrwLegenda(cCadastro,STR0007, {	{"ENABLE"    ,STR0031 },; // "Auditorias" ### "Sem Resultado"
   							       	{"BR_AMARELO",STR0029 },; // "Resultados Parcialmente Respondido"
   							       	{"BR_PRETO"  ,STR0030 },; // "Liberada para Encerramento"
   							       	{"DISABLE"   ,STR0027 }}) // "Encerrada"
Else
   For i := 1 to Len(aLegenda)
   		Aadd(aLegen,{aLegenda[i][1],aLegenda[i][2]})
   Next
   BrwLegenda(cCadastro,STR0007, aLegen) 
EndIf
Return(NIL)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Q100DelAre³ Autor ³ Paulo Emidio de Barros³ Data ³31/05/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se a Area auditada podera ser excluida			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q100DelArea()											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QIEA215.PRW                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Q100DelArea()

Local lChkRsp 	:= .F.	// Indica se o check-list ja esta respondido
Local nP        := 1

If Altera
	If oGetArea:aCols[oGetArea:oBrowse:nAt,Len(oGetArea:aCols[oGetArea:oBrowse:nAt])]	
		If !Empty(oGetArea:aCols[oGetArea:oBrowse:nAt,nPosDesAud])
			If GetMv("MV_QEXIAUD", .T., .F.)
				QUD->(DbSetOrder(1))
				For nP:= 1 to Len(oGetCheck:aCols)
					If QUD->(DbSeek(xFilial("QUD") + M->QUB_NUMAUD + oGetArea:aCols[oGetArea:oBrowse:nAt,nPosSeq]+;
									oGetCheck:aCols[nP,nPosChkAud]+;
									oGetCheck:aCols[nP,nPosChkRev]+;
									oGetCheck:aCols[nP,nPosChkItem]))
						While 	QUD->QUD_FILIAL = xFilial("QUD") .And. QUD->QUD_NUMAUD = M->QUB_NUMAUD .And.;
								QUD->QUD_SEQ = oGetArea:aCols[oGetArea:oBrowse:nAt,nPosSeq] .And.;
								QUD->QUD_CHKLST = oGetCheck:aCols[nP,nPosChkAud] .And.;
								QUD->QUD_REVIS = oGetCheck:aCols[nP,nPosChkRev] .And.;
								QUD->QUD_CHKITE = oGetCheck:aCols[nP,nPosChkItem] .And.;
								! QUD->(Eof())
							If QUD->QUD_NOTA > 0
								lChkRsp := .T.
								Exit
							Endif
							QUD->(DbSkip())
						EndDo						
					Endif
					If lChkRsp
						Exit
					Endif
				Next
			Else
				lChkRsp := .T.
			Endif

			QUH->(dbSetOrder(1))
			If 	lChkRsp .And.;
				QUH->(dbSeek(xFilial("QUH")+M->QUB_NUMAUD+oGetArea:aCols[oGetArea:oBrowse:nAt,nPosSeq]))
				oGetArea:aCols[oGetArea:oBrowse:nAt,Len(oGetArea:aCols[oGetArea:oBrowse:nAt])] := .F.	
				Help("",1,"QADNAODEL")
				oGetArea:oBrowse:Refresh(.T.)
	        EndIf
	    EndIf
    EndIf
EndIf

Return(NIL)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Q100DeChkA³ Autor ³ Paulo Emidio de Barros³ Data ³31/05/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se os CheckLists poderao ser excluidos			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q100DeChkA()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QIEA215.PRW                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Q100DeChkAs() 

Local lChkRsp 	:= .F.	// Indica se o check-list ja esta respondido

If Altera
	If oGetCheck:aCols[oGetCheck:oBrowse:nAt,Len(oGetCheck:aCols[oGetCheck:oBrowse:nAt])]	
		If !Empty(oGetCheck:aCols[oGetCheck:oBrowse:nAt,nPosDesAud])		
			QUJ->(dbSetOrder(1))

			If GetMv("MV_QEXIAUD", .T., .F.)
				QUD->(DbSetOrder(1))
				If QUD->(DbSeek(xFilial() + M->QUB_NUMAUD + oGetArea:aCols[oGetArea:oBrowse:nAt,nPosSeq]+;
								oGetCheck:aCols[oGetCheck:oBrowse:nAt,nPosChkAud]+;
								oGetCheck:aCols[oGetCheck:oBrowse:nAt,nPosChkRev]+;
								oGetCheck:aCols[oGetCheck:oBrowse:nAt,nPosChkItem]))
					While 	QUD->QUD_FILIAL = xFilial("QUD") .And. QUD->QUD_NUMAUD = M->QUB_NUMAUD .And.;
							QUD->QUD_SEQ = oGetArea:aCols[oGetArea:oBrowse:nAt,nPosSeq] .And.;
							QUD->QUD_CHKLST = oGetCheck:aCols[oGetCheck:oBrowse:nAt,nPosChkAud] .And.;
							QUD->QUD_REVIS = oGetCheck:aCols[oGetCheck:oBrowse:nAt,nPosChkRev] .And.;
							QUD->QUD_CHKITE = oGetCheck:aCols[oGetCheck:oBrowse:nAt,nPosChkItem] .And.;
							! QUD->(Eof())
						If QUD->QUD_NOTA > 0
							lChkRsp := .T.
							Exit
						Endif
						QUD->(DbSkip())
					EndDo						
				Endif
			Else
				lChkRsp := .T.
			Endif
			
			If 	lChkRsp .And.;
				QUJ->(dbSeek(xFilial("QUJ")+M->QUB_NUMAUD+;
				oGetArea:aCols[oGetArea:oBrowse:nAt,nPosSeq]+;
				oGetCheck:aCols[oGetCheck:oBrowse:nAt,nPosChkAud]+;
				oGetCheck:aCols[oGetCheck:oBrowse:nAt,nPosChkRev]+;
				oGetCheck:aCols[oGetCheck:oBrowse:nAt,nPosChkItem]))
				oGetCheck:aCols[oGetCheck:oBrowse:nAt,Len(oGetCheck:aCols[oGetCheck:oBrowse:nAt])] := .F.	
				Help("",1,"QADNAODEL")
				oGetCheck:oBrowse:Refresh(.T.)
	        EndIf
	    EndIf
    EndIf
EndIf

Return(NIL)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Q100VrfAud³ Autor ³ Paulo Emidio de Barros³ Data ³07/06/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se a Area auditada ja foi informada				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q100VrfAud()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Falso ou Verdadeiro										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QADA100.PRW                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Q100VrfAud()

Local lRetorno := .T.
                
QUH->(dbSetOrder(1))
If QUH->(dbSeek(xFilial("QUH")+cNumAud+aCols[N,nPosSeq]))
	Help("",1,"100EXISARE")
	lRetorno := .F. 
EndIf	

Return(lRetorno)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Q100VldUsu³ Autor ³ Paulo Emidio de Barros³ Data ³07/09/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida a filial do Auditor vinculado a Auditoria.		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q100VldUsu()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Falso ou Verdadeiro										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QADA100.PRW                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Q100VldUsu()

Local lRetorno 	:= .T.
Local cFilMat	:= Space(FWSizeFilial())
Local cCodMat	:= ""

//Auditor Lider
If ReadVar() == 'M->QUB_FILMAT'.Or. ReadVar() == 'M->QUB_AUDLID'
	cFilMat := M->QUB_FILMAT
	cCodMat := M->QUB_AUDLID
EndIf

//Auditores responsaveis pelas Areas Auditadas
If ReadVar() == 'M->QUH_FILMAT'.Or. ReadVar() == 'M->QUH_CODAUD'
	If ReadVar() == 'M->QUH_FILMAT'
		cFilMat := M->QUH_FILMAT
	Else
		cFilMat := aCols[n][nPosFilRes]
	Endif
	
	If ReadVar() == 'M->QUH_CODAUD'
		cCodMat := M->QUH_CODAUD
	Else
		cCodMat := aCols[n][nPosAudRes]
	Endif
EndIf

//Auditores Equipe de Apoio vinculados a Auditoria
If ReadVar() == 'M->QUC_FILMAT'.Or. ReadVar() == 'M->QUC_CODAUD'
	If ReadVar() == 'M->QUC_FILMAT'
		cFilMat := M->QUC_FILMAT
	Else
		cFilMat := aCols[n][nPosFilAud]
	Endif
	
	If ReadVar() == 'M->QUC_CODAUD'
		cCodMat := M->QUC_CODAUD
	Else
		cCodMat := aCols[n][nPosCodAud]
	Endif
EndIf

If !Empty(cFilMat) .And. !Empty(cCodMat)
	lRetorno := QA_ChkMat(cFilMat,cCodMat)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verificacao se o usuario e Auditor³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF lRetorno
	   lRetorno:=POSICIONE("QAA",1,cFilMat+cCodMat,"QAA_AUDIT")=="1"
	   IF !lRetorno
	   		Msgalert(OemtoAnsi(STR0059 ))  //"Usuario escolhido nao esta autorizado como Auditor"                                                                                                                                                                                                           
	   Endif		
	Endif

EndIf
                        

Return(lRetorno)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Q100AudMail³ Autor ³ Eduardo de Souza     ³ Data ³15/10/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta email da Auditoria em Html                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QADAudMail(ExpC1,ExpC2)   								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Tipo do Email  (1 = Auditoria / 2 - Encerramento)  ³±±
±±³          ³ ExpC2 - Mesagem do Email                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAQAD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Q100AudMail(cTipo,cMensag,lMailDest,nOpc)

Local cText     := ""
Local aUsrMat   := QA_USUARIO()
Local cMatFil   := aUsrMat[2]
Local cMatCod   := aUsrMat[3]
Local cTitTop   := ""
Local cCodTop   := ""
Local nPosQUH   := 0
Local lSoLider	:= GetMv("MV_AUDSLID", .T., .F.)
Local cTpMail   := QAA->QAA_TPMAIL
Local lPrimeiro := .T.
Local cMsg		:= ""

If cTpMail == "1"
	cTpMail:= "1" // HTML
Else
	cTpMail:= "2" // TEXTO
EndIf

If cTpMail == "1"
	cMsg:= '<HTML>'
	cMsg+= '  <TITLE>SIGAQAD</TITLE>'
	cMsg+= '<BODY>'
	
	cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
	cMsg+= '  <TR><TD borderColor=#0099cc borderColorLight=#0099cc align=left width=606 '
	cMsg+= '    bgColor=#0099cc borderColorDark=#0099cc height=1>'
	cMsg+= '    <P align=center><FONT face="Courier New" color=#ffffff size=4>'
	cMsg+= '    <B>'+OemToAnsi(STR0032)+'</B></FONT></P></TD></TR>' // "MENSAGEM" 
	cMsg+= '  <TR><TD align=left width=606 height=32>'
	cMsg+= '    <P align=Center>'+cMensag+'</P></TD></TR>'
	cMsg+= '</TABLE><BR>'
	
	cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
	cMsg+= '  <TR><TD borderColor=#0099cc borderColorLight=#0099cc align=left width=606 '
	cMsg+= '    bgColor=#0099cc borderColorDark=#0099cc height=1>'
	cMsg+= '    <P align=center><font face="Courier New" color="#ffffff" size="4"><b>'+OemToAnsi(STR0033)+'</b></font></P></TD></TR>' // "AUDITORIA"
	cMsg+= '</TABLE>'
	
	cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
	cMsg+= '  <TR><TD align=left width=77 height=32><b>'+RetTitle("QUB_NUMAUD")+'</b><br>'+QUB->QUB_NUMAUD+'</TD>' // Auditoria
	cMsg+= '    <TD align=left width=483 height=32><B>' +RetTitle("QUB_MOTAUD")+'</b><br>'+Posicione("SX5",1,xFilial("SX5")+"QE"+QUB->QUB_MOTAUD,"X5DESCRI()")+'</TD></TR>' // Motivo
	cMsg+= '</TABLE>'
	
	cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
	cMsg+= '  <TR><TD align=left width=20% height=32><b>'+RetTitle("QUB_TIPAUD")+'</b><BR>'+QADCBox("QUB_TIPAUD", QUB->QUB_TIPAUD)+'</TD>' // Tipo
	cMsg+= '    <TD align=left width=20% height=32><b>'+RetTitle("QUB_REFAUD")+'</b><BR>'+dtoc(QUB->QUB_REFAUD)+'</TD>' // Referencia
	cMsg+= '    <TD align=left width=20% height=32><b>'+RetTitle("QUB_INIAUD")+'</b><BR>'+dtoc(QUB->QUB_INIAUD)+'</TD>' // Inicio
	cMsg+= '    <TD align=left width=20% height=32><b>'+OemToAnsi(STR0034)+'</b><BR>'+dtoc(QUB->QUB_ENCAUD)+'</TD>'     // "Enc. Previsto"
	cMsg+= '    <TD align=left width=20% height=32><b>'+OemToAnsi(STR0035)+'</b><BR>'+dtoc(QUB->QUB_ENCREA)+'</TD></TR>'// "Enc. Real"
	cMsg+= '</TABLE>'
	
	cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
	cMsg+= '  <TR><TD align=left width=100% height=32><b>'+OemToAnsi(STR0036)+'</b><br>'+Posicione("QAA",1,QUB->QUB_FILMAT+QUB->QUB_AUDLID,"QAA_NOME")+'</TD></TR>' // "Auditor Lider"
	cMsg+= '</TABLE>'
	
	If !Empty(QUB->QUB_AUDRSP)
		cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
		cMsg+= '  <TR><TD align=left width=100% height=32><b>'+OemToAnsi(STR0037)+'</b><br>'+QUB->QUB_AUDRSP+'</TD></TR>' // "Auditado Responsavel"
		cMsg+= '</TABLE>'
	EndIf
	
	If !Empty(QUB->QUB_CODFOR)
		cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
		cMsg+= '  <TR><TD align=left width=86 height=32><b>'+RetTitle("QUB_CODFOR")+'</b><br>'+QUB->QUB_CODFOR+'</TD>' // Fornecedor
		cMsg+= '    <TD align=left width=543 height=32><b>'+OemToAnsi(STR0038)+'</b><br>'+Posicione("SA2",1,xFilial("SA2")+QUB->QUB_CODFOR,"A2_NOME")+'</TD></TR>' // "Razao Social"
		cMsg+= '</TABLE>'
	EndIf
	
	cMsg+= '&nbsp;'
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Descricao da Auditoria                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cText:= MsMM(QUB->QUB_DESCHV,TamSx3("QUB_DESCR1")[1])
	If !Empty(cText)
		cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
		cMsg+= '  <TR><TD borderColor=#0099cc borderColorLight=#0099cc align=left width=606 bgColor=#0099cc borderColorDark=#0099cc height=1>'
		cMsg+= '    <P align=center><font face="Courier New" color="#ffffff" size="4"><b>'+Upper(OemToAnsi(STR0012))+'</b></font></P></TD></TR>' // DESCRICAO
		cMsg+= '</TABLE>'
		
		cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1><tr>'
		cMsg+= '  <TD align=left width=100% height=32>'+cText+'</TD></tr>'
		cMsg+= '</TABLE>'
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Areas Auditadas   				             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMsg+= '&nbsp;'
	cMsg+= '<table borderColor="#0099cc" height="29" cellSpacing="1" width="645" borderColorLight="#0099cc" border="1">'
	cMsg+= '  <tbody>'
	cMsg+= '    <tr>'
	cMsg+= '      <td borderColor="#0099cc" borderColorLight="#0099cc" align="left" width="606" bgColor="#0099cc" borderColorDark="#0099cc" height="1">'
	cMsg+= '        <p align="center"><font face="Courier New" color="#ffffff" size="4"><b>'+Upper(OemToAnsi(STR0013))+'</b></font></p>'
	cMsg+= '      </td>'
	cMsg+= '    </tr>'
	cMsg+= '  </tbody>'
	cMsg+= '</table>'
	
	nPosQUH:= QUH->(RecNo())
	If QUH->(DbSeek(xFilial("QUH")+QUB->QUB_NUMAUD))
		While QUH->(!Eof()) .And. QUH->QUH_FILIAL+QUH->QUH_NUMAUD == xFilial("QUH")+QUB->QUB_NUMAUD
			If 	lSoLider .And.;
				QUH->QUH_FILMAT + QUH->QUH_CODAUD <> cMatFil + cMatCod .And.;
				QUB->QUB_FILMAT + QUB->QUB_AUDLID <> cMatFil + cMatCod
				QUH->(DbSkip())
				Loop
			Endif
		
			If lPrimeiro
				cMsg+= '<br>'
				cMsg+= '<table borderColor="#0099cc" height="29" cellSpacing="1" width="645" borderColorLight="#0099cc" border="1">'
				cMsg+= '  <tbody>'
			Endif
			
			cMsg+= '    <tr>'
			cMsg+= '      <td align="left" width="286" height="32"><b>'+OemToAnsi(STR0039)+'</b><br>'+QUH->QUH_DESTIN+'</td> ' // Area Auditada
			cMsg+= '      <td align="left" width="343" height="32"><b>'+OemToAnsi(STR0040)+'</b><br>'+QA_NUSR(QUH->QUH_FILMAT,QUH->QUH_CODAUD)+'</td>' // Auditor 
			cMsg+= '    </tr>'
			
			lPrimeiro := .F.
	    	QUH->(DbSkip())
		EndDo
		If ! lPrimeiro
			cMsg+= '  </tbody>'
			cMsg+= '</table>'
		Endif
	EndIf
	QUH->(DbGoto(nPosQUH))
	
	cMsg+= '&nbsp;'
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Equipe de Apoio     				             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If QUC->(DbSeek(xFilial("QUC")+QUB->QUB_NUMAUD))
		cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
		cMsg+= '  <TR><TD borderColor=#0099cc borderColorLight=#0099cc align=left width=606 '
		cMsg+= '    bgColor=#0099cc borderColorDark=#0099cc height=1>'
		cMsg+= '    <p align="center"><font face="Courier New" color="#ffffff" size="4"><b>'+Upper(OemToAnsi(STR0014))+'</b></font></TD></TR>' // "Equipe de Apoio"
		cMsg+= '</TABLE>'
		
		cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
		
		While QUC->(!Eof()) .And. QUC->QUC_FILIAL+QUC->QUC_NUMAUD == xFilial("QUC")+QUB->QUB_NUMAUD
			cMsg+= '  <tr><TD align=left width=100% height=32>'+QA_NUSR(QUC->QUC_FILMAT,QUC->QUC_CODAUD)+'</TD></tr>'
			QUC->(DbSkip())
		EndDo
		cMsg+= '</TABLE>'
	EndIf
	
	If cTipo == 2 // Encerramento de Auditoria
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Nao-Conformidades                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPosQUH:= QUH->(RecNo())
		If QUH->(DbSeek(xFilial("QUH")+QUB->QUB_NUMAUD))
			While QUH->(!Eof()) .And. QUH->QUH_FILIAL+QUH->QUH_NUMAUD == xFilial("QUH")+QUB->QUB_NUMAUD
				If 	lSoLider .And.;
					QUH->QUH_FILMAT + QUH->QUH_CODAUD <> cMatFil + cMatCod .And.;
					QUB->QUB_FILMAT + QUB->QUB_AUDLID <> cMatFil + cMatCod
					QUH->(DbSkip())
					Loop
				Endif
				
				QUG->(dbSetOrder(1))
				If QUG->(dbSeek(xFilial("QUG")+QUH->QUH_NUMAUD+QUH->QUH_SEQ))
					cMsg+= '&nbsp;'
					cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
					cMsg+= '  <TR><TD borderColor=#0099cc borderColorLight=#0099cc align=left width=606 '
					cMsg+= '    bgColor=#0099cc borderColorDark=#0099cc height=1>'
					cMsg+= '    <p align="center"><font face="Courier New" color="#ffffff" size="4"><b>'+OemToAnsi(STR0044)+'</b></font></TD></TR>' // "NAO-CONFORMIDADES"
					cMsg+= '</TABLE>'
					
					While QUG->(!Eof()) .And. QUG->QUG_FILIAL+QUG->QUG_NUMAUD+QUG->QUG_SEQ == xFilial("QUG")+QUH->QUH_NUMAUD+QUH->QUH_SEQ
						
						cTitTop:= RetTitle("QU3_CHKITE")
						cCodTop:= QUG->QUG_CHKITE
						IF QU3->(DBSeeK(xFILIAL("QU3")+QUG->QUG_CHKLST+QUG->QUG_REVIS+cCodTop))
							cDesTop:= QU3->QU3_DESCRI
							If !Empty(QU3->QU3_NORMA)
								cTitTop+= ' / '+RetTitle("QU3_NORMA")
								cCodTop+= ' / '+QU3->QU3_NORMA
							EndIf
						EndIf
						
						cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
						cMsg+= '  <tr>'
						cMsg+= '    <TD align=left width=100% height=32><b>'+cTitTop+'</b><br>'+cCodTop+' - '+cDesTop+'</TD>' // Topico/Norma
						cMsg+= '  </tr>'
						cMsg+= '</TABLE>'
						
						cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
						cMsg+= '  <tr>'
						cMsg+= '    <TD align=left width=100% height=32><b>'+OemToAnsi(STR0039)+'</b><br>'+QUH->QUH_DESTIN+'</TD>'
						cMsg+= '  </tr>'
						cMsg+= '</TABLE>'
						
						cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
						cMsg+= '  <tr>'
						cMsg+= '    <TD align=left width=100% height=32><b>'+OemToAnsi(STR0012)+'</b><br>'+MsMM(QUG->QUG_DESCHV,TamSX3('QUG_DESC1')[1])+'</TD>'
						cMsg+= '  </tr>'
						cMsg+= '</TABLE>'
						
						QUG->(dbSkip())
					EndDo
				EndIf
				
				QUH->(DbSkip())
			EndDo
		EndIf
		QUH->(DbGoto(nPosQUH))
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Observacao                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cText := MsMM(QUB->QUB_SUGCHV,TamSX3('QUB_SUGOBS')[1])
		If !Empty(cText)
			cMsg+= '&nbsp;'
			cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
			cMsg+= '  <TR><TD borderColor=#0099cc borderColorLight=#0099cc align=left width=606 bgColor=#0099cc borderColorDark=#0099cc height=1>'
			cMsg+= '    <P align=center><font face="Courier New" color="#ffffff" size="4"><b>'+Upper(RetTitle("QUB_SUGOBS"))+'</b></font></P></TD></TR>'
			cMsg+= '</TABLE>'
			
			cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1><tr>'
			cMsg+= '  <TD align=left width=100% height=32>'+cText+'</TD></tr>'
			cMsg+= '</TABLE>'
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Conclusao da Auditoria                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cText:= M->QUB_CONCLU
		If !Empty(cText)
			cMsg+= '&nbsp;'
			cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
			cMsg+= '  <TR><TD borderColor=#0099cc borderColorLight=#0099cc align=left width=606 bgColor=#0099cc borderColorDark=#0099cc height=1>'
			cMsg+= '    <P align=center><font face="Courier New" color="#ffffff" size="4"><b>'+Upper(RetTitle("QUB_CONCLU"))+'</b></font></P></TD></TR>' // CONCLUSAO
			cMsg+= '</TABLE>'
			
			cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1><tr>'
			cMsg+= '  <TD align=left width=100% height=32>'+cText+'</TD></tr>'
			cMsg+= '</TABLE>'
		EndIf
	EndIf
	
	cMsg+= '<p><FONT size=2><EM>'+OemToAnsi(STR0043)+'</EM></FONT></p>' // "Mensagem gerada automaticamente pelo Sistema SIGAQAD - Controle de Auditorias"
	cMsg+= '</BODY>'
	cMsg+= '</HTML>'

ElseIf cTpMail == "2"

	cMsg:= cMensag+CHR(13)+CHR(10)+CHR(13)+CHR(10)
	cMsg+= OemToAnsi(STR0033)+CHR(13)+CHR(10)+CHR(13)+CHR(10) // "AUDITORIA"
	cMsg+= RetTitle("QUB_NUMAUD")+": "+QUB->QUB_NUMAUD+CHR(13)+CHR(10) // Auditoria
	cMsg+= RetTitle("QUB_MOTAUD")+": "+Posicione("SX5",1,xFilial("SX5")+"QE"+QUB->QUB_MOTAUD,"X5DESCRI()")+CHR(13)+CHR(10) // Motivo
	cMsg+= RetTitle("QUB_TIPAUD")+": "+QADCBox("QUB_TIPAUD", QUB->QUB_TIPAUD)+CHR(13)+CHR(10) // Tipo
	cMsg+= RetTitle("QUB_REFAUD")+": "+dtoc(QUB->QUB_REFAUD)+CHR(13)+CHR(10) // Referencia
	cMsg+= RetTitle("QUB_INIAUD")+": "+dtoc(QUB->QUB_INIAUD)+CHR(13)+CHR(10) // Inicio
	cMsg+= OemToAnsi(STR0034)+":  "+dtoc(QUB->QUB_ENCAUD)+CHR(13)+CHR(10) // "Enc. Previsto"
	cMsg+= OemToAnsi(STR0035)+":  "+dtoc(QUB->QUB_ENCREA)+CHR(13)+CHR(10)// "Enc. Real"
	cMsg+= OemToAnsi(STR0036)+":  "+Posicione("QAA",1,QUB->QUB_FILMAT+QUB->QUB_AUDLID,"QAA_NOME")+CHR(13)+CHR(10) // "Auditor Lider"

	If !Empty(QUB->QUB_AUDRSP)
		cMsg+= OemToAnsi(STR0037)+": "+QUB->QUB_AUDRSP+CHR(13)+CHR(10) // "Auditado Responsavel"
	EndIf
	
	If !Empty(QUB->QUB_CODFOR)
		cMsg+= RetTitle("QUB_CODFOR")+": "+QUB->QUB_CODFOR+CHR(13)+CHR(10) // Fornecedor
		cMsg+= OemToAnsi(STR0038)+": "+Posicione("SA2",1,xFilial("SA2")+QUB->QUB_CODFOR,"A2_NOME")+CHR(13)+CHR(10) // "Razao Social"
	EndIf

	cMsg+= CHR(13)+CHR(10)	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Descricao da Auditoria                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cText:= MsMM(QUB->QUB_DESCHV,TamSx3("QUB_DESCR1")[1])
	If !Empty(cText)
		cMsg+= Upper(OemToAnsi(STR0012))+CHR(13)+CHR(10) // DESCRICAO
		cMsg+= cText+CHR(13)+CHR(10)
		cMsg+= CHR(13)+CHR(10)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Areas Auditadas   				             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMsg+= Upper(OemToAnsi(STR0013))+CHR(13)+CHR(10)+CHR(13)+CHR(10)

	nPosQUH:= QUH->(RecNo())
	If QUH->(DbSeek(xFilial("QUH")+QUB->QUB_NUMAUD))
		While QUH->(!Eof()) .And. QUH->QUH_FILIAL+QUH->QUH_NUMAUD == xFilial("QUH")+QUB->QUB_NUMAUD
			If 	lSoLider .And.;
				QUH->QUH_FILMAT + QUH->QUH_CODAUD <> cMatFil + cMatCod .And.;
				QUB->QUB_FILMAT + QUB->QUB_AUDLID <> cMatFil + cMatCod
				QUH->(DbSkip())
				Loop
			Endif

			cMsg+= OemToAnsi(STR0039)+": "+QUH->QUH_DESTIN+CHR(13)+CHR(10) // Area Auditada
			cMsg+= OemToAnsi(STR0040)+": "+QA_NUSR(QUH->QUH_FILMAT,QUH->QUH_CODAUD)+CHR(13)+CHR(10)+CHR(13)+CHR(10) // Auditor

	    	QUH->(DbSkip())
		EndDo
	EndIf
	QUH->(DbGoto(nPosQUH))
	
	cMsg+= CHR(13)+CHR(10)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Equipe de Apoio        	                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If QUC->(DbSeek(xFilial("QUC")+QUB->QUB_NUMAUD))
		cMsg+= Upper(OemToAnsi(STR0014))+CHR(13)+CHR(10) // "Equipe de Apoio"
		While QUC->(!Eof()) .And. QUC->QUC_FILIAL+QUC->QUC_NUMAUD == xFilial("QUC")+QUB->QUB_NUMAUD
			cMsg+= QA_NUSR(QUC->QUC_FILMAT,QUC->QUC_CODAUD)+CHR(13)+CHR(10)
			QUC->(DbSkip())
		EndDo
		cMsg+= CHR(13)+CHR(10)
	EndIf
	
	If cTipo == 2 // Encerramento de Auditoria
	
		nPosQUH:= QUH->(RecNo())
		If QUH->(DbSeek(xFilial("QUH")+QUB->QUB_NUMAUD))
			While QUH->(!Eof()) .And. QUH->QUH_FILIAL+QUH->QUH_NUMAUD == xFilial("QUH")+QUB->QUB_NUMAUD
				If 	lSoLider .And.;
					QUH->QUH_FILMAT + QUH->QUH_CODAUD <> cMatFil + cMatCod .And.;
					QUB->QUB_FILMAT + QUB->QUB_AUDLID <> cMatFil + cMatCod
					QUH->(DbSkip())
					Loop
				Endif
				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Nao-Conformidades                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QUG->(dbSetOrder(1))
		If QUG->(dbSeek(xFilial("QUG")+QUH->QUH_NUMAUD+QUH->QUH_SEQ))
			cMsg+= OemToAnsi(STR0044)+CHR(13)+CHR(10) // "NAO-CONFORMIDADES"
			While QUG->(!Eof()) .And. QUG->QUG_FILIAL+QUG->QUG_NUMAUD+QUG->QUG_SEQ == xFilial("QUG")+QUH->QUH_NUMAUD+QUH->QUH_SEQ	
						
						cTitTop:= RetTitle("QU3_CHKITE")
						cCodTop:= QUG->QUG_CHKITE
						IF QU3->(DBSeeK(xFILIAL("QU3")+QUG->QUG_CHKLST+QUG->QUG_REVIS+cCodTop))
							cDesTop:= QU3->QU3_DESCRI
							If !Empty(QU3->QU3_NORMA)
								cTitTop+= ' / '+RetTitle("QU3_NORMA")
								cCodTop+= ' / '+QU3->QU3_NORMA
							EndIf
						Endif
						
						cMsg+= cTitTop+" - "+cCodTop+" - "+cDesTop+CHR(13)+CHR(10) // Topico/Norma
				cMsg+= OemToAnsi(STR0012)+": "+MsMM(QUG->QUG_DESCHV,TamSX3('QUG_DESC1')[1])+CHR(13)+CHR(10)
				cMsg+= CHR(13)+CHR(10)

				QUG->(dbSkip())
			EndDo
		EndIf    
				QUH->(DbSkip())
			EndDo
		EndIf
		QUH->(DbGoto(nPosQUH))
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Observacao                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		cText := MsMM(QUB->QUB_SUGCHV,TamSX3('QUB_SUGOBS')[1])
		If !Empty(cText)
			cMsg+= Upper(RetTitle("QUB_SUGOBS"))+CHR(13)+CHR(10)
			cMsg+= cText+CHR(13)+CHR(10)+CHR(13)+CHR(10)
        EndIf
	    
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Conclusao da Auditoria                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cText:= M->QUB_CONCLU 
		If !Empty(cText)
			cMsg+= Upper(RetTitle("QUB_CONCLU"))+CHR(13)+CHR(10) // CONCLUSAO		
			cMsg+= cText+CHR(13)+CHR(10)+CHR(13)+CHR(10)
		EndIf
	EndIf
	cMsg+= OemToAnsi(STR0043) // "Mensagem gerada automaticamente pelo Sistema SIGAQAD - Controle de Auditorias"
EndIf

IF cTipo == 1
	// ponto de entrada - permite a alteracao do conteudo cMsg QDO nao e Encerramento
	If ExistBlock( "Q100MAIL" )
		cMsg := ExecBlock( "Q100MAIL", .f., .f.,{cMsg} )
	Endif
Endif	

Return cMsg

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Q100FilChkLst³ Autor ³ Paulo Emidio       ³ Data ³10/11/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Filtra Check-List por Area Auditada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q100FilChkLst(ExpN1)	      								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao do Browse                      			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAQAD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Q100FilChkLst(nOpc)

Local nArea
Local aAreaAnt := GetArea()          
Local cSeek 
Local aColsAux
Local nCpo 
Local aDadosAux := {}
Local aDadosCQst := {}  // Array das questoes por Check-list
Local aDadosAQst := {}  // Array das questoes por Area+Check-list

For nArea := 1 to Len(aDadosAud[2])//Areas Auditadas

	aColsAux := {}
	aDadosAQst := {}
	cSeek := M->QUB_NUMAUD+aDadosAud[2,nArea,nPosSeq]
    dbSelectArea("QUJ")
  	dbSetOrder(1)
	If dbSeek(xFilial("QUJ")+cSeek)
		While !Eof() .And. (QUJ_FILIAL+QUJ_NUMAUD+QUJ_SEQ)==xFilial("QUJ")+cSeek
		    Aadd(aColsAux,Array(nUsado+1))          
			For nCpo := 1 To Len(aHeader) 
			    cCpoGrv := FieldName(FieldPos(AllTrim(aHeader[nCpo,2])))
			    aColsAux[Len(aColsAux),nCpo] := &cCpoGrv
		    Next nCpo                
			AcolsAux[Len(aColsAux),nPosDesChk] := Posicione("QU2",1,xFilial("QU2")+;
			AcolsAux[Len(aColsAux),nPosChkAud]+AcolsAux[Len(aColsAux),nPosChkRev],"QU2_DESCRI")
			If nPosAli > 0 .and. nPosRec > 0
				AcolsAux[Len(aColsAux),nPosAli] := QUJ->(Alias())
				If IsHeadRec(aHeader[nPosRec,2])
					AcolsAux[Len(aColsAux),nPosRec] := QUJ->(RecNo())
				EndIf
			Endif
    	    aColsAux[Len(aColsAux),nUsado+1] := .F.
			aDadosCQst := {}
			If QUD->(dbSeek(xFilial("QUD")+cSeek+QUJ->QUJ_CHKLST+QUJ->QUJ_REVIS+QUJ->QUJ_CHKITE))
				While QUD->(!Eof()) .And. QUD->QUD_FILIAL+QUD->QUD_NUMAUD+QUD->QUD_SEQ+QUD->QUD_CHKLST+QUD->QUD_REVIS+QUD->QUD_CHKITE==xFilial("QUD")+cSeek+QUJ->QUJ_CHKLST+QUJ->QUJ_REVIS+QUJ->QUJ_CHKITE
					aAdd(aDadosCQst,{QUD->QUD_SEQ, QUD->QUD_CHKLST,QUD->QUD_REVIS,QUD->QUD_CHKITE,QUD->QUD_QSTITE,If(Empty(QUD->QUD_APLICA),"1",QUD->QUD_APLICA),QUD->QUD_TIPO} )
					QUD->(dbSkip())
				Enddo
				Aadd(aDadosAQst,aClone(aDadosCQst))
 				Endif
			dbSkip()		
		EndDo	   	
	Else
		aColsAux := Q100FilaCols("QUJ",3,1,3,@aHeadSav,@aDadosAud)
		aAdd(aDadosAQst,{{" ", " "," "," "," "," "," "}} )
	EndIf	       
	Aadd(aDadosAux,aClone(aColsAux))
	Aadd(aDadosQst,aClone(aDadosAQst))
	
Next nArea

RestArea(aAreaAnt)

Return(aDadosAux)

/*ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³q100DelChk³ Autor ³ Marcelo Iuspa			³ Data ³24/10/00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exclui os dados no arquivo de movimentos (QUD)			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ q100DelChk(EXPA1,EXPC1,EXPC2,EXPC3)						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPA1 = Vetor contendo os numeros do registros             ³±±
±±³          ³ EXPC1 = Numero da Auditoria								  ³±±
±±³          ³ EXPC2 = ordem do Indice corrente							  ³±±
±±³          ³ EXPC3 = Chave a ser utilizada							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/                     
 
Static Function q100DelChk(cNumAud,cAlias,cKey)
Local aOldArea := GetArea()
Local cCondQUD := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Os movimentos no QUD sao excluidos baseados no Check List e  ³
//³ Areas auditadas.                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
If cAlias = "QUH"
	cCondQUD := "QUD_NUMAUD+QUD_SEQ"   
ElseIf cAlias = "QUJ"
	cCondQUD := "QUD_NUMAUD+QUD_SEQ+QUD_CHKLST+QUD_REVIS+QUD_CHKITE"
EndIf		

dbSelectArea("QUD")
dbSetOrder(1)
IF QUD->(dbSeek(xFilial("QUD")+cKey))
	While QUD->(!Eof()) .And. QUD_FILIAL == xFilial("QUD").And. &cCondQUD == cKey
		RecLock("QUD",.F.)
		dbDelete()
		MsUnlock()
		FKCOMMIT()
	    dbSkip()
	EndDo
Endif
	
RestArea(aOldArea)
Return(NIL)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Q100Reun  ºAutor  ³Telso Carneiro      º Data ³  01/21/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡ao ³ Cadastros de Reunioes                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Qad100Man                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function Q100Reun(nOpcx,cNumAud,aHeaReu,aColReu,oDlg) 

Local oDlgR
Local nOpca
Local aButtons:={}                             
Local nPosArq 

Private oGetReu       

DEFINE MSDIALOG oDlgR FROM aMsSize[7],000 TO aMsSize[7]+aMsSize[4],aMsSize[5] TITLE OemToAnsi(STR0058) OF oDlg Pixel //"Cadastro de Reunioes"

RegToMemory("QUK")

dbSelectArea("QUK") 
IF Len(aHeaReu)==0
	aHeaReu :=aClone(APBuildHeader("QUK", {"QUK_CODOBS"}))
	ADHeadRec("QUK",aHeaReu)
ENDIF	                                  
IF Len(aColReu)==0
	aColReu :=aClone(Q100aCols(nOpcx,aHeaReu))
ENDIF

nPosArq :=GdFieldPos("QUK_ANEXO",aHeaReu)

aAdd(aButtons,{"SDUPROP" , {|| oGetReu:aCols[oGetReu:NAT,nPosArq]:=FQADGRATA(nOpcx,cNumAud,oGetReu:aCols[oGetReu:NAT,nPosArq]), oGetReu:Refresh()  } ,OemtoAnsi(STR0056),OemtoAnsi(STR0057) } )  //"Ata Reunião"###"Ata"

oGetReu :=MsNewGetDados():New(013,02,120,337,Iif(Altera .Or. Inclui,GD_INSERT+GD_DELETE+GD_UPDATE,0),"AllwaysTrue()",{|| Q100ReTUOk() },,,,99,,,{|| Q100DelOk() },oDlgR,aHeaReu,aColReu)
oGetReu:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT
                              
ACTIVATE MSDIALOG oDlgR ON INIT EnchoiceBar(oDlgR,{|| If( Q100ReTUOk() ,(nOpca:=1,oDlgR:End()),nOpca:=0) },{|| nOpca:= 0,oDlgR:End()},,aButtons) 

IF nOpca==1
 	aHeaReu:=aClone(oGetReu:aHeader)
 	aColReu:=aClone(oGetReu:aCols)
Else
	aHeaReu:={}          
	aColReu:={}	
ENDIF

Return(NIL)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FQADGRATA ºAutor  ³Microsiga           º Data ³  01/22/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Abre e grava e copia anexo da ata                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Q100Reun                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

STATIC FUNCTION FQADGRATA(nOpcx,cNumAud,cArquivo)

Local nPosReu := GdFieldPos("QUK_CODREU",oGetReu:aHeader) 
Local cNewArq := alltrim(cNumAud)+"REU"+Alltrim(oGetReu:aCols[oGetReu:NAT,nPosReu])+".xxx"
Local cQPathQAD:= Alltrim(GetMv("MV_QADPDOC"))
Local nHandle    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³consistencia do parametro de Anexos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF Empty(cQPathQAD)  
	Help(" ",1,"QADNAOANEX")	
	Return(cArquivo) 
Endif

If !Right( cQPathQAD,1 ) == "\"
	cQPathQAD := cQPathQAD + "\"
Endif

nHandle := fCreate(cQPathQAD+"SIGATST.CEL")
If nHandle <> -1  // Consegui criar e vou fechar e apagar novamente...
	fClose(nHandle)
	fErase(cQPathQAD+"SIGATST.CEL")
Else
	Help(" ",1,"QADNAOANEX")	
	Return(cArquivo) 
EndIf

IF EMPTY(cArquivo)
	cArquivo:=FQADDrive(nOpcx,,cNewArq)
Else
	FQADDrive(nOpcx,cArquivo)
Endif	      
	
Return(cArquivo) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q100aCols ³ Autor ³ Telso Carneiro        ³ Data ³21/01/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta o aCols de acordo com a opcao escolhida:             ³±±
±±³          ³ Inclusao, Alteracao, Exclusao e Consulta                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³ Q100Reun                                                   º±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q100aCols(nOpcx,aHeaReu)
Local nCnt  
Local cCpoGrv      
Local cKeyChkLst       
Local aAreaQUK
Local nX                        
Local nUsado   := Len(aHeaReu)
Local aColsAux := {}         
Local nPosMM   := GdFieldPos("QUK_MEMO1",aHeaReu)
Local nPosAli  := Ascan(aHeaReu,{|X| Upper( Alltrim(X[2])) == "QUK_ALI_WT"})
Local nPosRec  := Ascan(aHeaReu,{|X| Upper( Alltrim(X[2])) == "QUK_REC_WT"})
Local cTipo 	:= ""
Local aStruct

aAreaQUK := QUK->(GetARea())

If nOpcx == 3 //Inclusao

	Aadd(aColsAux,Array(nUsado+1))
	nUsado := 0
	aStruct := FWFormStruct(3,"QUK")[3] // Busca os campos usados (X3_USADO) da tabela
	For nX := 1 to Len(aStruct)
		If cNivel >= GetSx3Cache(aStruct[nX,1],"X3_NIVEL")
			nUsado++
			cTipo := GetSx3Cache(aStruct[nX,1],"X3_TIPO")                           
	        
	        If cTipo == "C"
	   	        aColsAux[1,nUsado] := SPACE(GetSx3Cache(aStruct[nX,1],"X3_TAMANHO"))
	       	Elseif cTipo == "N"
	           	aColsAux[1,nUsado] := 0
	        Elseif cTipo == "D"
	   	        aColsAux[1,nUsado] := dDataBase
	       	Elseif cTipo == "M"
	            aColsAux[1,nUsado] := ""
	   	    Else
	       	    aColsAux[1,nUsado] := .F.
	        Endif
	   		
	   		If GetSx3Cache(aStruct[nX,1],"X3_CONTEXT") == "V"
				aColsAux[1,nUsado]:= CriaVar(AllTrim(aStruct[nX,1]))
			Else
			    IF Alltrim(aStruct[nX,1])=="QUK_CODREU"
					aColsAux[1,nUsado]:= "01"					
				ELSEIF !EMPTY(GetSx3Cache(aStruct[nX,1],"X3_RELACAO"))
					aColsAux[1,nUsado]:= InitPAd(GetSx3Cache(aStruct[nX,1],"X3_RELACAO"))
				ENDIF	
			Endif
		EndIf 
	Next nX
	             
	If nPosAli > 0 .and. nPosRec > 0
		AcolsAux[Len(aColsAux),nPosAli] := QUK->(Alias())
		If IsHeadRec(aHeaReu[nPosRec,2])
			AcolsAux[Len(aColsAux),nPosRec] := 0
		EndIf
	Endif	
	aColsAux[1,Len(aHeaReu)+1] := .F.     
Else 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Salva o indice corrente e o registro para ser utilizado na Alteracao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	

	dbSelectArea("QUK")	
	dbSetOrder(1)
	dbSeek(xFilial("QUK")+QUB->QUB_NUMAUD)

	While QUK->(!Eof()) .And. xFilial("QUK") == QUK->QUK_FILIAL .And. ;
		QUK->QUK_NUMAUD==M->QUB_NUMAUD  
            
	    Aadd(aColsAux,Array(nUsado+1))          
	    
		For nX := 1 To Len(aHeaReu) 
			cCpoGrv := FieldName(FieldPos(AllTrim(aHeaReu[nX,2])))
	    	aColsAux[Len(aColsAux),nX] := &cCpoGrv	
	    Next                   
	    
		aColsAux[Len(aColsAux),nPosMM] := MsMM(QUK_CODOBS,TamSX3('QUK_MEMO1')[1])
		If nPosAli > 0 .and. nPosRec > 0
			AcolsAux[Len(aColsAux),nPosAli] := QUK->(Alias())
			If IsHeadRec(aHeaReu[nPosRec,2])
				AcolsAux[Len(aColsAux),nPosRec] := QUK->(RecNo())
			EndIf
		Endif	
    	aColsAux[Len(aColsAux),Len(aHeaReu)+1] := .F.

    	QUK->(dbSkip())
    EndDo                     
EndIf

//Recupera a area corrente do QUK
QUK->(RestArea(aAreaQUK))	

Return(aColsAux)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Q100ReTUOkºAutor  ³Microsiga           º Data ³  01/22/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Tudook Validacao do cadastro de Reunioes                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Q100Reun                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Q100ReTUOk()

Local lRet:= .T.
Local i,Y
Local nPosArq :=GdFieldPos("QUK_ANEXO",oGetReu:aHeader)
Local nPosMM  :=GdFieldPos("QUK_MEMO1",oGetReu:aHeader)

For i:=1 TO LEN(oGetReu:aCols)
    IF !oGetReu:aCols[i,LEN(oGetReu:aHeader)+1]
	    For Y:=1 TO LEN(oGetReu:aHeader)-2
			IF EMPTY(oGetReu:aCols[i,Y]) .AND. Y!=nPosArq .AND. Y!=nPosMM
				lRet:=.F.
				Help("",1,"OBRIGAT")
				EXIT
			ENDIF		    	     
		Next
	ENDIF
	IF !lRet
		EXIT
	ENDIF	
Next		

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Q100DelOk ºAutor  ³Microsiga           º Data ³  22/01/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Delok Validacao de delecao do cadastro de Reunioes          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Q100Reun                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Q100DelOk()

Local lRet:= .T.
Local i
Local nPosReu :=GdFieldPos("QUK_CODREU",oGetReu:aHeader)
Local cCodReu :=oGetReu:aCols[oGetReu:NAT,nPosReu]

For i:=LEN(oGetReu:aCols) TO 1 STEP -1
    IF !oGetReu:aCols[i,LEN(oGetReu:aHeader)+1]
		IF cCodReu<oGetReu:aCols[i,nPosReu]
			lRet:=.F.
			EXIT
		ENDIF 
	ELSE
		IF cCodReu>oGetReu:aCols[i,nPosReu]
			lRet:=.F.
			EXIT
		ENDIF 				    	     
	ENDIF
Next		
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Q100GrREu ºAutor  ³Microsiga           º Data ³  01/22/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava os dados do cadastro de Reunioes                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Q100Reun                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Q100GrREu(cNumAud,aHeaReu,aColReu)

Local i,T
Local cNomCp:=""
Local cQPathQAD:= Alltrim(GetMv("MV_QADPDOC"))
Local aQPath   := QDOPATH()
Local cQPathTrm:= aQPath[3]
Local nPosCod  := GdFieldPos("QUK_CODREU",aHeaReu) 
Local nPosMM   := GdFieldPos("QUK_MEMO1",aHeaReu) 
Local nPosAx   := GdFieldPos("QUK_ANEXO",aHeaReu) 
Local nPosOri  := GdFieldPos("QUK_ORIGEM",aHeaReu) 

If !Right( cQPathQAD,1 ) == "\"
	cQPathQAD := cQPathQAD + "\"
Endif
If !Right( cQPathTrm,1 ) == "\"
	cQPathTrm := cQPathTrm + "\"
Endif

FOR T:=1 TO Len(aColReu)
	IF !aColReu[T,Len(aHeaReu)+1]
		DbSelectArea("QUK")
		DbSetOrder(1)
		IF DBSeeK(xFilial("QUK")+cNumAud+aColReu[T,nPosOri]+aColReu[T,nPosCod])
			Reclock("QUK",.F.)
			For i:=1 to LEN(aHeaReu)
				cNomCp:= AllTrim(aHeaReu[i,2])
				nPosCp:= GdFieldPos(cNomCp,aHeaReu)                    
				IF cNomCp!="QUK_ANEXO" 
					IF cNomCp!="QUK_CODREU" .OR. cNomCp!="QUK_MEMO1"
						QUK->(FieldPut(FieldPos(cNomCp),aColReu[T,nPosCp]))
					Endif	
				Else
					IF !Empty(AllTrim(aColReu[T,nPosCp]))				
						QUK->(FieldPut(FieldPos(cNomCp),aColReu[T,nPosCp]))				        
					Endif	
				Endif
			Next
			MsUnlock()
			FKCOMMIT()
		Else
			Reclock("QUK",.T.)
			QUK->QUK_FILIAL:=xFilial("QUK")
			QUK->QUK_NUMAUD:=cNumAud
			For i:=1 to LEN(aHeaReu)
				cNomCp:= AllTrim(aHeaReu[i,2])
				nPosCp:= GdFieldPos(cNomCp,aHeaReu)
				IF cNomCp!="QUK_ANEXO" 
					IF cNomCp!="QUK_MEMO1" 
						QUK->(FieldPut(FieldPos(cNomCp),aColReu[T,nPosCp]))				
					Endif					
				Else 
					IF !Empty(AllTrim(aColReu[T,nPosCp]))				
						QUK->(FieldPut(FieldPos(cNomCp),aColReu[T,nPosCp]))				        
					Endif					
				EndIF
			Next
			MsUnlock()
			FKCOMMIT()			
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava a OBS da Reuniao										 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MsMM(QUK_CODOBS,,,aColReu[T,nPosMM],1,,,"QUK","QUK_CODOBS")

		IF FILE(cQPathTrm+Alltrim(aColReu[T,nPosAx]))
			FERASE(cQPathTrm +Alltrim(aColReu[T,nPosAx]))
		ENDIF
	Else 
		nPosCp:=Ascan(aHeaReu,{|x|AllTrim(x[2]) == "QUK_ANEXO"})
		IF FILE(cQPathQAD+Alltrim(aColReu[T,nPosCp]))
			FERASE(cQPathQAD +Alltrim(aColReu[T,nPosCp]))
		ENDIF
		IF FILE(cQPathTrm+Alltrim(aColReu[T,nPosCp]))
   	    	FERASE(cQPathTrm +Alltrim(aColReu[T,nPosCp]))
   	    ENDIF	                                          
   	    
		nPosCp:=Ascan(aHeaReu,{|x|AllTrim(x[2]) == "QUK_CODREU"})
		DbSelectArea("QUK")
		DbSetOrder(1)
		IF DBSeeK(xFilial("QUK")+cNumAud+aColReu[T,nPosOri]+aColReu[T,nPosCp])
    		MSMM(QUK_CODOBS ,,,,2)
			Reclock("QUK",.F.)
			DbDelete()		
		    MsUnlock()
		    FKCOMMIT()
		ENDIF                      
	Endif
Next
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Q100DelREuºAutor  ³Telso Carneiro      º Data ³  22/01/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza a exclusao da Reuniao e atas                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Q100Reun                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q100DelREu(cNumAud)

Local aQArea:=GetArea()
Local cQPathQAD:= Alltrim(GetMv("MV_QADPDOC"))
Local aQPath   := QDOPATH()
Local cQPathTrm:= aQPath[3]                                              

If !Right( cQPathQAD,1 ) == "\"
	cQPathQAD := cQPathQAD + "\"
Endif
If !Right( cQPathTrm,1 ) == "\"
	cQPathTrm := cQPathTrm + "\"
Endif

DbSelectArea("QUK")
QUK->(dBSetOrder(1))
IF DBSeeK(xFilial("QUK")+cNumAud+"1")
	While QUK->(!EOF()) .AND. QUK->QUK_NUMAUD==cNumAud .AND. QUK->QUK_ORIGEM=="1"

		IF FILE(cQPathQAD+Alltrim(QUK->QUK_ANEXO))
			FERASE(cQPathQAD +Alltrim(QUK->QUK_ANEXO))
		ENDIF

		IF FILE(cQPathTrm+Alltrim(QUK->QUK_ANEXO))
			FERASE(cQPathTrm +Alltrim(QUK->QUK_ANEXO))
		ENDIF

   		MSMM(QUK_CODOBS ,,,,2)
        RecLock("QUK",.F.)
        DbDelete()
        MsUnlock()
        FKCOMMIT()
		QUK->(DbSkip())
	Enddo
Endif
RestArea(aQArea)
Return(NIL)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FQAD100SEQ³ Autor ³ Aldo Marini Junior    ³ Data ³ 06/01/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa generico para Buscar Sequencias                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SX3                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/

Function FQAD100SEQ()
Return ( If(Len(aCols)==1 .And. Empty(aCols[1,1]),"01",StrZero(Val(aCols[Len(aCols)-1,1])+1,2,0)))

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QA100ChkAg ³ Autor ³Eduardo de Souza     ³ Data ³15/01/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Checa se existe agendamento para esta Auditoria            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QA100ChkAg()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SX3                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QA100ChkAg()
Local lRet:= .T.

QUA->(DbSetOrder(3))
If QUA->(DbSeek(xFilial("QUA")+M->QUB_NUMAUD))

	If QUA->QUA_STATUS <> "2"
		lRet:= MsgYesNo(OemToAnsi(STR0053),cCadastro) // "Existe agendamento para esta Auditoria. Deseja Continuar ?"
	EndIf

EndIf	
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Q100TopAutºAutor  ³Telso Carneiro      º Data ³  25/06/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Preenchimento Automatico do Topicos do Check-list           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GATILHO DO QUJ_CHKLST                                      º±±	
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q100TopAut(N)
Local aCheck  := aClone(oGetCheck:aCols)
Local nI	  := 0
Local aTCheck := {}
Local lTopAut := GETMV("MV_QADTOPA",.T.,"2") == "1" //Define que todos os Topicos cadastrados neste check-list sejam montados Automaticamente 1=SIM/2=NAO
Local nCnt := 0
Local nPosChk := 0
Local i

IF lTopAut
	IF MSGYesNO(OemToAnsi(STR0064)) //"Deseja que todos os Topicos cadastrados neste check-list sejam montados Automaticamente ? Conforme Parametro MV_QADTOPA"
		IF !Empty(aCheck[N,nPosChkAud]) .AND. !Empty(aCheck[N,nPosChkRev])
			QU3->(dbSetOrder(1)) 
			QU3->(DbGotop())
			IF QU3->(dbSeek(xFilial("QU3")+aCheck[N,nPosChkAud]+aCheck[N,nPosChkRev]))
				While QU3->(!Eof()) .And. (QU3->QU3_CHKLST+QU3->QU3_REVIS) == (aCheck[N,nPosChkAud]+aCheck[N,nPosChkRev])
					If aCheck[n,nPosChkItem] <> QU3->QU3_CHKITE
						AADD(aTCheck,aClone(aCheck[N]))
						nI:=Len(aTcHeck)
						aTCheck[nI,nPosChkItem]:= QU3->QU3_CHKITE
					Endif
					QU3->(dbSkip())
				EndDo
			Endif
		Endif
		IF Len(aTcHeck)>0
			aTCheck:= aSort(aTCheck,,,{ |x,y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3]  })
			For nI:= 1 To Len(aTCheck)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza o primeira posicao do check-list no aCols quando o Check-list e Digitado³
				//³e nao escolhido pelo SXB                                                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				IF (nPosChk:=ASCAN(aCheck,{|X| !X[LEN(X)] .AND. X[1]==aTCheck[nI,nPosChkAud] .AND. X[2]== aTCheck[nI,nPosChkRev] .AND. Empty(X[3]) }))>0
					oGetCheck:acols[nPosChk]:=AClone(aTCheck[nI])
					aCheck[nPosChk]:=AClone(aTCheck[nI])
				Endif                 
				
				IF ASCAN(aCheck,{|X| !X[LEN(X)] .AND. X[1]==aTCheck[nI,nPosChkAud] .AND. X[2]== aTCheck[nI,nPosChkRev] .AND. X[3]==aTCheck[nI,nPosChkItem] })==0
					AADD(oGetCheck:acols,AClone(aTCheck[nI]))
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza array aDadosQst quando nova linha area+checklist            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					For i:=1 TO (Len(oGetCheck:Acols) - Len(aDadosQst[oGetArea:oBrowse:nAt]) )
						Aadd(aDadosQst[oGetArea:oBrowse:nAt],{{" "," "," "," "," "," "," "}} )
					Next i

				nCnt := 0
				QU4->(dbSetOrder(1)) 
				QU4->(DbGotop())
				If QU4->(DBSeek(xFilial("QU4")+aTCheck[nI,nPosChkAud]+aTCheck[nI,nPosChkRev]+aTCheck[nI,nPosChkItem]))
				
				While QU4->(!Eof()) .And. (QU4->QU4_CHKLST+QU4->QU4_REVIS+QU4->QU4_CHKITE) == (aTCheck[nI,nPosChkAud]+aTCheck[nI,nPosChkRev]+aTCheck[nI,nPosChkItem])
					nCnt++
					If nCnt > Len(aDadosQst[oGetArea:oBrowse:nAt,Len(oGetCheck:Acols)])
						aAdd(aDadosQst[oGetArea:oBrowse:nAt,Len(oGetCheck:Acols)],{oGetArea:aCols[oGetArea:oBrowse:nAt,nPosSeq], QU4->QU4_CHKLST,QU4->QU4_REVIS,QU4->QU4_CHKITE,QU4->QU4_QSTITE," ","1"} )
					Else
						aDadosQst[oGetArea:oBrowse:nAt,Len(oGetCheck:Acols),nCnt]:={oGetArea:aCols[oGetArea:oBrowse:nAt,nPosSeq],QU4->QU4_CHKLST,QU4->QU4_REVIS,QU4->QU4_CHKITE,QU4->QU4_QSTITE," ","1"} 
					EndIf 
					QU4->(dbSkip())
				EndDo
				Endif

			Next
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza a NewGetdados³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oGetCheck:oBrowse:Refresh()
	Endif
Endif

Return(" ")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Q100AutQstºAutor  ³Aldo Marini Junior  º Data ³  12/02/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Preenchimento no array da selecao de questoes do check-list º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QADA100.PRW                                                º±±	
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Q100AtuQst()
Local nCnt := 0
Local cCheckAud := aDadosAud[3,oGetArea:oBrowse:nAt,oGetCheck:oBrowse:nAt,nPosChkAud]
Local cCheckRev := aDadosAud[3,oGetArea:oBrowse:nAt,oGetCheck:oBrowse:nAt,nPosChkRev]
Local cCheckItem := aDadosAud[3,oGetArea:oBrowse:nAt,oGetCheck:oBrowse:nAt,nPosChkItem]




If !Empty(cCheckAud) .And. !Empty(cCheckRev) .And. !Empty(cCheckItem)
	If (Len(aDadosQst[oGetArea:oBrowse:nAt])>=oGetCheck:oBrowse:nAt .And. Empty(aDadosQst[oGetArea:oBrowse:nAt,oGetCheck:oBrowse:nAt,1,2])) .Or.;
		Len(aDadosQst[oGetArea:oBrowse:nAt])<Len(oGetCheck:Acols)

		If Len(aDadosQst[oGetArea:oBrowse:nAt])<Len(oGetCheck:Acols)
			Aadd(aDadosQst[oGetArea:oBrowse:nAt],{{" "," "," "," "," "," "," "}} )
		Endif
		
		QU4->(dbSetOrder(1))		
		If QU4->(dbSeek(xFilial("QU4")+cCheckAud+cCheckRev+cCheckItem))
		While QU4->(!Eof()) .And. (QU4->QU4_CHKLST+QU4->QU4_REVIS+QU4->QU4_CHKITE) == (cCheckAud+cCheckRev+cCheckItem)


				nCnt++
				If nCnt > Len(aDadosQst[oGetArea:oBrowse:nAt,oGetCheck:oBrowse:nAt])
					aAdd(aDadosQst[oGetArea:oBrowse:nAt,oGetCheck:oBrowse:nAt],{oGetArea:aCols[oGetArea:oBrowse:nAt,nPosSeq], QU4->QU4_CHKLST,QU4->QU4_REVIS,QU4->QU4_CHKITE,QU4->QU4_QSTITE," ","1"} )
				Else
					aDadosQst[oGetArea:oBrowse:nAt,oGetCheck:oBrowse:nAt,nCnt]:= {oGetArea:aCols[oGetArea:oBrowse:nAt,nPosSeq], QU4->QU4_CHKLST,QU4->QU4_REVIS,QU4->QU4_CHKITE,QU4->QU4_QSTITE," ","1"} 
				Endif
			QU4->(dbSkip())                   
		EndDo		       
    Endif
Endif
Endif



Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QAD100LIST³ Autor ³ Aldo Marini Junior 	³ Data ³12/02/05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta tela para selecao de questoes                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QAD100LIST(nAtuArea,nAtuChk)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Numero da linha atual da getdados - Areas          ³±±
±±³          ³ EXPN2 = Numero da linha atual da getdados - Check-list     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                     
Function QAD100LIST(nAtuArea,nAtuChk,nOpc,oDlg)

Local oQst
Local oGetQst
Local oGetQstA
Local cTexto     := ""
Local aDadosAQst := {}
Local nOpcao     :=2
Local nRegQU4    := 0
Local nRegQUE    := 0
Local bCampo := { |nCPO| Field(nCPO) }
Local oDlg1
Local	oOk 	 := LoaDbitmap( GetResources(), "LBOK" )
Local	oNo 	 := LoaDbitmap( GetResources(), "LBNO" )
Local aStruct    := {}
Local aStructQU4 := {}
Local aStructQUE := {}
Local nI

Private aTela := {}
Private aGets := {}
Private lOk   := .F.
Private oGet

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se os dados do Check-list estao preenchidos e/ou deleteados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(aDadosAud[3,nAtuArea,nAtuChk,nPosChkAud]) .Or. ;        // Check-list em branco
	Empty(aDadosAud[3,nAtuArea,nAtuChk,nPosChkRev]) .Or. ;       // Revisao Check-list em branco 
	Empty(aDadosAud[3,nAtuArea,nAtuChk,nPosChkItem]) .Or. ;      // Topico em branco
	aDadosAud[3,nAtuArea,nAtuChk,Len(aHeadSav[3])+1] == .T.				  // Verifica se o Check-list esta deletado
	Return
Endif

DEFINE MSDIALOG oDlg1 FROM aMsSize[7],000 TO aMsSize[6],600 TITLE OemToAnsi(STR0060) OF oDlg Pixel //"Seleciona Questoes"

cTexto:= OemToAnsi(STR0015)+" "+aDadosAud[3,nAtuArea,nAtuChk,nPosChkAud]+"-"+aDadosAud[3,nAtuArea,nAtuChk,nPosChkRev]+" "+aDadosAud[3,nAtuArea,nAtuChk,nPosChkItem]+" "+aDadosAud[3,nAtuArea,nAtuChk,nPosDesChk]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza array aDadosQst quando nova linha area+checklist            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 3 .Or. nOpc == 4
	Q100AtuQst()
Endif

aDadosAQst := aClone(aDadosQst)

@ 015,002 SAY OemToAnsi(cTexto) COLOR CLR_HRED SIZE 270,007 OF oDlg1 PIXEL  //"Documentos"
oQst := TCBrowse():New(022,002,340,IF(aMsSize[4]<=206,50,95),,,,oDlg1,,,,,,,,,,,,.F.,,.T.,,.F.)
oQst:AddColumn(TCColumn():New(' '								, {|| IF(aDadosAQst[nAtuArea,nAtuChk][oQst:nAT,6]=="1",oOk,oNo) },,,,"LEFT",, .T., .F.,,,, .F., ) )
oQst:AddColumn(TCColumn():New(OemToAnsi(RetTitle("QUD_QSTITE")), {|| aDadosAQst[nAtuArea,nAtuChk][oQst:nAT,5] },,,,"LEFT",, .F., .F.,,,, .F., ) )
oQst:AddColumn(TCColumn():New(OemToAnsi(RetTitle("QUD_TIPO"))  , {|| QA_CBox("QUD_TIPO", aDadosAQst[nAtuArea,nAtuChk][oQst:nAT,7]) },,,,"LEFT",, .F., .F.,,,, .F., ) )
oQst:cTooltip:=OemToAnsi(STR0061) // "Duplo click para selecionar/nao selecionar questoes"
oQst:SetArray(aDadosAQst[nAtuArea,nAtuChk])
If nOpc == 3 .Or. nOpc == 4
	oQst:bLDbLClick:= {|| (aDadosAQst[nAtuArea,nAtuChk][oQst:nAT,6]:=If(aDadosAQst[nAtuArea,nAtuChk][oQst:nAT,6]=="1","2","1"),oQst:Refresh())  }
Endif
oQst:Align := CONTROL_ALIGN_TOP

Q100VISQST(@nRegQU4,@nRegQUE,nAtuArea,nAtuChk,oQst:nAT)

aStructQU4 := FWSX3Util():GetAllFields( "QU4" )
For nI := 1 To len(aStructQU4)
	If !aStructQU4[nI] $ "QU4_OBSCHV|QU4_REQCHV|"
		aAdd(aStruct,aStructQU4[nI])
	EndIf
Next
aStructQU4 := {}

aTela := {}
aGets := {}
oGetQst:= MsMGet():New('QU4',nRegQU4,2,,,,aStruct,{75,002,210,345},aStruct,3,,,,oDlg1,,.F.)
oGetQst:oBox:Align := CONTROL_ALIGN_ALLCLIENT
oGetQst:EnchRefreshAll()

aStruct := {}
aStructQUE :=  FWSX3Util():GetAllFields( "QUE" )
For nI := 1 To len(aStructQUE)
	If !aStructQUE[nI] $ "QUE_OBSCHV|QUE_REQCHV|"
		aAdd(aStruct,aStructQUE[nI])
	EndIf
Next
aStructQUE := {}

aTela := {}
aGets := {}
oGetQstA:= MsMGet():New('QUE',nRegQUE,2,,,,aStruct,{75,002,210,345},aStruct,3,,,,oDlg1,,.F.)
oGetQstA:oBox:Align := CONTROL_ALIGN_ALLCLIENT
oGetQstA:EnchRefreshAll()

oQst:bChange := { || (Q100VISQST(@nRegQU4,@nRegQUE,nAtuArea,nAtuChk,oQst:nAT),;
						If(aDadosQst[nAtuArea,nAtuChk,oQst:nAT,7] == "1",;
						  (oGetQst:EnchRefreshAll(),oGetQstA:Hide(),oGetQst:Show()),;
						  (oGetQstA:EnchRefreshAll(),oGetQst:Hide(),oGetQstA:Show())) )}

ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,{|| (oDlg1:End(),nOpcao:=1)},{|| oDlg1:End()}) CENTERED

If nOpcao == 1 .And. (nOpc == 3 .Or. nOpc == 4)
	aDadosQst := aClone(aDadosAQst)
Endif

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q100VISQST³ Autor ³ Aldo Marini Junior 	³ Data ³12/02/05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Posiciona na questao a ser selecionada                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q100VISQST(nRegQU4,nAtuArea,nAtuChk,nAtuQst)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Numero do recno da tabela QU4-Questoes             ³±±
±±³          ³ EXPN2 = Numero da linha atual da getdados - Areas          ³±±
±±³          ³ EXPN3 = Numero da linha atual da getdados - Check-list     ³±±
±±³          ³ EXPN4 = Numero da linha atual da getdados - Questoes       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                     
Function Q100VISQST(nRegQU4,nRegQUE,nAtuArea,nAtuChk,nAtuQst)
Default nRegQU4 := 0
Default nRegQUE := 0


If aDadosQst[nAtuArea,nAtuChk,nAtuQst,7] == "1"
	If QU4->(dbSeek(xFilial("QU4")+aDadosQst[nAtuArea,nAtuChk,nAtuQst,2]+aDadosQst[nAtuArea,nAtuChk,nAtuQst,3]+aDadosQst[nAtuArea,nAtuChk,nAtuQst,4]+aDadosQst[nAtuArea,nAtuChk,nAtuQst,5]))
		RegToMemory("QU4")
		nRegQU4 := QU4->(Recno())
	Endif
Else
	If QUE->(dbSeek(xFilial("QUE")+M->QUB_NUMAUD+aDadosQst[nAtuArea,nAtuChk,nAtuQst,2]+aDadosQst[nAtuArea,nAtuChk,nAtuQst,3]+aDadosQst[nAtuArea,nAtuChk,nAtuQst,4]+aDadosQst[nAtuArea,nAtuChk,nAtuQst,5]))
		RegToMemory("QUE")
		nRegQUE := QUE->(Recno())
	Endif
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ QAD100AUDº Autor ³ Cicero Cruz        º Data ³  21/09/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Lista Compromissos dos auditores em outras auditorias em umº±±
±±º          ³ determinado periodo                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAQAD                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QAD100AUD(oDlg)
Local aTabela := {}
Local nI
Local lRet 		:= .F. 
Local dIniAud 	:= M->QUB_INIAUD
Local dFimAud 	:= M->QUB_ENCAUD  
Local cNumAud 	:= M->QUB_NUMAUD
Local aAreaQUH	:= QUH->(GetArea())
Local aAreaQUC	:= QUC->(GetArea())
Local aAreaQUB	:= QUB->(GetArea())
Local oDlgAuditores, oGetAgAud
Local oPanel
Local cIndice
Local cChvQUB
Local cQuery
Local aColsAxH := Aclone(oGetArea:Acols)//Areas Auditadas
Local aColsAxC := Aclone(oGetAudit:Acols)//Equipe de Apoio
Local aColsAux :={}  //Somente Filial e Codigo
Local cDFilAud := ""
Local cDCodAud := ""
Local cDestin  := SPACE(TamSX3("QUH_DESTIN")[1])
Local bQuery,bQuery2             

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do Array aColsAux de Pesquisa elimando a duplicacao dos Auditores e Equipe de Apoio  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aEval(aColsAxH,{|x| IF(!x[len(x)],AADD(aColsAux,{x[nPosFilRes],x[nPosAudRes]}),"") })

For nI:=1 TO Len(aColsAxC)
	IF !aColsAxC[nI,Len(aColsAxC[nI])]
		cDFilAud:=aColsAxC[nI,nPosFilAud]
		cDCodAud:=aColsAxC[nI,nPosCodAud]
		IF Ascan(aColsAux,{|y| y[1]==cDFilAud .AND. y[2]==cDCodAud})==0
			AADD(aColsAux,{cDFilAud,cDCodAud})
		Endif
	Endif
Next

cQuery :="SELECT QUB.QUB_FILIAL,QUB.QUB_NUMAUD,QUB.QUB_INIAUD,QUB.QUB_ENCAUD,QUH.QUH_FILMAT CDFILAUD,QUH.QUH_CODAUD CDCODAUD,QUH.QUH_DESTIN CDESTIN "
cQuery +="FROM " + RetSqlName("QUB")+" QUB, "+RetSqlName("QUH")+" QUH "  		
cQuery +="WHERE QUB.QUB_ENCREA='' AND QUB.QUB_NUMAUD<>'"+M->QUB_NUMAUD+"' AND "  
// Entre
cQuery +="((QUB.QUB_INIAUD >= '"+DTOS(dIniAud)+"' And  QUB.QUB_ENCAUD <= '"+DTOS(dFimAud)+"') OR "
// Inicio da  auditoria intersecciona com a  auditoria analizada
cQuery +="(QUB.QUB_INIAUD <= '"+DTOS(dFimAud)+"' And QUB.QUB_ENCAUD > '"+DTOS(dFimAud)+"') OR "
// Fim da auditoria instersecciona com a auditoria analisada
cQuery +="(QUB.QUB_INIAUD < '"+DTOS(dIniAud)+"' And QUB.QUB_ENCAUD >= '"+DTOS(dIniAud)+"')) AND " 
cQuery +="QUB.D_E_L_E_T_ <> '*' AND QUB.QUB_FILIAL=QUH.QUH_FILIAL AND "
cQuery +="QUB.QUB_NUMAUD=QUH.QUH_NUMAUD AND ("
For nI := 1 To len(aColsAux)
	IF nI > 1
		cQuery +=" OR "
	Endif
	cQuery +="(QUH.QUH_FILMAT='"+aColsAux[nI,1]+"' AND QUH.QUH_CODAUD='"+aColsAux[nI,2]+"')"
Next
cQuery +=") AND QUH.D_E_L_E_T_ <> '*' "	
        cQuery +="UNION "                                     

cQuery +="SELECT QUB.QUB_FILIAL,QUB.QUB_NUMAUD,QUB.QUB_INIAUD,QUB.QUB_ENCAUD,QUC.QUC_FILMAT CDFILAUD,QUC.QUC_CODAUD CDCODAUD, '  ' CDESTIN "
cQuery +="FROM " + RetSqlName("QUB")+" QUB, "+RetSqlName("QUC")+" QUC "  		
cQuery +="WHERE QUB.QUB_ENCREA='' AND QUB.QUB_NUMAUD<>'"+M->QUB_NUMAUD+"' AND "
// Entre
cQuery +="((QUB.QUB_INIAUD >= '"+DTOS(dIniAud)+"' And  QUB.QUB_ENCAUD <= '"+DTOS(dFimAud)+"') OR "
// Inicio da  auditoria intersecciona com a  auditoria analizada
cQuery +="(QUB.QUB_INIAUD <= '"+DTOS(dFimAud)+"' And QUB.QUB_ENCAUD > '"+DTOS(dFimAud)+"') OR "
// Fim da auditoria instersecciona com a auditoria analisada
cQuery +="(QUB.QUB_INIAUD < '"+DTOS(dIniAud)+"' And QUB.QUB_ENCAUD >= '"+DTOS(dIniAud)+"')) AND " 		
cQuery +="QUB.D_E_L_E_T_ <> '*' AND QUB.QUB_FILIAL=QUC.QUC_FILIAL AND "
cQuery +="QUB.QUB_NUMAUD=QUC.QUC_NUMAUD AND ("
For nI := 1 To len(aColsAux)
	IF nI > 1
		cQuery +=" OR "
	Endif
	cQuery +="(QUC.QUC_FILMAT='"+aColsAux[nI,1]+"' AND QUC.QUC_CODAUD='"+aColsAux[nI,2]+"')"	
Next		
cQuery +=") AND QUC.D_E_L_E_T_ <> '*'"	

    If Upper(TcGetDb()) $ "ORACLE.INFORMIX"
	cQuery += " ORDER BY 1,2,3,4"
Else
	cQuery += " ORDER BY " + SqlOrder("QUB_FILIAL+QUB_NUMAUD+QUB_INIAUD+QUB_ENCAUD")
Endif

cQuery := ChangeQuery(cQuery)			
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQUB",.T.,.T.)	

TcSetField("TMPQUB","QUB_INIAUD","D")
TcSetField("TMPQUB","QUB_ENCAUD","D")		

While TMPQUB->(!Eof())
	Aadd(aTabela,{TMPQUB->CDESTIN,TMPQUB->CDFILAUD,TMPQUB->CDCODAUD,TMPQUB->QUB_NUMAUD,TMPQUB->QUB_INIAUD,TMPQUB->QUB_ENCAUD} )
	TMPQUB->( DbSkip() )
Enddo
   	    TMPQUB->(DBCLOSEAREA())
DbSelectArea("QUB")  	    


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se nao existirem compromissos  para os auditores ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len( aTabela ) == 0 
	DbSelectArea("QUH")	
	RestArea(aAreaQUH)	
	DbSelectArea("QUC")	
	RestArea(aAreaQUC)
	DbSelectArea("QUB")			
	RestArea(aAreaQUB)
	Return .T.
EndIf

DEFINE MSDIALOG oDlgAuditores FROM	aMsSize[7],000 TO aMsSize[6],725 TITLE OemToAnsi(STR0067) PIXEL Of oDlg // "Auditores Comprometidos"
oDlgAuditores:lMaximized := .F.

@ 00,00 MSPANEL oPanel PROMPT "" SIZE 055,050 OF oDlgAuditores
@ 07, 3 TO 42, 360 OF oPanel  PIXEL
@ 10, 7 SAY OemToAnsi(STR0065) SIZE 355,32 OF oPanel PIXEL //"Alguns auditores escolhidos ja estao comprometidos com outras auditorias, conforme listado abaixo :"
@ 24, 7 SAY OemToAnsi(STR0066) SIZE 355,32 OF oPanel PIXEL COLOR CLR_RED // "ATENCAO: Esta mensagem e somente um alerta, clique em cancelar para retirar desta auditoria estes auditores ou em OK para prosseguir com a Inclusao/Alteracao."
oPanel:Align := CONTROL_ALIGN_TOP

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta TCBrowse  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetAgAud:= TCBrowse():New(010,002,500,95,,,,oDlgAuditores,,,,,,,,,,,,.F.,,.T.,,.F.)
oGetAgAud:AddColumn(TCColumn():New(OemToAnsi(STR0012)                        	, {|| OemToAnsi(IF(!Empty(Alltrim(aTabela[oGetAgAud:nAT,1])),STR0040,STR0014))},,,,"LEFT",, .F., .F.,,,, .F., ) ) //Descricao###Auditor###Equipe de Apoio 
oGetAgAud:AddColumn(TCColumn():New(OemToAnsi(Alltrim(RetTitle("QUH_DESTIN")))	, {|| aTabela[oGetAgAud:nAT,1] },,,,"LEFT",, .F., .F.,,,, .F., ) ) 
oGetAgAud:AddColumn(TCColumn():New(OemToAnsi(Alltrim(RetTitle("QUH_FILMAT")))	, {|| aTabela[oGetAgAud:nAT,2] },,,,"LEFT",20, .F., .F.,,,, .F., ) ) 
oGetAgAud:AddColumn(TCColumn():New(OemToAnsi(Alltrim(RetTitle("QUH_CODAUD")))	, {|| aTabela[oGetAgAud:nAT,3] },,,,"LEFT",, .F., .F.,,,, .F., ) ) 
oGetAgAud:AddColumn(TCColumn():New(OemToAnsi(STR0068)				 		  	, {|| aTabela[oGetAgAud:nAT,4] },,,,"LEFT",, .F., .F.,,,, .F., ) ) //"Auditoria"
oGetAgAud:AddColumn(TCColumn():New(OemToAnsi(STR0069)				 			, {|| aTabela[oGetAgAud:nAT,5] },,,,"LEFT",, .F., .F.,,,, .F., ) ) //"De"
oGetAgAud:AddColumn(TCColumn():New(OemToAnsi(STR0070)				 			, {|| aTabela[oGetAgAud:nAT,6] },,,,"LEFT",, .F., .F.,,,, .F., ) ) //"Ate"
oGetAgAud:SetArray(aTabela)
oGetAgAud:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlgAuditores ON INIT EnchoiceBar(oDlgAuditores,{|| lRet := .T.,oDlgAuditores:End()},{|| lRet := .F.,oDlgAuditores:End()}) CENTERED

DbSelectArea("QUH")	
RestArea(aAreaQUH) 

DbSelectArea("QUC")	
RestArea(aAreaQUC) 

DbSelectArea("QUB")
RestArea(aAreaQUB)
Return lRet
