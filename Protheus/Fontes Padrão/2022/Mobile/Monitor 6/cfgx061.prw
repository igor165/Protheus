#include "protheus.ch"
#include "cfgx061.ch"

#define PDRIVER "DBFCDX"

Static aPEmp
Static cLastID  := Replicate("0",10)
Static cLastDir := Replicate("0",6)
Static __PError := .T.
Static aCTipos
Static nSys := 1

Function CFGX061()
Local i
Local cSvAlias := Alias()
Local oUser
Local oSerie
Local aBtn := Array(8)
Local cOrdem := STR0032
Local oOrdem
Local nUser := 1
Local oSys
Local cAplCli:=GetMv("MV_CLIEADV",,"5 - CLI")  // Parametro destinado a cadastro da aplicacao do cliente
Local aSys := {"1 - SFA","2 - TFA","3 - FDA","4 - PMS",cAplCli }
Local cAliasBase := "SA3"
/*/
*********************************************************************
* aSaveUser:														*
* [1] -> situacao (0 - nao alterado / 1 - alterado / 2 - excluido)	*
* [2] -> P_SERIE													*
* [3] -> P_USER														*
* [4] -> P_MAIL														*
* [5] -> P_USERID													*
* [6] -> P_CODVEND													*
* [7] -> P_FREQ														*
* [8] -> P_FTIPO													*
*********************************************************************

*********************************************************************
* aSaveServ:														*
* [1] -> situacao (0 - nao alterado / 1 - alterado / 2 - excluido)	*
* [2] -> P_ID														*
* [3] -> P_SERIE													*
* [4] -> P_EMPFI													*
* [5] -> P_TIPO														*
* [6] -> P_CLASSE													*
*********************************************************************

*********************************************************************
* aUser																*
* [1] -> usuario													*
* [2] -> num serie													*
*********************************************************************
/*/

Private oDlg61
Private lChange := .F. //habilita botao salvar
Private aUser := {{},{}}
Private aSaveUser := {}
Private aSaveServ := {}
Private aSaveCond := {}
Private aSaveTabl := {}
Private nAtuOrd := 2
Private nLastUser := 0
Private PUALIAS
Private PSALIAS
Private PCALIAS
Private PLALIAS
Private PALMDIR := PGetDir()

//verifica se o job esta no ar
If ( PInJob() )
	MsgInfo("Para cadastrar usuários do Palm o job nao pode estar no ar.",STR0018)
	Return
EndIf

//cria diretorio do palm
MakeDir(PALMDIR)

//carrega arquivo com lista de servicos (PALM.SVC)
If !File(PALMDIR+"HANDHELD.SVC")
//	aCTipos := PReadSVC()
//Else
	Alert("Arquivo " + PALMDIR+"HANDHELD.SVC nao encontrado.")
	Return
EndIf

//abre tabelas usadas pelo prg (PALMUSER/PALMSER/SA3)

PUALIAS := POpenUser()
PSALIAS := POpenServ()
PCALIAS := POpenCond()
PFALIAS := POpenTabl() 
PTALIAS := POpenTime()
PLALIAS := POpenLog()
ChkFile("SA3",.F.,,,,)
ChkFile("DA1",.F.,,,,)

//carrega usuarios na memoria

DbSelectArea(PUALIAS)                                          
DbSetOrder(3)
DbGoBottom()
cLastDir := If(Eof(),cLastDir,P_DIR)

DbSetOrder(2)
DbGoTop()

if Val(P_SISTEMA)=0
   nSys:=1
else   
   nSys:=Val(P_SISTEMA) // Pega o sitema do primeiro cadastrado  ASSUME SFA
endif

While !Eof()
	Aadd(aUser[1],P_USER)
	Aadd(aUser[2],P_SERIE)
	Aadd(aSaveUser,{0,P_SERIE,P_USER,P_MAIL,P_USERID,P_CODVEND,P_FREQ,P_FTIPO,P_DIR,P_LOCK,P_DEVICE,P_SISTEMA,P_DELDATA})
	DbSkip()
End

//procura pelo ultimo ID de servico e carrega servicos na memoria

DbSelectArea(PSALIAS)
DbSetOrder(2)
DbGoBottom()
cLastID := If(Eof(),cLastID,P_ID)

DbSetOrder(1)
DbGoTop()
While !Eof()
	Aadd(aSaveServ,{0,P_ID,P_SERIE,P_EMPFI,P_TIPO,P_CLASSE})
	DbSkip()
End

DEFINE MSDIALOG oDlg61 TITLE STR0001 FROM 0,0 TO 250,450 OF oMainWnd PIXEL //"Usuários do Palm"

@01,05 SAY STR0002 PIXEL //"Usuário:"
@10,05 LISTBOX oUser VAR nUser ITEMS aUser[1] PIXEL SIZE 100,90
oUser:bChange := {|| oSerie:Refresh(),nSys := PUpdSys(nUser,@oSys),oSys:Refresh()}

@01,107 SAY STR0003 PIXEL //"Número de Série:"
@10,107 LISTBOX oSerie VAR nUser ITEMS aUser[2] PIXEL SIZE 75,90
oSerie:bChange := {|| oUser:Refresh(),nSys := PUpdSys(nUser,@oSys),oSys:Refresh()}

@106,05 SAY STR0031 PIXEL SIZE 30,10 //"Ordem:"
@105,25 COMBOBOX oOrdem VAR cOrdem ITEMS {STR0033,STR0032} PIXEL SIZE 60,50 ; //"Número de Série" # "Usuário"
ON CHANGE (nLastUser := nUser,nAtuOrd := oOrdem:nAt,PSortUser(),PUpdUObj(@oUser,@oSerie,@oSys))

@106,107 SAY "Sistema:" PIXEL SIZE 30,10 //"Sistema:"
@105,135 COMBOBOX oSys VAR nSys ITEMS aSys PIXEL SIZE 40,50 ;
ON CHANGE ( If(oSys:nAt=1,(cAliasBase := "SA3"), (cAliasBase := "AA1")), nSys := oSys:nAt )

@10,187 BUTTON aBtn[1] PROMPT STR0004 SIZE 35,11 PIXEL ; //"&Incluir"
ACTION If(PCadUser(0, nSys),PUpdUObj(@oUser,@oSerie,@oSys),)

@23,187 BUTTON aBtn[2] PROMPT STR0005 SIZE 35,11 PIXEL WHEN !Empty(aUser[1]) ; //"&Alterar"
ACTION If(PCadUser(nUser, nSys),PUpdUObj(@oUser,@oSerie,@oSys),)

@36,187 BUTTON aBtn[3] PROMPT STR0006 SIZE 35,11 PIXEL WHEN !Empty(aUser[1]) ; //"&Excluir"
ACTION If(PDelUser(nUser),(oUser:SetItems(aUser[1]),oSerie:SetItems(aUser[2])),)

@49,187 BUTTON aBtn[4] PROMPT STR0007 SIZE 35,11 PIXEL WHEN lChange ; //"Sal&var"
ACTION (PSaveUser(),PSaveServ(),PSaveCond(),PSaveTabl())

@62,187 BUTTON aBtn[5] PROMPT STR0008 SIZE 35,11 PIXEL WHEN !Empty(aUser[1]) ; //"&Localizar"
ACTION PFindNext(@nUser,@oUser,@oSerie,@oSys)

@75,187 BUTTON aBtn[6] PROMPT "&Cond. Int." SIZE 35,11 PIXEL WHEN !Empty(aUser[1]) ;
ACTION PCondInt() //"&Cond. Int."

@88,187 BUTTON aBtn[7] PROMPT STR0054 SIZE 35,11 PIXEL WHEN !Empty(aUser[1]) ;
ACTION PTabelas() //"&Tabela

@101,187 BUTTON aBtn[8] PROMPT STR0009 SIZE 35,11 PIXEL ACTION oDlg61:End() //"&Sair"

ACTIVATE DIALOG oDlg61 CENTERED

If ( lChange )
	If MsgYesNo("Deseja salvar as alterações?","Atenção")
		PSaveUser()
		PSaveServ()
		PSaveCond()
		PSaveTabl()
	EndIf
EndIf

(PUALIAS)->(DbCloseArea())
(PSALIAS)->(DbCloseArea())
(PCALIAS)->(DbCloseArea())
(PFALIAS)->(DbCloseArea())
SA3->(DbCloseArea())

DbSelectArea(cSvAlias)
Return NIL

Static Function PUpdSys(nUser,oSys)
Local nSys

If nUser != Nil .And. nUser != 0
	dbSelectArea(PUALIAS)
	dbSetOrder(1)
	dbSeek(aUser[2,nUser])
	nSys := Val((PUALIAS)->P_SISTEMA)
	If nSys = 0
		nSys = 1
	EndIf
Else
	nSys := 1
EndIf
oSys:Refresh()
Return nSys

/*/
*************************************************
* PFindNext()									*
* funcao auxiliar p/ procura de usuario 		*
*************************************************
/*/
Function PFindNext(nPos,oObj1,oObj2,oSys)
Local oDlgSeek, cSeek := Space(30)
Local lCase := .F., lWord := .F., lChg := .F.
Local aCoors := Array(4), cTitle := ""
Local lReturn := .F., nBefore := nPos
Local cOrdem := STR0033
Local oOrdem

oDlg61:CoorsUpdate()

aCoors[1] := oDlg61:nTop+130
aCoors[2] := oDlg61:nLeft+200
aCoors[3] := aCoors[1]+130
aCoors[4] := aCoors[2]+340

DEFINE MSDIALOG oDlgSeek FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] TITLE STR0026 PIXEL //"Localizar"

@07,02 SAY STR0027 PIXEL //"Localizar:"
@05,30 GET cSeek PIXEL SIZE 100,9

@20,02 TO 62,130 LABEL STR0028 PIXEL //"Opções"
@27,05 CHECKBOX lCase PROMPT STR0029 FONT oDlgSeek:oFont PIXEL SIZE 80,09 //"&Coincidir maiúsc./minúsc."
@38,05 CHECKBOX lWord PROMPT STR0030 FONT oDlgSeek:oFont PIXEL SIZE 80,09 //"Localizar palavra &inteira"
@50,05 SAY STR0031 PIXEL SIZE 30,10 //"Ordem:"
@49,30 COMBOBOX oOrdem VAR cOrdem ITEMS {STR0032,STR0033} PIXEL SIZE 60,50 //"Número de Série" # "Usuário"

@05,135 BUTTON STR0034 PIXEL OF oDlgSeek SIZE 33,11; //"&Próximo"
ACTION (nPos := FastSeek(cSeek,nPos,aUser[oOrdem:nAt],lCase,lWord),oObj1:Refresh(),oObj2:Refresh(),oSys:Refresh())

//**************************************************
//* funcao FastSeek encotrada no fonte CFGX021.PRW *
//**************************************************

@18,135 BUTTON "OK" PIXEL ACTION (lReturn := .T.,oDlgSeek:End()) SIZE 33,11
@31,135 BUTTON STR0017 PIXEL ACTION oDlgSeek:End() SIZE 33,11 //"&Cancelar"

ACTIVATE MSDIALOG oDlgSeek

If lReturn
	lReturn := lChg
Else
	nPos := nBefore
	oObj1:Refresh()
	oObj2:Refresh()
	oSys:Refresh()
EndIf
Return lReturn

/*/
*************************************************
* PSortUser()									*
* ordena vetor de usuarios:						*
* 1 - usuario									*
* 2 - serie										*
*************************************************
/*/
Function PSortUser(nOrd)
Local aTmp := Aclone(aSaveUser)
Local cTmp := aUser[2][nLastUser]

DEFAULT nOrd := nAtuOrd

If nOrd < 1
	nOrd := 1
ElseIf nOrd > 2
	nOrd := 2
EndIf

nOrd += 1

aTmp := Asort(aTmp,,,{|x,y| x[nOrd] < y[nOrd]})
aUser[1] := {}
aUser[2] := {}

Aeval(aTmp,{|x,y| Aadd(aUser[1],x[3]),Aadd(aUser[2],x[2])})
nLastUser := Ascan(aUser[2],cTmp)
Return

/*/
*************************************************
* Funcoes p/ cadastro de usuario				*
*************************************************

*************************************************
* PCadUser()									*
* tela p/ cadastro de usuario					*
*************************************************
/*/
Function PCadUser(nUser, nSys)
Local oDlg
Local aInfo
Local oUDI
Local oUName
Local oVName
Local cUName := Space(15)
Local cVName := Space(40)
Local cDevice:= ""
Local oDispos 
Local oMail
Local lRet := .F.
Local aPswInfo
Local nPos
Local nStart
Local nAtEnd
Local nPos1
Local oFTipo
Local cFTipo := ""
Local aFTipo := {STR0050,STR0051,STR0052} //"Minuto(s)" # "Hora(s)" # "Dia(s)"
Local oStatus
Local nStatus := 0
Local cStatus := ""
Local aStatus := {{"1-Livre","2-Job","3-Handheld","4-Processando","5-Bloqueado"}, {"L", "J","H","P","B"}}
Local oDelData
Local ldelData := .F.
Local aDevice := {"1=PalmOS","2=Pocket"} //"1=PalmOs"#"2=Pocket"


DEFAULT nUser := 0

Private aListServ := {}

//***********************************************
//* aInfo:										*
//* [1] -> P_SERIE								*
//* [2] -> P_USER								*
//* [3] -> P_MAIL								*
//* [4] -> P_USERID								*
//* [5] -> P_CODVEND							*
//* [6] -> P_FREQ								*
//* [7] -> P_FTIPO								*
//* [8] -> P_DIR								*
//* [9] -> P_LOCK							    *
//*[10] -> P_DEVICE  						    *
//*[11] -> P_SISTEMA						    *
//*[12] -> P_DELDATA						    *
//***********************************************

aInfo := PRetUInfo(nUser, nSys)

If nUser <> 0

	If Val(aInfo[11]) <> nSys
		If MsgYesNo("Este usuario esta cadastrado para outro sistema. Deseja Continuar ?","Atenção")
			aInfo[11] := Str(nSys,1,0)
		Else
			Return .T.
		EndIf
	EndIf
	
	//atualiza variaveis com nome do usuario do siga e nome do vendedor
	
	aPswInfo := PUpdUser(aInfo[4])
	cUName := aPswInfo[1][2]
	cVName := PUpdVend(aInfo[5], nSys)
	cFTipo := aFTipo[Val(aInfo[7])]
	nStatus := aScan(aStatus[2], {|x| x == aInfo[9]})
	If nStatus = 0
		nStatus := 1
	EndIf
	cStatus := aStatus[1, nStatus]
	ldelData := If(aInfo[12] = "T", .T., .F.)

	cDevice	 :=aInfo[10]
	cDispo   :=aInfo[10]
	
	//procura no vetor de servicos os pertencentes ao usuario que esta sendo alterado
	
	nStart := 1
	nAtEnd := Len(aSaveServ)
	While (nPos1 := Ascan(aSaveServ,{|x| x[3] == aInfo[1]},nStart)) > 0
		Aadd(aListServ,aSaveServ[nPos1])
		If (nStart := ++nPos1) > nAtEnd
			Exit
		EndIf
	End
EndIf

DEFINE MSDIALOG oDlg TITLE STR0010 FROM 0,0 TO 215,470 PIXEL //"Propriedades do Usuário do Palm"

@07,05 SAY STR0011 PIXEL //"Número de Série:"
@05,58 GET aInfo[1] PIXEL SIZE 139,10 WHEN (nUser == 0)

@22,05 SAY STR0012 PIXEL //"Usuário:"
@20,58 GET aInfo[2] PIXEL SIZE 139,10

@37,05 SAY STR0013 PIXEL //"Usuário do Siga:"
@35,58 MSGET aInfo[4] PIXEL F3 "USR" ;
VALID (aPswInfo := PUpdUser(aInfo[4]),cUName := aPswInfo[1][2],oUName:Refresh(),;
If(Empty(aInfo[3]),(aInfo[3] := aPswInfo[1][14],If(Empty(aInfo[3]),aInfo[3] := Space(120),aInfo[3]),oMail:Refresh()),),.T.)

@35,100 MSGET oUName VAR cUName PIXEL SIZE 97,10 WHEN .F.

if nSys=1
   @52,05 SAY STR0014 PIXEL //"Código do Vendedor:"   SFA
   @50,58 MSGET aInfo[5] PIXEL F3 "SA3" ;
   VALID (cVName := PUpdVend(aInfo[5], nSys),oVName:Refresh(),.T.)
elseif nSys=2
   @52,05 SAY "Código do Técnico" PIXEL //"Código do Tecnico:"  TFA            
   @50,58 MSGET aInfo[5] PIXEL F3 "AA1" ;
   VALID (cVName := PUpdVend(aInfo[5], nSys),oVName:Refresh(),.T.)
elseif nSys=3
   @52,05 SAY "Código do Motorista" PIXEL //"Código do Vendedor:"  FDA          
   @50,58 MSGET aInfo[5] PIXEL F3 "SA3" ;
   VALID (cVName := PUpdVend(aInfo[5], nSys),oVName:Refresh(),.T.)
endif

@50,100 MSGET oVName VAR cVName PIXEL SIZE 97,10 WHEN .F.

@67,05 SAY STR0015 PIXEL //"E-mail:"
@65,58 GET oMail VAR aInfo[3] PIXEL SIZE 139,10

@79,05 SAY STR0016 PIXEL SIZE 40,20 //"Frequencia de Sincronismo:"
@80,58 GET aInfo[6] PIXEL PICTURE "99" VALID PValidTime(aInfo[6],aInfo[7])

@80,70 COMBOBOX oFTipo VAR cFTipo ITEMS aFTipo PIXEL SIZE 40,50 ;
ON CHANGE (aInfo[7] := StrZero(oFTipo:nAt,1,0),If(oFTipo:nAt == 2,(aInfo[6] := 1),))

@80,115 SAY "Disp.:" PIXEL //"Dispositivo:"
@80,130 COMBOBOX oDispos VAR cDevice ITEMS aDevice PIXEL SIZE 40,50 ;  // "Dispositivo:"
ON CHANGE aInfo[10] := Subs(cDevice,1,1)

@80,180 COMBOBOX oStatus VAR cStatus ITEMS aStatus[1] PIXEL SIZE 55,10 ;
ON CHANGE (ChkStatus(@aInfo, cStatus, aStatus)) WHEN nStatus != 4

@91,180 CHECKBOX oDelData VAR ldelData PROMPT "Excluir Base" PIXEL SIZE 55,10 ;
ON CHANGE (PDelData(@aInfo, lDelData))

@05,202 BUTTON "&OK" SIZE 28,11 PIXEL ;
ACTION If(PAddUser(nUser,aInfo),(lRet := .T.,oDlg:End()),)

@18,202 BUTTON STR0017 SIZE 28,11 PIXEL ACTION oDlg:End() //"&Cancelar"

@31,202 BUTTON STR0053 SIZE 28,11 PIXEL ACTION PListServ(aInfo, nSys) //"&Serviços"

ACTIVATE DIALOG oDlg CENTERED

Return lRet

Function PValidTime(nTime,cFTipo)
Local lRet := .T.

If cFTipo $ "13"
	lRet := nTime > 0
ElseIf cFTipo == "2"
	lRet := (nTime > 0) .And. (nTime < 24)
EndIf
Return lRet


Function ChkStatus(aInfo, cStatus, aStatus)
Local cDir       := PALMDIR+"P"+AllTrim(aInfo[8])+"\"
Local aDir       := {}
Local ni 	     := 0
Local nNewStatus := aScan(aStatus[1], {|x| x == cStatus})
Local nOldStatus := aScan(aStatus[2], {|x| x == aInfo[9]})
Local cMsg       := ""
Local cDriver    := GetLocalDBF()
If nOldStatus = 0
	nOldStatus := 1
EndIf

If nNewStatus >= 2 .And. nNewStatus <= 4
	cMsg := "O status " + aStatus[1,nNewStatus] + " não pode ser selecionado manualmente."
	MsgStop(cMsg, "Handheld Status")
	cStatus := aStatus[1,nOldStatus]
Else
	If !Empty(aInfo[9])
		If "Livre" $ cStatus
			cMsg += "A alteração do Status do vendedor de " + aStatus[1,nOldStatus]
			cMsg += " para " + cStatus + " implica na deleção dos dados da pasta DIFS do vendedor.
			cMsg += "Caso existam informações não importadas para o Protheus estas serão perdidas." + Chr(13) + Chr(10)
			cMsg += "Deseja continuar ?"
			If MsgYesNo(cMsg, "Handheld Status")
				PAddLog(aInfo[1],"STATUS")
				aDir := Directory(cDir+"DIFS\*.DBF")
				For ni := 1 To Len(aDir)
					DbUseArea(.T.,PDRIVER,cDir+"DIFS\" + aDir[ni, 1],aDir[ni, 1],.F.)
					Zap
					dbCloseArea()
				Next
				aInfo[9] := If(aStatus[2,nNewStatus]="L", Space(1), aStatus[2, nNewStatus])
				PUpdLog(,"Status alterado de " + aStatus[1,nOldStatus] + " para " + aStatus[1,nNewStatus] + " - " + Time())
			EndIf
		EndIf
	Else
		PAddLog(aInfo[1],"STATUS")
		aInfo[9] := If(aStatus[2,nNewStatus]="L", Space(1), aStatus[2, nNewStatus])
		PUpdLog(,"Status alterado de " + aStatus[1,nOldStatus] + " para " + aStatus[1,nNewStatus] + " - " + Time())
	EndIf
EndIf
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PAddUser ³ Autor ³ Fabio Garbin          ³ Data ³ 14.12.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Adiciona/altera usuario no vetor de usuarios               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PAddUser                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                             	                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CFGX061                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Analista   ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Cleber M.  ³24/11/06³113088³-Correcao para pesquisar o campo na tabela³±±
±±³            ³        ³      ³conforme o Sistema (SFA, TFA ou FDA).     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PAddUser(nUser,aInfo)
Local i						//Usada em lacos For...Next
Local nSave					//Indice do array aSaveUser
Local lRet := .F.			//Indica retorno da operacao
Local nOrd := nAtuOrd		//Ordem atual
Local nPos					//Posicao encontrada no array aUser

DEFAULT nUser := 0
DEFAULT aInfo := PRetUInfo()

//serie em branco

If Empty(aInfo[1])
	MSGSTOP(STR0019,STR0018) //"Informe o Número de Série." # "Atenção"

//serie ja existe

ElseIf (nUser == 0) .And. (Ascan(aUser[2],aInfo[1]) <> 0)
	MSGSTOP(STR0020,STR0018) //"Número de Série já existe." # "Atenção"
	
//usuario em branco
	
ElseIf Empty(aInfo[2])
	MSGSTOP(STR0021,STR0018) //"Informe o Usuário." # "Atenção"
Else
	nPos := Ascan(aUser[1],aInfo[2])
	
	//usuario ja existe
	
	If nPos <> 0 .And. nPos <> nUser
		MSGSTOP(STR0035,STR0018) //"Usuário já existe." # Atenção
	Else
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se nao existir o usuario do siga ou vendedor limpa os campos referentes ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Do Case                          
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ SFA ou FDA ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case nSys == 1 .OR. nSys == 3
				DbSelectArea("SA3")
				DbSetOrder(1)
				aInfo[5] := If(DbSeek(xFilial("SA3")+aInfo[5]),aInfo[5],"")
			
			//ÚÄÄÄÄÄ¿
			//³ TFA ³
			//ÀÄÄÄÄÄÙ
			Case nSys == 2
				DbSelectArea("AA1")
				DbSetOrder(1)
				aInfo[5] := If(DbSeek(xFilial("AA1")+aInfo[5]),aInfo[5],"")
	
		EndCase
			
		PswOrder(1)
		aInfo[4] := If(PswSeek(aInfo[4]),aInfo[4],"")
		lRet := .T.
	EndIf
EndIf

If lRet
	nPos := Ascan(aUser[If(nOrd == 1,2,1)],{|x| x > aInfo[nOrd]})
	If nUser == 0
		cLastDir := Soma1(cLastDir)
		Aadd(aUser[1],NIL)
		Aadd(aUser[2],NIL)
		If nPos == 0
			nUser := Len(aUser[1])
		Else
			nUser := nPos
		    Ains(aUser[1],nUser)
   		    Ains(aUser[2],nUser)
		EndIf
		aInfo[8] := cLastDir
		Aeval(aListServ,{|x| x[3] := aInfo[1]})
	ElseIf nOrd == 2
		If ( nUser > nPos )
			Adel(aUser[1],nUser)
			Adel(aUser[2],nUser)
			nUser := If(nPos == 0,Len(aUser[1]),nPos)
			Ains(aUser[1],nUser)
			Ains(aUser[2],nUser)
		EndIf
	EndIf
	aUser[1][nUser] := aInfo[2]
	aUser[2][nUser] := aInfo[1]
	
	//atualiza informacoes no vetor de usuarios procurando pelo numero de serie
	//e seta o primeiro elemento com 1 (alterado)

	nSave := Ascan(aSaveUser,{|x| x[2] == aUser[2][nUser]})
	If nSave == 0
		Aadd(aSaveUser,)
		nSave := Len(aSaveUser)
	EndIf

	aSaveUser[nSave] := {1}

	For i := 1 To Len(aInfo)
		Aadd(aSaveUser[nSave],aInfo[i])
	Next
	
	//atualiza informacoes no vetor de servicos procurando pelo ID do servico
	//e seta o primeiro elemento com 1 (alterado)
	
	For i := 1 To Len(aListServ)
		nPos := Ascan(aSaveServ,{|x| x[2] == aListServ[i][2]})
		If ( nPos == 0 )
			aListServ[i][3] := aInfo[1]
			Aadd(aSaveServ,aListServ[i])
		Else
			aSaveServ[nPos] := aListServ[i]
		EndIf
	Next
	
	lChange := .T.
	nLastUser := nUser
EndIf
Return lRet

/*/
*************************************************
* PDelUser()									*
* exclui usuario do vetor de usuarios			*
*************************************************
/*/
Function PDelUser(nUser)
Local i
Local aInfo
Local nSave
Local lRet := .F.

DEFAULT nUser := 0

If nUser <> 0
	lRet := MsgNoYes(STR0025+Trim(aUser[1][nUser])+" ?",STR0018) //"Tem certeza que deseja excluir o usuário " # "Atenção"
	If lRet
		aInfo := PRetUInfo(nUser)
		
		//procura pelo usuario e seta o primeiro elemento do vetor com 2 (excluido)
		
		nSave := Ascan(aSaveUser,{|x| x[2] == aUser[2][nUser]})
		If nSave == 0
			Aadd(aSaveUser,)
			nSave := Len(aSaveUser)
		EndIf
		aSaveUser[nSave] := {2}
		For i := 1 To Len(aInfo)
			Aadd(aSaveUser[nSave],aInfo[i])
		Next
		
		ADel(aUser[1],nUser)
		ADel(aUser[2],nUser)
		ASize(aUser[1],Len(aUser[1])-1)
		ASize(aUser[2],Len(aUser[2])-1)
		lChange := .T.
	EndIf
EndIf
Return lRet

/*/
*************************************************
* PRetUInfo()									*
* retorna vetor com informacoes do usuario		*
*************************************************
/*/
Function PRetUInfo(nUser, nSys)
Local aRet
Local nSave

DEFAULT nUser := 0

If nUser == 0
	aRet := {Space(20),;
			 Space(30),;
			 Space(120),;
			 Space(6),;
			 Space(6),;
			 1,;
			 "1",;
			 Space(8),;
			 Space(1),;
			 Space(1),;
			 Str(nSys,1,0),;
			 Space(1)}
Else
	nSave := Ascan(aSaveUser,{|x| x[2] == aUser[2][nUser]})
	If nSave == 0
		DbSelectArea(PUALIAS)
		DbSetOrder(1)
		DbSeek(aUser[2][nUser])
		aRet := {P_SERIE,;
				 P_USER,;
				 PadR(P_MAIL,120),;
				 P_USERID,;
				 P_CODVEND,;
				 P_FREQ,;
				 P_FTIPO,;
				 P_DIR,;
				 P_LOCK,;
				 If(!Empty(P_DEVICE),P_DEVICE,"1"),;
				 If(!Empty(P_SISTEMA),P_SISTEMA,"1"),;
				 P_DELDATA}
				 
	Else
		aRet := {aSaveUser[nSave][2],;
				 aSaveUser[nSave][3],;
				 PadR(aSaveUser[nSave][4],120),;
				 If(Empty(aSaveUser[nSave][5]),Space(6),aSaveUser[nSave][5]),;
				 If(Empty(aSaveUser[nSave][6]),Space(6),aSaveUser[nSave][6]),;
				 aSaveUser[nSave][7],;
				 aSaveUser[nSave][8],;
				 aSaveUser[nSave][9],;
				 aSaveUser[nSave][10],;
				 If(!Empty(aSaveUser[nSave][11]),aSaveUser[nSave][11],"1"),;
				 If(!Empty(aSaveUser[nSave][12]),aSaveUser[nSave][12],"1"),;
				 aSaveUser[nSave][13]}
	EndIf
EndIf
Return aRet

/*/
*************************************************
* PSaveUser()									*
* salva informacoes do vetor de usuarios na		*
* tabela PALMUSER								*
*************************************************
/*/
Function PSaveUser()
Local i
Local ni := 1
Local cDir
Local aDir := {}
Local nWork := Val(GetSrvProfString("HandHeldWorks","3"))
DbSelectArea(PUALIAS)
DbSetOrder(1)
For i := 1 To Len(aSaveUser)
	If aSaveUser[i][1] == 1
		
		//procura pelo usuario na tabela p/ inclusao ou alteracao
		cDir := PALMDIR+"P"+AllTrim(aSaveUser[i][9])+"\"
		If DbSeek(aSaveUser[i][2])
			RecLock(PUALIAS,.F.)
		Else
			RecLock(PUALIAS,.T.)
			
			//cria diretorio p/ o usuario
			MakeDir(cDir)
			MakeDir(cDir+"ATUAL\")
			MakeDir(cDir+"NEW\")
			MakeDir(cDir+"DIFS\")
		EndIf
		P_SERIE	  := aSaveUser[i][2]
		P_USER	  := aSaveUser[i][3]
		P_MAIL	  := aSaveUser[i][4]
		P_USERID   := aSaveUser[i][5]
		P_CODVEND  := aSaveUser[i][6]
		P_FREQ	  := aSaveUser[i][7]
		P_FTIPO    := aSaveUser[i][8]
		P_DIR      := aSaveUser[i][9]
		P_LOCK     := aSaveUser[i][10]
		P_DEVICE   := aSaveUser[i][11]
		P_SISTEMA  := aSaveUser[i][12]
		P_DELDATA  := aSaveUser[i][13]
		MsUnlock()
		aSaveUser[i][1] := 0

		DbSelectArea(PTALIAS)
		DbSetOrder(1)
		If dbSeek((PUALIAS)->P_SERIE)
			RecLock(PTALIAS,.F.)
			(PTALIAS)->P_RANGE := PRetRange((PUALIAS)->P_FREQ,(PUALIAS)->P_FTIPO)
			(PTALIAS)->(MsUnlock())
		EndIf

		DbSelectArea(PUALIAS)
		DbSetOrder(1)
		If (PUALIAS)->P_DELDATA = "T"
			aDir := Directory(cDir+"NEW\*.*")
			For ni := 1 To Len(aDir)
				FErase(cDir+"NEW\" + aDir[ni, 1])
			Next

			aDir := Directory(cDir+"DIFS\*.*")
			For ni := 1 To Len(aDir)
				FErase(cDir+"DIFS\" + aDir[ni, 1])
			Next

			aDir := Directory(cDir+"ATUAL\*.*")
			For ni := 1 To Len(aDir)
				FErase(cDir+"ATUAL\" + aDir[ni, 1])
			Next
			// Inicia Job para usuario que excluiu base
			RecLock(PUALIAS,.F.)
			P_LOCK    := "J"
			MsUnlock()
			StartJob("PExecServ",GetEnvServer(),.F.,P_SERIE, nWork + i)
		EndIf
	ElseIf aSaveUser[i][1] == 2
		
		//procura pelo usuario na tabela p/ exclusao
		
		If DbSeek(aSaveUser[i][2])
			RecLock(PUALIAS,.F.,.T.)
			DbDelete()
			MsUnlock()
		    // Apaga os servicos desse Handheld
			dbSelectArea(PSALIAS)
		   dbSetOrder(1)
		   If dbSeek(aSaveUser[i][2])
		   	While !Eof() .And. (PSALIAS)->P_SERIE == aSaveUser[i][2]
					RecLock(PSALIAS,.F.,.T.)
					DbDelete()
					MsUnlock()
					dbSkip()
		    	EndDo
			EndIf
			DbSelectArea(PUALIAS)
			DbSetOrder(1)
		EndIf
	EndIf
Next
DbCommit()
lChange := .F.
Return .T.

/*/
*************************************************
* PUpdUser()									*
* retorna nome do usuario do siga				*
*************************************************
/*/
Function PUpdUser(cID)
Local aRet

PswOrder(1)
If PswSeek(cID)
	aRet := PswRet(1)
Else
	aRet := {{"","","","",{},Ctod(""),0,.F.,.F.,{},"","","",Space(120),0,Ctod(""),.F.,0,.F.,""}}
EndIf
Return aRet

/*/
*************************************************
* PUpdVend()									*
* retorna nome do vendedor						*
*************************************************
/*/
Function PUpdVend(cCode, nSys)
Local nRec
Local cRet
Local cAliasBase := If(nSys = 1, "SA3", "AA1")
Local cCampo     := If(nSys = 1, "SA3->A3_NOME", "AA1->AA1_NOMTEC") 

if nSys = 1 .Or. nSys = 3
   cAliasBase := "SA3"
   cCampo     := "SA3->A3_NOME"
elseif nSys = 2
   cAliasBase := "AA1"
   cCampo     := "AA1->AA1_NOMTEC"
endif
DbSelectArea(cAliasBase)
DbSetOrder(1)
nRec := Recno()
DbSeek(xFilial(cAliasBase)+cCode)
cRet := &cCampo
DbGoTo(nRec)
Return cRet

/*/
*************************************************
* PUpdCond()									*
* retorna Descricao da Condicao					*
*************************************************
/*/
Function PUpdCond(cCond)
Local nRec
Local cRet

DbSelectArea("SE4")
DbSetOrder(1)
nRec := Recno()
DbSeek(xFilial("SE4")+cCond)
cRet := SE4->E4_DESCRI
DbGoTo(nRec)
Return cRet


/*/
*************************************************
* PUpdUObj()									*
* atualiza objetos da tela principal			*
*************************************************
/*/
Function PUpdUObj(o1,o2,o3)

If ( o1 <> NIL )
	o1:SetItems(aUser[1])
	o1:nAt := nLastUser
	o1:Refresh()
	o3:Refresh()          
EndIf

If ( o2 <> NIL )
	o2:SetItems(aUser[2])
	o2:nAt := nLastUser
	o2:Refresh()
EndIf

Return .T.

/*/
*************************************************
* Funcoes p/ cadastro de servico				*
*************************************************

*************************************************
* PListServ()									*
* lista servicos do usuario na tela				*
*************************************************
/*/
Function PListServ(aInfo, nSys)
Local i
Local cTitle := STR0036 //"Serviços do Usuário "
Local oServ
Local aBtn := Array(5)
Local aList := {}
Local bLine := {|| {aList[oServ:nAt][1],; //servico
					aList[oServ:nAt][2],; //empresa/filial
					aList[oServ:nAt][3]}} //classe

//coloca nome do usuario no titulo da janela

cTitle += aInfo[2]

aCTipos := PReadSVC(.T., nSys)

DEFINE MSDIALOG oDlg TITLE cTitle FROM 0,0 TO 208,450 PIXEL

@05,05 LISTBOX oServ FIELDS HEADER STR0037,STR0038,STR0039 ; //"Serviço" # "Empresa/Filial" # "Classe"
FIELDSIZES 70,50,50 SIZE 177,95 PIXEL

PUpdSObj(,bLine,@aList,.F.)
oServ:SetArray(aList)
oServ:bLine := bLine

@05,187 BUTTON aBtn[1] PROMPT STR0004 SIZE 35,11 PIXEL ; //"&Incluir"
ACTION If(PCadServ(0,.f.),PUpdSObj(@oServ,bLine,@aList),)

@18,187 BUTTON aBtn[2] PROMPT STR0005 SIZE 35,11 PIXEL WHEN (aList[1][4] > 0) ; //"&Alterar"
ACTION If(PCadServ(aList[oServ:nAt][4],.f.),PUpdSObj(@oServ,bLine,@aList),)

@31,187 BUTTON aBtn[3] PROMPT STR0006 SIZE 35,11 PIXEL WHEN (aList[1][4] > 0) ; //"&Excluir"
ACTION If(PDelServ(aList[oServ:nAt][4]),PUpdSObj(@oServ,bLine,@aList),)

@44,187 BUTTON aBtn[4] PROMPT STR0009 SIZE 35,11 PIXEL ACTION oDlg:End() //"&Sair"

@57,187 BUTTON aBtn[5] PROMPT "Serv. &Padrao" SIZE 35,13 PIXEL ; 
ACTION If(PCadServ(0,.T.),PUpdSObj(@oServ,bLine,@aList),)

ACTIVATE DIALOG oDlg CENTERED

Return

/*/
*************************************************
* PCadServ()									*
* tela p/ cadastro de servico					*
*************************************************
/*/
Function PCadServ(nServ,lCadPadrao)
Local oDlg
Local aInfo
Local lRet := .F.
Local cEmpFi := ""
Local cTipo := ""
Local cClasse := ""
Local oEmpFi
Local oTipo
Local oClasse
Local aClasse := {STR0040,STR0041} //"Upload" # "Download"
Local aTipo := {}
Local aEmpFi := {}
Local nRecSav
Local nPos
Local nTipo

DEFAULT nServ := 0

/*/
*************************************************
* aInfo:										*
* P_ID											*
* P_SERIE										*
* P_EMPFI										*
* P_TIPO										*
* P_CLASSE										*
*************************************************
/*/

aInfo := PRetSInfo(nServ)

If aPEmp == NIL
	aPEmp := {}
	DbSelectArea("SM0")
	nRecSav := Recno()
	DbGoTop()
	While ( !Eof() )
		Aadd(aPEmp,M0_CODIGO+M0_CODFIL)
		DbSkip()
	End
	DbGoTo(nRecSav)
EndIf

If nServ == 0 .Or. PValServ(aInfo)

	Aeval(aPEmp,{|x,y| Aadd(aEmpFi,Subs(x,1,2)+"/"+Subs(x,3,4))})
	Aeval(aCTipos,{|x,y| Aadd(aTipo,x[1]+" - "+x[2])})
	
	If ( nServ <> 0 )
		nTipo := Ascan(aCTipos,{|x| x[2] == Trim(aInfo[4])})
		cEmpFi := aEmpFi[Ascan(aPEmp,aInfo[3])]
		cTipo := aTipo[nTipo]
		cClasse := aClasse[Val(aInfo[5])]
	Else
		nTipo := 1
	EndIf
	
	DEFINE MSDIALOG oDlg TITLE STR0042 FROM 0,0 TO 100,470 PIXEL //"Propriedades do Serviço"

	//aInfo[2]
	@07,05 SAY STR0043 PIXEL //"Empresa/Filial:"
	@05,58 COMBOBOX oEmpFi VAR cEmpFi ITEMS aEmpFi PIXEL SIZE 30,50

	If !lCadPadrao
		//aInfo[3]
		@22,05 SAY STR0044 PIXEL //"Tipo:"
		@20,58 COMBOBOX oTipo VAR cTipo ITEMS aTipo PIXEL SIZE 100,50
	
		//aInfo[4]
		@37,05 SAY STR0045 PIXEL //"Classe:"
		@35,58 COMBOBOX oClasse VAR cClasse ITEMS aClasse PIXEL SIZE 60,50
		@35,58 COMBOBOX oClasse VAR cClasse ITEMS aClasse PIXEL SIZE 60,50

		@05,202 BUTTON "&OK" SIZE 28,11 PIXEL ;
		ACTION (PUpdServ(oEmpFi:nAt,oTipo:nAt,oClasse:nAt,@aInfo),If(PAddServ(nServ,aInfo),(lRet := .T.,oDlg:End()),))
	Else
		@05,202 BUTTON "&Confirma" SIZE 28,11 PIXEL ; //Cad. Padrao
		ACTION ( If(PAddAllServ(nServ,@aInfo,oEmpFi:nAt),(lRet := .T.,oDlg:End()),) )
    Endif

	@18,202 BUTTON STR0017 SIZE 28,11 PIXEL ACTION oDlg:End() //"&Cancelar"
	
	ACTIVATE DIALOG oDlg CENTERED
Else
	MSGSTOP(STR0047,STR0018) //"Erro na configuração do serviço" # "Atenção
EndIf

Return lRet

/*/
*************************************************
* PRetSInfo()									*
* retorna vetor com informacoes do servico		*
*************************************************
/*/
Function PRetSInfo(nServ)
Local aRet

DEFAULT nServ := 0

If ( nServ == 0 ) .Or. ( nServ > Len(aListServ) )
	aRet := {Space(10),;
			 Space(20),;
			 Space(4),;
			 Space(10),;
			 Space(1)}
Else
	aRet := {aListServ[nServ][2],;
			 aListServ[nServ][3],;
			 aListServ[nServ][4],;
			 aListServ[nServ][5],;
			 aListServ[nServ][6]}
EndIf
Return aRet

/*/
*************************************************
* PMaskClass()									*
* mascara p/ classe do servico					*
*************************************************
/*/
Function PMaskClass(cClasse)
Local cRet := ""

DEFAULT cClasse := ""

If ( !Empty(cClasse) )
	If ( cClasse == "1" )
		cRet := STR0040 //"Upload"
	ElseIf ( cClasse == "2" )
		cRet := STR0041 //"Download"
	Else
		cRet := STR0048 //"Indefinido"
	EndIf
EndIf
Return cRet

/*/
*************************************************
* PMaskClass()									*
* mascara p/ nome do servico					*
*************************************************
/*/
Function PMaskServ(cServ)
Local cRet := ""
Local nPos

DEFAULT cServ := ""

cServ := Trim(cServ)

If ( !Empty(cServ) )
	nPos := Ascan(aCTipos,{|x| x[2] == cServ})
	If ( nPos == 0 )
		cRet := STR0048 //"Indefinido"
	Else
		cRet := aCTipos[nPos][1]
	EndIf
EndIf
Return cRet

/*/
*************************************************
* PUpdServ()									*
* atualiza campos com o valor real				*
*************************************************
/*/
Function PUpdServ(nEmpFi,nTipo,nClasse,aInfo)

aInfo[3] := aPEmp[nEmpFi]
aInfo[4] := aCTipos[nTipo][2]
aInfo[5] := StrZero(nClasse,1,0)
Return .T.

/*/
*************************************************
* PAddServ()									*
* adiciona/altera servco no vetor de servicos	*
* do usuario									*
*************************************************
/*/
Function PAddServ(nServ,aInfo)
Local i
Local cID
Local lRet := .T.
Local nPos

If nServ == 0
	nPos := Ascan(aListServ,{|x| x[1] == 2 .And. Trim(x[4]) == aInfo[3] .And. Trim(x[5]) == aInfo[4] .And. Trim(x[6]) == aInfo[5]})
	If ( nPos == 0 )
		nPos := Ascan(aListServ,{|x| x[1] <> 2 .And. Trim(x[4]) == aInfo[3] .And. Trim(x[5]) == aInfo[4] .And. Trim(x[6]) == aInfo[5]})
		If ( nPos <> 0 )
			MSGSTOP("Serviço já cadastrado para este usuário.",STR0018) //"Serviço já cadastrado para este usuário." # "Atenção"
			lRet := .F.
		Else
			cLastID := Soma1(cLastID)
			aInfo[1] := cLastID
			Aadd(aListServ,{1})
			nServ := Len(aListServ)
			
			For i := 1 To Len(aInfo)
				Aadd(aListServ[nServ],aInfo[i])
			Next
		EndIf
	Else
		nServ := nPos
		aListServ[nServ][1] := 1
		For i := 1 To Len(aInfo)
			aListServ[nServ][i+1] := aInfo[i]
		Next
	EndIf
Else
	aListServ[nServ][1] := 1
	For i := 1 To Len(aInfo)
		aListServ[nServ][i+1] := aInfo[i]
	Next
EndIf

Return lRet

/*/
*************************************************
* PUpdSObj()									*
* atualiza objetos da tela de servicos			*
*************************************************
/*/
Function PUpdSObj(oServ,bLine,aList,lUpd)
Local i
Local nPos

DEFAULT lUpd := .T.

aList := {}
For i := 1 To Len(aListServ)
	If ( aListServ[i][1] <> 2 )
        Aadd(aList,{})
		
		nPos := Len(aList)
		Aadd(aList[nPos],PMaskServ(aListServ[i][5])) //servico
		
		If ( Empty(aListServ[i][4]) ) //empresa
			Aadd(aList[nPos],"")
		Else
			Aadd(aList[nPos],Subs(aListServ[i][4],1,2)+"/"+Subs(aListServ[i][4],3,4))
		EndIf
		
		Aadd(aList[nPos],PMaskClass(aListServ[i][6])) //classe
		Aadd(aList[nPos],i) //posicao
	EndIf
Next

If ( Empty(aList) )
	aList := {{"","","",0}}
EndIf

If ( lUpd )
	oServ:SetArray(aList)
	oServ:bLine := bLine
	oServ:Refresh()
EndIf
Return

/*/
*************************************************
* PValServ()									*
* valida servico segundo informacoes tratadas	*
* pelo prg (empresas,tipos,classe...)			*
*************************************************
/*/
Function PValServ(aInfo)
Local lRet := .F.
Local nPos
Local nVal1
Local nVal2

// verifica se a empresa existe

If ( Ascan(aPemp,aInfo[3]) <> 0 )

	//verifica se o servico existe

	nPos := Ascan(aCTipos,{|x| x[2] == Trim(aInfo[4])})
	If ( nPos <> 0 )
	
		//verifica se a classe corresponde ao servico
	
		nVal1 := Val(aInfo[5])
		If ( nVal1 > 0 .And. nVal1 < 3)
			nVal2 := Val(aCTipos[nPos][3])
			If ( nVal2 == 0 )
				lRet := .T.
			Else
				lRet := ( nVal1 == nVal2 )
			EndIf
		EndIf
	EndIf
EndIf
Return lRet

/*/
*************************************************
* PDelUser()									*
* exclui servico do vetor de servico do usuario *
*************************************************
/*/
Function PDelServ(nServ)
//Local i
Local lRet := .F.

DEFAULT nServ := 0

If nServ <> 0
	lRet := MsgNoYes(STR0049,STR0018) //"Tem certeza que deseja excluir esse serviço ?" # "Atenção"
	If lRet
		aListServ[nServ][1] := 2
	EndIf
EndIf
Return lRet

/*/
*************************************************
* PSaveServ()									*
* salva informacoes do vetor de servicos na		*
* tabela PALMSERV								*
*************************************************
/*/
Function PSaveServ()
Local i

DbSelectArea(PSALIAS)
DbSetOrder(2)
For i := 1 To Len(aSaveServ)
	If aSaveServ[i][1] == 1
	
		//procura pelo servico na tabela p/ inclusao ou alteracao
		
		If DbSeek(aSaveServ[i][2])
			RecLock(PSALIAS,.F.)
		Else
			RecLock(PSALIAS,.T.)
		EndIf
		P_ID   	 := aSaveServ[i][2]
		P_SERIE	 := aSaveServ[i][3]
		P_EMPFI	 := aSaveServ[i][4]
		P_TIPO   := aSaveServ[i][5]
		P_CLASSE := aSaveServ[i][6]
		MsUnlock()
		aSaveServ[i][1] := 0
	ElseIf aSaveServ[i][1] == 2
	
		//procura pelo servico na tabela p/ exclusao
	
		If DbSeek(aSaveServ[i][2])
			RecLock(PSALIAS,.F.,.T.)
			DbDelete()
			MsUnlock()
		EndIf
	EndIf
Next
DbCommit()
Return .T.


// ************ PCondInt()

Function PCondInt()
Local i
Local cSvAlias := Alias()
Local oCond
Local aBtn  := Array(4)
Local nCond := 1

/*/
*********************************************************************
* aSaveCond:														*
* [1] -> situacao (0 - nao alterado / 1 - alterado / 2 - excluido)	*
* [2] -> P_COND	     												*
* [3] -> P_STCODPR													*
* [4] -> P_CODPR													*
* [5] -> P_STDTENT													*
* [6] -> P_DTENT													*
* [7] -> P_STIPPG													*
* [8] -> P_TIPPG													*
* [9] -> P_STTES													*
* [10]-> P_TES														*
* [11]-> P_STDESC                                                   *
* [12]-> P_DESC                                                     *
*********************************************************************
/*/

Private oDlgCnd
Private aCond := {}
Private nLastUser := 0

//carrega usuarios na memoria
DbSelectArea(PCALIAS)
DbSetOrder(1)
DbGoTop()
While !Eof()
	Aadd(aCond,P_COND)
	Aadd(aSaveCond,{0,P_COND,P_STCODPR,P_CODPR,P_STDTENT,P_DTENT,P_STIPPG,P_TIPPG,P_STTES,P_TES,P_STDESC,P_DESC})
	DbSkip()
End

//procura pelo ultimo ID de servico e carrega servicos na memoria

DEFINE MSDIALOG oDlgCond TITLE "Condição de Pagamento Inteligente" FROM 0,0 TO 218,300 OF oDlg61 PIXEL //"Condição de Pagamento Inteligente"

@01,05 SAY "Condições:" PIXEL //"Condições:"
@10,05 LISTBOX oCond VAR nCond ITEMS aCond PIXEL SIZE 100,90
oCond:bChange := {|| oCond:Refresh()}

@10,110 BUTTON aBtn[1] PROMPT STR0004 SIZE 35,11 PIXEL ; //"&Incluir"
ACTION If(PCadCond(0),(oCond:SetItems(aCond)),)

@23,110 BUTTON aBtn[2] PROMPT STR0005 SIZE 35,11 PIXEL WHEN !Empty(aUser[1]) ; //"&Alterar"
ACTION If(PCadCond(nCond),(oCond:SetItems(aCond)),)

@36,110 BUTTON aBtn[3] PROMPT STR0006 SIZE 35,11 PIXEL WHEN !Empty(aUser[1]) ; //"&Excluir"
ACTION If(PDelCond(nCond),(oCond:SetItems(aCond)),)

@49,110 BUTTON aBtn[4] PROMPT STR0009 SIZE 35,11 PIXEL ACTION oDlgCond:End() //"&Sair"

ACTIVATE DIALOG oDlgCond CENTERED

DbSelectArea(cSvAlias)
Return NIL

/*
*************************************************
* PCadCond()									*
* tela p/ cadastro de Concicao					*
*************************************************
/*/
Function PCadCond(nCond)
Local oDlg
Local aInfo
Local oUDI
Local oCond
Local cCond := Space(15)
Local lRet := .F.
Local aPswInfo
Local nPos
Local nStart
Local nAtEnd
Local nPos1
Local oHPreco
Local oHTab
Local oHDias
Local oHPag
Local oHTes
Local oHDesc
Local cHPreco := "2"
Local cHDias  := "2"
Local cHPag   := "2"
Local cHTes   := "2"
Local cHDesc  := "2"

Local aOpc := {"1=Fixo","2=Sugestão"} //"1=Fixo"#"2=Sugestão"

DEFAULT nCond := 0

Private aListServ := {}
/*
*********************************************************************
* aInfo:									   	   					*
* [1] -> P_COND	     												*
* [2] -> P_STCODPR													*
* [3] -> P_CODPR													*
* [4] -> P_STDTENT													*
* [5] -> P_DTENT													*
* [6] -> P_STIPPG													*
* [7] -> P_TIPPG													*
* [8] -> P_STTES													*
* [9] -> P_TES														*
* [10]-> P_STDESC                                                   *
* [11]-> P_DESC                                                     *
*********************************************************************
/*/

aInfo := PRetCInfo(nCond)

If nCond <> 0
	
	//atualiza variaveis com nome do usuario do siga e nome do vendedor
	SE4->(dbSeek(xFilial("SE4")+aInfo[1]))
	cCond    := SE4->E4_DESCRI
	
EndIf

DEFINE MSDIALOG oDlg TITLE "Condicao Inteligente" FROM 0,0 TO 195,470 PIXEL OF oDlgCond //"Cadastro de Condicao Inteligente"

@07,05 SAY "Condicao:" PIXEL //"Condicao:"
@07,58 MSGET aInfo[1] PIXEL F3 "SE4" WHEN (nCond == 0);
VALID (cCond := PUpdCond(aInfo[1]),oCond:Refresh(),.T.)

@07,100 MSGET oCond VAR cCond PIXEL SIZE 87,10 WHEN .F.

@22,05 SAY "Tabela de Preço:" PIXEL //"Tabela de Preço:"
//@22,58 GET aInfo[2] PIXEL SIZE 139,10

@22,58 COMBOBOX oHPreco VAR aInfo[2] ITEMS aOpc PIXEL SIZE 40,30;

@22,100 MSGET aInfo[3] PIXEL F3 "DA0" 

@37,05 SAY "Dias para Entrega:" PIXEL //"Dias para Entrega:"
//@22,58 GET aInfo[2] PIXEL SIZE 139,10

@37,58 COMBOBOX oHDias VAR aInfo[4] ITEMS aOpc PIXEL SIZE 40,30;

@37,100 GET aInfo[5] PIXEL SIZE 40,10 PICTURE "999";

@52,05 SAY "Tipo de Pagamento:" PIXEL //"Tipo de Pagamento:"
//@22,58 GET aInfo[2] PIXEL SIZE 139,10

@52,58 COMBOBOX oHPag VAR aInfo[6] ITEMS aOpc PIXEL SIZE 40,30;

@52,100 MSGET aInfo[7] PIXEL F3 "24";

@67,05 SAY "TES:" PIXEL //"TES:"
//@22,58 GET aInfo[2] PIXEL SIZE 139,10

@67,58 COMBOBOX oHTes VAR aInfo[8] ITEMS aOpc PIXEL SIZE 40,30;

@67,100 MSGET aInfo[9] PIXEL F3 "SF4";

@82,05 SAY "Desconto:" PIXEL //"Desconto:"
//@22,58 GET aInfo[2] PIXEL SIZE 139,10

@82,58 COMBOBOX oHDesc VAR aInfo[10] ITEMS aOpc PIXEL SIZE 40,30;

@82,100 GET aInfo[11] PIXEL SIZE 40,10 PICTURE "99.99";

@05,202 BUTTON "&OK" SIZE 28,11 PIXEL ;
ACTION If(PAddCond(nCond,aInfo),(lRet := .T.,oDlg:End()),)

@18,202 BUTTON STR0017 SIZE 28,11 PIXEL ACTION oDlg:End() //"&Cancelar"

ACTIVATE DIALOG oDlg CENTERED

Return lRet

/*/
*************************************************
* PRetCInfo()									*
* retorna vetor com informacoes da condicao		*
*************************************************
/*/
Function PRetCInfo(nCond)
Local aRet
Local nSave

DEFAULT nCond := 0

If nCond == 0
	aRet := {Space(3),;
			 "2",;
			 Space(3),;
			 "2",;
			 0,;
			 "2",;
			 Space(3),;
			 "2",;
			 Space(3),;
			 "2",;
			 0}
Else
	nSave := Ascan(aSaveCond,{|x| x[2] == aCond[nCond]})
	If nSave == 0
		DbSelectArea(PCALIAS)
		DbSetOrder(1)
		DbSeek(aCond[nCond])
		aRet := {P_COND,;
				 P_STCODPR,;
				 P_CODPR,;			 
				 P_STDTENT,;
				 P_DTENT,;				 
				 P_STIPPG,;
				 P_TIPPG,;				 
				 P_STTES,;
				 P_TES,;				 
				 P_STDESC,;
				 P_DESC}
	Else
		aRet := {aSaveCond[nSave][2],;
				 If(Empty(aSaveCond[nSave][4]),"2",aSaveCond[nSave][3]),;
				 aSaveCond[nSave][4],;
				 If(Empty(aSaveCond[nSave][6]),"2",aSaveCond[nSave][5]),;
				 aSaveCond[nSave][6],;
				 If(Empty(aSaveCond[nSave][8]),"2",aSaveCond[nSave][7]),;
				 aSaveCond[nSave][8],;
				 If(Empty(aSaveCond[nSave][10]),"2",aSaveCond[nSave][9]),;
				 aSaveCond[nSave][10],;
				 If(Empty(aSaveCond[nSave][12]),"2",aSaveCond[nSave][11]),;
				 aSaveCond[nSave][12],;
				 }
	EndIf
EndIf
Return aRet

/*/
**************************************************
* PAddCond()									 * 
* adiciona/altera condicao no vetor de condicoes *
**************************************************
/*/
Function PAddCond(nCond,aInfo)
Local i
Local nSave
Local lRet := .F.
Local nPos

DEFAULT nCond := 0
DEFAULT aInfo := PRetCInfo()

//serie em branco

If Empty(aInfo[1])
	MSGSTOP("Informe uma Condição.",STR0018) //"Informe uma Condição." # "Atenção"

//serie ja existe

ElseIf (nCond == 0) .And. (Ascan(aCond,aInfo[1]) <> 0)
	MSGSTOP("Condicao ja Existe.",STR0018) //"Condicao ja Existe" # "Atenção"
	
Elseif Empty(aInfo[10])
	MSGSTOP("Informe o Equipamento HandHeld. Palm OS ou Pocket PC? ",STR0018) //"Informe o Equipamento (Palm ou Pocket)"

ElseIf !SE4->(dbSeek(xFilial("SE4")+aInfo[1]))
	MSGSTOP("Condicao nao Cadastrada.",STR0018) //"Condicao nao Cadastrada." # "Atenção"
	
Else
/*	nPos := Ascan(aCond,aInfo[2])
	//usuario ja existe
	
	If nPos <> 0 .And. nPos <> nCond
		MSGSTOP("Condicao já existe.",STR0018) //"Condicao já existe." # Atenção
	Else
	
		//se nao existir o usuario do siga ou vendedor limpa os campos referentes
		DbSelectArea("SF4")
		DbSetOrder(1)
		aInfo[5] := If(DbSeek(xFilial("SA3")+aInfo[5]),aInfo[5],"")
		PswOrder(1)
		aInfo[4] := If(PswSeek(aInfo[4]),aInfo[4],"")
	EndIf
*/
	lRet := .T.
EndIf

If lRet
	nPos := Ascan(aCond,{|x| x > aInfo[1]})
	If nCond == 0
		//cLastDir := Soma1(cLastDir)
		Aadd(aCond,NIL)
		If nPos == 0
			nCond := Len(aCond)
		Else
			nCond := nPos
		    Ains(aCond,nCond)
		EndIf
//		Aeval(aListServ,{|x| x[3] := aInfo[1]})
	EndIf
	aCond[nCond] := aInfo[1]
	
	//atualiza informacoes no vetor de usuarios procurando pelo numero de serie
	//e seta o primeiro elemento com 1 (alterado)

	nSave := Ascan(aSaveCond,{|x| x[2] == aCond[nCond]})
	If nSave == 0
		Aadd(aSaveCond,)
		nSave := Len(aSaveCond)
	EndIf

	aSaveCond[nSave] := {1}

	For i := 1 To Len(aInfo)
		Aadd(aSaveCond[nSave],aInfo[i])
	Next
	
	lChange := .T.
//	nLastCond := nUser
EndIf
Return lRet

/*/
*************************************************
* PSaveCond()									*
* salva informacoes do vetor de usuarios na		*
* tabela PALMCOND								*
*************************************************
/*/
Function PSaveCond()
Local i
//Local cDir

DbSelectArea(PCALIAS)
DbSetOrder(1)
For i := 1 To Len(aSaveCond)
	If aSaveCond[i][1] == 1
		
		//procura pela condicao na tabela p/ inclusao ou alteracao
		
		If DbSeek(aSaveCond[i][2])
			RecLock(PCALIAS,.F.)
		Else
			RecLock(PCALIAS,.T.)		
		EndIf
		P_COND	  := aSaveCond[i][2]
		P_STCODPR := aSaveCond[i][3]
		P_CODPR	  := aSaveCond[i][4]
		P_STDTENT := aSaveCond[i][5]
		P_DTENT   := aSaveCond[i][6]
		P_STIPPG  := aSaveCond[i][7]
		P_TIPPG   := aSaveCond[i][8]
		P_STTES   := aSaveCond[i][9]
		P_TES     := aSaveCond[i][10]
		P_STDESC  := aSaveCond[i][11]
		P_DESC    := aSaveCond[i][12]
		MsUnlock()
		aSaveCond[i][1] := 0
	ElseIf aSaveCond[i][1] == 2
		
		//procura pelo usuario na tabela p/ exclusao
		
		If DbSeek(aSaveCond[i][2])
			RecLock(PCALIAS,.F.,.T.)
			DbDelete()
			MsUnlock()
		EndIf
	EndIf
Next
DbCommit()
lChange := .F.
Return .T.

/*/
*************************************************
* PDelCond()									*
* exclui condicao do vetor de condicoes			*
*************************************************
/*/
Function PDelCond(nCond)
Local i
Local aInfo
Local nSave
Local lRet := .F.

DEFAULT nCond := 0

If nCond <> 0
	lRet := MsgNoYes(STR0025+Trim(aCond[nCond])+" ?",STR0018) //"Tem certeza que deseja excluir o usuário " # "Atenção"
	If lRet
		aInfo := PRetCInfo(nCond)
		
		//procura pela condicao e seta o primeiro elemento do vetor com 2 (excluido)
		
		nSave := Ascan(aSaveCond,{|x| x[2] == aCond[nCond]})
		If nSave == 0
			Aadd(aSaveCond,)
			nSave := Len(aSaveCond)
		EndIf
		aSaveCond[nSave] := {2}
		For i := 1 To Len(aInfo)
			Aadd(aSaveCond[nSave],aInfo[i])
		Next
		
		ADel(aCond,nCond)
		ASize(aCond,Len(aCond)-1)
		lChange := .T.
	EndIf
EndIf
Return lRet

Static Function FastSeek(cGet,nLastSeek,aArray,lCase,lWord)
Local nSearch := 0
Local bSearch

cGet := Trim(cGet)

If ( lCase .And. lWord )
	bSearch := {|x| Trim(x) == cGet}
ElseIf ( !lCase .And. !lWord )
	bSearch := {|x| Trim(Upper(SubStr(x,1,Len(cGet)))) == Upper(cGet)}
ElseIf ( lCase .And. !lWord )
	bSearch := {|x| Trim(SubStr(x,1,Len(cGet))) == cGet}
ElseIf ( !lCase .And. lWord )
	bSearch := {|x| Trim(Upper(x)) == Upper(cGet)}
EndIf

nSearch := Ascan(aArray,bSearch,nLastSeek+1)
If ( nSearch == 0 )
	nSearch := Ascan(aArray,bSearch)
	If ( nSearch == 0 )
		nSearch := nLastSeek
	EndIf
EndIf
Return nSearch


// Cadastro de tabelas para Novo MCS - Eadvpl
// ************ PTabelas()

Function PTabelas()
Local i
Local cTbAlias := Alias()
Local oTabl
Local aBtn  := Array(4)
Local nTabl := 1

/*/
*********************************************************************
* aSaveTabl:														*
* [1] -> situacao (0 - nao alterado / 1 - alterado / 2 - excluido)	*
* [2] -> P_TABELA   												*
* [3] -> P_DESCRI   												*
* [4] -> P_EMPFI													*
* [5] -> P_TOHOST													*
* [6] -> P_TPCARGA													*
*********************************************************************
/*/

Private oDlgTabl
Private aTabl := {}
Private nLastUser := 0

//carrega usuarios na memoria
	
DbSelectArea(PFALIAS)
DbSetOrder(1)
DbGoTop()
While !Eof()
	Aadd(aTabl,P_TABELA)
	Aadd(aSaveTabl,{0,P_TABELA,P_DESCRI,P_EMPFI,P_TOHOST,P_TPCARGA})
	DbSkip()
End

DEFINE MSDIALOG oDlgTabl TITLE "Tabelas para MCS" FROM 0,0 TO 218,300 OF oDlgTabl PIXEL //"Tabelas para MCS"

@01,05 SAY "Tabelas MCS:" PIXEL //"Tabelas MCS"
@10,05 LISTBOX oTabl VAR nTabl ITEMS aTabl PIXEL SIZE 100,90
oTabl:bChange := {|| oTabl:Refresh()}

@10,110 BUTTON aBtn[1] PROMPT STR0004 SIZE 35,11 PIXEL ; //"&Incluir"
ACTION If(PCadTabl(),(oTabl:SetItems(aTabl)),)

@23,110 BUTTON aBtn[2] PROMPT STR0005 SIZE 35,11 PIXEL WHEN !Empty(aUser[1]) ; //"&Alterar"
ACTION If(PCadTabl(nTabl),(oTabl:SetItems(aTabl)),)

@36,110 BUTTON aBtn[3] PROMPT STR0006 SIZE 35,11 PIXEL WHEN Len(aTabl)>0 ; //"&Excluir"
ACTION If(PDelTabl(nTabl,aTabl),(oTabl:SetItems(aTabl)),)

@49,110 BUTTON aBtn[4] PROMPT STR0009 SIZE 35,11 PIXEL ACTION oDlgTabl:End() //"&Sair"

ACTIVATE DIALOG oDlgTabl CENTERED

DbSelectArea(cTbAlias)
Return NIL

/*
*************************************************
* PCadTabl()									*
* tela p/ cadastro de Tabelas para MCS   		*
*************************************************
/*/
Function PCadTabl(nTabl)
Local oDlg
Local aInfo
Local oUDI
Local oTabl
Local cTabl := Space(10)
Local lRet := .F.
Local aPswInfo
Local nPos
Local nStart
Local nAtEnd
Local nPos1
Local oTcarga
Local oTOhost
Local oEmpFi
Local cTCarga := "1"
Local cTOhost := "1"              
Local aEmpFi := {}
Local cEmpFI :="" 

Local aOpc1 := {"1=Retorna","2=Nao Retorna"} //"1=Retona"#"2=Nao Retorna"
Local aOpc2 := {"1=Incremental","2=Completa"} //"1=Incremental"#"2=Completa"

DEFAULT nTabl := 0

Private aListServ := {}
/*
*********************************************************************
* aInfo:									   	   					*
* [1] -> P_TABELA	   												*
* [2] -> P_DESCRI   												*
* [3] -> P_EMPFI 													*
* [4] -> P_TOHOST 													*
* [5] -> P_TPCARGA													*
*********************************************************************
/*/

aInfo := PRetFInfo(nTabl)

If aPEmp == NIL
	aPEmp := {}
	DbSelectArea("SM0")
	nRecSav := Recno()
	DbGoTop()
	While ( !Eof() )
		Aadd(aPEmp,M0_CODIGO+M0_CODFIL)
		DbSkip()
	End
	DbGoTo(nRecSav)
EndIf

DEFINE MSDIALOG oDlg TITLE "Tabelas x MCS" FROM 0,0 TO 200,470 PIXEL OF oDlg //"Cadastro de Tabelas MCS"

@07,05 SAY STR0054 PIXEL //"Tabela:"
@07,58 GET aInfo[1] PIXEL SIZE 139,10

@22,05 SAY "Descricao:" PIXEL //"Descricao"
@22,58 GET aInfo[2] PIXEL SIZE 139,10


@37,05 SAY STR0043 PIXEL //"Empresa/Filial:"
@37,58 COMBOBOX oEmpFi VAR aInfo[3] ITEMS aPEmp PIXEL SIZE 30,70

@52,05 SAY "Retaguarda:" PIXEL //"Retaguarda"
@52,58 COMBOBOX oTOHost VAR aInfo[4] ITEMS aOpc1 PIXEL SIZE 139,30;

@67,05 SAY "Tipo Carga:" PIXEL //"Tipo Carga"
@67,58 COMBOBOX oTCarga VAR aInfo[5] ITEMS aOpc2 PIXEL SIZE 139,30;

@82,78 BUTTON "&OK" SIZE 28,11 PIXEL ;
ACTION If(PAddTabl(nTabl,aInfo),(lRet := .T.,oDlg:End()),)

@82,138 BUTTON STR0017 SIZE 28,11 PIXEL ACTION oDlg:End() //"&Cancelar"

ACTIVATE DIALOG oDlg CENTERED

Return lRet

/*/
*************************************************
* PRetFInfo()									*
* retorna vetor com informacoes ds Tabelas 		*
*************************************************
/*/
Function PRetFInfo(nTabl)
Local aRet
Local nSave

DEFAULT nTabl := 0

If nTabl == 0
	aRet := {Space(10),;
			 Space(20),;
			 Space(04),;
			 .F.,;
			 "" }
Else
	nSave := Ascan(aSaveTabl,{|x| x[2] == aTabl[nTabl]})
	If nSave == 0
		DbSelectArea(PFALIAS)
		DbSetOrder(1)
		DbSeek(aTabl[nTabl])
		aRet := {P_TABELA,;
				 P_DESCRI,;
				 P_EMPFI,;			 
				 P_TOHOST,;
				 P_TPCARGA }
	Else
		aRet := {aSaveTabl[nSave][2],;
				 aSaveTabl[nSave][3],;
				 aSaveTabl[nSave][4],;
				 aSaveTabl[nSave][5],;
				 aSaveTabl[nSave][6],;
				 }

	EndIf
EndIf
Return aRet

/*/
**************************************************
* PAddTabl()									 * 
* adiciona/altera Tabela no vetor de Tabelas     *
**************************************************
/*/
Function PAddTabl(nTabl,aInfo)
Local i
Local nSave
Local lRet := .F.
Local nPos

DEFAULT nTabl := 0
DEFAULT aInfo := PRetFInfo()

//serie em branco

If Empty(aInfo[1])
	MSGSTOP("Informe o nome da tabela.",STR0018) //"Informe uma Tabela." # "Atenção"

//serie ja existe

ElseIf (nTabl == 0) .And. (Ascan(aTabl,aInfo[1]) <> 0)
	MSGSTOP("Tabela ja Existe.",STR0018) //"Tabela ja Existe" # "Atenção"

Elseif Empty(aInfo[2])
	MSGSTOP("Informe a Descricao da Tabela ",STR0018) //"Informe a Descricao da Tabela "

Elseif Empty(aInfo[3])
	MSGSTOP("Informe a Empresa/Filial ",STR0018) //"Informe a Empresa/Filial "

Elseif Empty(aInfo[4])
	MSGSTOP("Informe a direcao da tabela ",STR0018) //"Informe a direcao da tabela "

Elseif Empty(aInfo[5])
	MSGSTOP("Informe o tipo de Carga da Tabela ",STR0018) //"Informe o tipo de Carga da Tabela "
	
Else
	lRet := .T.
EndIf

If lRet
	nPos := Ascan(aTabl,{|x| x > aInfo[1]})
	If nTabl == 0

		Aadd(aTabl,NIL)
		If nPos == 0
			nTabl := Len(aTabl)
		Else
			nTabl := nPos
		    Ains(aTabl,nTabl)
		EndIf
	EndIf
	aTabl[nTabl] := aInfo[1]
	
	//atualiza informacoes no vetor de usuarios procurando pelo numero de serie
	//e seta o primeiro elemento com 1 (alterado)

	nSave := Ascan(aSaveTabl,{|x| x[2] == aTabl[nTabl]})
	If nSave == 0
		Aadd(aSaveTabl,)
		nSave := Len(aSaveTabl)
	EndIf

	aSaveTabl[nSave] := {1}

	For i := 1 To Len(aInfo)
		Aadd(aSaveTabl[nSave],aInfo[i])
	Next
	
	lChange := .T.

EndIf
Return lRet

/*/
*************************************************
* PValTabl()									*
* valida tabela segundo informacoes tratadas	*
* pelo prg (empresas,tipos,classe...)			*
*************************************************
/*/
Function PValTabl(aInfo)
Local lRet := .F.
Local nPos
Local nVal1
Local nVal2

// verifica se a empresa existe

If ( Ascan(aPemp,aInfo[3]) <> 0 )

	//verifica se o servico existe

	nPos := Ascan(aCTipos,{|x| x[2] == Trim(aInfo[4])})
	If ( nPos <> 0 )
	
		//verifica se a classe corresponde ao servico
	
		nVal1 := Val(aInfo[5])
		If ( nVal1 > 0 .And. nVal1 < 3)
			nVal2 := Val(aCTipos[nPos][3])
			If ( nVal2 == 0 )
				lRet := .T.
			Else
				lRet := ( nVal1 == nVal2 )
			EndIf
		EndIf
	EndIf
EndIf
Return lRet

/*/
*************************************************
* PSaveTabl()									*
* salva informacoes do vetor de usuarios na		*
* tabela PALMCOND								*
*************************************************
/*/
Function PSaveTabl()
Local i
//Local cDir

DbSelectArea(PFALIAS)
DbSetOrder(1)
For i := 1 To Len(aSaveTabl)
	If aSaveTabl[i][1] == 1
		
		//procura pela condicao na tabela p/ inclusao ou alteracao
		
		If DbSeek(aSaveTabl[i][2])
			RecLock(PFALIAS,.F.)
		Else
			RecLock(PFALIAS,.T.)		
		EndIf  
		
		P_TABELA := aSaveTabl[i][2]
		P_DESCRI := aSaveTabl[i][3]
		P_EMPFI  := aSaveTabl[i][4]
		P_TOHOST := IF(aSaveTabl[i][5]="1", .T., .F. )
		P_TPCARGA:= aSaveTabl[i][6] 

		MsUnlock()
		aSaveTabl[i][1] := 0
	ElseIf aSaveTabl[i][1] == 2
		
		//procura pelo usuario na tabela p/ exclusao
		
		If DbSeek(aSaveTabl[i][2])
			RecLock(PFALIAS,.F.,.T.)
			DbDelete()
			MsUnlock()
		EndIf
	EndIf
Next
DbCommit()
lChange := .F.
Return .T.

/*/
*************************************************
* PDelTabl()									*
* exclui usuario do vetor de usuarios			*
*************************************************
/*/
Function PDelTabl(nTabl, aTabl)
Local i
Local aInfo
Local nSave
Local lRet := .F.

DEFAULT nTabl := 0

If nTabl <> 0
	lRet := MsgNoYes("Tem certeza que deseja excluir a tabela "+Trim(aTabl[nTabl])+" ?",STR0018) //"Tem certeza que deseja excluir o usuário " # "Atenção"
	If lRet
		aInfo := PRetFInfo(nTabl)
		
		//procura pelo usuario e seta o primeiro elemento do vetor com 2 (excluido)
		nSave := Ascan(aSaveTabl,{|x| x[2] == aTabl[nTabl]})
		If nSave == 0
			Aadd(aSaveTabl,)
			nSave := Len(aSaveTabl)
		EndIf
		aSaveTabl[nSave] := {2}
		For i := 1 To Len(aInfo)
			Aadd(aSaveTabl[nSave],aInfo[i])
		Next
		
		ADel(aTabl,nTabl)
		ASize(aTabl,Len(aTabl)-1)
		lChange := .T.
	EndIf
EndIf
Return lRet

Function PDelData(aInfo, lDelData)
Local cMsg := "" 

If !lDelData
	aInfo[12] := Space(1)
Else
	cMsg += "Esta alteração implica na exclusão da base de dados do vendedor. 
	cMsg += "Caso existam informações não importadas para o Protheus estas serão perdidas." + Chr(13) + Chr(10)
	cMsg += "Deseja continuar ?"
	
	If MsgNoYes(cMsg, "Excluir Base")
		aInfo[12]	:= "T"
	EndIf		

EndIf

Return Nil


// Testes (Cadastro padrao de Servicos)
Function PAddAllServ(nServ,aInfo,nEmpFi)
Local i,j
Local cID
Local lRet := .T.
Local nPos  
Local cMsg := "Esta operação irá cadastrar automaticamente os serviços padrões do SFA."+Chr(13)+Chr(10)+"Deseja continuar?"
Local aPadrao := {}

aInfo[3] := aPEmp[nEmpFi]

If MsgNoYes(cMsg,"Cadastro de Serviços")
	PLoadPadrao(@aPadrao)

	For j := 1 To Len(aPadrao) 

		nPos := Ascan(aListServ,{|x| x[1] == 2 .And. Trim(x[4]) == aInfo[3] .And. Trim(x[5]) == aPadrao[j][1] .And. Trim(x[6]) == aPadrao[j][2]})
		If ( nPos == 0 )
			nPos := Ascan(aListServ,{|x| x[1] <> 2 .And. Trim(x[4]) == aInfo[3] .And. Trim(x[5]) == aPadrao[j][1] .And. Trim(x[6]) == aPadrao[j][2]})
			If ( nPos <> 0 )
				MSGSTOP("Serviço " + PMaskServ(aPadrao[j][1]) + " já cadastrado para este usuário.",STR0018) //"Serviço já cadastrado para este usuário." # "Atenção"
				//lRet := .F.
			Else
				cLastID := Soma1(cLastID)
				aInfo[1] := cLastID
				Aadd(aListServ,{1})
				nServ := Len(aListServ)
	
				//For i := 1 To Len(aInfo)
				Aadd(aListServ[nServ],aInfo[1])
				Aadd(aListServ[nServ],aInfo[2])
				Aadd(aListServ[nServ],aInfo[3])
				Aadd(aListServ[nServ],aPadrao[j][1])
				Aadd(aListServ[nServ],aPadrao[j][2])
				//Next
				
			EndIf
		EndIf
		
    Next

Else
	lRet := .F.    
Endif

Return lRet


Function PLoadPadrao(aPadrao)   
/****************************************
*                                       *
* aPadrao:                              *
* [1] - Tipo (nome da funcao)           *
* [2] - Classe (1=upload;2=download)    *
*                                       *
****************************************/
aAdd(aPadrao,{"U_PVendedor","2"})
aAdd(aPadrao,{"U_PRota","2"})
aAdd(aPadrao,{"U_PCliente","2"})
aAdd(aPadrao,{"PProduto","2"})
aAdd(aPadrao,{"U_PTransp","2"})
aAdd(aPadrao,{"U_PCondicao","2"})
aAdd(aPadrao,{"U_PPedido","2"})
aAdd(aPadrao,{"U_PCenVends","2"})
aAdd(aPadrao,{"U_PConfig","2"})
aAdd(aPadrao,{"U_PImpPed","1"})
aAdd(aPadrao,{"U_PImpOco","1"})

//Pronta Entrega  ( FDA ) 
if nSys = 3
   aAdd(aPadrao,{"U_PRONTAENT","2"})
   aAdd(aPadrao,{"U_MOVMTOSPE","2"})
   aAdd(aPadrao,{"U_PExpReceb","2"})
   aAdd(aPadrao,{"U_PBancos","2"})
   aAdd(aPadrao,{"U_IMPNOTA","1"})
   aAdd(aPadrao,{"U_Impdev","1"})
   aAdd(aPadrao,{"U_PImprecP","1"})
endif

Return Nil
