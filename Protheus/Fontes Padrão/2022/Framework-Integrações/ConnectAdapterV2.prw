#include "restful.ch"
#include 'totvs.ch'
#Include "APWIZARD.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} ConAdapterV2
Classe Adapter para o servico
@author  Alessandro Afonso / SigFrido
@type class
@since 22/02/2021
@Date 26/01/2022
/*/
//-------------------------------------------------------------------
CLASS ConAdapterV2 FROM FWAdapterBaseV2
    data cParam1
	data cParam2
    data cParam3
    data lLocal
    data cJson
    METHOD New()
    METHOD GetListConnect() 
EndClass
 
Method New( cVerb ) CLASS ConAdapterV2
    ::cParam1 := ''
    ::cParam1 := ''
    ::cParam3 := ''
    ::lLocal  := .F.
    ::cJson   := ''
    _Super:New( cVerb, .T. )
return
 
//Criaco do servico que ira executar o adapter
//-------------------------------------------------------------------
/*/{Protheus.doc} listview
Declaracao do ws listview
@author Alessandro
@type class
@since 22/02/2021
/*/
//-------------------------------------------------------------------
WSRESTFUL listview DESCRIPTION 'Listview Analytics e FinancialSecuriy' FORMAT "application/json,text/html"
    WSDATA View     AS CHARACTER OPTIONAL
    WSDATA Page     AS INTEGER OPTIONAL
    WSDATA PageSize AS INTEGER OPTIONAL
    WSDATA Order    AS CHARACTER OPTIONAL
    WSDATA Filial   AS CHARACTER OPTIONAL
    WSDATA Fields   AS CHARACTER OPTIONAL
	WSDATA isAnalytics   AS BOOLEAN OPTIONAL
	WSDATA isQuery       AS BOOLEAN OPTIONAL
    WSDATA DROP     AS CHARACTER OPTIONAL 
	WSDATA ForceInitialDate AS BOOLEAN OPTIONAL
    WSMETHOD GET DESCRIPTION "Retorna o resultado de uma View do BA"  WSSYNTAX "/api/v1/listview"  //PATH "/api/v1/listview"  PRODUCES APPLICATION_JSON
     
END WSRESTFUL

WSMETHOD GET WSRECEIVE Page WSSERVICE listview 
Return getConnList(self)
 
Static Function getConnList( oWS, lLocal )
   Local oConnList as object
   DEFAULT oWS:Page      := 1 
   DEFAULT oWS:PageSize  := 10
   DEFAULT oWS:Fields    := "" 
   DEFAULT oWS:View      := "ND|"
   DEFAULT oWS:Filial    := ""
   DEFAULT oWS:DROP      := ""
   DEFAULT lLocal               := .F.
   DEFAULT oWS:isAnalytics      := .T.
   DEFAULT oWS:isQuery          := .F.
   DEFAULT oWS:ForceInitialDate := .F.

   If !lLocal 
        oWS:SetContentType("application/json;charset=UTF-8")
   Endif

   //RpcSetEnv(cEmp,cFil,,,,,)
   Conout("Banco  ---------------" + Upper(TCGetDB()) )
   oConnList := ConAdapterV2():new( 'GET' ) 
   Conout("Linha 242 ---------------" + oWS:View + " - " + Time())

    // Esse metodo ira processar as informacoes
    oConnList:GetListConnect( oWS )
    //Retorna a vesï¿½o do fonte ConnectAdapterV2.
    cJson := fGetJso2Esp(oConnList:cJson, oWs, At('VERSAO', Upper(oWS:View)) > 0) // get no json especifico para Filial

    If lLocal
        cxSelView := Upper(Left(oWS:View,At("|",oWS:View)-1))
        FErase("c:\temp\views\" + cxSelView + ".json")
        MemoWrit("c:\temp\views\" + cxSelView + ".json",cJson )
    Else
        oWS:SetResponse(cJson)
    Endif

   oConnList:DeActivate()
   oConnList := nil  
   cJson := ""
   
Return .T.


Method GetListConnect( oWS ) CLASS ConAdapterV2
    Local aArea     AS ARRAY
    Local cSelView  AS CHARACTER
    Local aRetF     := GetAPOInfo("ConnectAdapterV2.prw")
    Local cBanco    := Upper(TCGetDB())
    Local nSize     := 0
    Local nPage     := 0
	Local lOffSet   := .F.
    DEFAULT oWS:View      := "ND|"
    aArea   := FwGetArea()
	
	// verifica se pode-se usar o OFFSET nas querys
	lOffSet :=  GetOffSet()

	If Subs(cBanco,1,5) == 'MSSQL'
		cBanco := 'MSSQL'
	Endif
	
    ACY->(dbSetOrder(1))
    SAH->(dbSetOrder(1))    

    If TCCanOpen( 'RECEBIMENTO'+cEmpAnt ) 
        fDropView(cBanco)
    Endif

    cSelView := Upper(Left(oWS:View,At("|",oWS:View)-1))
    cSelView :=  Alltrim(Replace(cSelView,'01',''))

	If  !lOffSet
		If oWS:Page == 0
			oWS:Page := 1
		Endif

		nSize      := oWS:PageSize * oWS:Page
		nPage     := ( nSize - oWS:PageSize ) + 1
	Else
		nPage := 0
		If oWS:Page > 1
			nPage := oWS:Page - 1
		Endif
		nPage      := oWS:PageSize * nPage
		nSize      := oWS:PageSize 
    Endif

    ::cJson := fAnalyticsJson(nPage, nSize, oWS:PageSize, oWS, cBanco, cSelView, oWS:ForceInitialDate, lOffSet)
    
    If Len(aRetF) >= 5
        Conout("ConnectAdapterV2: Data Fonte "  +  DTOC(aRetF[4]) + '-' + aRetF[5] + " - now : "+ DtoC(Date()) + ' - ' + Time()  + ' / TheardID: ' + Alltrim(Str(ThreadID())) )
    Else
        Conout("ConnectAdapterV2: Data Fonte "  + " - now : "+ DtoC(Date()) + ' - ' + Time()  + ' / TheardID: ' + Alltrim(Str(ThreadID())) )
    Endif

    FwrestArea(aArea)
Return

Static Function fGetJso2Esp(cJson, oWs, lViewVer, cFonte)
    Local cRet      := ""
    Local aVer      := GetVer()
    Local aRet      := {}
	
    Default cFonte  := "ConnectAdapterV2.prw"
    
    If !lViewVer 
        Return cJson
    Endif
    
	aView :=  Separa(oWS:View, "|")
    If Len(aView) >= 3 .and. !Empty(aView[3])
        cFonte := aView[3]
    Endif
    
    aRet := GetAPOInfo(cFonte)
    If Len(aRet) > 0
        cRet := '{ "items": ['
        cRet += '{'
        cRet += '    "Versao": "' + Alltrim(aVer[Len(aVer),1]) + '",' 
        cRet += '    "Descricao":   "' + Alltrim(aVer[Len(aVer),2]) + '",' 
        cRet += '    "Fonte": "' + cFonte + '",' 
        cRet += '    "Data":  "' + DTOC(aRet[4]) + '-' + aRet[5] + '",' 
		cRet += '    "Banco":  "' +  Upper(TCGetDB()) + '" ' 
        cRet += '}'
        cRet += ']}'
    Endif
    
Return cRet
/*{Protheus.doc} FConfigAnalytics
    Funcao para configurar o analytc syncconctrol no ERP
    @author Alessandro Afonso
    @since 17/09/2020
    @type Function
    @version V9
*/
Main Function FConfigAnalytics()
    Local oWizard
	Local oEmpresas
	Local oListUpd
	Local oPanelEmp
	Local oPanelMEmp
	Local oOk	:= LoadBitMap(GetResources(),"LBOK")
	Local oNo	:= LoadBitMap(GetResources(),"LBNO")

	Local aListUpd	:= {{.F.	,'' }}
	Local aTitUpd	:=	{' ','Descricao' }
	Local aTitEmp 	:= {' ', 'Codigo','Empresa','Nome','Id.'}
	Local aEmpresas	:= {{.F.,'','','',0}}
	Local aResumo	:= {}
	Local aAplica   := {}
	Local lMarcaEmp	:= .T.
	Default cTipo   := 'U'
	Default lForce  := .F.

	PRIVATE lMsFinalAuto := .F.
	PRIVATE cSigla	     :=	cTipo
	PRIVATE nModulo	     := 4
	PRIVATE oEdit
	Private __cEmpFil 	:= ""
	Private cFilAnt     := ''
	Private cEmpAnt     := '' 
    Private cxUser		:= Padr("Administrador",25)

    If !SelEmp()
		Return .F.
	Endif
    
	RpcSetType(3)
	RpcSetEnv(Left(__cEmpFil,2),Substr(__cEmpFil,4,Len(__cEmpFil)),,,,,)

    cHEADER := "Configuracao Analytics SyncControl Erp"
    cTEXT := "Este programa tem por objetivo de preparar o ERP para analytics, executando os procedimentos abaixo, conforme selecao do usurio:"+CRLF
    cTEXT += "1) Criar o campo S_T_A_M_P_, data da ultima alteracao, nas tabelas do ERP: SE1, SC5, SF2, SD2."+CRLF

    DEFINE WIZARD oWizard TITLE "Config Analytics SyncControls - ERP"  ;
	HEADER cHEADER ;
	MESSAGE "" ;
	TEXT cTEXT ;
	NEXT {||VerExcl(cTipo) .and. InicioEmp(aEmpresas,oEmpresas) } ;
	FINISH {|| .T. } ;
	PANEL

    CREATE PANEL oWizard ;
	HEADER "Selecione a empresa:" ;
	MESSAGE "" ;
	BACK {|| .T. } ;
	NEXT {|| Inicio(aListUpd,oListUpd,aEmpresas,aAplica,cTipo)} ;
	FINISH {|| .F. } ;
	PANEL

    // Segunda etapa
	CREATE PANEL oWizard ;
	HEADER "Procedimentos selecionados abaixo serao executados." ;
	MESSAGE "" ;
	BACK {|| .T. } ;
	NEXT {|| Executa(aEmpresas,aListUpd,,aResumo,aAplica, cTipo, lForce) } ;
	FINISH {|| .F. } ;
	PANEL

    CREATE PANEL oWizard ;
	HEADER "Resumo do processamento" ;
	MESSAGE "" ;
	BACK {|| .F. } ;
	NEXT {|| .F. } ;
	FINISH {|| .T. } ;
	PANEL 

    oPanelEmp := 	oWizard:GetPanel(2)
	@00,00 MSPANEL oPanelMEmp PROMPT "" SIZE 20,30 of oPanelEmp
	oPanelMEmp:Align := CONTROL_ALIGN_BOTTOM
	oButton := TButton():New( 0,0, 'Marcar/Desmarcar Todos', oPanelMEmp,	{|| Aeval(aEmpresas,{|aElem|aElem[1] := lMarcaEmp}), lMarcaEmp := !lMarcaEmp, oEmpresas:Refresh() },075,015,,,,.T.,,,,,,)
	oButton:SetColor(CLR_BLACK)

	oEmpresas := TWBrowse():New(	53,10,330,140,,aTitEmp,,oPanelEmp,,,,,,,,,,,,,"ARRAY",.T.)
	oEmpresas:bLDblClick := {|| aEmpresas[oEmpresas:nAt,1] := !aEmpresas[oEmpresas:nAt,1], oEmpresas:Refresh()}
	oEmpresas:SetArray( aEmpresas )
	oEmpresas:bLine   := {|| {If(aEmpresas[oEmpresas:nAt,1], oOk, oNo),	aEmpresas[oEmpresas:nAT,2],aEmpresas[oEmpresas:nAT,3],aEmpresas[oEmpresas:nAT,4] } }
	oEmpresas:Align := CONTROL_ALIGN_ALLCLIENT


	oPanelUpd := oWizard:GetPanel(3)
	@00,00 MSPANEL oPanelMUpd PROMPT "" SIZE 10,10 of oPanelUpd
	oPanelMUpd:Align := CONTROL_ALIGN_BOTTOM

	oListUpd := TWBrowse():New(	53,10,330,140,,aTitUpd,,oPanelUpd,,,,,,,,,,,,,"ARRAY",.T.)
	oListUpd:bLDblClick := {|| aListUpd[oListUpd:nAt,1] := !aListUpd[oListUpd:nAt,1], oListUpd:Refresh()}
    oListUpd:SetArray( aListUpd )
	oListUpd:bLine   := {|| {If(aListUpd[oListUpd:nAt,1], oOk, oNo),	aListUpd[oListUpd:nAT,2]} }
	oListUpd:Align := CONTROL_ALIGN_ALLCLIENT


	// Terceira etapa
	oPanelTree := oWizard:GetPanel(4)

	DEFINE FONT oFont NAME "Tahoma" SIZE 0, -10

	oEdit := TSimpleEditor():New( 0,0,oPanelTree,260,184 )
	oEdit:Align := CONTROL_ALIGN_ALLCLIENT

	ACTIVATE WIZARD oWizard CENTERED
Return Nil


Static Function VerExcl(cTipo)
	If !  MyOpenSm0Ex()
		MsgAlert("Necessario acesso exclusivo!")
		Return .f.
	EndIf
Return .t.

Static Function Inicio(aListUpd,oListUpd,aEmpresas,aAplica,cTipo)
	Local oOk	:= LoadBitMap(GetResources(),"LBOK")
	Local oNo	:= LoadBitMap(GetResources(),"LBNO")
	Local nX		:= 0
	Local lEmpty:= .t.
	For nX:= 1 to len(aEmpresas)
		If aEmpresas[nX,1]
			lEmpty:= .f.
			Exit
		EndIf
	Next
	If lEmpty
		MsgAlert('Necessario selecionar no manimo uma empresa!')
		Return .f.
	EndIf

	lMsFinalAuto := .F.
	aListUpd:= GetListUpd(aEmpresas)
	oListUpd:SetArray( aListUpd )
	oListUpd:bLine   := {|| {If(aListUpd[oListUpd:nAt,1], oOk, oNo),	aListUpd[oListUpd:nAT,2] } }
	oListUpd:Refresh()

Return .t.

Static Function GetListUpd(aEmpresas)
	Local aList		:= {}
    AAdd( aList, {	.t.,'Será necessário acesso exclusivo para criação do campo S_T_A_M_P_, data da ultima alteracao, nas tabelas do ERP: SE1, SF2, SC5, SD2?'})
Return aClone(aList)

Static Function MyOpenSM0Ex(cxEmp, lOpenEx)
	Local lOpen := .F. 
	Local nLoop := 0       
	Default cxEmp := ''
    Default lOpenEx := .T.
	If ! Empty( Select( "SM0" ) ) 
		Return .t.
	EndIf

	If Select("SX3") > 0
		Return .T.
	Endif

	For nLoop := 1 To 20
        If lOpenEx
		    OpenSm0Excl(cxEmp) 
        Else
            OpenSm0(cxEmp)
        EndIf    

		If !Empty( Select( "SM0" ) ) 
			lOpen := .T. 
			Exit	
		EndIf
		Sleep( 500 ) 
	Next nLoop 

	If !lOpen
		MsgAlert( "Nao foi possivel a abertura da tabela de empresas de forma exclusiva!" )
	EndIf                                 
Return( lOpen )

//------------------------------------------------------------------------------------------------------------------
/*{Protheus.doc} SelEmp 
funcao para selecionar empresas
@owner     Alessandro
@author	Rafael Mota Previdi
@version	1.0
@since	11/12/2013 
/*/
//------------------------------------------------------------------------------------------------------------------
Static Function SelEmp(cUserName)
	Local oBmp, oDlgLogin, oCbxEmp, oUsuario, oSenha, oFont
	Local cSenha			:= Space(26)
	Local cEmpAtu			:= ""
	Local lOk				:= .F.
	Local aCbxEmp			:= {}
	Default cUserName		:= Padr("Administrador",25)

	oFont := TFont():New('Arial',, -11, .T., .T.)

	OpenSM0()

	SM0->(DbGotop())
	While ! SM0->(Eof())
		Aadd(aCbxEmp, SM0->M0_CODIGO + '/' + SM0->M0_CODFIL + ' - '+ SM0->M0_NOME+' / '+ SM0->M0_FILIAL)
		SM0->(DbSkip())
	EndDo

	SM0->(DbCloseArea())


	DEFINE MSDIALOG oDlgLogin FROM  0,0 TO 160,380  Pixel TITLE OemToAnsi("Login ")
	oDlgLogin:lEscClose := .F.
	@ 000,000 BITMAP oBmp RESNAME "LOGIN" oF oDlgLogin SIZE 95,oDlgLogin:nBottom  NOBORDER WHEN .F. PIXEL
	@ 010,050 Say "Usuario:" PIXEL of oDlgLogin   FONT oFont //
	@ 018,050 GET oUsuario  VAR cUserName  SIZE 70, 9 OF oDlgLogin PIXEL FONT oFont
	@ 010,130 Say "Senha:" PIXEL of oDlgLogin  FONT oFont //
	@ 018,130 GET oSenha VAR cSenha PASSWORD  SIZE 50, 9 OF oDlgLogin PIXEL FONT oFont
	@ 034,050 Say "Selecione a Empresa:" PIXEL of oDlgLogin  FONT oFont //
	@ 042,050 MSCOMBOBOX oCbxEmp VAR cEmpAtu ITEMS aCbxEmp SIZE 130,10 OF oDlgLogin PIXEL

	TButton():New( 058,100,"&Ok", oDlgLogin, {|| aUser := VldLogin(cUserName, cSenha),  If(Empty(aUser),(lOk := .F.), (lOk := .T.  ,__cEmpFil :=GetEmpt(cEmpAtu),oDlgLogin:End()) )	},38, 14,,, .F., .t., .F.,, .F.,,, .F. ) //
	TButton():New( 058,140,"&Cancelar", oDlgLogin, {|| lOk := .F. , oDlgLogin:End() }, 38, 14,,, .F., .t., .F.,, .F.,,, .F. ) //

	ACTIVATE MSDIALOG oDlgLogin CENTERED

Return lOk

Static Function  GetEmpt(cEmpAtu)
Local cRet := Alltrim(Left(cEmpAtu, At("-", cEmpAtu)-1))
Return cRet

Static Function VldLogin(cUserName, cSenha)
	Local aUser := {'Admin',''}

	If PswAdmin( cUserName, cSenha )==0
		If PswSeek( cUserName, .T. )  
			aUser	:= PswRet() // Retorna vetor com informacoes do usuario
		EndIf
	Elseif PswAdmin( cUserName, cSenha )==2
		IW_Msgbox("Senha e/ou usuario invalidos!")
		aUser := {}
	Elseif PswAdmin( cUserName, cSenha )==1
		MsgAlert('Operacao nao autorizada. Faca login como usurio Administrador para continuar a operacao!','Usuario Invalido!')
		aUser := {}
	Endif
    cxUser := Alltrim(cUserName)
Return aUser

Static Function InicioEmp(aEmpresas,oEmpresas)
	Local oOk	:= LoadBitMap(GetResources(),"LBOK")
	Local oNo	:= LoadBitMap(GetResources(),"LBNO")

	//-- Obtem as Empresas para processamento... 

	SM0->(dbGotop())
	aEmpresas := {}
	While !SM0->(Eof())
		If Ascan(aEmpresas,{ |x| x[2] == SM0->M0_CODIGO}) == 0 //--So adiciona no array se a empresa for diferente
			cTab := 'sx3'+SM0->M0_CODIGO+'0'
			If	File(cTab+'.dbf') .Or. File(cTab+'.dtc') .OR. Select("SX3") > 0
				SM0->(Aadd(aEmpresas,{.T.,	M0_CODIGO,	M0_FILIAL, M0_NOME, Recno() }))
			EndIf
		EndIf			
		SM0->(dbSkip())
	EndDo	
	SM0->(DbGoTop())                           

	RpcSetType(3) 
	RpcSetEnv(Left(__cEmpFil,2),Substr(__cEmpFil,4,2))
	__cInterNet := Nil

	nModulo := 4

	oEmpresas:SetArray( aEmpresas )
	oEmpresas:bLine   := {|| {If(aEmpresas[oEmpresas:nAt,1], oOk, oNo),	aEmpresas[oEmpresas:nAT,2],aEmpresas[oEmpresas:nAT,3],aEmpresas[oEmpresas:nAT,4] } }
	oEmpresas:Refresh()
Return .t.

Static Function Executa(aEmpresas,aListUpd,oTree,aResumo,aAplica,cTipo, lForce)            
	Local cArqLog
	Default cTipo := 'U'

	If ! MsgYesno("Confirma a execucao das tarefas marcadas?")
		Return .f.
	EndIf

	RpcClearEnv()                                          

	oProcess := MsNewProcess():New({|| cArqLog := ProcUpd( aListUpd, aEmpresas,aResumo,oProcess,aAplica,cTipo, lForce )},'Atualizando','Aguarde o termino do processamento',.T.)
	oProcess:Activate()

	If Empty(cArqLog)
		aResumo := {}
	Endif

	ShowItem(oEdit, '\system\'+cArqLog)

	GrvLog(aResumo, cArqLog)

Return .t.  

Static Function ProcUpd( aListUpd, aEmpresas,aResumo,oProcess,aAplica, cTipo, lForce )
	Local nAux       := 0
	Local nEmpresa   := 0
	Local cArqLog    := ''
    Local cBanco    := ""
    Local lOpenEx   := .T.
    Local lPopulouStamp := .F.

	For nEmpresa := 1 To Len(aEmpresas)
		If ! aEmpresas[nEmpresa,1]
			Loop
		EndIf
        lOpenEx := fAcessExc(aListUpd)
		If ! MyOpenSm0Ex(aEmpresas[nEmpresa,2], lOpenEx) 
			Loop
		EndIF
		SM0->(DbGoTo(aEmpresas[nEmpresa,5]))
		RpcSetType(3) 
		RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL) /// Suspeita de demora neste ponto
		__cInterNet  := Nil
		nModulo      := 04
		lMsFinalAuto := .F.
        cBanco       := TCGetDB()

		oProcess:IncRegua1("Processando criaï¿½ï¿½o do campo S_T_A_M_P_ ... ")
		oProcess:SetRegua2(Len(aListUpd)*8)
		cArqLog := 'AnalyticsSyncControl_'+Subs(StrTran(DtoC(Date()),'/',''),1,4)+Subs(StrTran(Time(),':',''),1,4)+".LOG"	
        lPopulouStamp := .F.

		For nAux := 1 To Len(aListUpd)
			If ! aListUpd[nAux,1]
				Loop
			EndIf                 

   			oProcess:IncRegua2("Processando... ")
            if nAux == 1
                fCriaStamp()
                FSGrvArq(cArqLog,"Empresa: " + cEmpAnt + ", User: " + cxUser + " - Criacao do campo S_T_A_M_P_ realizada para as tabelas: SC5,SE1,SF2,SD2" + " - " + DTOC(dDatabase) + " " + Time())
                lPopulouStamp := .T.
            Endif

			oProcess:IncRegua2("Processando... gerando o arquivo c:\temp\script.sql scripts de criacao das views...")
		Next  

		RpcClearEnv()
			 
	Next

Return cArqLog

Static Function ShowItem(oEdit, cArq)
	Local cLinha:= "<HTML><HEAD><TITLE></TITLE></HEAD><BODY><TABLE>
	cLinha += '<TR><TD>'+'Para mais detalhes da instalacao consulte o arquivo:' + cArq +'</TD></TR>' 
	cLinha +='</TABLE></BODY></HTML>'

	oEdit:Load( cLinha )
Return 

Static Function GrvLog( aResumo, cArqLog )
	Local cTexto := ''
	Local i      := 0

	Default cArqLog  := 'AnalyticsSyncControl_'+Subs(StrTran(DtoC(Date()),'/',''),1,4)+Subs(StrTran(Time(),':',''),1,4)+".LOG"	

	StrTran(Time(),':','')

	If Empty(cArqLog)
		Return
	EndIf
	For i := 1 To Len(aResumo)

		cTexto += Repl('=',220)
		cTexto += CRLF		
		If Len(aResumo[i]) > 0
			cTexto += aResumo[i,2]
		Else
			cTexto += 'Nenhuma erro encontrado.' + CRLF
		EndIf
		cTexto +=  CRLF
		FSGrvArq(cArqLog,cTexto)
		cTexto := ''

	Next

Return

Static Function fCriaStamp()
    Local cRet := ''
    Default lOpenAmb := .F.
    
    //Editar o arquivo:C:\Program Files (x86)\dbaccess042020\dbaccess.ini
    //Obrigatorio para funcionar a funcao cRet := TCConfig( 'SETAUTOSTAMP=ON' ), e criar o campo S_T_A_M_P_.
    //[MSSQL]
    //user=sa
    //password=
    //TableSpace=
    //IndexSpace=
    //UseRowStamp=1 -----------

    //If lOpenAmb
    //    RpcSetEnv(cEmp,cFil,,,,,)
    //Endif
    // Para setar todos os registros de uma tabela apos criado o campo S_T_A_M_P_
    // Sql
    // update SD2T30 SET S_T_A_M_P_ = CURRENT_TIMESTAMP;
    // Oracle
    // UPDATE SD2T30 SET S_T_A_M_P_ = to_char(to_date(start_time, 'yyyy/mm/dd-hh:mi:ss:ff3'), '2012/10/10-19:30:00:00')
    // Postgre

    cRet := TCConfig( 'SETAUTOSTAMP=ON' )
    If cRet == 'OK' // Se a tabela estiver aberta por outro usuario nao cria o campo.
        //O acesso entao tem de ser exclusivo para evitar que alguem abra a tabela antes da rotina executar.
        SE1->(dbSetOrder(1))
        SF2->(dbSetOrder(1))
        SD2->(dbSetOrder(1))
        SC5->(dbSetOrder(1))
        SC6->(dbSetOrder(1))
		DA1->(dbSetOrder(1))
		DA0->(dbSetOrder(1))
    Endif

Return Nil

//Funcao dropa a view e cria novamente, gera o script se elecionado pelo usuario
Static Function fDropView(cBanco)
    Local aRet    :=  {'ITEM','FILIAL','CFOP','Cliente','CondPgto','Cotacao','Devolucoes','Empresa','GrupoCliente','GrupoEstoque','Item','Moeda','NotaFiscal','Pedido','RegComercial','Regiao','TES','Transportadora','UnidadeMedidaItem','VendedorRepst','Recebimento','ReceberCarteira','Banco','CentroCusto','EspecDoc','GrpFornecedor','Fornecedor','ModalCobranca','PagamentoCarteira','NatFinanceira','Pagamento','TpCarteira'}
    Local ni      := 0
    Local lAtuVer := .T.

    For ni := 1 to Len(aRet)
        
        cSelView := aRet[ni] + cEmpAnt
        TcSqlExec("DROP VIEW " + cSelView  )
        TcSqlExec("DROP VIEW " + Upper(cSelView) )
 
    Next ni

Return lAtuVer

//Grava arquivo de log.
Static Function FSGrvArq(cArquivo,cLinha)
If ! File(cArquivo)
	If (nHandle2 := MSFCreate(cArquivo,0)) == -1
		Return
	EndIf
Else
	If (nHandle2 := FOpen(cArquivo,2)) == -1
		Return
	EndIf
EndIf
FSeek(nHandle2,0,2)
FWrite(nHandle2,cLinha+CRLF)
FClose(nHandle2)
Return

Static Function fAcessExc(aListUpd)
Local ni := 1
Local lRet := .F. 

For ni := 1 to Len(aListUpd)
    If aListUpd[ni][1] == .T. .and. ( ni == 1 .or. ni == 2 )
        lRet := .T.
    Endif
Next ni 

Return lRet
static Function getVer()
    Local aVer := {}
	aAdd(aVer, {"V01.1", "Ajuste novo modelo do analytics-adeste-protest"})
	aAdd(aVer, {"V01.2", "Ajuste para enviar registro deletados."})
	aAdd(aVer, {"V01.3", "Ajuste para integracao com o financeiro do TOTVS SFA."})
	aAdd(aVer, {"V01.4", "Ajustes para retorno da querys."})
	aAdd(aVer, {"V01.5", "Compatibilizacao criacao de pontos de entrada, view de pedido e itens."})
	aAdd(aVer, {"V01.6", "Ajustes na api do analytics para exportação do cadastro de TES."})
	aAdd(aVer, {"V01.7", "Ajustes na query das consulta para utilizacao do OFFSET."})
	aAdd(aVer, {"V01.8", "Ajustes na mensagem para nao enviar campo data em branco."})
	aAdd(aVer, {"V01.9", "Ajustes para banco de dados MSSQL7."})
	aAdd(aVer, {"V02.1", "Checagem do SGBD o uso da funcao OFFSET."})
Return aVer

Static Function GetOffSet()
Local cOffeSetAtivo := '0'
Local cQuery        := ""
Local lRet          := .F.
Local nRet          := -1
//Verifica se o OffSet esta ativo.
If file("ConnectAdapterOffSet.seq") 
	cOffeSetAtivo := Memoread("ConnectAdapterOffSet.seq")
Endif

If cOffeSetAtivo == '1'
	Return .T.
Endif

cQuery  := " SELECT * FROM " + RetSqlName('SE1') + " ORDER BY R_E_C_N_O_ OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY "
nRet    := TCSqlExec( cQuery )
If Empty(nRet)
    lRet := .T.
	Memowrite("ConnectAdapterOffSet.seq", '1')
Endif

Return lRet
