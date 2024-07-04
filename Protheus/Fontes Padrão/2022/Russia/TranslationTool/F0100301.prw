#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} SndAtuSX
Envia os Flavours da Russia para a API do AtuSX.
Refatorado do original feito por rafael.talha.
@author izac.ciszevski
@since 03/05/2017
/*/
User Function F0100301()

    DEFINE MSDIALOG oDlg TITLE "Cadastros de Tradu��es - AtuSx" FROM 000, 000 TO 150, 500 PIXEL

    @018, 015 SAY "Atualiza��o das tradu��es que ser�o utilizadas nos Ambientes da R�ssia. " SIZE 300, 300 OF oDlg PIXEL

    DEFINE SBUTTON FROM 060, 010 TYPE 1 ACTION (U_F0100302({FWCodEmp(), FWCodFil()}), oDlg:End())                        ENABLE OF oDlg
    DEFINE SBUTTON FROM 060, 215 TYPE 2 ACTION (MsgAlert("Atualiza��o cancelada."), oDlg:End())  ENABLE OF oDlg

    ACTIVATE MSDIALOG oDlg CENTERED

Return
// Russia_R5
