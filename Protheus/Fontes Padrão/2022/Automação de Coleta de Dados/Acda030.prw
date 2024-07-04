#INCLUDE "Acda030.ch" 
#INCLUDE "Protheus.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ACDA030  ³ Autor ³ Ricardo               ³ Data ³ 23/03/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de manutencao no arquivo mestre de inventario     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ACDA030()

Local aCores := {}
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

PRIVATE cDelFunc := "ACDA30Exc()"
PRIVATE lLocaliz := GetMv('MV_LOCALIZ')=='S'

If ExistBlock('ACD030MNU')
	ExecBlock('ACD030MNU',.F.,.F.)
EndIf

If ! IntAcd(.T.)
	Return .F.
EndIf


If ! SuperGetMV("MV_CBPE012",.F.,.F.)
	CBAlert(STR0019) //"Necessario ativar o parametro MV_CBPE012"
	Return .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := STR0008 // //"Mestre de inventario"

aCores := {	{ "CBA->CBA_STATUS == '0'", "BR_VERDE"},;
			{ "CBA->CBA_STATUS == '1'", "BR_AMARELO"},;
			{ "CBA->CBA_STATUS == '2'", "BR_CINZA"},;
			{ "CBA->CBA_STATUS == '3'", "BR_LARANJA"},;
			{ "CBA->CBA_STATUS == '4'", "BR_AZUL"},;
			{ "CBA->CBA_STATUS == '7'", "BR_BRANCO"},;
			{ "CBA->CBA_STATUS == '5'", "BR_VERMELHO"},;
			{ "CBA->CBA_STATUS == '6'", "BR_PRETO"} }
mBrowse( 6, 1, 22, 75, "CBA", , , , , , aCores, , , ,{|x|TimerBrw(x)})
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Acda30Inc ºAutor  ³Eduardo Motta       º Data ³  08/03/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inclusao do mestre de inventario                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAACD                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ACDA30Inc(cAlias,nReg,nOPc)
Private lInclui := .t.
Return AxInclui(cAlias,nReg,nOPc,nil,nil,nil,"ACDA30Chk()")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Acda30Alt ºAutor  ³Eduardo Motta       º Data ³  08/03/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Alteracao do mestre de inventario                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAACD                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ACDA30Alt(cAlias,nReg,nOPc)
Private lInclui := .f.
If CBA->CBA_STATUS=="1"
	Alert(STR0020) //"Inventario em andamento, nao sera possivel alterar!!!"
	Return
EndIf

If CBA->CBA_STATUS=="2"
	Alert(STR0021) //"Inventario em pausa, nao sera possivel alterar!!!"
	Return
EndIf

If CBA->CBA_STATUS$"543"
	Alert(STR0022) //"Inventario concluido, nao sera possivel alterar!!!"
	Return
EndIf
Return AxAltera(cAlias,nReg,nOPc,nil,nil,nil,nil,"ACDA30Chk()")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Acda30Del ºAutor  ³Anderson Rodrigues  º Data ³  18/02/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exclusao do Mestre de inventario                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAACD                                                    º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Erike Yuri    ³13/07/04³      ³Alteracao que permite excluir SB7 quando³±±
±±³              ³        ³      ³o Status estiver finalizado,CBA_STATUS=4³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Acda30Del(cAlias,nReg,nOPc)
Local nI      	:= 0
Local aSB7    	:= SB7->(GetArea())
Local cCodInv 	:= CBA->CBA_CODINV
Local aProdDel	:= {}
Local lWmsNew   := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local oEstEnder := Iif(lWmsNew,WMSDTCEstoqueEndereco():New(),Nil)
Local lCBB		:= .F.
Private lInclui := .f.
If CBA->CBA_STATUS == "5" // processadoo
	MsgAlert(STR0023) //"Nao e permitida a exclusao de Mestres de Inventario ja processado !!!"
	Return .f.
ElseIf CBA->CBA_STATUS == "4" // finalizado
	MsgAlert(STR0075+; //'Este Mestre de Inventario esta finalizado, se o mesmo for excluido, sera efetuada a exclusao de '
	STR0076+; //'todos "Lancamentos Inventariados" (SB7) deste Mestre, e este Mestre de Inventario ficara com '
	STR0077+chr(13)+chr(10)+chr(13)+chr(10)+STR0078+; //'Status de "Em Andamento".'###'Para excluir definitivamente este '
	STR0079+; //'Mestre de Inventario, esta rotina devera ser executada ate que o Mestre de inventario esteja com '
	STR0080) //'Status de "Nao Iniciado" ou "Em Andamento".'

	If !IW_MSGBOX(STR0025,STR0026,"YESNO") //"Deseja prosseguir com a exclusao?"###"Atencao"
		Return .f.
	Endif

	//Carrega array com produtos do inventario para desbloqueio
	CBLoadEst(aProdDel,.f.)
	For nI:=1 To Len(aProdDel)
		CBUnBlqInv(cCodInv,aProdDel[nI,1])
	Next

	//Como nao existe rotina automatica para a exclusao do SB7(Mata270), a exclusao sera feita diretamente
	Begin Transaction
		DbSelectArea("SB7")
		SB7->(DbOrderNickName("ACDSB701"))
		SB7->(DbSeek(xFilial("SB7")+CBA->CBA_CODINV))
		While SB7->(!Eof() .AND. B7_FILIAL+B7_DOC==xFilial("SB7")+CBA->CBA_CODINV)	
			RecLock("SB7",.F.)
			SB7->(DbDelete())
			SB7->(MsUnLock())
			If lWmsNew
				oEstEnder:oEndereco:SetArmazem(SB7->B7_LOCAL)
				oEstEnder:oEndereco:SetEnder(SB7->B7_LOCALIZ)
				oEstEnder:UpdEnder()
			EndIf
			SB7->(DbSkip())	
		EndDo

		RecLock("CBA",.F.)
		CBA->CBA_STATUS := "3" // contado
		CBA->(MsUnLock())
	End Transaction
	RestArea(aSB7)
ElseIf CBA->CBA_STATUS$"3|2|1|0" // contado/em pausa/em andamento/nao iniciado
	CBB->(DbSetOrder(1))
	CBB->(DbSeek(xFilial("CBB")+CBA->CBA_CODINV))
	While ! CBB->(EOF()) .and. CBB->(CBB_FILIAL+CBB_CODINV) == xFilial("CBB")+CBA->CBA_CODINV
		lCBB := .T.
		If CBB->CBB_STATUS == "1"
			MsgAlert(STR0027+chr(13)+CHR(10)+; //"Nao e permitida a exclusao de Mestres de Inventario com contagens em andamento!!!"
			STR0028 ) //"Necessario excluir ou finalizar a contagem em andamento."
			Return .f.
		Endif
		CBB->(DbSkip())
	Enddo

	If lCBB
		MsgAlert(STR0029+; //"Ja foram realizadas contagens para este Mestre de Inventario, "
		STR0030)           //"se o mesmo for excluido todas as contagens realizadas tambem serao excluidas !!!"
		If !IW_MSGBOX(STR0025,STR0026,"YESNO") //"Deseja prosseguir com a exclusao?"###"Atencao"
			Return .f.
		Endif
	EndIf

	If AxDeleta(cAlias,nReg,nOPc,nil,nil,nil) == 2
		CBB->(DbSetOrder(1))
		CBB->(DbSeek(xFilial("CBB")+cCodInv))
		While ! CBB->(EOF()) .and. CBB->(CBB_FILIAL+CBB_CODINV) == xFilial("CBB")+cCodInv
			While CBC->(DbSeek(xFilial("CBC")+CBB->CBB_NUM))
				ACD35CBM(5,CBA->CBA_CODINV,CBC->CBC_COD,CBC->CBC_LOCAL,CBC->CBC_LOCALI,CBC->CBC_LOTECT,CBC->CBC_NUMLOT,CBC->CBC_NUMSER)
				RecLock("CBC",.f.)
				CBC->(DbDelete())
				CBC->(MsUnlock())
			Enddo
			RecLock("CBB",.f.)
			CBB->(DbDelete())
			CBB->(MsUnlock())
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Decrementa numero de contagens realizadas do mestre          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			CBAtuContR(cCodInv, 2)
			
			CBB->(DbSkip())
		Enddo
		If CBA->CBA_STATUS == '0'
			ACDA30Exc()
		EndIf	
	EndIf
Else
	AxDeleta(cAlias,nReg,nOPc,nil,nil,nil)
	If CBA->CBA_STATUS == '0'
		ACDA30Exc()
	EndIf	
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ACDA30Chk ºAutor  ³Eduardo Motta       º Data ³  08/03/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Executa as validacoes padroes                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAACD                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ACDA30Chk()
Local nTamProd := TamSX3("B1_COD")[1]
Local nTamEnd  := TamSX3("BF_LOCALIZ")[1]
Local lWmsNew  := SuperGetMV("MV_WMSNEW",.F.,.F.)

If	M->CBA_TIPINV == "2" // Por endereco
	If Empty(M->CBA_LOCALI)
		Alert(STR0009) //"O campo endereco nao pode ficar em branco."
		Return .F.
	EndIf
EndIf 
If FindFunction("WMSVldInve") .AND. lWmsNew 
	If !WMSVldInve(M->CBA_LOCAL,M->CBA_LOCALI,M->CBA_PROD,M->CBA_TIPINV,.T.)
		Return .F.
	EndIf
EndIf   

If ! lInclui
	Return .t.
EndIf
If M->CBA_DATA < dDataBase
	Alert(STR0031)  //"Data do Inventario menor que a database"
	Return .f.
EndIf
If M->CBA_TIPINV=="1" // por produto
	If !EMPTY(M->CBA_PROD) .And. !ExistCpo("SB1",M->CBA_PROD)
		Return .f.		
	EndIf
	CBA->(DbSetOrder(3)) //CBA_FILIAL+CBA_TIPINV+CBA_STATUS+CBA_LOCAL+CBA_PROD+CBA_DATA
	If	CBA->(DbSeek(xFilial("CBA")+"1"+"0"+M->CBA_LOCAL+Padr(M->CBA_PROD,nTamProd)+DTOS(M->CBA_DATA))) .or. ;
		CBA->(DbSeek(xFilial("CBA")+"1"+"1"+M->CBA_LOCAL+Padr(M->CBA_PROD,nTamProd)+DTOS(M->CBA_DATA)))
		Alert(STR0032) //"Inventario ja cadastrado "
		Return .f.
	EndIf
Else  // por endereco
	CBA->(DbSetOrder(2)) //CBA_FILIAL+CBA_TIPINV+CBA_STATUS+CBA_LOCAL+CBA_LOCALI+CBA_DATA
	If	CBA->(DbSeek(xFilial("CBA")+"2"+"0"+M->CBA_LOCAL+Padr(M->CBA_LOCALI,nTamEnd)+DTOS(M->CBA_DATA))) .or. ;
		CBA->(DbSeek(xFilial("CBA")+"2"+"1"+M->CBA_LOCAL+Padr(M->CBA_LOCALI,nTamEnd)+DTOS(M->CBA_DATA))) 
		Alert(STR0032) //"Inventario ja cadastrado "
		Return .f.
	EndIf
EndIf
If ExistBlock('ACDA30OK')
	If ! Execblock('ACDA30OK',.F.,.F.)
		Return .f.
	Endif
Endif
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Acda30Exc ºAutor  ³Eduardo Motta       º Data ³  04/02/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exclusao do mestre de inventario, libera o endereco        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAACD                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ACDA30Exc()
Local lWmsNew   := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local oEstEnder := Nil
If	CBA->CBA_STATUS$"54" //If CBA->CBA_STATUS #"1" 
	Return .t.
EndIf
If	CBA->CBA_TIPINV== "1"
	SB2->(DbSetorder(1))
	If	SB2->(DbSeek(xFilial("SB2")+CBA->(CBA_PROD+CBA_LOCAL)))
		RecLock("SB2")
		SB2->B2_DTINV := CTOD("")
		SB2->(MsUnlock())
	EndIf
Else
	If !lWmsNew
		SBE->(DbSetOrder(1))
		If	SBE->(DbSeek(xFilial("SBE")+CBA->CBA_LOCAL+CBA->CBA_LOCALI))
			RecLock("SBE")
			SBE->BE_STATUS := "1"
	        SBE->BE_DTINV  := CTOD('')
			SBE->(MsUnlock())
		EndIf
	Else
		oEstEnder := WMSDTCEstoqueEndereco():New()
		oEstEnder:oEndereco:SetArmazem(CBA->CBA_LOCAL)
		oEstEnder:oEndereco:SetEnder(CBA->CBA_LOCALI)
		oEstEnder:UpdEnder()
	EndIf
EndIf
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AIVA30Loc ºAutor  ³Ricardo             º Data ³  20/04/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se utiliza localizacao                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAACD                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                  
Function AIVA30Loc()
Return (M->CBA_TIPINV=="2" .AND. lLocaliz)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AIVA30Aut ºAutor  ³Ricardo             º Data ³  20/04/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera mestre inventario automaticamente conf. parametros    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAACD                                                    º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Erike Yuri   ³08/10/04³      ³ Inclusao de opcoes automaticas incluin-³±±
±±³              ³        ³      ³ do Geracao automatica de Mestre de in- ³±±
±±³              ³        ³      ³ ventario,Lancamento SB7,Acerto e Exclu-³±±
±±³              ³        ³      ³ sao automatica de lancamento SB7.      ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AIVA30Aut()
Local nAcao    := 0
Local nOpca    := 0
Local aSays    := {}
Local aButtons := {}
Local lRetPe   := .T.
Private cCadastro := OemToAnsi(STR0033) //"Geracao automatica"


AADD(aButtons, { 1,.T.,{|o| nOpca:= 1, o:oWnd:End()}})
AADD(aButtons, { 2,.T.,{|o| o:oWnd:End()}})

If ! Pergunte("AIA033",.T.)
	Return
EndIf

nAcao := MV_PAR01

If	nAcao==1 //Geracao automatica de mestre de inventario
	AADD(aSays,OemToAnsi(STR0034)) //"Esta rotina tem o objetivo de efetuar a geracao"
	AADD(aSays,OemToAnsi(STR0035)) //"automatica de mestres de inventario, a partir do"
	AADD(aSays,OemToAnsi(STR0036)) //"range informado pelo operador nos parametros."
	FormBatch(cCadastro, aSays, aButtons,,200,450 ) // Monta Caixa de dialogo
	If	nOpca <> 1
		Return
	EndIf
	If	lLocaliz //Utiliza Controle de Localizacao == Gera por Produto ou Endereco
  		If ! Pergunte("AIA031",.T.)  //Seleciona Produto ou Endereco
			Return
		EndIf
		If mv_par01 == 01 //Produto
			If ! Pergunte("AIA032",.T.) 
				Return
			EndIf
			Processa({|| AI031( )})
		Else //Endereco
			If ! Pergunte("AIA030",.T.)
				Return
			EndIf
	   		If ExistBlock('AI030PER') 
		   		lRetPe := ExecBlock("AI030PER",.F.,.F.)
		   		If ValType(lRetPe) <> 'L'
		   			lRetPe:= .T.
		   		EndIf
			EndIF			
			If lRetPe
		   		Processa({|| AI030( )})
		 	EndIf
		EndIf
	Else //Nao utiliza Controle de Localizacao == Gera por Produto
		If ! Pergunte("AIA032",.T.)
			Return
		EndIf
		Processa({|| AI031( )})
	EndIf
ElseIf nAcao==2 //Exclusao automatica de mestre de inventario
	AADD(aSays,OemToAnsi(STR0037)) //"A T E N C A O:"
	AADD(aSays,OemToAnsi(STR0038)) //"Esta rotina tem o objetivo de efetuar a exclusao"
	AADD(aSays,OemToAnsi(STR0039)) //"automatica de mestres de inventarios informados "
	AADD(aSays,OemToAnsi(STR0040)) //"nos parametros solicitados."
	FormBatch(cCadastro, aSays, aButtons,,200,450 ) // Monta Caixa de dialogo
	If nOpca == 1
		If	!Pergunte("AIA034",.T.)  //Seleciona o Mestre de Inventario de Ate
			Return
		EndIf
		Processa({||ExcluiCBA()})
	EndIf
ElseIf nAcao==3 //Geracao automatica do lancamento de inventario
	AADD(aSays,OemToAnsi(STR0081)) //'Esta rotina tem o objetivo de efetuar a geracao automatica'
	AADD(aSays,OemToAnsi(STR0082)) //'do lancamento de inventario (tabela SB7), atraves da tabela'
	AADD(aSays,OemToAnsi(STR0083)) //'de mestre de inventario (CBA), que ja foi finalizada. Caso'
	AADD(aSays,OemToAnsi(STR0084)) //'o modelo do inventario seja o "2", so sera gerado lancamento'
	AADD(aSays,OemToAnsi(STR0085)) //'para os totais inventariados diferentes do saldo em estoque.'
	FormBatch(cCadastro, aSays, aButtons,,200,450 ) // Monta Caixa de dialogo
	If	nOpca == 1
		If	!Pergunte("AIA034",.T.) //Seleciona o Mestre de Inventario de Ate
			Return
		EndIf
		Processa({||GeraSB7Auto()})
	EndIf
ElseIf nAcao==4 //Exclusao automatica do lancamento de inventario
	AADD(aSays,OemToAnsi(STR0037)) //"A T E N C A O:"
	AADD(aSays,OemToAnsi(STR0038)) //"Esta rotina tem o objetivo de efetuar a exclusao"
	AADD(aSays,OemToAnsi(STR0041)) //"automatica dos lancamentos de inventarios infor-"
	AADD(aSays,OemToAnsi(STR0042)) //"mados nos parametros solicitados."
	FormBatch(cCadastro, aSays, aButtons,,200,450 ) // Monta Caixa de dialogo
	If nOpca == 1
		If	!Pergunte("AIA034",.T.)  //Seleciona o Mestre de Inventario de Ate
			Return
		EndIf
		Processa({||ExcluiSB7()})
	EndIf
ElseIf nAcao==5 //Geracao de acerto automatico
	AADD(aSays,OemToAnsi(STR0086)) //'Esta rotina ira gerar movimentacoes de ajuste para corrigir o saldo do'
	AADD(aSays,OemToAnsi(STR0087)) //'estoque. Estas movimentacoes serao baseadas nas contagens realizadas e'
	AADD(aSays,OemToAnsi(STR0088)) //'cadastradas na rotina de inventario.'
	AADD(aSays,OemToAnsi(STR0089)) //'Esta rotina tambem ira efetuar o ajuste das etiquetas (CB0), caso o'
	AADD(aSays,OemToAnsi(STR0090)) //'cliente utilize codigo interno.'
	FormBatch(cCadastro, aSays, aButtons,,200,450 ) // Monta Caixa de dialogo
	If nOpca == 1
		If	!Pergunte("AIA036",.T.)  //Seleciona o Mestre de Inventario de Ate
			Return
		EndIf
		Processa({||GeraAcerto()})
	EndIf
EndIf
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AI030     ºAutor  ³Microsiga           º Data ³  20/04/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Geracao do CBA                                             º±±
±±º          ³ Por Endereco                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAACD                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AI030()
Local cCodInv    := ""
Local lACDA30VE  := ExistBlock("ACDA30VE") // Por Endereco
Local lACD030FM  := ExistBlock("ACD030FM") // Fim da Rotina
Local aLog       := {}
Local aArea      := SGetArea()
Local lWmsNew 	 := SuperGetMv('MV_WMSNEW',.F.,.F.)

Static __lMobEnd := NIL

If __lMobEnd == NIL
	__lMobEnd := A30PergMob("AIA030")
EndIf

SGetArea(aArea,"CBA")

If MV_PAR05 < 1 
	MsgAlert(STR0043) //"O numero de contagens nao pode ser igual ou inferior a zero, favor verificar !!!"
	Return
EndIf

dbSelectArea("SBE")
SBE->(dbSetOrder(1))
SBE->(dbSeek(xFilial("SBE")+MV_PAR01,.T.))
While !SBE->(Eof()) .and. xFilial("SBE") == SBE->BE_FILIAL .and. SBE->BE_LOCAL <= MV_PAR02

	If	!(SBE->BE_LOCALIZ >= MV_PAR03 .and. SBE->BE_LOCALIZ <= MV_PAR04)
		IncProc()
		SBE->(dbSkip())
		Loop
	EndIf

	If !RegistroOK('SBE', .F.)
		aadd(aLog,{"AI030","98",NIL,NIL,SBE->BE_LOCAL,SBE->BE_LOCALIZ})
		IncProc()
		SBE->(dbSkip())
		Loop
	EndIf	

	CBA->(dbSetOrder(2)) //CBA_FILIAL+CBA_TIPINV+CBA_STATUS+CBA_LOCAL+CBA_LOCALI+CBA_DATA
	If	CBA->(dbSeek(xFilial("CBA")+"2"+"0"+SBE->BE_LOCAL+SBE->BE_LOCALIZ+DTOS(MV_PAR06))) .OR.;
		CBA->(dbSeek(xFilial("CBA")+"2"+"1"+SBE->BE_LOCAL+SBE->BE_LOCALIZ+DTOS(MV_PAR06)))
		IncProc()
		SBE->(DbSkip())
		Loop
	EndIf

	If FindFunction("WMSVldInve") .AND. lWmsNew 
		If !WMSVldInve(SBE->BE_LOCAL,SBE->BE_LOCALIZ,,"2",.F.)
			aadd(aLog,{"AI030","98",NIL,NIL,SBE->BE_LOCAL,SBE->BE_LOCALIZ})
			IncProc()
			SBE->(dbSkip())
			Loop
		EndIf
	EndIf   

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada para Validar o SBE                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lACDA30VE
		lOK := ExecBlock("ACDA30VE",.F.,.F.) //Por Endereco
		If (ValType(lOk) == "L")
			If !lOK
				aadd(aLog,{"AI030","98",NIL,NIL,SBE->BE_LOCAL,SBE->BE_LOCALIZ})
				IncProc()
				SBE->(dbSkip())
				Loop
			EndIf
		EndIf
	EndIf
	
	cCodInv := GetSXENum("CBA","CBA_CODINV")
	RecLock("CBA",.T.)
	CBA->CBA_Filial := xFilial("CBA")
	CBA->CBA_CODINV := cCodInv
	CBA->CBA_DATA   := MV_PAR06
	CBA->CBA_CONTS  := MV_PAR05
	CBA->CBA_STATUS := "0"
	CBA->CBA_TIPINV := "2"
	CBA->CBA_LOCAL  := SBE->BE_LOCAL
	CBA->CBA_LOCALI := SBE->BE_LOCALIZ
	CBA->CBA_CLASSA := Str(MV_PAR07,1)
	CBA->CBA_CLASSB := Str(MV_PAR08,1)
	CBA->CBA_CLASSC := Str(MV_PAR09,1)
	If __lMobEnd
		CBA->CBA_INVGUI := Str(MV_PAR10,1)
		CBA->CBA_RECINV := Str(MV_PAR11,1)
	EndIf
	MsUnlock()
	If __lSX8
		ConfirmSx8()
	EndIf
	//Mestres de Inventario gerados
	aadd(aLog,{"AI030","01",CBA_CODINV,NIL,CBA->CBA_LOCAL,CBA->CBA_LOCALI})
	
	IncProc()
	SBE->(dbSkip())
EndDo
SRestArea(aArea) 

If lACD030FM
	ExecBlock("ACD030FM",.F.,.F.)
EndIf

MostraLog("AI030","AIA030",aLog)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AI031     ºAutor  ³Microsiga           º Data ³  17/04/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Geracao do CBA                                             º±±
±±º          ³ Por Prduto                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAACD                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AI031()
Local nX          := 0
Local lOk
Local lACDA30VP   := ExistBlock("ACDA30VP")
Local lIntegraWMS := SuperGetMv('MV_WMSNEW',.F.,.F.) 
Local lPrdBloq    := .F.
Local aLog        := {}
Local aArea       := SGetArea()
Local oProduto    := Nil

Static __lMobPrd  := NIL

If __lMobPrd == NIL
	__lMobPrd := A30PergMob("AIA032")
EndIf

SGetArea(aArea,"CBA")
If	MV_PAR04 < 1
	MsgAlert(STR0043) //"O numero de contagens nao pode ser igual ou inferior a zero, favor verificar !!!"
	Return
EndIf

dbSelectArea("SB5")
SB5->(dbSetOrder(1))
dbSelectArea("SB1")
SB1->(dbSetOrder(1))
SB1->(dbSeek(xFilial("SB1")+MV_PAR02,.T.))
While !SB1->(Eof()) .and. xFilial("SB1") == SB1->B1_FILIAL .and. SB1->B1_COD <= MV_PAR03

	If lPrdBloq .And. SB1->B1_MSBLQL == "1"
		IncProc()
		SB1->(DbSkip())
		Loop
	Else
		If !ExistCpo("SB1",SB1->B1_COD)
			lPrdBloq := .T.
			IncProc()
			SB1->(DbSkip())
			Loop
		EndIf
	EndIf

	CBA->(dbSetOrder(3)) //CBA_FILIAL+CBA_TIPINV+CBA_STATUS+CBA_LOCAL+CBA_PROD+CBA_DATA
	If	CBA->(dbSeek(xFilial("CBA")+"1"+"0"+MV_PAR01+SB1->B1_COD+DTOS(MV_PAR05))) .OR.;
		CBA->(dbSeek(xFilial("CBA")+"1"+"1"+MV_PAR01+SB1->B1_COD+DTOS(MV_PAR05)))
		IncProc()
		SB1->(DbSkip())
		Loop
	EndIf

	//Gerar mestre de inventario para armazens com saldo
	//esta validacao so ocorre por produto
	SB2->(DbSetorder(1))
	If	RetFldProd(SB1->B1_COD,"B1_LOCPAD") # MV_PAR01 .And. ;
		!SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+MV_PAR01))
		IncProc()
		SB1->(DbSkip())
		Loop
	EndIf

	//So analisa um produto para bloqueio se encontrar na tabela de complemento,
	//caso contrario eu crio o mestre
	If	MV_PAR06==1 .and. SB5->(DbSeek(xFilial("SB5")+SB1->B1_COD))
		If	!Empty(SB5->B5_PERIOT) .And. (SB5->(B5_DTINV+B5_PERIOT)>dDataBase)
			IncProc()
			SB1->(DbSkip())
			Loop
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada para Validar o SB1                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If	lACDA30VP
		lOK := ExecBlock("ACDA30VP",.F.,.F.)
		If (ValType(lOk) == "L")
			If !lOK
				aadd(aLog,{"AI031","98",NIL,SB1->B1_COD,RetFldProd(SB1->B1_COD,"B1_LOCPAD"),""})
				IncProc()
				SB1->(dbSkip())
				Loop
			Endif
		EndIf
	Endif
	
	
	If lIntegraWMS
		If IntWMS(SB1->B1_COD)
			If FindFunction("WMSVldInve") 
				If !WMSVldInve(MV_PAR01,,SB1->B1_COD,,.F.)
					aadd(aLog,{"AI031","98",NIL,SB1->B1_COD,RetFldProd(SB1->B1_COD,"B1_LOCPAD"),""})
					IncProc()
					SB1->(dbSkip())
					Loop
				EndIf
			EndIf   

			//Regra WMS para gerar inventário apenas para os produtos componentes
			If WmsPrdPai(SB1->B1_COD)
				MTWmsPai(SB1->B1_COD,@oProduto)
				If aScan(oProduto:aProduto,{|x| x[1] == (oProduto:GetProduto())}) = 0
					For nX := 1 To Len(oProduto:aProduto)
						CBA->(dbSetOrder(3))//CBA_FILIAL+CBA_TIPINV+CBA_STATUS+CBA_LOCAL+CBA_PROD+DTOS(CBA_DATA)
						If CBA->(dbSeek(xFilial("CBA")+"1"+"0"+MV_PAR01+oProduto:aProduto[nX][1]+DTOS(MV_PAR05)))
							Loop
						Else
							a030GrvCBA(oProduto:aProduto[nX][1],aLog)
						EndIf	
					Next nX
				Else
					SB1->(dbSkip())
					Loop	
				EndIf
			Else
				a030GrvCBA(SB1->B1_COD,aLog)
			EndIf
		Else
			a030GrvCBA(SB1->B1_COD,aLog)
		EndIF			
	Else	
		a030GrvCBA(SB1->B1_COD,aLog)
	EndIf
	SB1->(dbSkip())
EndDo
SRestArea(aArea)
MostraLog("AI031","AIA032",aLog)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TimerBrw  ³ Autor ³ Eduardo Motta         ³ Data ³ 06/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao que cria timer no mbrowse                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cMBrowse -> form em que sera criado o timer                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static Function TimerBrw(oMBrowse)
Local oTimer
DEFINE TIMER oTimer INTERVAL 1000 ACTION TmBrowse(GetObjBrow(),oTimer) OF oMBrowse
oTimer:Activate()
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmBrowse ³ Autor ³ Eduardo Motta         ³ Data ³ 06/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de timer do mbrowse                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cMBrowse -> objeto mbrowse a dar refresh                   ³±±
±±³          ³ oTimer   -> objeto timer                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static Function TmBrowse(oObjBrow,oTimer)
oTimer:Deactivate()
oObjBrow:Refresh()
oTimer:Activate()
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AIVA030Lg ³ Autor ³ Eduardo Motta         ³ Data ³ 06/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Legenda para as cores da mbrowse                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AIVA30Lg()
Local aCorDesc := {} 
aCorDesc := {	{"BR_VERDE",	STR0011},; //"Nao Iniciado"
			 	{"BR_AMARELO",	STR0012},; //"Em Andamento"
			 	{"BR_CINZA",	STR0044},; //"Em Pausa"
				{"BR_LARANJA",	STR0045},; //"Contado"
				{"BR_AZUL",		STR0013},; //"Finalizado"
				{"BR_BRANCO",	STR0113},; //Parcialmente Processado
				{"BR_VERMELHO",	STR0014},; //"Processado"
				{"BR_PRETO", 	STR0112} } //"Endereco Sem Saldo"
BrwLegenda( STR0015,STR0016, aCorDesc ) //"Legenda - Mestre Inventario"###"Status"
Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³ExcluiCBA()  ºAutor³Erike Yuri da Silva º Data ³ 11/01/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³ Exclui os mestres de inventario que estiverem com status deº±±
±±º         ³ 0 = nao iniciado                                           º±±
±±º         ³ 2 = Em Pausa                                               º±±
±±º         ³ 3 = Contado                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ ACDA030                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ExcluiCBA()
Local nX        := 0
Local nCount    := 0
Local cProduto  := ""
Local cMestre   := ""
Local aProdEnd  := {}
Local cTrabtem  :=""

MsgAlert(STR0091+chr(13)+chr(10)+; //'Esta Rotina ira excluir todos "Mestres Inventariados" que possuirem o seguinte status:'
		 STR0092+chr(13)+chr(10)+; //'0 = Nao iniciado'
		 STR0093+chr(13)+chr(10)+; //'2 = Em Pausa'
		 STR0094+chr(13)+chr(10)+; //'3 = Contado'
		 STR0095+; //'Para os mestres que possuirem contagem em andamento, as mesmas deverao ser encerradas antes '
		 STR0096) //'de sua exclusao!'

If !IW_MSGBOX(STR0025,STR0026,"YESNO") //"Deseja prosseguir com a exclusao?"###"Atencao"
	Return .f.
Endif

//                  1         2         3         4         5         6
//         123456789012345678901234567890123456789012345678901234567890
AutoGRLog(Replicate("=",75))
AutoGRLog(STR0047) //"                         I N F O R M A T I V O"
AutoGRLog(STR0048) //"               H I S T O R I C O   D A S   E X C L U S O E S"
AutoGRLog(STR0049) //"                                   D E"
AutoGRLog(STR0050) //"                  M E S T R E S  D E  I N V E N T A R I O"
AutoGRLog(Replicate("=",75))
AutoGRLog(STR0051) //"P A R A M E T R O S:"
AutoGRLog(STR0052+MV_PAR01) //"Mestre De  : "
AutoGRLog(STR0053+MV_PAR02) //"Mestre Ate : "
AutoGRLog(Replicate("=",75))
AutoGRLog(STR0054) //"M E S T R E S   P R O C E S S A D O S :"
AutoGRLog(Replicate("=",75))

CBA->(dbSetOrder(1))
CBB->(dbSetOrder(3))
CBC->(DbSetOrder(2))
CBA->(dbSeek(xFilial("CBA")+MV_PAR01,.T.))
While CBA->(!Eof() .and. CBA_FILIAL==xFilial("CBA") .and.  CBA_CODINV<= MV_PAR02)
	If	CBA->CBA_STATUS $ "1|4|5" // Nao excluir mestres com contagem em andamento e finalizados
		CBA->(DbSkip())
		IncProc()
		Loop
	EndIf
	cMestre := CBA->CBA_CODINV
	Begin Transaction
		CBB->(DbSetOrder(1))
		CBB->(DbSeek(xFilial("CBB")+CBA->CBA_CODINV))
		While ! CBB->(EOF()) .and. CBB->(CBB_FILIAL+CBB_CODINV) == xFilial("CBB")+CBA->CBA_CODINV
			While CBC->(DbSeek(xFilial("CBC")+CBB->CBB_NUM))
				ACD35CBM(5,CBA->CBA_CODINV,CBC->CBC_COD,CBC->CBC_LOCAL,CBC->CBC_LOCALI,CBC->CBC_LOTECT,CBC->CBC_NUMLOT,CBC->CBC_NUMSER)
				RecLock("CBC",.f.)
				CBC->(DbDelete())
				CBC->(MsUnlock())
			Enddo
			RecLock("CBB",.f.)
			CBB->(DbDelete())
			CBB->(MsUnlock())
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Decrementa numero de contagens realizadas do mestre          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			CBAtuContR(CBA->CBA_CODINV, 2)
			
			CBB->(DbSkip())
		Enddo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz o desbloqueio do inventario                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aProdEnd := {}
		CBLoadEst(aProdEnd,.f.)
		For nX := 1 to len(aProdEnd)
			cProduto := Subs(aProdEnd[nX,1],01,Tamsx3("B1_COD")[1])
			CBUnBlqInv(CBA->CBA_CODINV,cProduto)
		Next

		RecLock("CBA",.F.)
		CBA->(DbDelete())
		CBA->(MsUnLock())
		AutoGRLog(STR0055+CBA->CBA_CODINV+STR0056) //"Mestre: "###", excluido com sucesso!"
	End Transaction
	CBA->(DbSkip())
	IncProc()
	nCount++
EndDo
AutoGRLog(Replicate("=",75))
AutoGRLog(STR0057+AllTrim(Str(nCount)) ) //"Quantidade de mestres de inventarios excluidos.: "

cTrabtem := NomeAutoLog()
ExibLogEst(cTrabtem)
Ferase(cTrabtem)//apos utilizar o arquivo limpa a memoria 
cTrabtem := Nil

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³GeraSB7Auto()ºAutor³Erike Yuri da Silva º Data ³ 08/10/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³ Geracao de Lancamento de Inventario (SB7) Automatico       º±±
±±º         ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ ACDA030                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GeraSB7Auto()
Local cMestreAte := MV_PAR02
Local lLoop      := .F.
Local nCountDocs := 0
Local nCountOk   := 0
Local nI         := 0
Local aAreaCBA   := SGetArea()
Local lI         := 0
Private lModelo1    := GetMV("MV_CBINVMD") =="1"
Private lUsaCB001   := UsaCB0("01")
Private aProdEnd    := {}
Private lMsErroAuto := .F.
Private aLogMestre  := {}

SGetArea(aAreaCBA,"CBA")

MsgAlert(STR0097+; //'Esta Rotina ira gerar "Lancamentos Inventariados" (SB7) dos '
		 STR0098) //'Mestres de Inventario informados no range, alterando o Status para "Finalizado"'

If !IW_MSGBOX(STR0099,STR0026,"YESNO") //'Deseja prosseguir com a geracao de "Lancamentos de Inventario"?'###"Atencao"
	Return .f.
Endif

//                  1         2         3         4         5         6
//         123456789012345678901234567890123456789012345678901234567890
AutoGRLog(Replicate("=",75))
AutoGRLog(STR0047) //"                         I N F O R M A T I V O"
AutoGRLog(STR0059) //"               H I S T O R I C O   D A S   G E R A C O E S"
AutoGRLog(STR0049) //"                                   D E"
AutoGRLog(STR0060) //"            L A N C A M E N T O  D O  I N V E N T A R I O (SB7)"
AutoGRLog(Replicate("=",75))
AutoGRLog(STR0051) //"P A R A M E T R O S:"
AutoGRLog(STR0052+MV_PAR01) //"Mestre De  : "
AutoGRLog(STR0053+cMestreAte) //"Mestre Ate : "
AutoGRLog(Replicate("=",75))
AutoGRLog(STR0061) //"I T E N S   P R O C E S S A D O S :"
AutoGRLog(Replicate("=",75))

CBA->(dbSetOrder(1))
CBB->(dbSetOrder(3))
CBC->(DbSetOrder(2))
CBA->(dbSeek(xFilial("CBA")+MV_PAR01,.T.))
While CBA->(!Eof() .and. CBA_FILIAL==xFilial("CBA") .and.  CBA_CODINV <= cMestreAte)
	If CBA->CBA_STATUS # "3"  //processa somente os mestre contados
		CBA->(DbSkip())
		IncProc()
		Loop
	EndIf

	If !CBB->(dbSeek(xFilial("CBB")+CBA->CBA_CODINV))
		CBA->(DbSkip())
		IncProc()
		Loop
	EndIf

	//Verifica se existe contagem em andamento 
	lLoop := .F.
	While CBB->(!Eof() .and. CBB->CBB_FILIAL+CBB_CODINV == xFilial("CBB")+CBA->CBA_CODINV)
		If CBB->CBB_STATUS=="1"
			lLoop := .T.
			Exit
		EndIf
		CBB->(dbSkip())
	EndDo

	If lLoop
		CBA->(DbSkip())
		IncProc()
		Loop
	EndIf

	//Analisa produto a produto e gera SB7
	aProdEnd := {}
	CBLoadEst(aProdEnd,.f.)
	lMsErroAuto	:= .F.
	CBAnaInv(.t.,.t.)

	CBA->(dbSkip())
	IncProc()
	nCountDocs++
EndDo

//Gravacao do Log
For nI:=1 To Len(aLogMestre)
	AutoGRLog(Space(aLogMestre[nI,2]*2)+aLogMestre[nI,3])
	If Empty(aLogMestre[nI,2]) .and. aLogMestre[nI,4]
		nCountOk++ //Contagens Ok
	EndIf
Next

AutoGRLog(Replicate("=",75))
AutoGRLog(STR0062+AllTrim(Str(nCountDocs))) //"Quantidade de mestres de inventarios analisados.: "
AutoGRLog(STR0063+AllTrim(Str(nCountOk)))   //"Quantidade de mestres de inventarios Ok.........: "
AutoGRLog(STR0064+AllTrim(Str(nCountDocs-nCountOk))) //"Quantidade de mestres de inventarios Divergentes: "

If ExistBlock('ACDA30LG')
	aUserLog := ExecBlock('ACDA30LG',.F.,.F.)
	If ValType(aUserLog) == 'A'
		AutoGRLog(Replicate("=",75))
		For lI := 1 To Len(aUserLog)
			AutoGRLog(aUserLog[lI,1]+aUserLog[lI,2])
		Next
	Endif
Endif

MOSTRAERRO()
SRestArea(aAreaCBA)
Return



Static Function ExcluiSB7()
Local nCountM := 0
Local nCountD := 0
Local aCBA    := CBA->(GetArea())
Local aSB7    := SB7->(GetArea())

MsgAlert(STR0100+; //'Esta Rotina ira excluir todos "Lancamentos Inventariados" (SB7) dos '
		 STR0101) //'Mestres de Inventario informados no range, alterando o Status para "Em Andamento"'

If !IW_MSGBOX(STR0025,STR0026,"YESNO") //"Deseja prosseguir com a exclusao?"###"Atencao"
	Return .f.
Endif


//                  1         2         3         4         5         6
//         123456789012345678901234567890123456789012345678901234567890
AutoGRLog(Replicate("=",75))
AutoGRLog(STR0047) //"                         I N F O R M A T I V O"
AutoGRLog(STR0048) //"               H I S T O R I C O   D A S   E X C L U S O E S"
AutoGRLog(STR0049)  //"                                   D E"
AutoGRLog(STR0060) //"            L A N C A M E N T O  D O  I N V E N T A R I O (SB7)"
AutoGRLog(Replicate("=",75))
AutoGRLog(STR0051) //"P A R A M E T R O S:"
AutoGRLog(STR0052+MV_PAR01) //"Mestre De  : "
AutoGRLog(STR0053+MV_PAR02) //"Mestre Ate : "
AutoGRLog(Replicate("=",75))
AutoGRLog(STR0065) //"D O C U M E N T O S   P R O C E S S A D O S :"
AutoGRLog(Replicate("=",75))

CBA->(dbSetOrder(1))
CBB->(dbSetOrder(3))
CBC->(DbSetOrder(2))
CBA->(dbSeek(xFilial("CBA")+MV_PAR01,.T.))
While CBA->(!Eof() .and. CBA_FILIAL==xFilial("CBA") .and.  CBA_CODINV<= MV_PAR02)

	If CBA->CBA_STATUS # "4" // Nao faz diferente de finalizado (status = 4 indica que gerou sb7)
		CBA->(DbSkip())
		IncProc()
		Loop
	EndIf
	nCountD := 0
	//Como nao existe rotina automatica para a exclusao do SB7(Mata270), a exclusao sera feita diretamente
	Begin Transaction
		DbSelectArea("SB7")
		SB7->(DbOrderNickName("ACDSB701"))
		SB7->(DbSeek(xFilial("SB7")+CBA->CBA_CODINV))
		While SB7->(!Eof() .AND. B7_FILIAL+B7_DOC==xFilial("SB7")+CBA->CBA_CODINV)	
			RecLock("SB7",.F.)
			SB7->(DbDelete())
			SB7->(MsUnLock())
			nCountD++
			SB7->(DbSkip())
		EndDo
		AutoGRLog(STR0066+CBA->CBA_CODINV+STR0067+AllTrim(Str(nCountD))+ STR0068) //"Mestre:"###", foram excluidos "###" documentos na tabela de lanc. invent."
		RecLock("CBA",.F.)
		CBA->CBA_STATUS := "3" // Contado
		CBA->(MsUnLock())
	End Transaction
	CBA->(DbSkip())
	IncProc()
	nCountM++
EndDo
AutoGRLog(Replicate("=",75))
AutoGRLog(STR0062+AllTrim(Str(nCountM)) ) //"Quantidade de mestres de inventarios analisados.: "
MostraErro()

RestArea(aSB7)
RestArea(aCBA)
Return




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³GeraAcerto() ºAutor³Erike Yuri da Silva º Data ³ 08/10/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³ Geracao o acerto do inventario a partir no cod. do mestre  º±±
±±º         ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ ACDA030                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GeraAcerto()
Local cMestreDe  := MV_PAR01
Local cMestreAte := MV_PAR02
Local nRecnoSB7  := 0
Local aAreaCBA   := SGetArea()
Private lModelo1  := GetMV("MV_CBINVMD") =="1"
Private lUsaCB001 := UsaCB0("01")

SGetArea(aAreaCBA,"CBA")

If !IW_MSGBOX(STR0102,STR0026,"YESNO") //'Deseja prosseguir com o "Acerto de Inventario"?'###"Atencao"
	Return .f.
Endif

SB7->(DbOrderNickName("ACDSB701"))
CBA->(dbSetOrder(1))
CBA->(dbSeek(xFilial("CBA")+cMestreDe,.T.))
While CBA->(!Eof() .and. CBA_FILIAL==xFilial("CBA") .and.  CBA_CODINV<= cMestreAte)
	If CBA->CBA_STATUS # "4"  //Somente gera acerto do mestre de inventario que ja esta finalizado (SB7 gerado)
		CBA->(DbSkip())
		IncProc()
		Loop
	EndIf

	SB7->(DbSeek(xFilial("SB7")+CBA->CBA_CODINV))
	While SB7->(!Eof() .AND. B7_FILIAL+B7_DOC==xFilial("SB7")+CBA->CBA_CODINV)	
		nRecnoSB7 := SB7->(Recno())
		MATA340(.t.,CBA->CBA_CODINV)
		SB7->(DbOrderNickName("ACDSB701"))
		SB7->(DbGoto(nRecnoSB7))
		SB7->(DbSkip())
	End

	CBA->(dbSkip())
	IncProc()
EndDo
SRestArea(aAreaCBA)
Return



Static Function MostraLog(cRotina,cPerg,aLog)
Local nI       := 0
Local nOk      := 0
Local nNo      := 0
Local aExcecao := {}
Local nTamSX1  := Len(SX1->X1_GRUPO)
Local xPar := ""
Local cTrabtem := ""

AutoGRLog(Replicate("=",75))
AutoGRLog(STR0047) //"                         I N F O R M A T I V O"
If cRotina=="AI031"
	AutoGRLog(STR0059) //"               H I S T O R I C O   D A S   G E R A C O E S"
	AutoGRLog(STR0049) //"                                   D E"
	AutoGRLog(STR0070) //"                 M E S T R E   D E   I N V E N T A R I O"
ElseIf cRotina=="AI030"
	AutoGRLog(STR0059) //"               H I S T O R I C O   D A S   G E R A C O E S"
	AutoGRLog(STR0049) //"                                   D E"
	AutoGRLog(STR0070) //"                 M E S T R E   D E   I N V E N T A R I O"
EndIf
AutoGRLog(Replicate("=",75))
AutoGRLog(STR0051) //"P A R A M E T R O S:"
cPerg := PADR(cPerg,nTamSX1)
SX1->(DbSetOrder(1))
SX1->(DbSeek(cPerg))
While SX1->(!Eof() .AND. X1_GRUPO == cPerg)
	xPar := cValToChar(&(SX1->X1_VAR01))
	If SX1->X1_GSC == 'G'
		SX1->(AutoGRLog(STR0071+SX1->X1_ORDEM+": "+X1_PERGUNT+xPar)) //"Pergunta "
	Else
		SX1->(AutoGRLog(STR0071+X1_ORDEM+": "+X1_PERGUNT+If(xPar=="1",STR0103,STR0104))) //"Pergunta " //'Sim'###'Nao'
	Endif
	SX1->(DbSkip())
Enddo

AutoGRLog(Replicate("=",75))
AutoGRLog(STR0061) //"I T E N S   P R O C E S S A D O S :"
AutoGRLog(Replicate("=",75))

For nI:=1 To Len(aLog)
	If aLog[nI,2]=="98"
		aadd(aExcecao,{aLog[nI,1],NIL,aLog[nI,3],aLog[nI,4],aLog[nI,5],aLog[nI,6]})
		Loop
	EndIf
	If cRotina == "AI030"
		AutoGRLog(STR0055+aLog[nI,3]+STR0072+aLog[nI,5]+STR0073+aLog[nI,6]) //"Mestre: "###" - Local: "###" - Endereco: "
	ElseIf cRotina == "AI031"
		AutoGRLog(STR0055+aLog[nI,3]+STR0074+aLog[nI,4]+STR0072+aLog[nI,5]) //"Mestre: "###" - Produto: "###" - Local: "
	EndIf
	nOk++
Next

If !Empty(aExcecao)
	AutoGRLog("")
	AutoGRLog(Replicate("=",75))
	AutoGRLog(STR0105) //"E X C E C O E S:"
	AutoGRLog(STR0106) //"- Nao foi gerado mestre de inventario para o(s) item(s) abaixo."
EndIf

For nI:=1 To Len(aExcecao)
	If cRotina == "AI030"
		AutoGRLog(STR0107+aExcecao[nI,5]+STR0073+aExcecao[nI,6]) //"Local: "###" - Endereco: "
	ElseIf cRotina == "AI031"
		AutoGRLog(STR0108+aExcecao[nI,4]+STR0072+aExcecao[nI,5]) //"Produto: "###" - Local: "
	EndIf
	nNo++
Next
AutoGRLog(Replicate("=",75))
AutoGRLog(STR0109+Str(nOk)) //"Sucesso(s)....:"
AutoGRLog(STR0110+Str(nNo)) //"Divergencia(s):"

cTrabtem := NomeAutoLog()
ExibLogEst(cTrabtem)	
Ferase(cTrabtem)//apos utilizar o arquivo limpa a memoria 
cTrabtem := Nil

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MTA010MI  º Autor ³ Aecio Ferreira Gomes º Data ³  24/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Verifica se existe o produto na tabela CBJ                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA010(Cadastro de produtos)                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MTA010MI(cProduto)

Local lRet     := .F.
Local cAliasCBA:= ""

	cAliasCBA := GetNextAlias()
	cQuery    := ""

	cQuery += "SELECT COUNT(*) QTDBASE FROM " + RetSqlName( "CBA" ) + " "
	cQuery += "WHERE "
	cQuery += "CBA_FILIAL='" + xFilial( "CBA" ) + "' AND "
	cQuery += "CBA_PROD='" + cProduto            + "' AND "
	cQuery += "D_E_L_E_T_=' '"

	cQuery := ChangeQuery( cQuery )
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCBA,.F.,.T. )

	If (cAliasCBA)->QTDBASE > 0		
		Help(" ",1,"MTA010MI")
		lRet := .T.
	Endif	

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} a030GrvCBA()
Função para gravar produtos normais ou partes do produto pai.
@author Totvs
@since 13/12/2016
@version P118
@return nil
/*/
//-------------------------------------------------------------------
Function a030GrvCBA(cProduto,aLog)

	cCodInv := GetSXENum("CBA","CBA_CODINV")
	RecLock("CBA",.T.)
	CBA->CBA_Filial := xFilial("CBA")
	CBA->CBA_CODINV := cCodInv
	CBA->CBA_DATA   := MV_PAR05
	CBA->CBA_CONTS  := MV_PAR04
	CBA->CBA_STATUS := "0"
	CBA->CBA_TIPINV := "1"
	CBA->CBA_PROD   := cProduto
	CBA->CBA_LOCAL  := MV_PAR01  
	CBA->CBA_CLASSA := Str(MV_PAR07,1)
	CBA->CBA_CLASSB := Str(MV_PAR08,1)
	CBA->CBA_CLASSC := Str(MV_PAR09,1)
	If __lMobPrd
		CBA->CBA_INVGUI := Str(MV_PAR10,1)
		CBA->CBA_RECINV := Str(MV_PAR11,1)
	EndIf
	MsUnlock()	
	If __lSX8
		ConfirmSx8()
	EndIf
	//Mestres de Inventario gerados
	aadd(aLog,{"AI031","01",CBA_CODINV,cProduto,CBA->CBA_LOCAL})
	
	IncProc()
Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ExibLogEst()
Função para mostrar log da rotina ACDA030
@param ctramtem arquivos de trabalho temporario
@author Jefferson Silva de Sousa
@since 21/01/2020
/*/
//-------------------------------------------------------------------
Function ExibLogEst(cTrabtem)
Local    oFile 
Local    cMemo    := ""
Local    lQuebra  := .T.
Local	 cMask	  := "*.txt|*.txt"
Default  cTrabtem := ""


oFile := FWFileReader():New(cTrabtem)

If (oFile:Open())
   While (oFile:hasLine())
      cMemo += oFile:GetLine(lQuebra)
   End
   oFile:Close()
EndIf

	DEFINE FONT oFont NAME "Courier New" SIZE 5,0   //6,15

	DEFINE MSDIALOG oDlg TITLE cTrabtem From 3,0 to 340,417 PIXEL

	@ 5,5 GET oMemo  VAR cMemo MEMO SIZE 200,145 OF oDlg PIXEL
	oMemo:bRClicked := {||AllwaysTrue()}
	oMemo:oFont:=oFont

	DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga
	DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(cMask,OemToAnsi(STR0044)),If(cFile="",.t.,MemoWrite(cFile,cMemo))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."
	DEFINE SBUTTON  FROM 153,115 TYPE 6 ACTION (PrintLog(cTrabtem,cMemo)) ENABLE OF oDlg PIXEL //Imprime e Apaga

	ACTIVATE MSDIALOG oDlg CENTER

	cMemo := Nil

Return


 /*/{Protheus.doc} Menudef
	(long_description)
	@type  Static Function
	@author TOTVS
	@since 21/02/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function MenuDef()

Local aRotMenu := { }


aRotMenu :=  {			{ STR0001, "AxPesqui",		0, 1}     ,; //"Pesquisar"
						{ STR0002, "AxVisual",		0, 2}     ,; //"Visualizar"
						{ STR0003, "ACDA30Inc",		0, 3}     ,; //"Incluir"
						{ STR0004, "ACDA30Alt",		0, 4, 17} ,; //"Alterar"
						{ STR0005, "ACDA30Del",		0, 5, 17} ,; //"Excluir"
						{ STR0006, "AIVA30Aut",		0, 3, 17} ,; //"Automatico"
						{ STR0017, "ACDA032",		0, 2, 17} ,; //"Monitor"
						{ STR0018, "ACDR030",		0, 1}     ,; //"Relatorio"
						{ STR0007, "AIVA30Lg",		0, 3} }      //"Legenda"

 
 RETURN aRotMenu

//-------------------------------------------------------------------
/*/{Protheus.doc} ExibLogEst()
Função para imprimir log da rotina ACDA030
@param ctramtem arquivos de trabalho temporario
@author Jefferson Silva de Sousa
@since 29/09/2020
/*/
//-------------------------------------------------------------------
Static Function PrintLog(cFileErro,cConteudo)//Imprime o autoerro.log
Local nLin := 0
Local nX   := 0
Default cConteudo := ""
Default cFileErro := ""

	CursorWait()
	If IsTelnet() .Or. IsBlind()
		While !IsPrinter()
		    If !MsgRetryCancel(OemToAnsi(STR0045),OemToAnsi(STR0001)) //"Impressora nao esta pronta
			 	 Return .T.
			 Endif
		Enddo
		RptStatus({|lEnd| __CopyFile(cFileErro,"Lpt1")} )
	Else
		Private aReturn:= {STR0059, 1,STR0060, 1, 2, 1, "",1 }

		SetPrint(,cFileErro,nil ,STR0061,cFileErro,'','',.F.,"",.F.,"M")
		If nLastKey <> 27
	   		SetDefault(aReturn,"")
	   		nLinha:= MLCount(cConteudo,132)
	        For nX:= 1 To nLinha
				nLin++
				If nLin > 80
					nLin := 1
					@ 00,00 PSAY AvalImp(132)
				Endif
				@ nLin,000 PSAY Memoline(cConteudo,132,nX)
	        Next nX
			Set device to Screen
			MS_FLUSH()
		EndIf
	EndIf
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} A30PergMob
Função utilizada para validar a existência dos perguntes 10 e 11 na geração
automática dos mestres de inventário por produto e endereço
@author Squad Entradas
@since 04/02/2022
/*/
//-------------------------------------------------------------------
Static Function A30PergMob(cPerg)
Local lRet		:= .F.
Local nPos 		:= 0
Local oUtilSX1	:= FWSX1Util():New()

If CBA->(FieldPos("CBA_INVGUI")) > 0 .And. CBA->(FieldPos("CBA_RECINV")) > 0
	oUtilSX1:AddGroup(cPerg)
	oUtilSX1:SearchGroup()
	nPos := aScan(oUtilSX1:aGrupo,{|x| AllTrim(x[1]) == cPerg })
	If nPos > 0
		If Len(oUtilSX1:aGrupo[nPos][2]) > 10
			lRet := .T.
		EndIf
	EndIf
EndIf

Return lRet
