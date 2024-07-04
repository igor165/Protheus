#include "totvs.ch"
#include "mingleteste.ch"
 
//-------------------------------------------------------------------
/*/{Protheus.doc} mingleTeste
    Função para validar o envio da URL do mingle
    @author thiago murakami
    @since 28/01/2020
    @version 1.0
    @return
/*/
//-------------------------------------------------------------------
Main Function mingleTeste()

Local oLayer    := FWLayer():New()
Local oDlg      := Nil

Local cUsuario  := space(60)
Local cUsuarioID:= STR0013
Local cEmpresa  := STR0014
Local cFil      := STR0015
Local cTitulo   := STR0016
Local dDataAtual:= DTOS(Date())
Local cMensagem := STR0012
Local cToken    := space(400)


//-------------------------------------------------------------------
// Monta tela de seleção de empresas.
//-------------------------------------------------------------------
DEFINE DIALOG oDlg TITLE STR0001 FROM 050, 051 TO 750,500 PIXEL
    //-------------------------------------------------------------------
    // Monta as sessões da tela. 
    //-------------------------------------------------------------------  
    oLayer:Init( oDlg )
    oLayer:addLine( "TOP", 80, .F.)
    oLayer:addCollumn( "TOP_ALL",100, .T. , "TOP")

    oLayer:addWindow( "TOP_ALL", "TOP2_WINDOW", STR0002 , 100, .F., .T.,, "TOP"    ) //"Parâmetros"

    oParam  := oLayer:getWinPanel( "TOP_ALL", "TOP2_WINDOW", "TOP" ) 

    oFont := TFont():New('Courier new',,-12,.T.)

    //label
    oSay1:= TSay():New(01,010,{|| STR0003 },oParam,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20) //"Usuario"
    oSay1:= TSay():New(25,010,{|| STR0004 },oParam,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20) //"UsuarioID"
    oSay1:= TSay():New(50,010,{|| STR0005 },oParam,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20) //"Empresa"
    oSay1:= TSay():New(75,010,{|| STR0006 },oParam,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20) //"Filial"
    oSay1:= TSay():New(100,010,{|| STR0007 },oParam,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20) //"Titulo"
    oSay1:= TSay():New(125,010,{|| STR0008 },oParam,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20) //"Data"
    oSay1:= TSay():New(150,010,{|| STR0009 },oParam,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20) //"Mensagem"
    oSay1:= TSay():New(175,010,{|| STR0010 },oParam,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20) //"Token"
    
    oUsuario := TGet():New( 010, 010, bSETGET(cUsuario),oParam, ;
    100, 010, "!@",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cUsuario",,,, )

    oUsuarioID := TGet():New( 033, 010, bSETGET(cUsuarioID),oParam, ;
    100, 010, "!@",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cUsuarioID",,,, )

    oEmpresa := TGet():New( 058, 010, bSETGET(cEmpresa),oParam, ;
    100, 010, "!@",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cEmpresa",,,, )

    oFilial := TGet():New( 082, 010, bSETGET(cFil),oParam, ;
    100, 010, "!@",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cFil",,,, )

    oTitulo := TGet():New( 107, 010, bSETGET(cTitulo),oParam, ;
    100, 010, "!@",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cTitulo",,,, )

    oData := TGet():New( 132, 010, bSETGET(dDataAtual),oParam, ;
    100, 010, "!@",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dDataAtual",,,, )

    oMensagem := TGet():New( 158, 010, bSETGET(cMensagem),oParam, ;
    100, 010, "!@",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cMensagem",,,, )
    
    oToken := tMultiget():new(182,010,bSETGET(cToken),oParam,100,70,,,,,,.T.)
     

ACTIVATE DIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg, { || EnvioPost( cUsuario, cUsuarioID, cEmpresa, cFil, cTitulo, dDataAtual, cMensagem, cToken ), { }, ''  },  { || oDlg:End() }, .F., {},,,.F.,.F.,.F.,.T.,.F.)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} EnvioPost    
    Função de envio do Post
    @author thiago murakami
    @since 28/01/2020
    @version 1.0
    @param cUsuario, cUsuarioID, cEmpresa, cFil, cTitulo, dDataAtual, cMensagem, cToken
    @return
/*/
//-------------------------------------------------------------------

Static Function EnvioPost(cUsuario, cUsuarioID, cEmpresa, cFil, cTitulo, dDataAtual, cMensagem, cToken)

Local cURL      := "https://mingle.totvs.com.br/api/api/v1/events/protheus"
Local cPostRet  := ""
Local aHeader   := {}
Local cJson     := ""

cJson   +='{'
cJson   +=' "EventViewer": ['
cJson   +=  '{"branch": "'+ cFil +'",'
cJson   +=  '"companyID": "'+ cEmpresa +'",'
cJson   +=  '"events": ['
cJson   +=      '{"levelID": 1,'
cJson   +=      '"program": "TESTE",'
cJson   +=      '"channelID": "002",'
cJson   +=      '"categoryID": "002",'
cJson   +=      '"ownerID": "000388",'
cJson   +=      '"title": "'+ cTitulo +'",'
cJson   +=      '"time": "15:42:33-03:00",'
cJson   +=      '"eventID": "001",'
cJson   +=      '"sequenceID": "52bd6e762660400090348140c3007928",'
cJson   +=      '"date": "'+ dDataAtual +'",'
cJson   +=      '"message": "'+ cMensagem +'"}],'
cJson   +='"userLogin":"'+ cUsuario + '",'
cJson   +='"userID":"'+ cUsuarioID +'"}]'
cJson   += '}'

aAdd(aHeader, 'Content-Type:application/json')
aAdd(aHeader, 'X-MINGLE-HOST-AUTH:'+ cToken)

cPostRet := HTTPPost( cURL, "", cJson, 120, @aHeader)

MsgInfo(cPostRet, STR0011 )

return