#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEM939.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} fJsPMSt
Retorna o status do Json da API de Get do processamento
Obs.: função criada para ser possível finalizar o processo de issue x cobertura, 
sendo possível manipular o status que seria retornado pela API do P&M
@author  Allyson Luiz Mesashi
@since   25/04/2022
/*/
//-------------------------------------------------------------------
Function fJsPMSt( oJson, cStatus )

cStatus := cValToChar( oJson["status"] )

Return cStatus

//-------------------------------------------------------------------
/*/{Protheus.doc} fTokenPM()
Função que gera o token de acesso no P&M
@author  Allyson Luiz Mesashi
@since   18/04/2022
/*/
//-------------------------------------------------------------------
Function fTokenPM( cToken, cErrToken )

Local aHeader	:= {}
Local cBody		:= ""
Local cRet		:= ""
Local lRet 		:= .F.
Local oClient 	:= Nil
Local oJson 	:= JsonObject():New()

oClient := FwRest():New(cPMToken)

aAdd( aHeader, "content-type: application/x-www-form-urlencoded" ) 

cBody := "client_id=" + cPMClient + "&client_secret=" + cPMSecret + "&grant_type=client_credentials&client_credentials&scope=authorization_api"

oClient:SetPostParams(cBody)
oClient:SetPath("")

If oClient:Post(aHeader)
	lRet := .T.
	cRet := oClient:GetResult()
	oJson:fromJson(cRet)
	cToken := oJson["access_token"]
Else
	cErrToken := oClient:GetResult()
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} f939BAPI
Retorna as opções de combobox do campo REF_TIPO
@author  Allyson Luiz Mesashi
@since   10/05/2022
/*/
//-------------------------------------------------------------------
Function f939BAPI()

Local cOpcBox := STR0142//"1=Filiais;2=Grupos de cargo;3=Cargos;4=Departamentos;5=Funcionários;6=Grupos de contrato;7=Movimentação de cargos;8=Movimentação de departamentos;9=Movimentação de filiais;A=Movimentação de grupos de cargo;B=Afastamentos;C=Faltas;D=Líder dos funcionários"

Return cOpcBox

//-------------------------------------------------------------------
/*/{Protheus.doc} f939BStat
Retorna as opções de combobox do campo REF_STATUS
@author  Allyson Luiz Mesashi
@since   10/05/2022
/*/
//-------------------------------------------------------------------
Function f939BStat()

Local cOpcBox := STR0143//"0=Não iniciado;1=Executando;2=Concluído;3=Houve erro de validação;X=Não encontrado"

Return cOpcBox

//-------------------------------------------------------------------
/*/{Protheus.doc} fMsgErr()
Função que exibe o alerta que houve erros e direciona para a documentação do P&M
@author  Allyson Luiz Mesashi
@since   12/05/2022
/*/
//-------------------------------------------------------------------
Function fMsgErr()

Local oButton1
Local oGroup1
Local oPanel1
Local oSay1
Local oSay2
Local oDlg

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0148) FROM 000, 000  TO 200, 500 COLORS 0, 16777215 PIXEL //"Validação"

    @ 000, 000 MSPANEL oPanel1 SIZE 300, 150 OF oDlg COLORS 0, 16777215 RAISED
    @ 005, 012 GROUP oGroup1 TO 055, 237 PROMPT OemToAnsi(STR0001) OF oPanel1 COLOR 0, 16777215 PIXEL //"Atenção"
    @ 017, 017 SAY oSay1 PROMPT OemToAnsi(STR0149 + CRLF + STR0150) SIZE 215, 035 OF oPanel1 COLORS 0, 16777215 PIXEL //"Foram retornados erros na integração com o P&M"##"Verifique a documentação do P&M conforme orientações no link abaixo"
    @ 063, 012 SAY oSay2 PROMPT "https://tdn.totvs.com/x/rKpLK" SIZE 095, 007 OF oPanel1 COLORS 0, 16777215 PIXEL
    @ 070, 200 BUTTON oButton1 PROMPT "OK" SIZE 037, 012 OF oPanel1 PIXEL

    oSay2:bLClicked := {|| ShellExecute("open", "https://tdn.totvs.com/pages/viewpage.action?pageId=676047532", "", "", 1) }

    oButton1:bLClicked := {|| oDlg:End() }

ACTIVATE MSDIALOG oDlg CENTERED

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GPS04328()
Função que exibe as opções da consulta padrão S04328
@author  Allyson Luiz Mesashi
@since   13/05/2022
/*/
//-------------------------------------------------------------------
Function GPS04328(l1Elem)

Local cTitulo		:= STR0183//"Tipo de desligamento"
Local cMvPar
Local aDesc		    := { STR0184, STR0185, STR0186 }//"Pedido de desligamento"##"Sem justa causa"##"Com justa causa"
Local lRet			:= .T.

l1Elem	:= IF( l1Elem == NIL .and. ValType( l1Elem ) != "L" , .T. , .F. )

If f_Opcoes(@cMvPar, cTitulo, aDesc, "123", Nil, Nil, l1Elem, 1, 1)
	VAR_IXB	:= StrTran(cMvPar, "*")
	lRet:= .T.
EndIf

Return lRet
