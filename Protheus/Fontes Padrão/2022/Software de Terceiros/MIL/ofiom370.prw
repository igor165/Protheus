// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 10     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#include "Protheus.ch"
#INCLUDE "OFIOM370.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOM370 ³ Autor ³ Manoel                ³ Data ³ 18/01/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Liberacao de Credito                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOM370
Local aCores := {{ 'Alltrim(VSW->VSW_CRELIB) == ""'  , 'BR_VERDE' }  ,;
				{ 'Alltrim(VSW->VSW_CRELIB) == "0"' , 'BR_AZUL' }   ,;
				{ 'Alltrim(VSW->VSW_CRELIB) $ "2/1"', 'BR_VERMELHO' }}
					
Private cCadastro := STR0004 // Liberacao de Credito
Private aRotina := {{ STR0001,"axPesqui", 0 , 1},;	// Pesquisar
					{ STR0002,"FS_OM370", 0 , 2},;	// Liberar
					{ STR0003,"OM370LEG", 0 , 2}}	// Legenda

DbSelectArea("VSW")
DbSetOrder(2)
mBrowse( 6, 1,22,75,"VSW",,,,,,aCores)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_OM370 ³ Autor ³ Manoel                ³ Data ³ 18/01/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela e Movimentacoes da Liberacao de Credito               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_OM370(cAlias,nReg,nOpc)

DEFINE FONT oFnt3 NAME "Arial" BOLD

Private oTipo, oPosCli, oEnvia, oLimite, oDtLim, oRisco, oMotivo
Private oMsg
Private aNewBot := {}
aadd(aNewBot,{"PRECO" ,{|| Fc010Con("SA1",SA1->(recno()),2) },STR0027})//Posicao do Cliente

dbSelectArea("SX3")
DbSetOrder(2)
If dbSeek("A1_LC")
	If !(cNivel>=x3_nivel)
		MsgStop(STR0021,STR0020) // Nivel de Usuario não permite alteração do campo A1_LC. / Atencao
		return .f.
	Endif
Endif

If dbSeek("A1_VENCLC")
	If !(cNivel>=x3_nivel)
		MsgStop(STR0022,STR0020) // Nivel de Usuario não permite alteração do campo A1_VENCLC. / Atencao
		return .f.
	Endif
Endif

If dbSeek("A1_RISCO")
	If !(cNivel>=x3_nivel)
		MsgStop(STR0023,STR0020) // Nivel de Usuario não permite alteração do campo A1_RISCO. / Atencao
		return .f.
	Endif
Endif

DbSelectArea("SA1")
DbSetOrder(1)
DbSeek(xFilial("SA1")+VSW->VSW_CODCLI+VSW->VSW_LOJA)

cMsg  := Space(1000)

nOpca := 0
nTipo := 1

aRisco := {STR0005,STR0006,STR0007,STR0008,STR0009} //Risco A #  Risco B # Risco C # Risco D # Risco E
If ( Empty(SA1->A1_RISCO) .Or. !(SA1->A1_RISCO $ "A/B/C/D/E") )
	cRisco := Alltrim(STR0010+"E")  //Risco E
Else
	cRisco := Alltrim(STR0010+SA1->A1_RISCO)  //Risco
EndIf

nLimite := SA1->A1_LC
dDtLim  := SA1->A1_VENCLC
cMotivo := VSW->VSW_MOTIVO

DEFINE MSDIALOG oDlg TITLE STR0011 FROM  00,02 TO 31,80 OF oMainWnd //Tipo de Liberacao

@  29,  14 RADIO oTipo VAR nTipo PROMPT STR0012,STR0013,STR0014 on CHANGE FS_MudaMsg() OF oDlg PIXEL SIZE 75,12 //0-Liberacao Provisoria # 1-Libera # 2-Nao Libera

@  71,  14 SAY STR0015 SIZE 60,08 OF oDlg PIXEL COLOR CLR_BLACK //Data Limite
@  81,  14 msget oDtLim  VAR dDtLim Picture "@D" SIZE 40,11 OF oDlg PIXEL COLOR CLR_BLACK

@ 101,  14 SAY STR0016 SIZE 50,08 OF oDlg PIXEL COLOR CLR_BLACK //Limite
@ 111,  14 msget oLimite VAR nLimite Picture "@E 999,999,999.99" SIZE 60,11 OF oDlg PIXEL COLOR CLR_BLACK

@ 131,  14 SAY STR0010 SIZE 50,08 OF oDlg PIXEL COLOR CLR_BLACK //Risco
@ 141,  14 MSCOMBOBOX oRisco VAR cRisco SIZE 40,50 FONT ofnt3 COLOR CLR_BLACK ITEMS aRisco OF oDlg PIXEL

@ 161,  14 SAY STR0017 SIZE 50,11 OF oDlg PIXEL COLOR CLR_BLACK  //Mensagem
@ 171,  14 GET oMsg VAR cMsg OF oDlg MEMO SIZE 280,029 PIXEL

@ 204,  14 SAY STR0018 SIZE 60,08 OF oDlg PIXEL COLOR CLR_BLACK //Motivo
@ 203,  34 msget oMotivo VAR cMotivo Picture "@!S80" SIZE 230,11 OF oDlg PIXEL COLOR CLR_BLACK

oMsg:bLostFocus:={||oMsg:Refresh()}
@ 203, 266 BUTTON oEnvia PROMPT STR0019 OF oDlg SIZE 29,11 PIXEL  ACTION (FS_EnviaMsg(cMsg)) //Envia Msg

ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{|| IIf(FS_OM370TOK(),(lOk:=.t.,nOpca:=1,oLimite:SetFocus(),oDlg:End()),.t.) },{|| oDlg:End() },,aNewBot)

If nOpca == 1
	Begin Transaction
		DbSelectArea("SA1")
		RecLock("SA1",.f.)
		If VSW->VSW_CRELIB == "0" .and. strzero(nTipo-1,1) == "0" // Mudando de "Credito Liberado Provisoriamente" para "Nao Liberado"
			SA1->A1_RISCO  := VSW->VSW_RISANT
			SA1->A1_LC     := VSW->VSW_LCANT
			SA1->A1_VENCLC := VSW->VSW_VLCANT
		Else
			SA1->A1_RISCO  := Right(cRisco,1)
			SA1->A1_LC     := nLimite
			SA1->A1_VENCLC := dDtLim
		Endif
		MsUnlock()
		DbSelectArea("VSW")
		RecLock("VSW",.f.)
		VSW->VSW_CRELIB := strzero(nTipo-1,1)
		VSW->VSW_MOTIVO := cMotivo
		VSW->VSW_USULIB := Subs(cUsuario,7,15)
		VSW->VSW_DTHLIB := left(Dtoc(dDataBase),6) + right(Dtoc(dDataBase),2) + "-" + left(Time(),5) // Dia/Mes/Ano(2 posicoes)-Hora:Minuto
		MsUnlock()
		If !Empty(cMsg)
			(FS_EnviaMsg(cMsg))
		Endif
	End Transaction
Else
	Return .t.
EndIf

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_EnviaMsg³ Autor ³ Manoel               ³ Data ³ 18/01/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ retorna MSG de Liberacao ou nao a Maquina solicitante      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_EnviaMsg(cMsgEnv)
WinExec("Net Send "+Alltrim(VSW->VSW_IPCOMP)+" "+cMsgEnv+CHR(13)+CHR(10)+ STR0030 +" "+cMotivo) //Motivo:
Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OM370LEG   ³ Autor ³ Manoel               ³ Data ³ 18/01/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria uma janela contendo a legenda da mBrowse              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM370LEG()
Local aLegenda  := {{'BR_VERDE'   , STR0028 } ,;	// Nao Avaliado
					{'BR_VERMELHO' , STR0031 } ,; 	// Encerrado
					{'BR_AZUL'     , STR0029 } } 	// Liberacao Provisoria
BrwLegenda(cCadastro,STR0003 ,aLegenda) //legenda
Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Fs_MudaMsg ³ Autor ³ Manoel               ³ Data ³ 18/01/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Altera Msg de acordo com o a situacao de Liberacao         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_MudaMsg()
cMsg := ""
If nTipo == 3
	cMsg := STR0025+" "  //"Nao foi Liberado o Credito para o Cliente"
Else
	cMsg := STR0024+" " //"Foi Liberado o Credito para o Cliente"
Endif
cMsg += VSW->VSW_CODCLI+" "+VSW->VSW_LOJA+" "+Left(SA1->A1_NOME,20)+CHR(13)+CHR(10)
cMsg += STR0032 + SUBS(cUsuario,7,15) + STR0033 + dtoc(ddatabase) + " - " + LEFT(TIME(),5)+CHR(13)+CHR(10)
cMsg += STR0026+" "+transform(VSW->VSW_VALCRE,"@E 999,999,999.99")  //"Valor Solicitado"
oMsg:Refresh()
Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Fs_OM370Tok³ Autor ³ Manoel               ³ Data ³ 26/11/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao de Verificacao (Tudo OK)                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_OM370TOK()
If ExistBlock("OF370TOK")
	If !ExecBlock("OF370TOK",.f.,.f.)
		return .f.
	Endif
Endif
return .t.