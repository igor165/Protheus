#INCLUDE "loca002.ch" 
/*/{PROTHEUS.DOC} LOCA002.PRW
ITUP BUSINESS - TOTVS RENTAL
ATUALIZAÇÃO DA DATA DE ENTREGA
NA VERSÃO ANTERIOR CHAMAVA-SE ANVI007.PRW
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

#INCLUDE "TOTVS.CH"
FUNCTION LOCA002
LOCAL   AAREA   := GETAREA()
LOCAL   OOK     := LOADBITMAP( GETRESOURCES(), "LBOK")
LOCAL   ONO     := LOADBITMAP( GETRESOURCES(), "LBNO")
LOCAL   CQRYZP5

PRIVATE ODLG, OLISTP5, OPNLSOL, OPNLZP5
PRIVATE ABRZP5	:= {}
PRIVATE LINVGRP	:= .F.

IF SELECT("TMPFPA") > 0
	TMPFPA->( DBCLOSEAREA() )
ENDIF

CQRYZP5 := " SELECT FPA_NFREM , FPA_DNFREM , FPA_GRUA , FPA_AS , FPA_DTPREN , FPA_MOTENT, FPA_OBRA "
CQRYZP5 += "      , COALESCE(DA4_NOME, '') DA4_NOME "
CQRYZP5 += "      , ZAG.R_E_C_N_O_ FPARECNO "
CQRYZP5 += " FROM " + RETSQLNAME("FPA") + " ZAG (NOLOCK) "
CQRYZP5 += "        LEFT JOIN " + RETSQLNAME("DA4") + " DA4 (NOLOCK) ON DA4_FILIAL='"+XFILIAL('DA4')+"' AND DA4_COD=FPA_MOTENT AND DA4.D_E_L_E_T_='' "
CQRYZP5 += " WHERE  FPA_FILIAL = '"+XFILIAL("FPA")+"' "
CQRYZP5 += "   AND  FPA_PROJET = '"+ FP0->FP0_PROJET +"' "
//CQRYZP5+="   AND  FPY_STATUS IN ('02','03','04') "
CQRYZP5 += "   AND  ZAG.D_E_L_E_T_ = '' "
CQRYZP5 := CHANGEQUERY(CQRYZP5) 
DBUSEAREA(.T.,"TOPCONN", TCGENQRY(,,CQRYZP5),"TMPFPA", .F., .T.)

WHILE TMPFPA->( !EOF() )
	AADD(ABRZP5 , { .F.,;
				    TMPFPA->FPA_NFREM        , ; 
				    STOD(TMPFPA->FPA_DNFREM) , ; 
				    TMPFPA->FPA_GRUA         , ; 
				    TMPFPA->FPA_AS           , ; 
				    STOD(TMPFPA->FPA_DTPREN) , ; 
				    TMPFPA->FPA_MOTENT       , ; 
				    TMPFPA->DA4_NOME         , ; 
				    TMPFPA->FPARECNO         , ;
					TMPFPA->FPA_OBRA     } )
	TMPFPA->( DBSKIP() )
ENDDO 

DBCLOSEAREA()

RESTAREA(AAREA)

IF LEN(ABRZP5) == 0
	Help(Nil,	Nil,STR0001+alltrim(upper(Procname())),; //"RENTAL: "
	Nil,STR0002,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
	{STR0003}) //"Não existem registros para serem exibidos."
	RETURN NIL
ENDIF

DEFINE MSDIALOG ODLG TITLE STR0004 FROM 010,005 TO 550,900 PIXEL //"Dados da entrega na locação"
	OPNLSOL       := TPANEL():NEW(0, 0, "", ODLG, NIL, .T., .F., NIL, NIL, 0,050, .F., .T. ) 
	OPNLSOL:ALIGN := CONTROL_ALIGN_TOP 
	
	DEFINE FONT OFONT  NAME "MONOAS" SIZE 0, -16 BOLD
	DEFINE FONT OFONT1 NAME "MONOAS" SIZE 0, -18 BOLD
	
	@ 005,005 SAY STR0005     FONT OFONT1                PIXEL OF OPNLSOL //"Projeto: "
	@ 005,070 SAY FP0->FP0_PROJET FONT OFONT1 COLOR CLR_BLUE PIXEL OF OPNLSOL
	
	@ 020,005 SAY STR0006     FONT OFONT1                PIXEL OF OPNLSOL //"Cliente: "
	@ 020,070 SAY FP0->FP0_CLINOM FONT OFONT1 COLOR CLR_BLUE PIXEL OF OPNLSOL
	
	OPNLZP5 := TPANEL():NEW(0, 0, "", ODLG, NIL, .T., .F., NIL, NIL, 0,90, .F., .T. )
	OPNLZP5:ALIGN := CONTROL_ALIGN_ALLCLIENT
	
	@ 005,005 SAY STR0007 FONT OFONT PIXEL OF OPNLZP5 //"Nota fiscal de remessa: "
	
	@ 020,001 CHECKBOX LINVGRP PROMPT STR0008 SIZE 100, 10 OF OPNLZP5 PIXEL ON CLICK ( AEVAL(ABRZP5, {|Z| Z[1] := !Z[1] }),OLISTP5:REFRESH(.F.) ) //"INVERTER SELECAO" //"Inverte seleção"
	@ 030,001 LISTBOX OLISTP5 VAR CVARGRP FIELDS HEADER '','Nota fiscal','Emissão','Equipamento','Aut.Serviço','Dt.Prev.Entrega','Mot.Entrega','Nome Motorista','Obra' SIZE 446,150 ON DBLCLICK ( ABRZP5[OLISTP5:NAT,1] := !ABRZP5[OLISTP5:NAT,1],OLISTP5:REFRESH() ) OF OPNLZP5 PIXEL
	
	OLISTP5:SETARRAY(ABRZP5)
	OLISTP5:BLINE := {||{ IF(ABRZP5[OLISTP5:NAT,1],OOK,ONO),;
	                         ABRZP5[OLISTP5:NAT,2],;
	                         ABRZP5[OLISTP5:NAT,3],;
	                         ABRZP5[OLISTP5:NAT,4],;
	                         ABRZP5[OLISTP5:NAT,5],;
	                         ABRZP5[OLISTP5:NAT,6],;
	                         ABRZP5[OLISTP5:NAT,7],;
	                         ABRZP5[OLISTP5:NAT,8],;
							 ABRZP5[OLISTP5:NAT,10]}}
	
	@ 195,330 BUTTON STR0009	SIZE 070,015 OF OPNLZP5 PIXEL ACTION( ATUZLG() )  //"Atualiza entrega"
	@ 195,405 BUTTON STR0010		        SIZE 040,015 OF OPNLZP5 PIXEL ACTION ODLG:END()  //"Sair"

ACTIVATE MSDIALOG ODLG CENTERED

RETURN NIL



// ----------------------------------------------------------------------- \\
STATIC FUNCTION ATUZLG()
// ----------------------------------------------------------------------- \\
LOCAL   ODLGZLG
LOCAL   NI
LOCAL   NTEMP := 0
Local   _lErro := .F.
Local   _cTemp

PRIVATE _DDTENTRE
PRIVATE _CMTENTRE
PRIVATE _CNOMMOTO

FOR NI := 1 TO LEN(  ABRZP5 )
	IF ABRZP5[NI][1]
		NTEMP := NI
		EXIT
	ENDIF
NEXT

IF NTEMP == 0
	Help(Nil,	Nil,STR0001+alltrim(upper(Procname())),; //"RENTAL: "
	Nil,STR0002,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
	{STR0011}) //"Para alterar selecione um item."
	RETURN NIL
ENDIF

For nI := 1 to len( abrzp5 )
	FPA->(dbGoto(abrzp5[nI,9]))
	If abrzp5[nI,1]
		If empty(_cTemp)
			_cTemp := FPA->FPA_OBRA
		else
			If FPA->FPA_OBRA <> _cTemp
				_lErro := .T.
			EndIF
		EndIF
	EndIf
Next

/*
IF _lErro
	Help(Nil,	Nil,"RENTAL: "+alltrim(upper(Procname())),;
	Nil,"Inconsistência nos dados.",1,0,Nil,Nil,Nil,Nil,Nil,;
	{"Não podem ser selecionados itens de obras diferentes."})
	RETURN NIL
ENDIF
*/

_DDTENTRE := ABRZP5[NTEMP][6]
_CMTENTRE := ABRZP5[NTEMP][7]
_CNOMMOTO := ABRZP5[NTEMP][8]
_CPLACA   := SPACE(7)
_CREBOQUE := SPACE(30)

DEFINE MSDIALOG ODLGZLG TITLE STR0012 FROM 010,005 TO 280/*280*/, 500/*330*/ PIXEL //"Atualiza os dados da entrega"
	@ 010,005 SAY 	STR0013                   PIXEL OF ODLGZLG //"Previsão de entrega: "
	@ 020,005 MSGET _DDTENTRE                                      PIXEL OF ODLGZLG
	
	@ 010,070 SAY   STR0014                                  PIXEL OF ODLGZLG //"Placa ida: "
	@ 020,070 MSGET _CPLACA                                        PIXEL OF ODLGZLG
	
	@ 040,005 SAY 	STR0015                          PIXEL OF ODLGZLG //"Motorista entrega: "
	@ 050,005 MSGET _CMTENTRE F3 "DA4" VALID VALMOTO() SIZE  40,10 PIXEL OF ODLGZLG
	
	@ 040,070 SAY 	STR0016                             PIXEL OF ODLGZLG //"Nome motorista: "
	@ 050,070 MSGET _OMTENTRE VAR _CNOMMOTO WHEN .F.   SIZE 150,10 PIXEL OF ODLGZLG
	
	@ 070,005 SAY   STR0017                                PIXEL OF ODLGZLG //"Reboque ida: "
	@ 080,005 MSGET _CREBOQUE                                      PIXEL OF ODLGZLG
	
	@ 100,040 BUTTON STR0018	SIZE 040,012 OF ODLGZLG PIXEL ACTION( GRVDADOSMOT(), ODLGZLG:END() ) //"Confirma"
	@ 100,090 BUTTON STR0019	SIZE 040,012 OF ODLGZLG PIXEL ACTION( ODLGZLG:END() ) //"Cancela"
ACTIVATE MSDIALOG ODLGZLG CENTERED

RETURN NIL



// ----------------------------------------------------------------------- \\
STATIC FUNCTION VALMOTO()
// ----------------------------------------------------------------------- \\

LOCAL LRET

DA4->( DBSETORDER(1) )

IF DA4->( DBSEEK( XFILIAL("DA4") + _CMTENTRE ) )
	LRET := .T.
	_CNOMMOTO := DA4->DA4_NOME
ELSE
	Help(Nil,	Nil,STR0001+alltrim(upper(Procname())),; //"RENTAL: "
	Nil,STR0002,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
	{STR0020}) //"Motorista não localizado."
	LRET := .F.
	_CNOMMOTO := ""
ENDIF

_OMTENTRE:REFRESH()

RETURN LRET



// ----------------------------------------------------------------------- \\
STATIC FUNCTION GRVDADOSMOT()
// ----------------------------------------------------------------------- \\
LOCAL _NI

FOR _NI := 1 TO LEN( ABRZP5 )
	IF ABRZP5[_NI][1]
		FPA->( DBGOTO( ABRZP5[_NI][9] ) )

		RECLOCK("FPA",.F.)
		FPA->FPA_DTPREN := _DDTENTRE
		FPA->FPA_MOTENT	:= _CMTENTRE
		FPA->FPA_PLACAI := _CPLACA
		FPA->FPA_REBOQI := _CREBOQUE
		FPA->( MSUNLOCK() )
		
		ABRZP5[_NI][6] := _DDTENTRE
		ABRZP5[_NI][7] := _CMTENTRE
		ABRZP5[_NI][8] := _CNOMMOTO
	ENDIF
NEXT

OLISTP5:REFRESH()

RETURN NIL
