#include 'protheus.ch'

function VECEV01(); return



/*/{Protheus.doc} VEDMSCev
	Anomalias Prim
	
	@type function
	@author Vinicius Gati
	@since 18/02/2018
/*/
Class VEDMSCev
	METHOD New() CONSTRUCTOR
    METHOD ConvCli()
    Method AtuSa1()
    Method AtuSus()
EndClass

/*/{Protheus.doc} New
	Construtor
	
	@type function
	@author Vinicius Gati
	@since 18/02/2018
/*/
Method New() Class VEDMSCev
Return SELF


/*/{Protheus.doc} ConvCli
	@author       Vinicius Gati
	@since        18/02/2018
    @type function
	@description  Tenta encontrar cliente para evitar criacao de prospect e cria/altera prospect caso necessario
/*/
METHOD ConvCli(oDados) Class VEDMSCev
    local cQuery := ''
    local cClrDoc := oDados:GetValue('documento')

    cClrDoc := STRTRAN(cClrDoc, '-', '')
    cClrDoc := STRTRAN(cClrDoc, '/', '')
    cClrDoc := STRTRAN(cClrDoc, '.', '')

    if ! Empty(oDados:getvalue('documento'))
        cQuery := "SELECT R_E_C_N_O_ FROM " + RetSqlName('SA1')
        cQuery += " WHERE A1_FILIAL = '" + xFilial('SA1') + "' "
        cQuery += "   AND A1_CGC LIKE '"+ cClrDoc +"' "
        cQuery += "   AND D_E_L_E_T_ = ' ' "
        nRecno := FM_SQL(cQuery)
    endif

    if nRecno != Nil .AND. nRecno > 0
        return self:AtuSa1(nRecno, oDados)
    else
        return self:AtuSus(oDados:GetValue('recno', '0'), oDados)
    endif
    oRet := DMS_DataContainer():New({;
        {'erro'        , .T.} ;
    })
return oRet

/*/{Protheus.doc} AtuSa1
	@author       Vinicius Gati
	@since        18/02/2018
    @type function
	@description  Salva os dados ou cria cliente
/*/
METHOD AtuSa1(uRecno, oDados) Class VEDMSCev
    local nRecno := -1
    local cClrDoc := oDados:GetValue('documento')

    cClrDoc := STRTRAN(cClrDoc, '-', '')
    cClrDoc := STRTRAN(cClrDoc, '/', '')
    cClrDoc := STRTRAN(cClrDoc, '.', '')

    if ValType( uRecno ) == 'C'
        nRecno := VAL(uRecno)
    else
        nRecno := uRecno
    endif
    SA1->(DBGOTO( nRecno ))

	if Empty( SA1->A1_COD )
		return self:AtuSus( '-1', oDados )
	Else
		RecLock( "SA1", .F. )
	Endif

	cTel := oDados:GetValue('telefone', "")
	cTel := STRTRAN(cTel, "(", "")
	cTel := STRTRAN(cTel, ")", "")
	if LEN( ALLTRIM(cTel) ) == 8 .OR. LEN( ALLTRIM(cTel) ) == 9
		SA1->A1_TEL  := cTel
		SA1->A1_DDD  := ""
	elseIf LEN( ALLTRIM(cTel) ) == 10
		SA1->A1_TEL  := RIGHT( cTel, 8)
		SA1->A1_DDD  := LEFT( cTel , 2 )
	elseIf ! Empty( cTel )
		SA1->A1_TEL  := RIGHT( cTel, LEN(cTel)-2 )
		SA1->A1_DDD  := LEFT( cTel , 2 )
	endIf

	SA1->(MsUnLock())

	if VCF->(FieldPos("VCF_LATITU")) > 0 .and. !Empty(oDados:GetValue('_latitude', ''))
		DbSelectArea('VCF')
		DbSetOrder(1)

		oBckEBlk := ErrorBlock()
		oError := ErrorBlock({ |e| .T. })
		if oDados:GetValue('_latitude', "0") != "0"
			if dbSeek(xFilial('VCF') + SA1->A1_COD + SA1->A1_LOJA)
				RecLock("VCF", .F.)
				VCF->VCF_LATITU := VAL(oDados:GetValue('_latitude', "0"))
				VCF->VCF_LONGIT := VAL(oDados:GetValue('_longitude', "0"))
				VCF->(MsUnlock())
			end
		end
		oError := oBckEBlk
	end
    oRet := DMS_DataContainer():New({;
        {'prospect', .T.        },;
        {'recno', SUS->(recno())} ;
    })
Return oRet

/*/{Protheus.doc} AtuSa1
	@author       Vinicius Gati
	@since        18/02/2018
    @type function
	@description  Salva os dados ou cria prospect
/*/
Method AtuSus(uRecno, oDados) Class VEDMSCev
    local nRecno := -1
    local cClrDoc := oDados:GetValue('documento')

    cClrDoc := STRTRAN(cClrDoc, '-', '')
    cClrDoc := STRTRAN(cClrDoc, '/', '')
    cClrDoc := STRTRAN(cClrDoc, '.', '')

    if ValType( uRecno ) == 'C'
        nRecno := VAL(uRecno)
    else
        nRecno := uRecno
    endif
    SUS->(DBGOTO( nRecno ))

	if Empty( SUS->US_COD )
		RecLock( "SUS", .T. ) // novo
		SUS->US_FILIAL := xFilial('SUS')
		SUS->US_COD    := GETSXENUM('SUS', 'US_COD')
		CONFIRMSX8()
		SUS->US_LOJA   := '01'
		SUS->US_NOME   := oDados:GetValue('nome')
		SUS->US_CGC    := cClrDoc
	Else
		RecLock( "SUS", .F. )
	Endif

	cTel := oDados:GetValue('telefone', "")
	cTel := STRTRAN(cTel, "(", "")
	cTel := STRTRAN(cTel, ")", "")
	if LEN( ALLTRIM(cTel) ) == 8 .OR. LEN( ALLTRIM(cTel) ) == 9
		SUS->US_TEL  := cTel
		SUS->US_DDD  := ""
	elseIf LEN( ALLTRIM(cTel) ) == 10
		SUS->US_TEL  := RIGHT( cTel, 8)
		SUS->US_DDD  := LEFT( cTel , 2 )
	elseIf ! Empty( cTel )
		SUS->US_TEL  := RIGHT( cTel, LEN(cTel)-2 )
		SUS->US_DDD  := LEFT( cTel , 2 )
	endIf

	oBckEBlk := ErrorBlock()
	oError := ErrorBlock({ |e| .T. })
	if SUS->(FieldPos('US_XLATITU')) > 0 .and. oDados:GetValue('_latitude', "0") != "0"
		SUS->US_XLATITU := VAL(oDados:GetValue('_latitude', "0"))
		SUS->US_XLONGIT := VAL(oDados:GetValue('_longitude', "0"))
	end
	oError := oBckEBlk

	SUS->(MsUnLock())
    oRet := DMS_DataContainer():New({;
        {'prospect'        , .T.},;
        {'recno', SUS->(recno())} ;
    })
return oRet