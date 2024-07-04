#include "TMKA310B.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWBROWSE.CH'  
#INCLUDE 'FWMVCDEF.CH'

//------------------------------------------------------------------------------
/*/{Protheus.doc} TMKA130B

Chamada a grid de Membros da Campanha.

@sample		TMKA130B()

@param			Nenhum

@return		Nenhum

@author		Cristiane Nishizaka
@since			08/04/2014
@version		12.0
/*/
//------------------------------------------------------------------------------

Function TMKA130B(cAlias, nRecNo)

Local aArea		:= GetArea()
Local aAreaAOC	:= {}
Local aAreaSUO	:= {}
Local cAOGQry	:= ""
Local cChvCamp	:= ""
Local aDados	:= {}
Local aCampos	:= {}
Local nI		:= 0
Local cTipoCam	:= IIF(cAlias=="SUO","1","2")
Local lRet		:= .F.
Local oColumn	:= Nil
Local aInfo		:= {}
Local nX		:= 0
Local aObsFields := {}

Default cAlias		:= Alias()
Default nRecNo		:= ( cAlias )->( RecNo() )

aDados	:= Tk310ACpBrw( "AOG" )
aCampos	:= aDados[2] // cCampo, X3Titulo(),SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL,X3CBox()

If cAlias=="SUO"
	aAreaSUO	:= SUO->(GetArea())	
	DbSelectArea("SUO")
	DbSetOrder(1)
	SUO->(DbGoTo(nRecNo))
	
	cChvCamp := xFilial("SUO")+SUO->UO_CODCAMP
	cChvCamp := PadR(cChvCamp,TAMSX3( "AOG_CHVCAM")[1] )
	RestArea( aAreaSUO )
Else
	aAreaAOC	:= AOC->(GetArea())
	DbSelectArea("AOC")
	DbSetOrder(1)
	AOC->(DbGoTo(nRecNo))
	
	cChvCamp := xFilial("AOC")+AOC->AOC_CODIGO
	cChvCamp := PadR(cChvCamp,TAMSX3( "AOG_CHVCAM")[1] )
	RestArea( aAreaAOC )
EndIf

DbSelectArea("AOG")
DbSetOrder(2)

 If AOG->(DbSeek(xFilial("AOG")+cChvCamp+cTipoCam)) 

	While AOG->(!Eof()) .AND. AOG->AOG_FILIAL == xFilial("AOG") .AND. AOG->AOG_CHVCAM == cChvCamp .AND. AOG->AOG_TIPCAM == cTipoCam
		Aadd(aInfo,{AOG->AOG_CODIGO,AOG->AOG_CHAVE,Tk310DsEnt(),AOG->AOG_CHVLST,Posicione("SU4",1,AOG->AOG_CHVLST,"U4_DESC")})		
	AOG->(DbSkip())
	EndDo

EndIf

	DEFINE DIALOG oDlg TITLE STR0001 FROM 0,0 TO 500,800 PIXEL   //"Membros da Campanha"
	
	@00, 00 MsPanel oMainPanel Size 250, 80
	oMainPanel:Align := CONTROL_ALIGN_ALLCLIENT
	
	@00, 00 MsPanel oPanelBtn Size 250, 15
	oPanelBtn:Align := CONTROL_ALIGN_BOTTOM
	
	DEFINE FWBROWSE oBrowse DATA ARRAY ARRAY aInfo NO CONFIG  NO REPORT;
	DOUBLECLICK { || lRet := .T.,  oDlg:End() } Of oMainPanel
	
		If FATPDIsObFuscate("AOG_DESCRI",,.T.)
			aObsFields := {"AOG_DESCRI"}
			
			If FATPDActive() .And. FTPDUse(.T.)
				oBrowse:SetObfuscFields(aObsFields)
			Endif
		EndIf		
  	
		ADD COLUMN oColumn DATA &("{ || aInfo[oBrowse:At(),1] }") TITLE TxSX3Campo("AOG_CODIGO")[1] SIZE TamSX3("AOG_CODIGO")[1] ID "AOG_CODIGO" OF oBrowse
		ADD COLUMN oColumn DATA &("{ || aInfo[oBrowse:At(),2] }") TITLE TxSX3Campo("AOG_CHAVE")[1]  SIZE TamSX3("AOG_CHAVE")[1]  ID "AOG_CHAVE"  OF oBrowse
		ADD COLUMN oColumn DATA &("{ || aInfo[oBrowse:At(),3] }") TITLE TxSX3Campo("AOG_DESCRI")[1] SIZE TamSX3("AOG_DESCRI")[1] ID "AOG_DESCRI" OF oBrowse
		ADD COLUMN oColumn DATA &("{ || aInfo[oBrowse:At(),4] }") TITLE TxSX3Campo("AOG_CHVLST")[1] SIZE TamSX3("AOG_CHVLST")[1] ID "AOG_CHVLST" OF oBrowse
		ADD COLUMN oColumn DATA &("{ || aInfo[oBrowse:At(),5] }") TITLE TxSX3Campo("AOG_DESLST")[1] SIZE TamSX3("AOG_DESLST")[1] ID "AOG_DESLST" OF oBrowse
	//&( "{ || aInfo[oBrowse:At(),1] }")
		//oBrowse:SetInsert(.F.)
		ACTIVATE FWBROWSE oBrowse		
		//oBrowse:Refresh()
		
	DEFINE SBUTTON oBtnCan FROM 02, 365 TYPE 1 ENABLE OF oPanelBtn;		// Ok
	Action ( lRet := .F., oDlg:End() ) 
	
	ACTIVATE DIALOG oDlg CENTERED
	FATPDLogUser("TMKA130B")
RestArea( aArea )

Return

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

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDIsObfuscate
    @description
    Verifica se um campo deve ser ofuscado, esta função deve utilizada somente após 
    a inicialização das variaveis atravez da função FTPDLoad.

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado
    @return lObfuscate, Lógico, Retorna se o campo será ofuscado.
    @example FTPDIsObfuscate("A1_CGC",Nil,.T.)
/*/
//-----------------------------------------------------------------------------------
Function FATPDIsObfuscate(cField, cSource, lLoad)

	Local lObfuscate    := .F.
	
	If FATPDActive()
		FTPDIsObfuscate(cField, cSource, lLoad)
	EndIf
	
Return lObfuscate