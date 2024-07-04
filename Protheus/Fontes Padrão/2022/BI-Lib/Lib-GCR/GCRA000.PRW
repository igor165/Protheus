#INCLUDE "PROTHEUS.CH"
#INCLUDE "GCRA000.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GCRA000
Apresenta a tela de pesquisa de receita recorrente.

@author Marcia Junko
@since  30/06/2021
/*/
//-------------------------------------------------------------------
Function GCRA000()
    Local cLink := 'https://tdn.totvs.com/rest/api/content/626926607'
    Local cResponse := ""
    Local cError := ""
    Local aHeader := {}
    Local lNoLink := .F.

    AAdd( aHeader, "User-Agent: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Mobile Safari/537.36" ) 
    AAdd( aHeader, "Accept: application/json" )

    cResponse := HTTPGet( AllTrim( cLink ), ,, aHeader )
    lNoLink := ( HTTPGetStatus( @cError ) != 200 )

    ResearchGCR( lNoLink )
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} ResearchGCR
Função que monta a tela para apresentação da pesquisa

@param lNoLink, boolean, Indica se a página do documento está visível

@author Marcia Junko
@since  30/06/2021
/*/
//-------------------------------------------------------------------
Static Function ResearchGCR( lNoLink )
    Local cLink := 'https://tdn.totvs.com/pages/viewpage.action?pageId=626926607'
    Local cTextHtml := ""
    Local cTextHtml1 := ""
	Local nBuild := GCRGetBuild()
    Local nHeight := 600
    Local nWidth := 1250
	Local oDialog := Nil
    Local oFont
    Local oTIBrowser
    Local oPanel
    Local oPanel1
    Local oPanel2
    Local oWebChannel
    Local oWebEngine
    Local oTBitmap1
    Local oSay, oSay1

    Default lNoLink := .F.

    If !lNoLink
        nHeight := 850
    EndIf

	DEFINE DIALOG oDialog TITLE STR0001 FROM 010, 011 TO nHeight, nWidth  PIXEL //"Receitas Recorrentes"

    	@ 000, 000 MSPANEL oPanel OF oDialog SIZE 000, 000 
		oPanel:Align := CONTROL_ALIGN_ALLCLIENT

        If lNoLink
            // Cria fonte para ser usada no TSay
            oFont := TFont():New( 'Arial',, -16, .F. )

            @ 015, 015 MSPANEL oPanel1 OF oPanel SIZE 590, 265 //COLORS CLR_RED, CLR_RED

            @ 000, 495 MSPANEL oPanel2 OF oPanel2 SIZE 120, 95 // COLORS CLR_GREEN, CLR_GREEN
            
            @ 010, 000 BITMAP oTBitmap1 RESOURCE "GCR_IMAGE.PNG" PIXEL SIZE 200, 400 OF oPanel2 NOBORDER

            cTextHtml := '<br/><p>' + STR0002 + '</p>' + ; //"Olá, que bom ter você por aqui!"
                        '<p>' + STR0003 + '</p>' + ; //"Ficou curioso?"
                        '<p>' + STR0004 + '</p>' + ; //"Já conhece ou trabalha com o modelo de receita recorrente?"
                        '<p>' + STR0005 + '</p>' //"Se não conhece, podemos explicar:"

            // Cria o TSay permitindo texto no formato HTML
            oSay := TSay():New( 01, 01, {|| cTextHtml }, oPanel1,, oFont,,,, .T.,,, 500, 265,,,,,, .T. )
            oSay:SetTextAlign( 3, 0 )
            oSay:bLClicked := {|| MsgRun( STR0006, "URL",{|| ShellExecute( "open", cLink, "", "", 1 ) } ) }  //"Abrindo o link... Aguarde..."
 
            cTextHtml1 := '<p>' + STR0007 + '</p>'+; //"A receita recorrente nada mais é do que um fluxo contínuo de faturamento gerado para as empresas que vendem produtos e serviços por meio de assinaturas, planos e mensalidades."
                        '<br/>'+;
                        '<p><font size="3" color="blue"><b>' + STR0008 + '</b></font></p>'+; //"Por que utilizar o modelo de receita recorrente?"
                        '<p>' + STR0009 + '</p>'+;  //"Porque é a melhor maneira de fidelizar seus clientes, reduzir inadimplência e previsibilidade de lucro."
                        '<p>' + STR0010 + '</p>'+;  //"Aqui na Totvs, carregamos o DNA da inovação em cada linha de código dos nossos produtos."
                        '<p>' + STR0011 + '</p>'+;  //"Pensando no crescimento do seu negócio de forma prática e inteligente, estamos desenvolvendo uma solução para automatizar as cobranças recorrentes e melhorar ainda mais o seu desempenho financeiro."
                        '<p>' + STR0012 + ' <a href="' + cLink + '">' + STR0013 + '</a>' + STR0014 + '</p><br/>'    //"Interessou? Clique" ###  "aqui" ### " e saiba mais."
            
            oSay1 := TSay():New( 90, 01, {|| cTextHtml1 }, oPanel1,, oFont,,,, .T.,,, 585, 265,,,,,, .T. )
            oSay1:SetTextAlign( 3, 0 )
            oSay1:bLClicked := {|| MsgRun( STR0006, "URL", {|| ShellExecute( "open", cLink, "", "", 1 ) } ) }   //"Abrindo o link... Aguarde..."
        Else
            If ( nBuild >= 17 )
                oWebChannel := TWebChannel():New()
                nPort := oWebChannel::connect()
            
                oWebEngine := TWebEngine():New( oDialog, 0, 0, 395, 265,, nPort )
                oWebEngine:navigate( cLink )
                oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT
            Else
                oTIBrowser := TIBrowser():New( 0, 3, 615, 260, cLink, oPanel )
                oTIBrowser:Align := CONTROL_ALIGN_ALLCLIENT
            EndIf
        EndIf
	ACTIVATE DIALOG oDialog CENTERED
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetBuild
Verifica a versao de build

@Return cBuild, String, Versão de build

@author Marcia Junko
@since  29/06/2021
/*/
//-------------------------------------------------------------------
Static Function GCRGetBuild()
	Local nRet := 0
	Local cBuild := GetBuild()
	Local nEnd
		
	While ( At( ".", cBuild ) > 0 )
		nEnd := At( ".", cBuild ) + 1
		cBuild := SubStr( cBuild, nEnd )		
	EndDo
	
	cBuild := SubStr( cBuild, 1, 2 )
	nRet := Val( cBuild )
Return nRet
