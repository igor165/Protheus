#include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'PLSFUNREEMB.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} PLCancReemb
Função para exibir a Dialog ao selecionar a opção de Cancelamento ou a
opção de aguardando informação do beneficiário no Protocolo de Reembolso
@author Oscar Zanin
@since 24/09/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLCancReemb(cStatus)

Local oDlg := NIL
Local oMemo:= NIL
Local lRet := .F.
Local cTitulo := IIF(cStatus == "D", STR0001 /*"Cancelamento Reembolso"*/, STR0002 /*"Solicitação de Informações"*/)
Local cYesNo	:= IIF(cStatus == "D", STR0003 /*"Deseja realmente cancelar o reembolso?"*/, STR0004 /*"Confirma as informações?"*/)
Local cMemo		:= Space(Len(BOW->(BOW_MOTIND)))
//Essas duas variáveis definem a quantidade de caracteres que os campos do MSGET terão para uso
//Também são o retorno do que for informado.
Local cMotPad	:= SPACE(LEN(BOW->(BOW_MOTPAD)))
Local cDescri	:= Space(Len(BOW->(BOW_DESMOT)))

DEFINE MsDialog oDlg Title cTitulo From 0,0 To 17,46 OF GetWndDefault()
//DEFINE MSDIALOG oObjetoDLG TITLE cTitulo FROM nLinIni,nColIni TO nLinFim,nColFim OF oObjetoRef UNIDADE

@ 5,10  SAY STR0005 /*"Motivo Padrão"*/ SIZE 50,10 OF oDlg PIXEL
//	@ nLinha, nColuna MSGET VARIAVEL SIZE nLargura,nAltura UNIDADE OF oObjetoRef F3 cF3 VALID validação WHEN condição PICTURE cPicture
@ 15,10 MSGET cMotPad SIZE 35,10 OF oDlg PIXEL WHEN .T. F3 "BOWBBP" PICTURE "@!" VALID PLCanRmbF3(cMotPad, @cDescri, @lRet)
@ 15,45 MSGET cDescri SIZE 110,10 OF oDlg PIXEL WHEN .F. PICTURE "@!"

@ 39,10 SAY STR0006 /*"Observações"*/ SIZE 50,10 OF oDlg PIXEL
@ 49,10 GET oMemo VAR cMemo SIZE 150,50 OF oDlg MEMO NO VSCROLL PIXEL WHEN .T.

DEFINE SBUTTON FROM 104,85 TYPE 1 ACTION PLSdlgCanc(cMotPad, odlg) ENABLE OF oDlg
DEFINE SBUTTON FROM 104,115 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED

//Se foi informado o motivo, permite a gravação
If lRet
	If MsgYesNo(cYesNo)
		
		BEGIN TRANSACTION
			BOW->( RecLock("BOW",.F.) )
			BOW->BOW_MOTPAD 	:= cMotPad
				BOW->BOW_OBS	:= cMemo
			BOW->BOW_STATUS 	:= cStatus
			BOW->BOW_DTCANC		:= dDatabase
			BOW->BOW_USRRES		:= UsrFullName( RetCodUsr() )
			BOW->( MsUnLock() )
		END TRANSACTION
	Else
		lRet := .F.
		M->BOW_STATUS := BOW->BOW_STATUS
	Endif
else
	M->BOW_STATUS := BOW->BOW_STATUS
Endif

//Cancelo o título gerado na BD5 quando cancelo o protocolo
BD5->(DbSetOrder(17))  //Filial + ANOAUT, MESAUT, NUMAUT
If ( BD5->(DbSeek(xFilial("BD5") + BOW->(BOW_OPEMOV+BOW_ANOAUT+BOW_MESAUT+BOW_NUMAUT))) )
	PLSCNCGCOB( STR(BD5->(RECNO())), "2", "" ) // "2" - Cancelado
EndIf

return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLBrwRmbCan
Função para consultar os cancelamentos
@author Oscar Zanin
@since 22/09/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLBrwRmbCan()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('BOW')
oBrowse:SetDescription( STR0007 )//"Reembolsos Cancelados no período"

//Pergunte para o usuário informar Data inicial e Data Final
If Pergunte("BOWDT", .T.)
	If !(empty(MV_PAR01)) .AND. !(empty(MV_PAR02)) //Verifica se preencheu os parâmetros
		
		//Define o filtro do intervalo da data que o usuário escolheu
		oBrowse:SetFilterDefault( PLCancRFil(MV_PAR01, MV_PAR02) )
	EndIf
EndIf

//Define os campos que irão constar no Browse
oBrowse:SetOnlyFields( {'BOW_PROTOC' , 'BOW_NOMCLI' , 'BOW_DTDIGI' , 'BOW_CODRDA' , ;
'BOW_NOMRDA', 'BOW_MOTPAD' , 'BOW_MOTIND', 'BOW_DTCANC', 'BOW_USRRES'} )

//Remove os detalhes, pro browse ser só uma lista mesmo
oBrowse:disableDetails()
oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PLCancRFil()
Filtro do Browse para somente protocolos cancelados no período informado
@author Oscar Zanin
@since 22/09/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLCancRFil(dDataDe, dDataAte)

Local cRet := ""
Local dAux := StoD("  /  /    ")

//Garante que a data inicial é menor do que a data final
if dDataDe > dDataAte
	dAux := dDataAte
	dDataAte := dDataDe
	dDataDe := dAux
EndIf

//monta Filtro, condição da data
cRet := "BOW_DTCANC>='" + DtoS(dDataDe) + "' .AND. BOW_DTCANC<='" + DtoS(dDataAte) + "' "

//monta filtro, condição do status
cRet += " .AND. BOW_STATUS == 'D'"

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao para criar o menu da tela
@author Oscar Zanin
@since 23/09/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

//Não precisamos de opções no nosso Browse

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} PLCanRmbF3
Validação da consulta padrão (Código)
@author Oscar Zanin
@since 24/09/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLCanRmbF3(cConteudo, cDescri, lParam)

Local lRet := .F.

BBP->(DbSetOrder(1))
If BBP->(MsSeek(xFilial("BBP")+cConteudo))
	lRet := .T.
EndIf

cDescri := PLSrbF3Des(cConteudo)

lParam := lRet

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSrbF3Des
Validação da consulta padrão (Descrição)
@author Oscar Zanin
@since 24/09/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSrbF3Des(cConteudo)

Local cRet := ""

cRet := Posicione("BBP", 1, xFilial("BBP")+cConteudo, "BBP_DESMOT")

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSdlgCanc
Validação do preenchimento da Dialog
@author Oscar Zanin
@since 24/09/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSdlgCanc(cMotivo, odlg)

Local lRet := .F.

If (EmpTy(cMotivo))
	MsgAlert( STR0008 ) //"Atenção! Obrigatório informar o motivo!"
Else
	lRet := .T.
	oDlg:End()
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSVRCMR
Verificação se o procedimento solicitado no Protocolo de Reembolso
está no Contas Médicas (Processamento de Contas)
@author Oscar Zanin
@since 30/09/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSVRCMR(cProtoc,oBrwPro)

Local lRet 	:= .F.
Local lPreRet	:= .F.
Local aProced	:= {}
Local cMsg		:= ""
Local nI		:= 1
Local cCodRDA	:= ""
Local cCodInt := PLSINTPAD()
Local cChvMat	:= ""
Local cDatExe	:= ""
Local cChave	:= ""

LOCAL nPosCodRef	:= 0
LOCAL nPosMatric	:= 0
LOCAL nPosDatDoc	:= 0
LOCAL nPosCodPad	:= 0
LOCAL nPosCodPro	:= 0

DEFAULT oBrwPro := {}

B1N->(DbSelectArea("B1N"))
B1N->(DbSetOrder(1))

BD7->(DbSelectArea("BD7")) //BD7_FILIAL + BD7_CODOPE + BD7_CODRDA + BD7_OPEUSR + BD7_CODEMP + BD7_MATRIC + BD7_TIPREG + BD7_DATPRO + BD7_CODPAD + BD7_CODPRO
BD7->(DbSetOrder(14))


If !Empty(oBrwPro)
	//Tratar browse - solicitação do protocolo
	nPosCodRef	:=	PLRETPOS("B1N_CODREF",oBrwPro:aHeader)
	nPosMatric	:=	PLRETPOS("B1N_MATRIC",oBrwPro:aHeader)
	nPosDatDoc	:=	PLRETPOS("B1N_DATDOC",oBrwPro:aHeader)
	nPosCodPad	:=	PLRETPOS("B1N_CODPAD",oBrwPro:aHeader)
	nPosCodPro	:=	PLRETPOS("B1N_CODPRO",oBrwPro:aHeader)
	
	For nI := 1 to Len(oBrwPro:aCols)
		//Verifica se há código de RDA vinculada à rede não referenciada
		cCodRDA := PLSBK6B1N(oBrwPro:aCols[nI,nPosCodRef])
		
		If !( Empty( AllTrim(cCodRDA) ) )
			//Montamos as partes da chave
			cChvMat := Left(oBrwPro:aCols[nI,nPosMatric], Len(oBrwPro:aCols[nI,nPosMatric])-1) //Retira o dígito, pq na BD7 não tem
			cDatExe := DtoS(oBrwPro:aCols[nI,nPosDatDoc])
			cCodPad := oBrwPro:aCols[nI,nPosCodPad]
			cCdProc := oBrwPro:aCols[nI,nPosCodPro]
			cChave  := xFilial("BD7") + AllTrim( cCodInt + cCodRDA + cChvMat + cDatExe + cCodPad + cCdProc )
			
			//Verifica se existe na BD7
			If BD7->(MsSeek(cChave))
				lPreRet := .T.
			EndIf
			
			//Adiciona o código do procedimento
			If lPreRet
				Aadd( aProced, {cCodPad, cCdProc} )
			EndIf
			
			//Se passou um lPreRet .T., muda o retorno geral pra .T.
			If lPreRet
				lRet := .T.
			EndIf
			
			//Retorna a variável pro conteúdo padrão
			lPreret := .F.
		EndIf
	Next
Else
	If B1N->(MsSeek(xFilial("B1N") + cProtoc))
		//Verificar todos os itens vinculados ao protocolo
		While B1N->B1N_FILIAL == xFilial("B1N") .AND. B1N->B1N_PROTOC == cProtoc .AND. !(B1N->(EoF()))
			
			//Verifica se há código de RDA vinculada à rede não referenciada
			cCodRDA := PLSBK6B1N(B1N->B1N_CODREF)
			
			//Caso haja uma RDA vinculada, podemos buscar na BD7, se há algo no Contas médicas
			If !( Empty( AllTrim(cCodRDA) ) )
				
				//Montamos as partes da chave
				cChvMat := Left(B1N->B1N_MATRIC, Len(B1N->B1N_MATRIC)-1) //Retira o dígito, pq na BD7 não tem
				cDatExe := DtoS(B1N->B1N_DATDOC)
				cCodPad := B1N->B1N_CODPAD
				cCdProc := B1N->B1N_CODPRO
				cChave  := xFilial("BD7") + AllTrim( cCodInt + cCodRDA + cChvMat + cDatExe + cCodPad + cCdProc )
				
				//BD7_FILIAL + BD7_CODOPE + BD7_CODRDA + BD7_OPEUSR + BD7_CODEMP + BD7_MATRIC + BD7_TIPREG + BD7_DATPRO + BD7_CODPAD + BD7_CODPRO
				
				//Verifica se existe na BD7
				If BD7->(MsSeek(cChave))
					lPreRet := .T.
				EndIf
				
				//Adiciona o código do procedimento
				If lPreRet
					Aadd( aProced, {cCodPad, cCdProc} )
				EndIf
				
				//Se passou um lPreRet .T., muda o retorno geral pra .T.
				If lPreRet
					lRet := .T.
				EndIf
				
				//Retorna a variável pro conteúdo padrão
				lPreret := .F.
			EndIf
			B1N->(DbSkip())
		EndDo
	EndIf
EndIf

BD7->(DbCloseArea())

If lRet
	cMsg += STR0009 //"Foi identificada a ocorrência de procedimento/honorário com beneficiário, data "
	cMsg += STR0010 //"e prestador idênticos no Processamento de contas. Abaixo lista dos procedimentos "
	cMsg += STR0011 /*"desta solicitação neta situação: "*/ + CRLF
	For nI := 1 To Len(aProced)
		cMsg += aProced[nI][2] + " - " + POSICIONE('BR8',1,XFILIAL('BR8')+aProced[nI][1]+aProced[nI][2],'BR8_DESCRI') + CRLF
	Next
	cMsg += CRLF + STR0012 //"Deseja continuar?"
	lRet := MsgYesNo( cMsg, STR0013 /*"Atenção!"*/ )
else
	//Inverte o retorno, se achou, retorna valid = falso, se não achou, retorna valid = true
	lRet := !(lRet)
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSBK6B1N
Verifica se a Rede não referenciada informada possui um cadastro como rede de Atendimento
@author Oscar Zanin
@since 30/09/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSBK6B1N(cCpfCnpj)

Local cCodRDA	:= ""
Local cChave	:= ""

BK6->(DbSelectArea("BK6"))
BK6->(DbSetOrder(4)) //Ordena por CPF/CNPJ

BAU->(DbselectArea("BAU"))
BAU->(DbSetOrder(4)) // Ordena por CPF/CNPJ

//Busca na BK6 se o código existe e define a chave de busca para a BAU
If BK6->(MsSeek(xFilial("BK6") + AllTrim(cCpfCnpj )))
	cChave := xFilial("BAU") + AllTrim(BK6->BK6_CGC)
else
	cChave := xFilial("BAU") + AllTrim(cCpfCnpj)
EndIf

BK6->(DbCloseArea())

//Verifica se a rede não referenciada tem um cadastro de RDA
If BAU->(MsSeek(cChave))
	cCodRDA := BAU->BAU_CODIGO
EndIf

BAU->(DbCloseArea())

Return (cCodRDA)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSVRRCM
Verificação se o procedimento informado no Contas Médicas (Processamento
de Contas) já não foi pago em reembolso
@author Oscar Zanin
@since 01/10/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSVRRCM()
Local aAreaBD7 	:= BD7->(getArea())
Local lRet 		:= .f.
Local lPreRet	:= .f.
Local aProced	:= {}
Local cMsg		:= ""
Local nI		:= 1
Local lFound 	:= .f.
Local cRdaGen	:= getNewPar("MV_PLSRDAG", "") //Como vamos buscar reembolsos, precisamos da RDA genérica
Local aBusca	:= {}
Local nJ		:= 1
Local nRecBase 	:= 1
Local nRecTemp 	:= 1
Local aRecno 	:= {}
Local cCodPeg	:= ""
/*
===========================================================================================

- While, depois do primeiro Seek na BD7, com o índice 1
- Gravar num Array se pá o CODPEG e o RECNO
- Ordenar pelo índice 14
- Fazer uma busca para cada registro que está no array (usar o Recno pra montar a chave)
- Se surgir um novo registro no While (comparar se o RECNO está no array)
- Montar um array com as informações dos registros diferentes (que passaaram com o RECNO diferente mas a chave igual)

============================================================================================

Pegar o array de chaves e buscar na B44
- Verificar se o registro está com o campo DATPAG preenchido
- Se sim, retornar .T. //+ Mensagem de aviso

*/

B44->(DbSetOrder(5))
BD7->(DbSetOrder(1))
if BD7->( msSeek( xFilial("BD7") + BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) ) )

	nRecBase := BD7->(recno())
	aadd(aRecno, {nRecBase, BD7->BD7_CODPEG + BD7->BD7_NUMERO, BD7->BD7_CODOPE + cRdaGen + BD7->BD7_OPEUSR + BD7->BD7_CODEMP + BD7->BD7_MATRIC + BD7->BD7_TIPREG + DtoS(BD7->BD7_DATPRO) + BD7->BD7_CODPAD + BD7->BD7_CODPRO } )

endIf

if len(aRecno) > 0

	BD7->(dbGoTo(nRecBase))

	while ( xFilial("BD7") == BD7->BD7_FILIAL .and. aRecno[1,3] == BD7->BD7_CODOPE + BD7->BD7_CODRDA + BD7->BD7_OPEUSR + BD7->BD7_CODEMP + BD7->BD7_MATRIC + BD7->BD7_TIPREG + DtoS(BD7->BD7_DATPRO) + BD7->BD7_CODPAD + BD7->BD7_CODPRO ) .and. !lFound

		nRecTemp := BD7->(Recno())
		
		//Se achou de outra guia, adiciona no aBusca, para checar o reembolso
		if (BD7->BD7_CODPEG + BD7->BD7_NUMERO != aRecno[1,2]) 
	
			aadd(aBusca, {nRectemp, BD7->BD7_CODPEG + BD7->BD7_NUMERO, BD7->BD7_CODPAD, BD7->BD7_CODPRO, BD7->BD7_NUMERO})
			
			lFound := .t.
			
		endIf
			
	BD7->(dbSkip())
	endDo
	
	lFound := .f.
	
endIf

for nI := 1 to len(aBusca)

	If ( B44->(msSeek( xFilial("B44") + aBusca[nI][2] )) )

		lPreRet := .t.

		If !(empty(B44->B44_DATPAG))

			//Adiciona o código do procedimento
			If lPreRet
				aadd( aProced, {aBusca[nI][3], aBusca[nI][4], aBusca[nI][5]} )
			endIf
			
			//Se passou um lPreRet .T., muda o retorno geral pra .T.
			If lPreRet
				lRet := .t.
				exit
			endIf
			
			//Retorna a variável pro conteúdo padrão
			lPreret := .f.
			
		endIf
		
	endIf
	
next

restArea(aAreaBD7)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSATUB53
Atualiza B53
@author Roberto Vanderlei
@since 24/05/2017
@version P12
/*/
//-------------------------------------------------------------------
function PLSATUB53(cChaveAC9, cChaveInt, cAliasTab)

	Default cAliasTab := "BEA"

	AC9->(DbSetOrder(2))//AC9_FILIAL, AC9_ENTIDA, AC9_FILENT, AC9_CODENT, AC9_CODOBJ, R_E_C_N_O_, D_E_L_E_T_

	If AC9->(dbSeek( xFilial("AC9") + cAliasTab /*"BEA"*/ +xfilial('BE2')+cChaveAC9))
	    If B53->(dbSeek(xFilial("B53")+cChaveInt))
	      	If B53->B53_BANCON != '1'
		      	B53->(Reclock("B53",.F.))
				B53->B53_BANCON := '1'
				B53->(MsUnlock())
			EndIf
		EndIf
	else
	    If B53->(dbSeek(xFilial("B53")+cChaveInt))
	      If B53->B53_BANCON != '0'
		      	B53->(Reclock("B53",.F.))
				B53->B53_BANCON := '0'
				B53->(MsUnlock())
			EndIf
		EndIf
	EndIf
return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSOUTB1N
Deleta o Arquivo referenciado na pasta do banco de conhecimento (servidor)
@author Oscar Zanin
@since 20/10/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSOUTCONH( nRecno )

Local aArea 	:= getArea()
Local lRet		:= .F.
Local cDirDocs	:= ""
LOCAL cNameServ	:= ""
LOCAL cDir	 	:= getWebDir()
Local cChvACB	:= ""
Local lDel		:= .F.
Local cChaveAC9
Local cChaveInt

ACB->(DbSelectArea("ACB"))
ACB->(DbSetOrder(1))

AC9->(dbSelectArea("AC9"))

//Acha o caminho do banco de conhecimento
If FindFunction( "MsMultDir" ) .And. MsMultDir()
	cDirDocs := MsRetPath()
Else
	cDirDocs := MsDocPath()
Endif

Begin TRANSACTION

//Deleta registro na AC9
	AC9->(DbGoTo(nRecno))

	cChaveAC9 := AC9->AC9_CODENT 
	cChaveInt := substr(AC9->AC9_CODENT, len(xFilial("BEA")) + 1, 18)

//Monta chave para buscar correspondente na ACB
	cChvACB := xFilial("ACB") + AC9->AC9_CODOBJ
	AC9->(RecLock("AC9", .F.))
	AC9->(DbDelete())
	AC9->(MsUnlock())

//Deleta registro na ACB
	ACB->(MsSeek(cChvACB))
//Recupera nome do arquivo
	cNameServ := AllTrim(ACB->ACB_OBJETO)

//Deleta arquivo no servidor
	if file(PLSMUDSIS(cDirDocs + "\" + cNameServ))
		FErase(cDirDocs + "\" + cNameServ)
		lDel := .T.
	EndIf

	If ACB->(MsSeek(cChvACB))
		ACB->(RecLock("ACB", .F.))
		ACB->(DbDelete())
		ACB->(MsUnlock())
	EndIf

End TRANSACTION

AC9->(DbCloseArea())
ACB->(DbcloseArea())

PLSATUB53(cChaveAC9, cChaveInt)

restArea(aArea)

Return (lDel)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSCOPWEB
Retorna o caminho de um arquivo para download
@author Francisco Edcarlo
@since 06/01/2017
@version P12
/*/
//-------------------------------------------------------------------
Function PLSCOPWEB( nRecno )

Local aArea 	:= getArea()
Local cDirDocs	:= ""
LOCAL cNameServ	:= ""
LOCAL cDir	 	:= getWebDir()
LOCAL cDirWeb		:= getNewPar("MV_RELT","")
Local cChvACB	:= ""
Local lRet		:= ""
Local lDownload := getNewPar("MV_PLPDWN",.f.) //Parametro para permissão de download

if lDownload
	ACB->(DbSelectArea("ACB"))
	ACB->(DbSetOrder(1))
	
	AC9->(dbSelectArea("AC9"))
	
	//Acha o caminho do banco de conhecimento
	If FindFunction( "MsMultDir" ) .And. MsMultDir()
		cDirDocs := MsRetPath()
	Else
		cDirDocs := MsDocPath()
	Endif
	
	AC9->(DbGoTo(nRecno))
	//Monta chave para buscar correspondente na ACB
	cChvACB := xFilial("ACB") + AC9->AC9_CODOBJ
	ACB->(MsSeek(cChvACB))
	//Recupera nome do arquivo
	cNameServ := AllTrim(ACB->ACB_OBJETO)
	
	//Se encontrar o arquivo retorna o caminho para download
	if file(PLSMUDSIS(cDirWeb + "\" + cNameServ))
		lRet := substr(PLSMUDSIS(UPPER(cDirWeb + cNameServ)),at(UPPER(getSkinPls()), cDirWeb))
	EndIf
	
	AC9->(DbCloseArea())
	ACB->(DbcloseArea())
	
	restArea(aArea)
EndIf

Return (lRet)

/*/{Protheus.doc} PLSOUTB1N
Deleta o registro da B1N, caso já gravado
@author Oscar Zanin
@since 20/10/2015
@version P12
/*/
function PLSOUTB1N(nRecno)
local lRet	:= .f.
local aArea	:= getArea()

B1N->(dbGoTo(nRecno))

BOW->(dbSetOrder(1)) 
if BOW->( msSeek( xFilial("BOW") + B1N->B1N_PROTOC ) )

	BOW->(recLock("BOW", .F.))
		BOW->BOW_VLRAPR -= B1N->B1N_VLRAPR
	BOW->(msUnlock())
	
endIf 

B1N->(recLock("B1N", .f.))
	B1N->(dbDelete())
B1N->(msUnlock())

lRet := .t.

restArea(aArea)

return(lRet)

/*/{Protheus.doc} PLSBK6CHK
Verifica se existe o código informado na BK6
@author Oscar Zanin
@since 20/10/2015
@version P12
/*/
Function PLSBK6CHK(cCPFCNPJ, cNome, nRecno)

Local lComportamento	:= GetNewPar("MV_VRDANRF", .F.)
Local nI		:= 0
Local cCodBk6	:= ""
Local cNomBK6	:= ""
Local cProtocolo := ""

BOW->(DbSelectArea("BOW"))
BOW->(DbGoTo(nRecno))
cProtocolo := BOW->BOW_PROTOC
BOW->(DbcloseArea())

If lComportamento
	
	BK6->(DbSelectArea("BK6"))
	BK6->(DbSetOrder(4))
	if	!( BK6->(MsSeek(xFilial("BK6") + AllTrim(cCPFCNPJ))) )
		BEGIN TRANSACTION
			BK6->(RecLock("BK6", .T.))
			BK6->BK6_CODIGO := GetSX8Num("BK6", "BK6_CODIGO")
			BK6->(ConfirmSX8())
			BK6->BK6_CGC 	:= cCPFCNPJ
			BK6->BK6_NOME :=	cNome
			BK6->(MsUnlock())
		END TRANSACTION
	EndIf
	cCodBK6 := BK6->(BK6_CODIGO)
	cNomBK6 := BK6->(BK6_NOME)
	BK6->(DbCloseArea())
	
	B1N->(DbSelectArea("B1N"))
	B1N->(DbSetOrder(1))
	if B1N->(MsSeek(xFilial("B1N") + cProtocolo))
		BEGIN TRANSACTION
			While B1N->(B1N_PROTOC) == cProtocolo .AND. !(B1N->(EoF()))
				B1N->(RecLock("B1N", .F.))
				B1N->B1N_CODREF	:= cCodBK6
				B1N->B1N_NOMREF	:= cNomBK6
				B1N->(MsUnlock())
				B1N->(DbSkip())
			EndDo
		END TRANSACTION
	EndIf
	B1N->(DbcloseArea())
else
	
	B1N->(DbSelectArea("B1N"))
	B1N->(DbsetOrder(1))
	If B1N->(xFilial("B1N") + cProtocolo)
		BEGIN TRANSACTION
			While B1N->B1N_PROTOC == cProtocolo .AND. !(B1N->(Eof()))
				B1N->B1N_PRNOME := cNome
				B1N->B1N_PRCNPJ := cCPFCNPJ
				B1N->(Dbskip())
			EndDo
		END TRANSACTION
	EndIf
	B1N->(DbCloseArea())
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSCMPBOW
Grava Itens do reembolso Portal
@author Oscar Zanin
@since 20/10/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSCMPBOW(cCodSol, aDados, cAltera, cDocObrig, lCabAlt, cRecDivs, cAtuB1N, aDadBK6)
/*
Dados do aDados:
[1] = Matrícula (completa)
[2] = ::CPFCNPJ
[3] = UsrLogin
[4] = XFILIAL(BOW)
[5] = ::NomRdaNRef
[6] = ::NumDoc
[7] = ::DatDoc ->Vem caractere
[8] = ::Tipo
*/
Local aRetB1N	:= {}
Local lRet 	:= .F.
Local cRet		:= "true|Solicitação enviada com sucesso!"
Local nValMin := 0
Local lOk		:= .T.
Local lInsBK6	:= getNewPar("MV_VRDANRF",.F.)
Local aCliente	:= {}
Local nCount		:= 1
Local aDadCli		:= separa(aDados[2])
Local aDadRDA		:= {}
Local cCpfCnpj	:= StrTran(StrTran(StrTran(aDados[2],".",""),"-",""),"/","")
Local aRetWeBa	:= {}
Local aItensDup  := nil
Local nPos			:= 0
Local xCols      := ""
Local auxXcols := ""
Local nI			:= 0
Local aDadosBOW	:= {}
Local aItensB1N	:= {}
Local lGrvRmbBD5 := GetNewPar("MV_GRMBBD5", .F.)
Local cCodBK6 := ""
Local cNomBK6 := ""
Local cDescMun := ""
Local lDesMun := .F.
Local lFndBK6 := .F.
Local lFndPrest := .F.

Default aDadBK6	:= {}

BA1->(DbSetOrder(2))
BA1->(MsSeek(xFilial("BA1") + aDados[1]))

BA3->(DbSetOrder(1))
BA3->(MsSeek(xFilial("BA3") + Left( aDados[1], 14)))

BAU->(dbSetOrder(1))//BAU_FILIAL,BAU_CODIGO

BK6->(DbSetOrder(4))//BK6_FILIAL+BK6_CGC
lDesMun := BK6->( FieldPos("BK6_MUNCR") ) > 0

If !empty(cCodSol) .and. (cAltera == "true" .or. lCabAlt)
	aItensDup := {}
	BOW->(DbSetOrder(1))
	B1N->(DbSetOrder(2))
	If BOW->( MsSeek( xFilial("BOW") + cCodSol ) )
		cSql := "SELECT B1N_PROTOC, B1N_MATRIC, B1N_CODPAD, B1N_CODPRO FROM " + retSqlName("B1N") + " B1N "
		cSql += " INNER JOIN " + retSqlName("BOW") + " BOW "
		cSql += " ON ( ( B1N.B1N_FILIAL || B1N.B1N_PROTOC ) = ( BOW.BOW_FILIAL || BOW.BOW_PROTOC ) )"
		cSql += " WHERE "
		cSql += "	   	B1N.B1N_FILIAL = '" + xFilial("B1N") + "' "
		cSql += " AND BOW.BOW_FILIAL = '" + xFilial("BOW") + "' "
		cSql += " AND B1N.D_E_L_E_T_ = '' "
		cSql += " AND BOW.D_E_L_E_T_ = '' "
		cSql += " AND BOW.BOW_STATUS NOT IN ('A', 'D', '4') "
		cSql += " AND B1N.B1N_TIPDOC = '" + aDados[8] + "' "
		cSql += " AND B1N.B1N_PRCNPJ = '" + cCpfCnpj + "' "
		cSql += " AND B1N.B1N_PROTOC <> '" + cCodSol + "' "
		cSql += " AND B1N.B1N_IMGSTA <> 'DISABLE' "
		if !empty(cRecDivs) .and. cRecDivs != "0"
			cSql += " AND B1N.R_E_C_N_O_ IN(" + cRecDivs + ")"
		endIf
		if(cDocObrig == "true")
			cSql += " AND B1N.B1N_NUMDOC = '" + aDados[6] + "' "
		else
			cSql += " AND B1N.B1N_DATDOC = '" + dtos(ctod(aDados[7])) + "' "
		endif
		//aqui eu vou acrescentar todos os itens da solicitação que o usuario está gravando
		//o intuito dessa query é pegar possíveis itens repetidos em outros protocolos para não deixar gravar
		If (B1N->(MsSeek(xFilial("B1N") + cCodSol)))
			cSql += " AND ("
			While((!B1N->(EOF())) .AND. B1N->B1N_FILIAL == xFilial("B1N") .AND. B1N->B1N_PROTOC == cCodSol)
				cSql += " (B1N.B1N_CODPAD = '" + B1N->B1N_CODPAD + "' "
				cSql += " AND B1N.B1N_CODPRO = '" + B1N->B1N_CODPRO + "' "
				cSql += " AND B1N.B1N_MATRIC = '" + B1N->B1N_MATRIC + "' "
				if(cDocObrig == "false")
					if B1N->(FieldPos("B1N_VLRTOT")) > 0
						cSql += " AND B1N.B1N_VLRTOT = " + str(B1N->B1N_VLRTOT)
					else
						cSql += " AND B1N.B1N_VLRAPR = " + str(B1N->B1N_VLRAPR)
					endIf
				endIf
				cSql += ") OR "
				B1N->(DbSkip())
			EndDo
			//retiro a ultima palavra "OR " adicionada na string
			nPos := RAT("OR", cSql)
			cSql := SUBSTR(cSql, 1, nPos-1) + ")"
			
			cSql := ChangeQuery(cSql)
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"ALIASB1N",.T.,.F.)
			
			if !ALIASB1N->( Eof() )
				lOk := .F.
				xCols := "true|[" // para nao cair no exibe erro, vou tratar no callback
				auxXcols := "]"
			endIf
			
			while !ALIASB1N->( Eof() )
				//retorno esse objeto para o portal para identificar quais despesas existem em outros protocolos
				//não é viável retornar apenas que ha despesas já solicitadas, o beneficiario precisa saber quais são para remover da solicitação
				xCols += "{"
				xCols +=  "0:{field:'cProtoc',value:'" + ALIASB1N->B1N_PROTOC + "'},"
				xCols +=  "1:{field:'cMatric',value:'" + ALIASB1N->B1N_MATRIC + "'},"
				xCols +=  "2:{field:'cCodPad',value:'" + ALIASB1N->B1N_CODPAD + "'},"
				xCols +=  "3:{field:'cCodPro',value:'" + ALIASB1N->B1N_CODPRO + "'}}"
				ALIASB1N->( dbSkip() )
			endDo
			
			xCols += auxXcols
			cRet := xCols
			ALIASB1N->(dbCloseArea())
		EndIF
	EndIf
endIf

If lOk
	
	If ExistBlock("PLVLWEBA")
		aRetWeBa := ExecBlock("PLVLWEBA",.F.,.F.,{cCodSol, aDados})
		If (aRetWeBa[1])
			lOk 	:= .T.
		Else
			lOk 	:= .F.
			cRet 	:= "false|"+aRetWeBa[2]
		EndIf
	EndIf
	
EndIF

If lOk
	
	aCliente := PLSAVERNIV(	BA3->BA3_CODINT,BA3->BA3_CODEMP,BA3->BA3_MATRIC,IIF(BA3->BA3_TIPOUS=="1","F","J"),;
		BA3->BA3_CONEMP,BA3->BA3_VERCON,BA3->BA3_SUBCON,BA3->BA3_VERSUB,nil,BA1->BA1_TIPREG,.F.)
	
	BOW->(DbSelectArea("BOW"))
	BOW->(DbSetOrder(1))
	If (BOW->(MsSeek(xFilial("BOW")+cCodSol)))
	
	cMunicipio := BOW->BOW_DESMUN
	cEstado    := BOW->BOW_UFATE
	cCodMunic  := BOW->BOW_MUNATE
//Movendo o que pode ser tirado da transaction para deixa-la mais enxuta
		For nCount := 1 To LEN(ADadCli)
			If !EMPTY(ADadCli[nCount])
				lFndPrest := .T.
				lFndBK6 :=  BK6->( MsSeek( xFilial("BK6")+ cCpfCnpj ) )
				If lFndBK6 
					If lDesMun
						BOW->BOW_MUNATE	:= 	cCodMunic
					
						BID->(DbSetOrder(1))
						If BID->(MsSeek(xFilial("BID")+BK6->BK6_MUNCR))
							cDescMun := BID->BID_DESCRI
						EndIf
					EndIf
				Else // Cria novo registro de rede nao referenciada na BK6
					IF !lInsBK6
						aDadRda :=  PlsIncBK6(aDados[5], cCpfCnpj, aDados[9], aDados[10])
						cCodBK6 := aDadRda[1][1]
						cNomBK6 := aDadRda[1][2]
					EndIf
				EndIf

			EndIf
		Next
		
		//Vou procurar se para outros protocolos não existem redes não cadastradas na BK6, para inclusão								
		If ( Len(aDadBK6) > 0 )
			For nI := 1 To Len(aDadBK6)
				If !( BK6->(MsSeek( xFilial("BK6")+ aDadBK6[nI,2])) )						
					aDadRda :=  PlsIncBK6(aDadBK6[nI,1], aDadBK6[nI,2], aDadBK6[nI,3], aDadBK6[nI,4])	
				EndIf
			Next	
		EndIf

		BEGIN TRANSACTION

			BOW->(RecLock("BOW", .F.))
				BOW->BOW_FILIAL := xFilial("BOW")
				BOW->BOW_TIPPAC := GetNewPar("MV_PLSTPAA","1")
				BOW->BOW_STATUS := "1"
				BOW->BOW_USUARI := aDados[1]
				BOW->BOW_DATPAG := CTOD(aDados[7])
				If aCliente[1,1] <> "ZZZZZZ"
					BOW->BOW_CODCLI	:= aCliente[1][1]
					BOW->BOW_LOJA  	:= aCliente[1][2]
					BOW->BOW_NOMCLI	:= aCliente[1][3]
				EndIf
			
				BOW->BOW_TIPUSR := "99"
				BOW->BOW_VIACAR := BA1->BA1_VIACAR
				BOW->BOW_CODEMP := BA3->BA3_CODEMP
				BOW->BOW_MATRIC := BA3->BA3_MATRIC
				BOW->BOW_TIPREG := BA1->BA1_TIPREG
				BOW->BOW_DIGITO := BA1->BA1_DIGITO
				BOW->BOW_MATUSA := "1"
				BOW->BOW_DTDIGI := dDataBase
				BOW->BOW_OPERDA := BA1->BA1_CODINT
				BOW->BOW_CONEMP := BA3->BA3_CONEMP
				BOW->BOW_VERCON := BA3->BA3_VERCON
				BOW->BOW_SUBCON := BA3->BA3_SUBCON
				BOW->BOW_VERSUB := BA3->BA3_VERSUB
				
				If lFndPrest
					If lFndBK6 
						BOW->BOW_CODREF := BK6->BK6_CGC
						BOW->BOW_NOMREF := BK6->BK6_NOME
						BOW->BOW_UFATE  := cEstado
						BOW->BOW_SIGLA  := BK6->BK6_SIGLA
					
						If lDesMun
							BOW->BOW_MUNATE	:= 	cCodMunic
							BOW->BOW_DESMUN	:= 	cMunicipio
						EndIf
					Else // Cria novo registro de rede nao referenciada na BK6
						IF (!lInsBK6)
							BOW->BOW_CODREF 	:= cCodBK6
							BOW->BOW_NOMREF 	:= cNomBK6

						EndIf
					EndIf
				EndIf
					
				BOW->BOW_OPESOL := BA1->BA1_CODINT
				BOW->BOW_OPEUSR := BA1->BA1_CODINT
				BOW->BOW_ESTSOL := GETMV("MV_PLSESPD")
				BOW->BOW_OPEEXE := BA1->BA1_CODINT
				BOW->BOW_ESTEXE := GETMV("MV_PLSESPD")
				BOW->BOW_CDOPER := aDados[4]
				BOW->BOW_NOMOPE := Posicione("BSW", 5, xFilial("BSW") + aDados[4], "BSW_NOMUSR")
			
				If BAU->( MsSeek(xFilial("BAU")+GetNewPar("MV_PLSRDAG","999999")) )
					BOW->BOW_CODRDA := BAU->BAU_CODIGO
					BOW->BOW_TIPPRE := BAU->BAU_TIPPRE
				
					//------------------------------------------------------
					// Profissional relacionado a rda
					//------------------------------------------------------
					BB0->( DbSelectArea("BB0") )
					BB0->( DbSetOrder(1) ) //BB0_FILIAL + BB0_CODIGO
					BB0->( MsSeek( xFilial("BB0")+BAU->BAU_CODBB0 ) )
				
					If BB0->(Found())
						BOW->BOW_REGEXE := BB0->BB0_NUMCR
						BOW->BOW_NOMEXE := BB0->BB0_NOME
						BOW->BOW_CDPFRE := BB0->BB0_CODIGO
					EndIf
				
					BB0->( DbCloseArea() )

					//------------------------------------------------------
					// DadRda
					//------------------------------------------------------
					PLSDADRDA(BOW->BOW_OPERDA,BOW->BOW_CODRDA,"1",dDataBase,Subs(BOW->BOW_LOCATE,1,3),"")
					aDadRDA := PLSGETRDA()
					if len(aDadRDA) >=15
						BOW->BOW_CODESP := aDadRDA[15]
						BOW->BOW_DESESP := aDadRDA[17]
						BOW->BOW_LOCATE := aDadRDA[18]
						BOW->BOW_ENDLOC := aDadRDA[20]
					EndIf

				EndIf
			
				BOW->BOW_OPEMOV := PLSINTPAD()
			BOW->(MsUnLock())
		
			aRetB1N := PLSCMPB1N(BOW->BOW_PROTOC, aDados[1], cCpfCnpj, aDados[5], aDados[8], aDados[6], aDados[7],lInsBK6, cAtuB1N)

			BOW->(RecLock("BOW", .F.))
			BOW->BOW_VLRAPR := aRetB1N[2]
			BOW->(MsUnlock())
		
			cRet := aRetB1N[1]

			//Grava Histórico do reembolso
			PLGRVBOX(BOW->BOW_PROTOC,BOW->BOW_MATRIC,BOW->BOW_STATUS,,,,,,,,,.T.)

			//Após finalização da gravação do reembolso pelo portal (status = 'Protocolado'), grava guia de reembolso nas tabelas BD5, BD6 e BD7.
			If lGrvRmbBD5
				aDadosBOW := {{ "TP_CLIENTE", "WEB" },;							//Tipo de Cliente
							{ "TPGRV"		, "2" },;								//Tipo de Gravacao
							{ "TIPOMAT"   , "1" },;								//Matricula Siga
							{ "GERSEN"		, GetNewPar("MV_PLGSENW",.T.) },;	//Gera senha de autorização
							{ "CODLDP"		, PLSRETLDP(4)},;					//LOCAL de Digitacao
							{ "CODRDA"		, BOW->BOW_CODRDA },;				//Rda
							{ "CNES"		, BAU->BAU_CNES },;					//CNES
							{ "CODLOC"		, BOW->BOW_LOCATE },;				//LOCAL de atendimento
							{ "LOCPRO"		, "" },;								//LOCAL de atendimento da Rda do profissional
							{ "RDAPRO"		, BOW->BOW_OPEEXE },;				//Rda do Profissional de Saude
							{ "RDACONS"	, BOW->BOW_SIGLA  },;	  		    //Conselho Profissional de Saude
							{ "RDANUMC"	, BK6->BK6_CONREG },;				//Numero Conselho Profissional de Saude
							{ "RDAUFCO"	, BOW->BOW_ESTEXE },;				//Estado Conselho Profissional de Saude
							{ "OPEMOV"		, PLSINTPAD() },;						//Operadora de movimento
							{ "OPEINT"		, "" },;								//Operadora de movimento Internacao
							{ "USUARIO"	, aDados[1] },;						//Matricula
							{ "ORIGEM"    , "1" },;								//Origem 1=Autorizacao ou 2=Liberacao
							{ "NUMAUT"    , "" },; 								//Numero da Autorizacao
							{ "LVALOR"		, .T. },; 								//indica que o evento sera valorizado
							{ "LRETVPF"	, .T. },; 								//indica que devera ser retornado o valor da participacao financeira
							{ "LREGPAGATO", .T. },; 								//indica se ira checar regra de "pagar o evento no ato"
							{ "INCAUTIE"  , .F. },;								//Se o usuario for de intercambio e nao existir ele inclui
							{ "AUDEMP"  	, .F. },;								//Critica da operadora se manda para auditoria
							{ "RPC"  		, .T. },;								//.F. vem do remote .T web, pos
							{ "HORAPRO"	, SubStr( StrTran( Time(), ":", "" ), 1, 4 ) },; //Hora
							{ "DATPRO"		, BOW->BOW_DTDIGI },;				//Data de digitação
							{ "NUMLIB"		, "" },;								//Numero da liberacao
							{ "CODCBO"		, "" },;								//Cbos
							{ "CODESP"		, BOW->BOW_CODESP },;				//Especialidade
							{ "CIDPRI"		, "" },;             				//Cid Principal
							{ "CID2"		, "" },;								//Cid 2
							{ "CID3"		, "" },;								//Cid 3
							{ "CID4"		, "" },;								//Cid 4
							{ "CID5"		, "" },;								//Cid 5
							{ "OPESOL"		, BOW->BOW_OPESOL },;				//Operadora Solicitante
							{ "CDPFSO"		, "" },;								//Profissional Solicitante
							{ "CDOPEX"		, BOW->BOW_OPEEXE },;				//Operadora Executante
							{ "CDPFEX"		, BOW->BOW_CDPFRE },;       	    //Profissional Executante
							{ "CPFEXE"		, "" },;           	 				//Cpf Executante
							{ "CNESEXE"	, "" },;           					//Cnes Executante
							{ "NOMEXEC"	, BOW->BOW_NOMEXE },;            	//Nome Executante
							{ "NUMIMP"		, "" },;								//Atendimento Laboratorial
							{ "MSG01"    	, "" },; 								//Observacao
							{ "MSG02"    	, "" },;								//Observacao
							{ "MSG03"    	, "" },;								//Mensagem
							{ "NRAOPE"		, "" },;								//Numero autorizacao operadora
							{ "NRAEMP"		, "" },;      						//Numero autorizacao empresa
							{ "VIACAR"    , "" },; 								//Via do Cartao
							{ "DTVALID"   , "" },;     							//Data de Validade
							{ "AREAABR"   , "" },; 								//Abrangencia
							{ "NATJURI"   , "" },;								//Natureza juridica
							{ "TIPO"      , "04" },;								//Tipo de Guia
							{ "NOMUSR"    , "" },; 								//Nome Contido na carteirinha
							{ "TIPSAI"    , "" },; 								//Tipo de Saida
							{ "TIPATE"    , "" },; 								//Tipo de Atendimento
							{ "TIPATO"    , "" },; 								//Tipo de Atendimento Odontologico
							{ "TIPFAT"    , "" },; 								//Tipo de Faturamento
							{ "TIPDOE"    , "" },; 								//Tipo de Doenca
							{ "TMPDOE"    , "" },; 								//Tempo da Doenca
							{ "UNDDOE"    , "" },; 								//Unidade da Doenca
							{ "INDACI"    , "" },; 								//Indicacao de Acidente
							{ "TPEVEN"		, "" },; 								//Grupo de internacao
							{ "TIPINT"    , "" },;								//Tipo de Internacao
							{ "REGINT"   	, "" },;								//Regime da Internacao
							{ "PADINT"   	, "" },;								//Tipo de Acomodacao
							{ "PADCON"   	, "" },;								//Padrao de Conforto
							{ "CHKREG"    , "" },; 								//Se vai checar regras ou nao
							{ "DATSOL"    , "" },; 								//Carater da solicitacao
							{ "CARSOL"    , "" },; 								//Carater da solicitacao
							{ "INDCLI"    , "" },; 								//Indicacao de Clinica
							{ "TIPCON"    , "" },;								//Nome Contido na carteirinha
							{ "GUIPR"    	, "" },;								//Guia Principal
							{ "VALTOT"    , BOW->BOW_VLRAPR},;					//Valor total da Guia honorario
							{ "INTERN"    , .F. },; 								//Internacao
							{ "EVOLU"    	, .F. },; 								//Evolucao (prorrogacao de internacao)
							{ "QDISOL"    , 0 },;								//Quantidade de Diarias Solicitada
							{ "HORIND"    , .F. } ,;								//Honorario individual
							{ "CGCSOLT"   , "" } ,;								//Cgc Rda Solicitada
							{ "NUMPEG"    , "" } ,;								//Chave do BD6 - Numero da PEG
							{ "AUNMED" 	, {} } ,;								//Unidade / Participacao
							{ "FORBLO"		, .F. },;								//Bloqueio
							{ "RESINT"    , .F. },;
							{ "TIPGUI"   	, "04" },;
							{ "ESPSOL"		, BOW->BOW_CDPFSO } ,;
							{ "ATENRN"		, "0" },; 								//Atendimento RN
							{ "INIFAT"		, "" },;
							{ "PRVQUI"		, "" },;
							{ "PRVOPM"		, "" },;
							{ "FIMFAT"		, "" },;
							{ "DTRLZ"		, "" },;
							{ "DTRLZ2"		, "" },;
							{ "DTRLZ3"		, "" },;
							{ "DTRLZ4"		, "" },;
							{ "DTRLZ5"		, "" },;
							{ "DTRLZ6"		, "" },;
							{ "DTRLZ7"		, "" },;
							{ "DTRLZ8"		, "" },;
							{ "DTRLZ9"		, "" },;
							{ "DTRLZ1"		, "" },;
							{ "LODONTO"   , .F. },;
							{ "TIPOCONFIRM",  ""},;
							{ "OBSGUI"		, "" },;
							{ "ESPEXE"		, "" },;
							{ "PROTOC"		, BOW->BOW_PROTOC },;
							{ "GUIPRE"		, "" }} // Numero 2-Guia Prestador na guia de Consulta via Portal do Prestador.	
					
			

				PLGRGUIREE(aDadosBOW)
			EndIf		
		END TRANSACTION
	EndIf
	
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSREEMBDI
Verfica se usuário tem direito à solicitar reembolso
@author Oscar Zanin
@since 20/10/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSREEMBDI(cCodLog)

Local lRet 	:= .F.
Local cMatric := ""
Local nVidas	:= 0
Local nPermt	:= 0

B49->(DbSelectArea("B49"))
B49->(DbSetOrder(1))

If (B49->(MsSeek(xFilial("B49") + cCodLog)))
	cMatric := SubStr(B49->B49_BENEFI, 1, 14)
EndIf
B49->(DbCloseArea())

If !(Vazio(AllTrim(cMatric)))
	BA1->(DbSelectArea("BA1"))
	BA1->(DbSetOrder(2))
	If (BA1->(MsSeek(xFilial("BA1") + cMatric)))
		While BA1->(xFilial("BA1")+BA1_CODINT+BA1_CODEMP+BA1_MATRIC) == xFilial("BA1")+cMatric
			nVidas++  //acumulo a quantidade de beneficiários encontrados
			If !(BA1->BA1_REEWEB == "1" )  //Verifico quantos não podem acessar e solicitar o reembolso
				nPermt++
			EndIf
			BA1->(DbSkip())
		EndDo
	EndIf
	BA1->(DbCloseArea())
EndIf

//Se número de vidas for igual ao número de não permitidos, significa que ninguém da família tem acesso ao reembolso, logo, bloquea a página
//Se for diferente, pelo menos um pode solicitar reembolso e o acesso deve ser liberado.
IF (nVidas <> nPermt)
	lRet 		:= .T.
ENDIF

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSCMPB1N
Completa a gravação dos itens do reembolso pelo portal (B1N)
@author Oscar Zanin
@since 20/10/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSCMPB1N(cProtoc, cMatric, cCodRef, cNomRede, cTipDoc, cNumDoc, cDatDoc, lInsDB1N, cAtuB1N)
Local cRet := "false|"
Local lRet := .T.
Local nVlrApr	:= 0
Local nValMin	:= 0
Local cSeq 	:= "000"
Local dDatDoc	:= CtoD(cDatDoc)
Default lInsDB1N	:= .F.

//Somamos os valores dos procedimentos
B1N->(DbSelectArea("B1N"))
B1N->(DbSetOrder(2))
If (B1N->(MsSeek(xFilial("B1N") + cProtoc)))
	While ( !B1N->(EOF()) .AND. B1N->B1N_FILIAL == xFilial("B1N") .AND. B1N->B1N_PROTOC == cProtoc)
		if B1N->(FieldPos("B1N_VLRTOT")) > 0
			nVlrApr := nVlrApr + B1N->B1N_VLRTOT
		else
			nVlrApr := nVlrApr + (B1N->B1N_VLRAPR * B1N->B1N_QTDPRO)
		endIf
		B1N->(DbSkip())
	EndDo
EndIF

BA3->(DbSelectArea("BA3"))
BA3->(DbSetOrder(1))
If (BA3->(MsSeek(xFilial("BA3") + Left( cMatric, 14))))
	// ***************** Verifica valor minimo para solicitação de reembolso cadastrado no produto
	nValMin := BI3->BI3_VMIRMB
	If nVlrApr < nValMin // nao atingiu o valor necessário para solicitar o reembolso
		cRet := "false|Valor minimo [ " + Alltrim(Str(nValMin)) + " ] para solicitação de reembolso não atingido!"
		lRet := .F.
	EndIf
else
	lRet := .F.
EndIf
BA3->(DbCloseArea())




If lRet
	
	
	cRet := "true|Solicitação Enviada com sucesso! Seu número de protocolo é: " + BOW->BOW_PROTOC
EndIf
B1N->(DbcloseArea())

Return {cRet, nVlrApr}


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PlsGrvB1N 	³Autor  ³ Tabosa 	            ³ Data ³06.03.2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Grava os itens do protocolo de reembolso na B1N              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//Esta função era Static no fonte WSPLSXFUN, foi movida para cá e alterada para Function
Function PlsGrvB1N(cProt,oItens,aMatUsu,lInsDB1N,cCodInt,cCodRDA,cCodEsp,cTipPreFor,cRegExe,cEstExe,cCdPfRe,cCodLoc,cUFAte,cMunAte)
LOCAL aArea 	:= GetArea()
LOCAL nI 		:= 0
LOCAL cCodPad	:= GETMV("MV_PLSTBPD")
LOCAL cSeq		:= "000"
LOCAL cNomRef
Default lInsDB1N	:= .F.
Default cCodInt		:= ""
Default cCodRDA		:= ""
Default cCodEsp		:= ""
Default cTipPreFor	:= ""
Default cRegExe		:= ""
Default cEstExe		:= ""
Default cCdPfRe		:= ""
Default cCodLoc		:= ""
Default cUFAte		:= ""
Default cMunAte		:= ""

For nI := 1 To Len(oItens:LISTDESP)
	If Empty(oItens:LISTDESP[nI]:CODPAD)
		/* ==========================================================================================
		Busca o CODPAD do item (é feito dessa forma pois são configurados apenas procedimentos
		genericos para o Beneficiario, pois o mesmo nao precisa ver a tabela padrao dessa forma
		se faz necessário que seja trocado pelo procedimento correto pelo usuario da operadora
		que receber o reembolso, colocando assim o CODPAD e CODPSA correto daquele serviço
		========================================================================================== */
		BR8->(DbSetOrder(3))
		If BR8->(MsSeek(xFilial("BR8") + oItens:LISTDESP[nI]:CODPRO))
			cCodPad := BR8->BR8_CODPAD
		EndIf
	EndIf
	
	cSeq    := Soma1(cSeq)
	cNomRef := Posicione("BK6",4,xFilial("BK6")+ STRTRAN(STRTRAN(AllTrim(oItens:LISTDESP[nI]:CODRDA), "/", ""),".","") ,"BK6->BK6_NOME")
	
	B1N->(RecLock("B1N", .T.))
	B1N->B1N_FILIAL := xFilial("B1N")
	B1N->B1N_PROTOC := cProt
	B1N->B1N_CODPAD := cCodPad
	B1N->B1N_CODPRO := oItens:LISTDESP[nI]:CODPRO
	B1N->B1N_VLRAPR := Val(Alltrim(StrTran(StrTran(oItens:LISTDESP[nI]:VLRPRO, ".", ""),",",".")))
	B1N->B1N_CODREF := oItens:LISTDESP[nI]:CODRDA
	B1N->B1N_NOMREF := cNomRef
	B1N->B1N_USOCON := IIf(Alltrim(oItens:LISTDESP[nI]:USOC) == "S", "1", "0")
	B1N->B1N_TIPDOC := oItens:LISTDESP[nI]:TIPDOC
	B1N->B1N_NUMDOC := oItens:LISTDESP[nI]:NRODOC
	B1N->B1N_DATDOC := oItens:LISTDESP[nI]:DATDOC
	B1N->B1N_SEQUEN := cSeq
	B1N->B1N_QTDPRO := Val(oItens:LISTDESP[nI]:QTDPRO)
	B1N->B1N_QTDMED := Val(oItens:LISTDESP[nI]:QTDPRO)
	B1N->B1N_PROORI := oItens:LISTDESP[nI]:CODPRO
	B1N->B1N_EST	    := oItens:LISTDESP[nI]:ESTD
	B1N->B1N_CODMUN := oItens:LISTDESP[nI]:CODMUN
	B1N->B1N_DESMUN := Posicione("BID",1,xFilial("BID")+oItens:LISTDESP[nI]:CODMUN,"BID_DESCRI")
	B1N->B1N_MATRIC := aMatUsu[1]
	B1N->B1N_IMGSTA := "ENABLE"
	IF (lInsDB1N)
		B1N->B1N_PRCNPJ := oItens:LISTDESP[nI]:CODRDA
		B1N->B1N_PRNOME := oItens:LISTDESP[nI]:NOMRDA
		B1N->B1N_CODREF := ""//oItens:LISTDESP[nI]:CODRDA
		B1N->B1N_NOMREF := ""//cNomRef
	ENDIF
	B1N->B1N_DATPRO := oItens:LISTDESP[nI]:DATDOC
	B1N->(MsUnlock())
	PLSA001AGAT(cProt,cCodPad,oItens:LISTDESP[nI]:CODPRO,cCodInt ,cCodRDA ,cCodEsp ,cTipPreFor,cRegExe ,cEstExe ,cCdPfRe ,cCodLoc ,cUFAte ,cMunAte,Val(oItens:LISTDESP[nI]:QTDPRO),oItens:LISTDESP[nI]:DATDOC,.T.)
	
Next nI

RestArea(aArea)
Return()


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PlsIncBK6 	³Autor  ³ Tabosa 	            ³ Data ³06.03.2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Inclui rede de atendimento nao referenciada informada pelo	  ³±±
±±³          ³beneficiario no portal do beneficiario							  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//Esta função era Static no fonte WSPLSXFUN, foi movida para cá e alterada para Function
Function PlsIncBK6(cNome, cCpfCnpj, cUf, cCidade)

LOCAL aArea := GetArea()
LOCAL nI
LOCAL nRDA
LOCAL aRDA := separa(cCpfCnpj)
LOCAl aNomRDA := separa(cNome)
LOCAL aRet :={}

Default cUf		:= ""
Default cCidade	:= ""

nRDA := LEN(aRDA)
BK6->(DbSetOrder(4))
For nI := 1 To nRDA
	If !BK6->(MsSeek(xFilial("BK6") + aRDA[nI]))
		BK6->(RecLock("BK6", .T.))
			BK6->BK6_FILIAL := xFilial("BK6")
			BK6->BK6_CODIGO := (cCodigo := GETSX8Num("BK6", "BK6_CODIGO"))
			BK6->BK6_CGC    := aRDA[nI]
			BK6->BK6_NOME   := aNomRDA[nI]
			BK6->BK6_ESTCR  := cUf
			BK6->BK6_MUNCR  := cCidade	
		BK6->(MsUnlock())
		AADD(aRet, {aRDA[nI], aNomRDA[nI]})
	EndIf
	ConfirmSX8()
Next
RestArea(aArea)

Return aRet
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PLSREEMBIT³Autor  ³Karine Riquena Limp    ³ Data ³14.10.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Gravação do item do reembolso                                ³±±
±±³          ³beneficiario no portal do beneficiario                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
function PLSREEMBIT(lBOW, lB1N, cCodSol, oItemReemb, cRecB1N, cMatric, lCabAlt, cRecDivs, cCdOrigem) 
Local aAreaBA1		:= BA1->(GetArea())
local cProtoc 		:= cCodSol
local lBK6 			:= .F.
local cSql 			:= ""
local nVlrTot 		:= 0
local cSeq 			:= ""
local nVlrB1N 		:= 0
local aRetCri	   		:= {} 

default lCabAlt 		:= .F.
default cRecDivs 		:= ""
default cCdOrigem 	:= "00" //Origem não identificada 

BA1->(DbSetOrder(2))
BA1->(MsSeek(xFilial("BA1") + cMatric))

Begin Transaction	
	IIF(SELECT("BAU") == 0, CHKFILE("BAU"), )	//	Seleciona a "BAU" para evitar erro no POSICIONE
	IIF(SELECT("BK6") == 0, CHKFILE("BK6"), )	//	Seleciona a "BK6" para evitar erro no POSICIONE
	oItemReemb:CPFCNPJ := StrTran(StrTran(StrTran(oItemReemb:CPFCNPJ, ".", ""), "-", ""), "/", "")
	BK6->(DbSetOrder(4)) //Ordena por CPF/CNPJ
	lBK6 := BK6->(MsSeek(xFilial("BK6") + oItemReemb:CPFCNPJ))
	if lBOW
		RecLock("BOW", .T.)
			BOW->BOW_FILIAL := xFilial("BOW")
			BOW->BOW_TIPPAC := getNewPar("MV_PLSTPAA", "1")
			BOW->BOW_PROTOC := cProtoc := P773GerPro() //getSxEnum("BOW", "BOW_PROTOC")
			BOW->BOW_STATUS := "A"
			BOW->BOW_DTDIGI := dDataBase
			BOW->BOW_USUARI := cMatric
			BOW->BOW_OPEUSR := BA1->BA1_CODINT
			BOW->BOW_NOMUSR := BA1->BA1_NOMUSR
			BOW->BOW_MATANT := BA1->BA1_MATANT
			BOW->BOW_NOMRDA := POSICIONE("BAU", 1, xFilial("BAU") + GetNewPar("MV_PLSRDAG", "999999"), "BAU_NOME")
			BOW->BOW_CODRDA := BAU->BAU_CODIGO
			BOW->BOW_OPEMOV := PLSINTPAD() 
			if lBK6 .And. FunName()!= "RPC"
				BOW->BOW_NOMREF := BK6->BK6_NOME
				BOW->BOW_ENDLOC := BK6->BK6_ENDER
				BOW->BOW_SIGLA  := BK6->BK6_SIGLA
				BOW->BOW_CODREF := BK6->BK6_CGC
				BOW->BOW_UFATE  := BK6->BK6_ESTCR
				BOW->BOW_MUNATE := BK6->BK6_MUNCR
			else
				BOW->BOW_NOMREF 	:= oItemReemb:NomRDA
				BOW->BOW_CODREF 	:= oItemReemb:CPFCNPJ
				BOW->BOW_UFATE	:= oItemReemb:Uf
				BOW->BOW_MUNATE  	:= oItemReemb:Cidade
				BOW->BOW_DESMUN	:= PLRTDMRMGR(oItemReemb:Cidade)
			endIf
			BOW->BOW_DATPAG := oItemReemb:DATDOC
			BOW->BOW_VLRAPR := Val(oItemReemb:VLRPRO) / 100 //	O valor vai chegar sem o separador decimal, aqui garantimos que grave certo sempre..
			
			If BOW->(FieldPos("BOW_ORIGEM")) > 0
				BOW->BOW_ORIGEM := cCdOrigem 
			EndIf
			
		BOW->(MsUnLock())
		
		//Gravacao da tabela B00 - Registro de Protocolo de Atendimento	
		gerRegB00(BOW->BOW_PROTOC,,'BOW',.T.,.F.,BOW->(BOW_USUARI),,,,,,,,,,,,,,.T.)
	else
		BOW->(DbSetOrder(1))
		BOW->(MsSeek(xFilial("BOW")+cCodSol))	
	endIf
	
	if !lB1N
		B1N->(dbGoto(Val(cRecB1N)))
		
		if B1N->(FieldPos("B1N_VLRTOT")) > 0
			nVlrB1N := B1N->B1N_VLRTOT 
		else
			nVlrB1N := B1N->B1N_VLRAPR
		endIf
		 
	endif
	
	IF ALLTRIM(BK6->BK6_CGC) <> ALLTRIM(oItemReemb:CPFCNPJ) 	//	Ocorre se a RDA N.Ref. Não estiver selecionada
		BK6->(DBSETORDER(4))
		BK6->(DBSEEK(xFilial("BK6") + oItemReemb:CPFCNPJ))
	ENDIF
	
	RecLock("B1N", lB1N)
		B1N->B1N_FILIAL := xFilial("B1N")
		B1N->B1N_IMGSTA := "ENABLE"
		B1N->B1N_PROTOC := cProtoc
		B1N->B1N_CODPAD := IIf(!EMPTY(oItemReemb:CODPAD), oItemReemb:CODPAD, Posicione("BR8", 3, xFilial("BR8") + oItemReemb:CODPRO, "BR8_CODPAD"))
		B1N->B1N_CODPRO := oItemReemb:CODPRO
		B1N->B1N_USOCON := oItemReemb:USOC
		B1N->B1N_QTDPRO := Val(oItemReemb:QTDPRO)
		B1N->B1N_QTDMED := Val(oItemReemb:QTDPRO)
		if B1N->(FieldPos("B1N_VLRTOT")) > 0
			B1N->B1N_VLRTOT := Val(oItemReemb:VLRPRO) / 100 //	O valor vai chegar sem o separador decimal, aqui garantimos que grave certo sempre..
			B1N->B1N_VLRAPR := B1N->B1N_VLRTOT / B1N->B1N_QTDPRO 
		else
			B1N->B1N_VLRAPR := Val(oItemReemb:VLRPRO) / 100
		endIf
		
		if(lB1N)
			if !lBOW
				cSql := "SELECT MAX(B1N_SEQUEN) AS MAXSEQ, SUM(" + iif(B1N->(FIELDPOS("B1N_VLRTOT")) > 0, "B1N_VLRTOT", "B1N_VLRAPR") + ") AS VLRTOT FROM " + RetSqlName("B1N") + " WHERE B1N_PROTOC ='" + cProtoc + "' AND D_E_L_E_T_ = ' ' " 												
			else
				cSql := "SELECT SUM(" + iif(B1N->(FIELDPOS("B1N_VLRTOT")) > 0, "B1N_VLRTOT", "B1N_VLRAPR") + ") AS VLRTOT FROM " + RetSqlName("B1N") + " WHERE B1N_PROTOC ='" + cProtoc + "' AND D_E_L_E_T_ = ' ' " 												
			endIf		
			
			cSql := ChangeQuery(cSql)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"MAXSEQB1N",.T.,.F.)	
			
			cSeq := "001"
			
			if MAXSEQB1N->(!EOF())
				
				if !lBOW
					cSeq := Soma1(MAXSEQB1N->MAXSEQ)
				endIf
				
				nVlrTot := MAXSEQB1N->VLRTOT		
						
			endIf
			
			B1N->B1N_SEQUEN := cSeq
			
			MAXSEQB1N->(dbclosearea())
		
		else
		
			cSql := "SELECT SUM(" + iif(B1N->(FIELDPOS("B1N_VLRTOT")) > 0, "B1N_VLRTOT", "B1N_VLRAPR") + ") AS VLRTOT FROM " + RetSqlName("B1N") + " WHERE B1N_PROTOC ='" + cProtoc + "'"													
			
			cSql := ChangeQuery(cSql)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"MAXSEQB1N",.T.,.F.)	
			
			
			if MAXSEQB1N->(!EOF())
								
				nVlrTot := MAXSEQB1N->VLRTOT		
						
			endIf
						
			MAXSEQB1N->(dbclosearea())
			
		endIf
		
		B1N->B1N_PROORI := oItemReemb:CODPRO
		B1N->B1N_MATRIC := oItemReemb:MATRIC
		B1N->B1N_CODREC := oItemReemb:CODREC
		B1N->B1N_CODMED := oItemReemb:CODMED
		B1N->B1N_SEQMED := oItemReemb:SEQMED
		B1N->B1N_TIPSER := oItemReemb:TIPSER
		B1N->B1N_TIPDOC := oItemReemb:TIPDOC
		B1N->B1N_NUMDOC := oItemReemb:NRODOC
		B1N->B1N_DATDOC := B1N->B1N_DATPRO := oItemReemb:DATDOC
		B1N->B1N_PRNOME := oItemReemb:NOMRDA
		B1N->B1N_PRCNPJ := oItemReemb:CPFCNPJ
		if lBK6 .And. FunName()!= "RPC"
			B1N->B1N_EST    := BK6->BK6_ESTCR
			B1N->B1N_CODMUN := BK6->BK6_MUNCR
			B1N->B1N_SIGLA  := BK6->BK6_SIGLA
			B1N->B1N_DESMUN := Posicione("BID", 1, xFilial("BID") + B1N->B1N_CODMUN, "BID_DESCRI")
			B1N->B1N_CODREF := BK6->BK6_CGC
			B1N->B1N_NOMREF := BK6->BK6_NOME
		else
			B1N->B1N_EST    :=  oItemReemb:UF
			B1N->B1N_CODMUN :=  oItemReemb:Cidade
			B1N->B1N_DESMUN := PLRTDMRMGR(oItemReemb:Cidade)
			//OBS: Tivemos que colocar para gravar aqui o CNPJ e Nome RDA conforme cadastro, pois caso seja utilizada inclusão direta da BK6
			//estes campos ficam vazios e no relatório não sai o nome e CNPJ da Rede, pois não existe análise.
			B1N->B1N_CODREF :=  oItemReemb:CPFCNPJ
			B1N->B1N_NOMREF :=  oItemReemb:NOMRDA
		endIf
	B1N->(MsUnLock())
	
	BOW->(RecLock("BOW", .F.))
		BOW->BOW_VLRAPR := nVlrTot
	BOW->(msUnlock())	
	
	//se o cabeçalho foi alterado
	if lCabAlt .AND. !lBOW .AND. (!empty(cRecDivs) .Or. cRecDivs == "0")
		
		PLSUPDB1N(cCodSol, oItemReemb:CPFCNPJ, oItemReemb:NOMRDA, oItemReemb:TIPDOC, oItemReemb:NRODOC, oItemReemb:DATDOC, cRecDivs, oItemReemb:UF, oItemReemb:CIDADE)
		
	endIf
	
	if PLBCTREE() 
		aRetCri := PLCRITREE(B1N->(Recno()))
	endIf
	
	B1N->(Reclock("B1N", .F.)) 
		B1N->B1N_IMGSTA = IIF(len(aRetCri) > 0, "DISABLE", "ENABLE")
	B1N->(MsUnLock())
	
	BA1->(DbSetOrder(2))
	If BA1->(msSeek(xFilial("BA1") + cMatric))
		
		PLGRVBOX(BOW->BOW_PROTOC, BA1->BA1_MATRIC, BOW->BOW_STATUS,,,,,,,,, IIF(cCdOrigem == "01",.T.,.F. ) )	//	Grava Histórico de alteração do reembolso 
	EndIf
End Transaction

cRecB1N := Alltrim(Str(B1N->(RECNO())))

restArea(aAreaBA1)

return({ cProtoc + "|" + cRecB1N, aRetCri }) 

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSUPDB1N
Atualiza B1N quando o beneficiário alterar o cabeçalho do reembolso
@author Karine Riquena Limp
@since 27/09/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PLSUPDB1N(cCodSol, cCPFCNPJ, cNomRdaNRef, cTipDoc, cNumDoc, dDtEmi,cRecDivs,cUF,cCidade)
local aAreaBOW := BOW->(getArea())
local aAreaB1N := B1N->(getArea())
local aAreaBK6 := BK6->(getArea())
local lBK6 := .F.
local cRecB1N := ""

	BOW->(DbSetOrder(1))
	BOW->(MsSeek(xFilial("BOW")+cCodSol))	

	BK6->(DbSetOrder(4)) //Ordena por CPF/CNPJ
	lBK6 := BK6->(MsSeek(xFilial("BK6") + cCPFCNPJ))

	BOW->(RecLock("BOW", .F.))
					
			if lBK6
				BOW->BOW_NOMREF := BK6->BK6_NOME
				BOW->BOW_ENDLOC := BK6->BK6_ENDER
				BOW->BOW_SIGLA  := BK6->BK6_SIGLA
				BOW->BOW_CODREF := BK6->BK6_CGC
				BOW->BOW_UFATE  := BK6->BK6_ESTCR
				BOW->BOW_MUNATE := BK6->BK6_MUNCR
			else
				BOW->BOW_NOMREF := cNomRdaNRef
				BOW->BOW_CODREF := cCPFCNPJ
				BOW->BOW_UFATE  := cUF
				BOW->BOW_MUNATE := cCidade
			endIf
			
			BOW->BOW_DATPAG := dDtEmi
						
		BOW->(msUnlock())
		
	B1N->(dbSetOrder(1))
	B1N->(MsSeek(xFilial("B1N")+cCodSol))
	
	While !B1N->(Eof()) .and. (B1N->(B1N_FILIAL+B1N_PROTOC) == xFilial("B1N")+cCodSol)
		
		cRecB1N := alltrim(str(B1N->(RECNO())))
		if(empty(cRecDivs) .OR. (!empty(cRecDivs) .and. (cRecB1N $ cRecDivs)))
			
			B1N->(RecLock("B1N", .F.))
		
				B1N->B1N_TIPDOC := cTipDoc
				B1N->B1N_NUMDOC := cNumDoc
				B1N->B1N_DATDOC := B1N->B1N_DATPRO := dDtEmi
				B1N->B1N_PRNOME := cNomRdaNRef
				B1N->B1N_PRCNPJ := cCPFCNPJ 
				
				if lBK6
					B1N->B1N_EST    := BK6->BK6_ESTCR
					B1N->B1N_CODMUN := BK6->BK6_MUNCR
					B1N->B1N_SIGLA  := BK6->BK6_SIGLA
					B1N->B1N_DESMUN := Posicione("BID", 1, xFilial("BID") + B1N->B1N_CODMUN, "BID_DESCRI")
				else					
					B1N->B1N_EST    :=  cUF
					B1N->B1N_CODMUN :=  cCidade
				endIf	
		
			B1N->(msUnlock())
					
		endIf
		
		B1N->(dbSkip())
	
	EndDo
	
	restArea(aAreaBOW)	
	restArea(aAreaB1N)
	restArea(aAreaBK6)
	
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSBJECHK
Verifica se o tipo do serviço é medicamento
@author Oscar Zanin
@since 20/10/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSBJECHK(cTipSer)

Local cRet := "0"

BJE->(DbSelectArea("BJE"))
BJE->(DbSetOrder(1))
If (BJE->(MsSeek(xFilial("BJE")+cTipSer)))
	If !(Vazio(AllTrim(BJE->(BJE_ISMEDI))))
		cRet := "1"
	else
		cRet := "0"
	EndIf
EndIf

BJE->(DbCloseArea())

Return cRet
//-------------------------------------------------------------------
/*/{Protheus.doc} PLCHKDUPRE
Verifica se o item já existe na base de dados
@author Karine Riquena Limp
@since 19/04/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PLCHKDUPRE(oItemReemb, lDocObr, lWeb, cTipDoc, cCpfCnpj, cMatric, cCodPad, cCodPro, cNumDoc, cDatDoc, cVlrDoc, cCodRef)

local lRet       := .T.
local cSql       := ""
local cNumProt   := ""
local cProc 	   := ""
Local lVlrTot    := B1N->(FieldPos("B1N_VLRTOT")) > 0 
Local cCgc 	   := ""
Local cMsgDup	:= "" 
Default lWeb     := .T.
Default cTipDoc  := ""
Default cMatric  := ""
Default cCodPad  := ""
Default cCodPro  := ""
Default cCpfCnpj := ""
Default cNumDoc  := ""
Default cCodRef  := ""

//Verifica se existe BK6 para esse CPF/CNPJ pois, se existir, o sistema deve validar tanto pelo cnpj quando pela refe referenciada 
if !empty(cCpfCnpj)

	BK6->(DbSetOrder(4)) //Ordena por CPF/CNPJ
	
	cCgc := iif(lWeb, StrTran(StrTran(StrTran(oItemReemb:CPFCNPJ,".",""),"-",""),"/",""),  cCpfCnpj)
	//Busca na BK6 se o código existe e define a chave de busca para a BAU
	If BK6->(MsSeek(xFilial("BK6") + AllTrim(cCgc)))
		cCodRef := BK6->BK6_CGC
	EndIf
	
elseif !empty(cCodRef)

	BK6->(DbSetOrder(3)) //Ordena por codigo
	If BK6->(MsSeek(xFilial("BK6") + AllTrim(cCodRef)))
		cCpfCnpj := BK6->BK6_CGC
	EndIf
	
ElseIf lWeb .And. !Empty(oItemReemb:CPFCNPJ)

	BK6->(DbSetOrder(4)) //Ordena por CPF/CNPJ
	
	cCgc := iif(lWeb, StrTran(StrTran(StrTran(oItemReemb:CPFCNPJ,".",""),"-",""),"/",""),  cCpfCnpj)
	//Busca na BK6 se o código existe e define a chave de busca para a BAU
	If BK6->(MsSeek(xFilial("BK6") + AllTrim(cCgc)))
		cCodRef := BK6->BK6_CGC//BK6->BK6_CODIGO 
	EndIf
	
endIf

If lWeb
	cTipDoc	:= oItemReemb:TipDoc
	cCpfCnpj:= StrTran(StrTran(StrTran(oItemReemb:CPFCNPJ,".",""),"-",""),"/","")
	cMatric	:= oItemReemb:MATRIC
	cCodPad	:= oItemReemb:CODPAD
	cCodPro	:= oItemReemb:CODPRO
	cDatDoc	:= dtos(oItemReemb:DatDoc)
	cVlrDoc	:= str(val(oItemReemb:VLRPRO)/100)
	cNumDoc	:= oItemReemb:NroDoc
Else
	//Quando é portal, a variável lDocObr já vem preenchida
	//Realizar um seek na BBS pra verificar se o documento é obrigatório
	BBS->(DbSetOrder(2))
	If BBS->(DbSeek(xFilial("BBS")+cTipDoc))
		If BBS->BBS_OBRIGA == "1"
			lDocObr := "true"
		EndIf	
	EndIf
EndIf

//verifica se tem algum item igual na tela primeiro do remote
if !lWeb

	lRet := PLCHKDUBRW(cTipDoc, cCpfCnpj, cMatric, cCodPad, cCodPro, cNumDoc, cDatDoc, cVlrDoc, cCodRef)
	if !lRet
		MsgAlert("Este evento já foi informado!", "Atenção")
		Return lRet
	endIf
		
endIf

if lRet

	cSql := "SELECT B1N_PROTOC, B1N_CODPAD, B1N_CODPRO FROM " + retSqlName("B1N") + " B1N "
	cSql += " INNER JOIN " + retSqlName("BOW") + " BOW "
	cSql +=    " ON ( ( B1N.B1N_FILIAL || B1N.B1N_PROTOC ) = ( BOW.BOW_FILIAL || BOW.BOW_PROTOC ) )"
	cSql += " WHERE B1N.B1N_FILIAL = '" + xFilial("B1N") + "' "
	cSql +=   " AND BOW.BOW_FILIAL = '" + xFilial("BOW") + "' "
	cSql +=   " AND B1N.D_E_L_E_T_ = '' "
	cSql +=   " AND BOW.D_E_L_E_T_ = '' "
	cSql +=   " AND BOW.BOW_STATUS NOT IN ('A', 'D', '4') "
	cSql +=   " AND B1N.B1N_TIPDOC = '" + cTipDoc  + "' "
	cSql +=   " AND (B1N.B1N_PRCNPJ = '" + cCpfCnpj + "' "
	cSql +=   iif(!empty(cCodRef), " OR B1N.B1N_CODREF = '" + cCodRef + "'" , "") + ")"
	cSql +=   " AND B1N.B1N_MATRIC = '" + cMatric  + "' "
	cSql +=   " AND B1N.B1N_CODPAD = '" + cCodPad  + "' "
	cSql +=   " AND B1N.B1N_CODPRO = '" + cCodPro  + "' "
	cSql +=   " AND B1N.B1N_IMGSTA <> 'DISABLE' "
	cSql +=   " AND B1N.B1N_DATDOC = '" + cDatDoc + "' "
	
	
	If(lDocObr == "true")
		cSql += " AND B1N.B1N_NUMDOC = '" + cNumDoc + "' "
	Else
		
		if lVlrTot
			cSql += " AND B1N.B1N_VLRTOT = " + cVlrDoc
		else
			cSql += " AND B1N.B1N_VLRAPR = " + cVlrDoc
		endIf
	EndIf
	
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"ALIASB1N",.T.,.F.)
	if !ALIASB1N->( Eof() ) .AND. ALIASB1N->B1N_PROTOC <> M->B1N_PROTOC
		lRet := .F.
		cNumProt := ALIASB1N->B1N_PROTOC
		cProc	  := Posicione("BR8",1,xFilial("BR8")+ALIASB1N->(B1N_CODPAD+B1N_CODPRO),"BR8_DESCRI")
	
		cMsgDup := STR0018 + cNumProt + "." //"Este evento foi solicitado no protocolo de número "

	endIf
	ALIASB1N->(dbCloseArea())

endIf

//ponto de entrada criado para verificar se irá criticar um item duplicado ou não
If ExistBlock("PLRMBDUPL")
	lRet := ExecBlock("PLRMBDUPL",.F.,.F.,{lRet, cTipDoc, cCpfCnpj, cMatric, cCodPad, cCodPro, cNumDoc, cDatDoc, cVlrDoc })
EndIf

If !lWeb .And. !lRet
	MsgAlert(cMsgDup, STR0013) //"Atenção"
EndIf

Return If(lWeb,{lRet, cNumProt, cProc}, lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLRTDMRMGR
Verifica se o item já existe na base de dados
@author Karine Riquena Limp
@since 19/04/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PLRTDMRMGR(cCodMun)
Local aAreaBID	:= BID->(GetArea())
Local cDescMun	:= ""

Default cCodMun 	:= ""

BID->(DbSetOrder(1)) //Filial + Cod. Mun
If ( Empty(cCodMun) )
	cDescMun := "-"
Elseif ( BID->(MsSeek(xFilial("BID")+cCodMun)))
	cDescMun := BID->BID_DESCRI
Else
	cDescMun := "-"
EndIf

RestArea(aAreaBID)

Return cDescMun

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSRCRNRF
Quando reembolso Multicomprovante, é necessário percorrer os dados da B1N para montar os dados das redes, pois podemos 
ter várias redes diferents em um mesmo protocolo
@author Renan Martins
@since 01/2017
@version P12
/*/
//-------------------------------------------------------------------
Function PLSRCRNRF(cCodSol)
Local aArea 		:= B1N->(GetArea())
Local aArea2		:= BOW->(GetArea()) 
Local aDadPres	:= {}
Local cCnpjF		:= ""
Local aBowCn		:= ""

B1N->(DbGoTop())
B1N->(DbSetOrder(1))
B1N->(MsSeek(xFilial("B1N") + cCodSol))
	While( !B1N->(EoF()) .and. B1N->B1N_FILIAL == xFilial("B1N") .AND. B1N->B1N_PROTOC == cCodSol) 
		cCnpjF := B1N->B1N_PRCNPJ
		If ( Ascan(aDadPres,{|y| y[2] == cCnpjF} ) == 0 )
			aAdd(aDadPres, {B1N->B1N_PRNOME, B1N->B1N_PRCNPJ, B1N->B1N_EST, B1N->B1N_CODMUN})
		EndIf
		B1N->(DbSkip())	
	EndDo
BOW->(DbSetorder(1))			
If (BOW->(MsSeek(xFilial("BOW")+cCodSol)))
	aBowCn := {BOW->BOW_CODREF, BOW->BOW_NOMREF, BOW->BOW_UFATE, BOW->BOW_MUNATE}
EndIf	

RestArea(aArea)
RestArea(aArea2)
Return {aDadPres, aBowCn}

//-------------------------------------------------------------------
/*/{Protheus.doc} PLCRITREE
Verifica criticas reembolso
@author Karine Riquena Limp
@since 19/04/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PLCRITREE(nRecnoB1N) //23-01-2017
local aDadUsr  := {}
local cMatric  := ""
local cCodInt  := PLSINTPAD()
local aCriticas := {}
local nI		 := 1
B1N->(dbGoto(nRecnoB1N))

BOW->(DbSetOrder(1))
BOW->(MsSeek(xFilial("BOW")+B1N->B1N_PROTOC))

aDadUsr := PLSDADUSR(B1N->B1N_MATRIC,'1',.F.,dDatabase,,,"NAO_VALIDAR_CARTAO")
cMatric := AllTrim(B1N->B1N_MATRIC)

aRetFun := PLSAUTP(;
			B1N->B1N_DATPRO,;
			nil,;
			B1N->B1N_CODPAD,;
			B1N->B1N_CODPRO,;
			B1N->B1N_QTDPRO,;
			aDadUsr,;
			0,;
			{},;
			"1",;
			.F.,;
			nil,;
			.T.,;
			"1",;
			.T.,;
			nil,;
			nil,;
			nil,;
			nil,;
			"",;
			"",;
			"2",;
			.T.,;
			nil,;
			nil,;
			nil,;
			nil,;
			nil,;
			nil,;
			nil,;
			nil,;
			B1N->B1N_SEQUEN,;
			nil,;
			.F.,; 
			"1",;
			nil,;
			NIL,;
			NIL,;
			BOW->BOW_TIPPRE,;
			"",;
			nil,nil,nil,nil,nil,nil,nil,nil,;
			.T.,;
			nil,;
			.F.,; 
			nil,nil,nil,nil,nil,nil,;
			.T.,;
			,nil,nil,;
			"",;
			nil,;
			.F.,;
			.F.,;
			nil,nil,nil,nil,nil,nil,nil,nil,nil,;
			'04')
	
	if !aRetFun[1]
		
		BCT->(dbSetOrder(1))
		for nI := 1 to len(aRetFun[2])
			
			If At('nível',Lower(aRetFun[2,nI,2])) > 0
				Loop
			EndIf
			
			BCT->(dbGotop())
			if BCT->(msSeek(xFilial("BCT")+cCodInt+aRetFun[2,nI,1])) .and. BCT->BCT_VALREE
				aAdd(aCriticas, {aRetFun[2,nI,1], alltrim(aRetFun[2,nI,2])})
			endIf
			
		next nI
	
	endIf
			
Return aCriticas
//-------------------------------------------------------------------
/*/{Protheus.doc} PLBCTREE
Verifica se existe alguma crítica que valida no reembolso
@author Karine Riquena Limp
@since 19/04/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PLBCTREE()

local lRet       := .F.
local cSql       := ""
local cBCT		   := retSqlName("BCT")

If BCT->(FieldPos("BCT_VALREE")) > 0

	cSql := "SELECT BCT_CODGLO, BCT_DESCRI FROM " + cBCT + " BCT "
	cSql += " WHERE BCT.BCT_FILIAL = '" + xFilial("BCT") + "' "
	cSql +=   " AND BCT.BCT_CODOPE = '" + PLSINTPAD() +  "' "
	cSql +=   " AND BCT.BCT_VALREE = 'T' "
	cSql +=   " AND BCT.D_E_L_E_T_ = ' ' "
	
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"BCTREE",.T.,.F.)
	lRet := !BCTREE->( Eof() )
	
	BCTREE->(dbCloseArea())
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLDELITEM
Deleta os itens que foram negados por crítica
@author Thiago Ribas
@since 28/12/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PLDELITEM(cProtoc) 

LOCAL aRet := {}
LOCAL lDel := .F.
local nVlrNeg := 0
local lMultCom := GetNewPar("MV_PLREEMC", .F.)
DEFAULT cProtoc := ""

B1N->(dbSetOrder(6))
If B1N->(MsSeek(xFilial("B1N") + cProtoc + "DISABLE"))

	While B1N->B1N_FILIAL + B1N->B1N_PROTOC + B1N->B1N_IMGSTA == xFilial("B1N") + cProtoc + "DISABLE"
		
		lDel := .T.

		if (lMultCom)
			nVlrNeg += B1N->B1N_VLRAPR
		EndIf
		
		B1N->(RecLock("B1N", .F.))
		B1N->(DbDelete())
		B1N->(MsUnlock())
		
		B1N->(dbSkip())
	EndDo
	
	B1N->(dbSetOrder(1))
	If B1N->(MsSeek(xFilial("B1N") + cProtoc))
		aRet := {.T.,lDel}	
	Else
		aRet := {.F.,lDel}
	EndIf
	
	BOW->(dbSetOrder(1))
	If (BOW->(MsSeek(xFilial("BOW") + cProtoc)) .AND. lMultCom)
		BOW->(RecLock("BOW", .F.))
		BOW->BOW_VLRAPR := BOW->BOW_VLRAPR - nVlrNeg
		BOW->(MsUnlock())
	EndIf
Else
	aRet := {.T.,lDel}	
EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLGRGUIREE
Gera guia de reembolso utilizando classes após inclusão no portal.
@author Rodrigo Morgon
@since 23/11/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PLGRGUIREE(aDados, aItens, lTratStatus)
Local objCtrlGuia:= NIL
Local aCriticas	:= {}
Local oObjGui	:= nil
Local nPos		:= 0
Local cProtoc   := PLSRETDAD( aDados,"PROTOC","" )
Local cMatAnt   := ''
Local cNomBen   := ''
Local cMatric   := ''
Local cStatus   := ''

Default lTratStatus := .F.
Default aItens := {}


if len(aItens) == 0
	//Carrega aItens de acordo com o protocolo passado no cabeçalho
	B1N->(DbSetOrder(2))
	If (B1N->(MsSeek(xFilial("B1N")+cProtoc)))
	
		While ((!B1N->(EOF())) .AND. B1N->B1N_FILIAL == xFilial("B1N") .AND. B1N->B1N_PROTOC == cProtoc)
		
			BA1->( DbSetOrder(2) ) //BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO             		
			If BA1->( MsSeek( xFilial("BA1")+B1N->B1N_MATRIC ) )
				cMatAnt :=BA1->BA1_MATANT
				cNomBen := BA1->BA1_NOMUSR
				cMatric :=BA1->BA1_MATRIC
			Endif
		
			if lTratStatus
				if AllTrim(B1N->B1N_IMGSTA) == 'DISABLE'
					cStatus := '0'
				else
					cStatus := '1'
				endif
			endif
		
			AaDd( aItens, {{ "SEQMOV", B1N->B1N_SEQUEN },;
							{ "CODPRO", B1N->B1N_CODPRO },;
							{ "CODPAD", B1N->B1N_CODPAD },;
							{ "QTD"   , B1N->B1N_QTDPRO },;
							{ "QTDAUT", "" },;
							{ "VLRAPR", B1N->B1N_VLRAPR },;
							{ "PROTOC", B1N->B1N_PROTOC },;
							{ "RESAUT", "" },;
							{ "INDCLIEVO","" },;
							{ "DENTE" , "" },;
							{ "FACE"  , "" },;
							{ "HORINI", "" },;
							{ "HORFIM", "" },;
							{ "VIAAC",  "" },;
							{ "TECUT",  "" },;
							{ "REDAC",  1 },;
							{ "ATPPAR", {} },;
							{ "STPROC", cStatus } ,;
							{ "SLVPRO", "" } ,;
							{ "SLVPAD", "" } ,;
							{ "DIAGNO", "" },;
							{ "MATRIC", cMatric },;
							{ "MATANT", cMatAnt },;
							{ "NOMUSR", cNomBen },; 		 
							{ "DATPRO", "" } } )
							
			B1N->(DbSkip())
		EndDo
	EndIf
EndIf

objCtrlGuia 	:= CO_Guia():New()
oObjGui 		:= objCtrlGuia:addGuia(aDados,aItens)

//Atualizando Protocolo
PLATUGUI(cProtoc, oObjGui:getCodOpe(), oObjGui:getAnoPag(), oObjGui:getMesPag(), oObjGui:getNumAut(), oObjGui:getCodPeg(), oObjGui:getOriMov(), oObjGui:getNumero(), oObjGui:getCodLdp() )

//aRetorno := PLSRETOFF(oObjGui:getCodOpe() + oObjGui:getAnoPag() + oObjGui:getMesPag() + oObjGui:getNumAut())

freeObj(oObjGui)
oObjGui := nil

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLATUGUI

Atualiza os campos da BOW conforme número da guia gerado pelas classes na BD5/BD6/BD7

@author Roberto Vanderlei
@since 16/12/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PLATUGUI(cProtoc, cCodOpe, cAnoPag, cMesPag, cNumAut, cCodPeg, cOriMov, cNumGui, cCodLdp)

	BOW->(DbSetOrder(1))
		
	//Atualizando campo BOW
	If (BOW->(MsSeek(xFilial("BOW")+cProtoc)))
		
		BOW->(RecLock("BOW", .F.))
		
			BOW->BOW_ANOAUT := cAnoPag
			BOW->BOW_MESAUT := cMesPag
			BOW->BOW_OPEMOV := cCodOpe
			BOW->BOW_CODPEG := cCodPeg
			BOW->BOW_NUMAUT := cNumAut
			BOW->BOW_ORIMOV := cOriMov
			BOW->BOW_NUMGUI := cNumGui
			BOW->BOW_CODLDP := cCodLdp
		
		BOW->( MsUnLock() )		

	ENDIF
return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLWENBOWS
WHEN DO CAMPO BOW_STATUS
@author Saude
@since 09/02/2017
@version P12
/*/
//-------------------------------------------------------------------
Function PLWENBOWS() 
LOCAL lRet := .F.

//Com o status autorizado parcialmente, o sistema não deve permitir alterar o campo
//apenas se o protocolo estiver vinculado a uma autorização de reembolso.
If BOW->BOW_STATUS == "C"
	
	B44->(DbSetOrder(4))
	If B44->( MsSeek(xFilial("B44") + BOW->BOW_PROTOC))
		lRet := .F.
	Else
		lRet := (!INCLUI .or. ALTERA)
	EndIf
	
Else
	lRet := (!INCLUI.OR.ALTERA) .and. BOW->BOW_STATUS $ ",0,1,2,3,4,F,B"
EndIf

Return lRet